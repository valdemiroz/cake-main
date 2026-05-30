import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/dados/auth_service.dart';
import '/dados/pedidos_service.dart';
import '/dados/catalogo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminPagina extends StatefulWidget {
  @override
  State<AdminPagina> createState() => _AdminPaginaState();
}

class _AdminPaginaState extends State<AdminPagina>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        toolbarHeight: 80,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text('Painel Admin',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.amber.shade100,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt),    text: 'Pedidos'),
            Tab(icon: Icon(Icons.cake),         text: 'Catálogo'),
            Tab(icon: Icon(Icons.people),       text: 'Usuários'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PedidosTab(service: PedidosService()),
          _CatalogoTab(service: CatalogoService()),
          _UsuariosTab(service: AuthService()),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ABA 1 — PEDIDOS
// ════════════════════════════════════════════════════════════════════════════
class _PedidosTab extends StatefulWidget {
  final PedidosService service;
  const _PedidosTab({required this.service});
  @override
  State<_PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<_PedidosTab> {
  static const _statusList = ['Pendente', 'Em preparo', 'Pronto', 'Entregue'];
  String _filtro = 'Todos';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(
        android: androidSettings, iOS: iosSettings));
  }

  Future<void> _mostrarNotificacaoPronto() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pedido_status',
        'Status do Pedido',
        channelDescription: 'Notificações quando o pedido fica pronto',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(
        0, 'Pedido pronto! 🎉', 'Seu bolo está pronto e indo ao caminho!', details);
  }

  List<Map<String, dynamic>> get _pedidos {
    final all = widget.service.getTodosPedidos();
    return _filtro == 'Todos'
        ? all
        : all.where((p) => p['status'] == _filtro).toList();
  }

  Color _cor(String s) {
    switch (s) {
      case 'Pendente':   return Colors.orange;
      case 'Em preparo': return Colors.blue;
      case 'Pronto':     return Colors.green;
      case 'Entregue':   return Colors.grey;
      default:           return Colors.pink;
    }
  }

  bool _temImagensValidas(Map<String, dynamic> pedido) {
    final imagens = pedido['imagensObservacoes'];
    if (imagens is! List) return false;
    return imagens
        .where((img) =>
            img is String && img.isNotEmpty && File(img).existsSync())
        .isNotEmpty;
  }

  List<String> _getImagensValidas(Map<String, dynamic> pedido) {
    final imagens = pedido['imagensObservacoes'];
    if (imagens is! List) return [];
    return imagens
        .where((img) =>
            img is String && img.isNotEmpty && File(img).existsSync())
        .cast<String>()
        .toList();
  }

  void _mostrarImagemGrande(String caminhoImagem) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(caminhoImagem),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white, size: 50),
                      )),
            ),
            const SizedBox(height: 16),
            const Text('Toque para fechar',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Filters ──
      Container(
        color: Colors.amber.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Todos', ..._statusList].map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s),
                selected: _filtro == s,
                selectedColor: Colors.amber.shade200,
                onSelected: (_) => setState(() => _filtro = s),
              ),
            )).toList(),
          ),
        ),
      ),

      // ── Orders list ──
      Expanded(
        child: _pedidos.isEmpty
            ? Center(
                child: Text('Nenhum pedido.',
                    style: TextStyle(color: Colors.grey, fontSize: 16)))
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: _pedidos.length,
                itemBuilder: (_, i) {
                  final p  = _pedidos[i];
                  final dt = DateTime.parse(p['dataPedido']);
                  final fmt =
                      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

                  // extras
                  final outros = (p['outrosSelecionados'] as List?)
                          ?.cast<String>()
                          .where((s) => s.isNotEmpty)
                          .toList() ??
                      [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(children: [
                              Icon(Icons.cake,
                                  color: Colors.amber.shade700, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      '${p['tipoBolo']} · ${p['tamanho']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                              // Status dropdown
                              DropdownButton<String>(
                                value: p['status'],
                                underline: const SizedBox(),
                                items: _statusList
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: _cor(s),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Text(s,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (ns) async {
                                  if (ns != null) {
                                    await widget.service
                                        .atualizarStatus(p['id'], ns);
                                    setState(() {});
                                    if (ns == 'Pronto') {
                                      await _mostrarNotificacaoPronto();
                                    }
                                  }
                                },
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Nome: ${p['nomeCliente'] ?? 'Não informado'}',
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    Text(
      'Telefone: ${p['telefoneCliente'] ?? 'Não informado'}',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 13,
      ),
    ),
    Text(
      'Email: ${p['usuarioEmail']}',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 13,
      ),
    ),
  ],
),
                            if ((p['endereco'] as String?)?.isNotEmpty ?? false)
                              Text('Entrega: ${p['endereco']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                            Text(
                                'Sabor: ${p['sabor']}  |  Recheio: ${p['recheio']}  |  Cobertura: ${p['cobertura']}',
                                style: const TextStyle(fontSize: 13)),
                            if ((p['nivelAndares'] as int?) != null)
                              Text('Andares: ${p['nivelAndares']}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade700)),
                            // ── Extras (outros) ──
                            if (outros.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Adicionais: ${outros.join(', ')}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade800,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            if ((p['observacoes'] as String?)?.isNotEmpty ??
                                false)
                              Text('Obs: ${p['observacoes']}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            // Images
                            if (_temImagensValidas(p))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        _getImagensValidas(p).length,
                                    itemBuilder: (context, idx) {
                                      final img =
                                          _getImagensValidas(p)[idx];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            right: 6),
                                        child: GestureDetector(
                                          onTap: () =>
                                              _mostrarImagemGrande(img),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Container(
                                              width: 100, height: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors
                                                        .amber.shade200,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Image.file(
                                                File(img),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  color:
                                                      Colors.grey.shade200,
                                                  child: const Icon(
                                                      Icons
                                                          .image_not_supported,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'R\$ ${(p['preco'] as double).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                          fontSize: 16)),
                                  Row(children: [
                                    Text(fmt,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      onPressed: () async {
                                        await widget.service
                                            .deletarPedido(p['id']);
                                        setState(() {});
                                      },
                                    ),
                                  ]),
                                ]),
                          ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ABA 2 — CATÁLOGO
// ════════════════════════════════════════════════════════════════════════════
class _CatalogoTab extends StatefulWidget {
  final CatalogoService service;
  const _CatalogoTab({required this.service});
  @override
  State<_CatalogoTab> createState() => _CatalogoTabState();
}

class _CatalogoTabState extends State<_CatalogoTab> {
  // ── Category labels — includes 'outros' ───────────────────────────────────
  static const Map<String, String> _labels = {
    'tipos':      'Tipos de Bolo',
    'tamanhos':   'Tamanhos',
    'sabores':    'Sabores',
    'coberturas': 'Coberturas',
    'recheios':   'Recheios',
    'outros':     'Adicionais (Outros)',     // ← NEW
  };

  final CatalogoService _catalogo = CatalogoService();
  Map<String, List<Map<String, String>>> _opcoes = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() => _opcoes = widget.service.getOpcoesComDescricao());
  }

  // ── Andares pricing dialog ─────────────────────────────────────────────────
  Future<void> _editarAndares() async {
    final precos = _catalogo.getPrecosAndares();
    final ctrl1 = TextEditingController(text: precos[1]!.toStringAsFixed(2));
    final ctrl2 = TextEditingController(text: precos[2]!.toStringAsFixed(2));
    final ctrl3 = TextEditingController(text: precos[3]!.toStringAsFixed(2));
    final ctrl4 = TextEditingController(text: precos[4]!.toStringAsFixed(2));

    final salvar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Preço dos Andares'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campoAndar('1 andar',    ctrl1),
          _campoAndar('2 andares',  ctrl2),
          _campoAndar('3 andares',  ctrl3),
          _campoAndar('4 andares',  ctrl4),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar')),
        ],
      ),
    );

    if (salvar == true) {
      await _catalogo.salvarPrecoAndar(
          1, double.tryParse(ctrl1.text.replaceAll(',', '.')) ?? 0);
      await _catalogo.salvarPrecoAndar(
          2, double.tryParse(ctrl2.text.replaceAll(',', '.')) ?? 0);
      await _catalogo.salvarPrecoAndar(
          3, double.tryParse(ctrl3.text.replaceAll(',', '.')) ?? 0);
      await _catalogo.salvarPrecoAndar(
          4, double.tryParse(ctrl4.text.replaceAll(',', '.')) ?? 0);
      setState(() {});
    }
  }

  Widget _campoAndar(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(labelText: label, prefixText: 'R\$ '),
        ),
      );

  // ── Add item dialog ────────────────────────────────────────────────────────
  Future<void> _adicionar(String cat) async {
    final nomeCtrl  = TextEditingController();
    final descCtrl  = TextEditingController();
    final precoCtrl = TextEditingController();
    String imagemSelecionada = '';
    bool boloDeAndar    = false;
    bool podeUsarImagens = false;

    final picker = ImagePicker();

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Adicionar em ${_labels[cat]}'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nomeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nome do item')),
              const SizedBox(height: 12),
              TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Descrição')),
              const SizedBox(height: 12),
              TextField(
                controller: precoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Preço (opcional)',
                    hintText: 'Ex: 49.90'),
              ),
              // Show tipo-specific toggles only for 'tipos'; hide for 'outros'
              if (cat == 'tipos')
                Column(children: [
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: boloDeAndar,
                    title: const Text('Bolo de Andares'),
                    subtitle: const Text(
                        'Permite selecionar quantidade de andares'),
                    onChanged: (v) => setDialogState(
                        () => boloDeAndar = v ?? false),
                  ),
                  CheckboxListTile(
                    value: podeUsarImagens,
                    title: const Text('Pode usar imagens'),
                    subtitle: const Text(
                        'Permite que o cliente envie imagens para o pedido'),
                    onChanged: (v) => setDialogState(
                        () => podeUsarImagens = v ?? false),
                  ),
                ]),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Selecionar Imagem'),
                onPressed: () async {
                  final XFile? picked = await picker.pickImage(
                      source: ImageSource.gallery);
                  if (picked != null) {
                    setDialogState(
                        () => imagemSelecionada = picked.path);
                  }
                },
              ),
              if (imagemSelecionada.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.file(File(imagemSelecionada),
                      height: 120, fit: BoxFit.cover),
                ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Adicionar',
                  style: TextStyle(color: Colors.amber.shade700)),
            ),
          ],
        ),
      ),
    );

    if (res == true && nomeCtrl.text.trim().isNotEmpty) {
      await widget.service.adicionarItem(
        cat,
        nomeCtrl.text.trim(),
        descCtrl.text.trim(),
        imagemSelecionada,
        precoCtrl.text.trim(),
        boloDeAndar,
        podeUsarImagens,
      );
      _carregar();
    }
  }

  // ── Edit item dialog ───────────────────────────────────────────────────────
  Future<void> _editar(String cat, Map<String, String> item) async {
    final nomeCtrl  = TextEditingController(text: item['nome']);
    final descCtrl  = TextEditingController(text: item['descricao']);
    final precoCtrl = TextEditingController(text: item['preco'] ?? '');
    bool boloDeAndar    = item['boloDeAndar'] == 'true';
    bool podeUsarImagens = item['podeUsarImagens'] == 'true';
    String imagemAtual  = item['imagem'] ?? '';

    final picker = ImagePicker();

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Item'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 12),
              TextField(
                  controller: descCtrl,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Descrição')),
              const SizedBox(height: 12),
              TextField(
                controller: precoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Preço (opcional)',
                    hintText: 'Ex: 49.90'),
              ),
              if (cat == 'tipos')
                Column(children: [
                  CheckboxListTile(
                    value: boloDeAndar,
                    title: const Text('Bolo de Andares'),
                    subtitle: const Text(
                        'Permite selecionar quantidade de andares'),
                    onChanged: (v) => setDialogState(
                        () => boloDeAndar = v ?? false),
                  ),
                  CheckboxListTile(
                    value: podeUsarImagens,
                    title: const Text('Pode usar imagens'),
                    subtitle: const Text(
                        'Permite que o cliente envie imagens para o pedido'),
                    onChanged: (v) => setDialogState(
                        () => podeUsarImagens = v ?? false),
                  ),
                ]),
              const SizedBox(height: 16),
              if (imagemAtual.isNotEmpty)
                Image.file(File(imagemAtual),
                    height: 150, fit: BoxFit.cover),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Alterar Imagem'),
                onPressed: () async {
                  final XFile? picked = await picker.pickImage(
                      source: ImageSource.gallery);
                  if (picked != null) {
                    setDialogState(() => imagemAtual = picked.path);
                  }
                },
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Salvar',
                  style: TextStyle(color: Colors.amber.shade700)),
            ),
          ],
        ),
      ),
    );

    if (res == true) {
      await widget.service.atualizarItem(
        cat,
        item['nome']!,
        nomeCtrl.text.trim(),
        descCtrl.text.trim(),
        imagemAtual,
        precoCtrl.text.trim(),
        boloDeAndar,
        podeUsarImagens,
      );
      _carregar();
    }
  }

  Future<void> _remover(String cat, String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover item'),
        content: Text('Remover "$nome"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remover',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await widget.service.removerItem(cat, nome);
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Andares pricing card ──────────────────────────────────────────
        Card(
          child: ListTile(
            leading: const Icon(Icons.layers, color: Colors.amber),
            title: const Text('Configurar Bolo de Andares'),
            subtitle: const Text('Editar preços dos andares'),
            trailing: const Icon(Icons.edit),
            onTap: _editarAndares,
          ),
        ),
        const SizedBox(height: 16),

        // ── One card per category ─────────────────────────────────────────
        ..._labels.entries.map((e) {
          final chave = e.key;
          final label = e.value;
          final itens = _opcoes[chave] ?? [];

          // Pick accent colour: 'outros' gets a teal accent to stand out
          final isOutros = chave == 'outros';
          final accentColor =
              isOutros ? Colors.teal : Colors.amber.shade800;
          final accentLight =
              isOutros ? Colors.teal.shade50 : Colors.amber.shade50;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            if (isOutros)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.add_shopping_cart,
                                    color: accentColor, size: 22),
                              ),
                            Text(label,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor)),
                          ]),
                          IconButton(
                            icon: Icon(Icons.add_circle,
                                color: accentColor, size: 30),
                            onPressed: () => _adicionar(chave),
                          ),
                        ]),

                    // Helper text for 'outros'
                    if (isOutros) ...[
                      Text(
                        'Itens exibidos como adicionais opcionais na tela do cliente.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal.shade700,
                            fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 12),

                    if (itens.isEmpty)
                      Text('Nenhum item ainda.',
                          style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: itens.map((item) => Chip(
                          label: Text(item['nome']!),
                          backgroundColor: accentLight,
                          side: BorderSide(
                              color: isOutros
                                  ? Colors.teal.shade300
                                  : Colors.amber.shade400),
                          onDeleted: () =>
                              _remover(chave, item['nome']!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        )).toList(),
                      ),

                    const Divider(height: 24),

                    ...itens.map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          // Show image thumbnail for 'outros' items
                          leading: isOutros &&
                                  (item['imagem'] ?? '').isNotEmpty &&
                                  File(item['imagem']!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(item['imagem']!),
                                    width: 48, height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                          title: Row(children: [
                            Expanded(
                              child: Text(item['nome']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                            if (item['boloDeAndar'] == 'true')
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: const Text('Andares'),
                                  backgroundColor:
                                      Colors.orange.shade100,
                                ),
                              ),
                            if (item['podeUsarImagens'] == 'true')
                              Chip(
                                label: const Text('Imagens'),
                                backgroundColor:
                                    Colors.blue.shade100,
                              ),
                          ]),
                          subtitle: isOutros &&
                                  (item['preco'] ?? '').isNotEmpty
                              ? Text(
                                  'R\$ ${item['preco']}',
                                  style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontWeight: FontWeight.w600),
                                )
                              : null,
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: accentColor),
                            onPressed: () => _editar(chave, item),
                          ),
                        )),
                  ]),
            ),
          );
        }),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ABA 3 — USUÁRIOS
// ════════════════════════════════════════════════════════════════════════════
class _UsuariosTab extends StatefulWidget {
  final AuthService service;
  const _UsuariosTab({required this.service});
  @override
  State<_UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<_UsuariosTab> {
  List<Map<String, dynamic>> get _users => widget.service.listarTodos();

  Future<void> _deletar(String email) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir usuário'),
        content: Text('Excluir a conta de $email?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await Hive.box('usuarios').delete(email);
      setState(() {});
    }
  }

  Future<void> _toggleAdmin(Map<String, dynamic> u) async {
    await widget.service
        .atualizarUsuario(u['email'], {'isAdmin': !(u['isAdmin'] == true)});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lista = _users;
    return lista.isEmpty
        ? Center(
            child: Text('Nenhum usuário cadastrado.',
                style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final u       = lista[i];
              final isAdmin = u['isAdmin'] == true;
              final isProt  = u['email'] == 'admin@cakemain.com';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin
                        ? Colors.amber.shade200
                        : Colors.pink.shade100,
                    child: Icon(
                        isAdmin
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: isAdmin
                            ? Colors.amber.shade700
                            : Colors.pink),
                  ),
                  title: Text(u['nome'] ?? 'Sem nome',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['email'] ?? ''),
                        if ((u['telefone'] as String?)?.isNotEmpty ?? false)
                          Text(u['telefone']!,
                              style: const TextStyle(fontSize: 12)),
                      ]),
                  isThreeLine:
                      (u['telefone'] as String?)?.isNotEmpty ?? false,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Tooltip(
                      message:
                          isAdmin ? 'Remover admin' : 'Tornar admin',
                      child: IconButton(
                        icon: Icon(Icons.admin_panel_settings,
                            color: isAdmin ? Colors.amber : Colors.grey),
                        onPressed:
                            isProt ? null : () => _toggleAdmin(u),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: isProt
                              ? Colors.grey.shade300
                              : Colors.red),
                      onPressed:
                          isProt ? null : () => _deletar(u['email']),
                    ),
                  ]),
                ),
              );
            },
          );
  }
}