// ignore_for_file: unused_element, unnecessary_type_check

import 'package:flutter/material.dart';
import '/dados/auth_service.dart';
import '/dados/catalogo_service.dart';
import '/dados/pedidos_service.dart';
import 'perfil_pagina.dart';
import '/conta/pedidos_pagina.dart';
import '/conta/login_perfil.dart';
import 'pepito.dart';
import 'suporte.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BolosPagina extends StatefulWidget {
  @override
  State<BolosPagina> createState() => _BolosPaginaState();
}

class _BolosPaginaState extends State<BolosPagina> {
  final _catalogoService = CatalogoService();
  final _pedidosService  = PedidosService();
  final _auth            = AuthService();
  final _obsCtrl         = TextEditingController();
  final _enderecoCtrl    = TextEditingController();
  final _imagePicker     = ImagePicker();

  Map<String, List<String>> _opcoes = {};

  // Itens de seleção do banco de dados ─
  String? _tipo, _tamanho, _sabor, _cobertura, _recheio;

  // Andares (quando um bolo possui tal função)
  int?    _nivelAndares;

  // Outros itens
  final Set<String> _outrosSelecionados = {};
  List<Map<String, String>> _outrosItens = [];

  bool _loading  = false;
  bool _enviando = false;
  List<XFile> _imagensObservacoes = [];

  // Lógica do bolo de andar - caixa
  bool get _ehBoloDeAndar =>
      _tipo != null && _catalogoService.isBoloDeAndar(_tipo!);
  
// Preços padronizados
  static const Map<String, double> _precosFallback = {
    'Pequeno (15cm)': 25.0,
    'Médio (20cm)':  30.0,
    'Grande (25cm)': 45.0,
    'Festa (30cm)':  85.0,
  };

  double _precoDoItem(String categoria, String? nome) {
    if (nome == null) return 0;
    return _catalogoService.obterPreco(categoria, nome) ??
        (categoria == 'tamanhos' ? _precosFallback[nome] ?? 0 : 0);
  }

  double _precoOutro(String nome) =>
      _catalogoService.obterPreco('outros', nome) ?? 0;

  double get _preco {
    final base = [
      _precoDoItem('tipos', _tipo),
      _precoDoItem('tamanhos', _tamanho),
      _precoDoItem('sabores', _sabor),
      _precoDoItem('coberturas', _cobertura),
      _precoDoItem('recheios', _recheio),
    ].fold(0.0, (t, v) => t + v);

    final andares = _ehBoloDeAndar
        ? _catalogoService.obterPrecoAndar(_nivelAndares)
        : 0.0;

    final extras = _outrosSelecionados.fold(
        0.0, (t, nome) => t + _precoOutro(nome));

    return base + andares + extras;
  }
  
  get onTap => null;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    _enderecoCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    final opcoes = _catalogoService.getOpcoes();
    final outros = _catalogoService.getOutros();
    if (!mounted) return;
    setState(() {
      _opcoes      = opcoes;
      _outrosItens = outros;
      _loading     = false;
    });
  }
  
  void _toggle(String? current, String value, void Function(String?) setter) {
    setState(() => setter(current == value ? null : value));
  }

  void _toggleOutro(String nome) {
    setState(() {
      if (_outrosSelecionados.contains(nome)) {
        _outrosSelecionados.remove(nome);
      } else {
        _outrosSelecionados.add(nome);
      }
    });
  }

  // Adicionar imagens em observações para customizar (Se o bolo tiver tal função)
  bool _podeAdicionarImagem() =>
      _tipo != null && _catalogoService.podeUsarImagens(_tipo!);

  Future<void> _adicionarImagem() async {
    if (!_podeAdicionarImagem()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Este tipo de bolo não permite envio de imagens'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    if (_imagensObservacoes.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Apenas 1 imagem é permitida por pedido'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    try {
      final XFile? imagem = await _imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (imagem != null) setState(() => _imagensObservacoes.add(imagem));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }
  void _removerImagem(int index) =>
      setState(() => _imagensObservacoes.removeAt(index));

  Future<List<String>> _salvarImagensLocalmente() async {
    final List<String> caminhos = [];
    try {
      final appDir     = await getApplicationDocumentsDirectory();
      final pastaPedidos = Directory('${appDir.path}/pedidos_images');
      if (!await pastaPedidos.exists()) await pastaPedidos.create(recursive: true);
      for (int i = 0; i < _imagensObservacoes.length; i++) {
        final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final destino     = '${pastaPedidos.path}/$nomeArquivo';
        await File(_imagensObservacoes[i].path).copy(destino);
        caminhos.add(destino);
      }
    } catch (e) {
      debugPrint('Erro ao salvar imagens: $e');
    }
    return caminhos;
  }

  // Informação (botão de "?" ao lado)
  void _mostrarInfo(String chave, String item) {
    final lista = _catalogoService.getOpcoesComDescricao()[chave] ?? [];
    Map<String, String>? encontrado;
    for (var i in lista) {
      if (i is Map && i['nome'] == item) {
        encontrado = Map<String, String>.from(i);
        break;
      }
    }
    final descricao  = encontrado?['descricao'] ?? 'Sem descrição disponível.';
    final imagemPath = encontrado?['imagem'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (imagemPath.isNotEmpty)
              Image.file(File(imagemPath), height: 220, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(descricao),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  // Lógica de pedido (Precisa marcar todas as caixas)
  Future<void> _pedir() async {
    if (_ehBoloDeAndar && _nivelAndares == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a quantidade de andares do bolo.')));
      return;
    }
    if ([_tipo, _tamanho, _sabor, _cobertura, _recheio].any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todas as opções antes de pedir!')));
      return;
    }
    final usuario = await _auth.getUsuarioLogado();
    if (usuario == null) {
      _loginRequired();
      return;
    }
    _mostrarFormasPagamento(usuario);
  }

  // Confirmar pedido, endereço de entrega e pagamento 
  Future<void> _confirmarPedido({
    required Map<String, dynamic> usuario,
    required String formaPagamento,
    required VoidCallback afterPop,
  }) async {
    if (_enderecoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe o endereço de entrega.')));
      return;
    }
    afterPop();
    setState(() => _enviando = true);
    final imagensSalvas = await _salvarImagensLocalmente();

    // Registra estes dados do usuário no pedido
    await _pedidosService.criarPedido(
  usuarioEmail: usuario['email'],
  nomeCliente: usuario['nome'] ?? '',
  telefoneCliente: usuario['telefone'] ?? '',

  tipoBolo: _tipo!,
  tamanho: _tamanho!,
  sabor: _sabor!,
  cobertura: _cobertura!,
  recheio: _recheio!,
  observacoes: _obsCtrl.text.trim(),
  endereco: _enderecoCtrl.text.trim(),
  preco: _preco,
  formaPagamento: formaPagamento,
  imagensObservacoes: imagensSalvas,
  nivelAndares: _nivelAndares,
  outrosSelecionados: _outrosSelecionados.toList(),
);
    if (!mounted) return;
    setState(() => _enviando = false);
    _confirmacao();
  }

  // Formas de pagamento
  void _mostrarFormasPagamento(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? formaSelecionada;
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Escolha a forma de pagamento',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                  fontSize: 20),
            ),
            content: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    
    // Endereçamento exigido em todas as formas de pagamento
    children: [
              TextField(
                controller: _enderecoCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Endereço de entrega',
                  hintText: 'Rua, número, bairro, cidade',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 14),
              _paymentOption(
                title: 'Cartão de Crédito/Débito',
                subtitle: 'Em 2x, 3x ou 4x sem juros.',
                icon: Icons.credit_card,
                isSelected: formaSelecionada == 'Cartão',
                onTap: () {                   if (_enderecoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Informe o endereço de entrega'),
                      ),
                    );
                    return;
                  }
                  setDialogState(() => formaSelecionada = 'Cartão');
                  Navigator.pop(ctx);
                  _mostrarDetalheCartao(usuario);
                },
              ),
              const SizedBox(height: 12),
              _paymentOption(
                title: 'PIX',
                subtitle: 'Pagamento instantâneo via QR Code.',
                icon: Icons.pix,
                isSelected: formaSelecionada == 'PIX',
                onTap: () {
  if (_enderecoCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informe o endereço de entrega'),
      ),
    );
    return;
  }

  setDialogState(() => formaSelecionada = 'PIX');
  Navigator.pop(ctx);
  _mostrarPix(usuario);
},),
              const SizedBox(height: 12),
              _paymentOption(
                title: 'Dinheiro',
                subtitle: 'Pagamento na entrega (informe o troco).',
                icon: Icons.money,
                isSelected: formaSelecionada == 'Dinheiro',
                onTap: () => setDialogState(() => formaSelecionada = 'Dinheiro'),
              ),
            ],),),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: formaSelecionada != 'Dinheiro'
                    ? null
                    : () => _confirmarPedido(
                          usuario: usuario,
                          formaPagamento: 'Dinheiro',
                          afterPop: () => Navigator.pop(ctx),
                        ),
                child: const Text('Confirmar Pedido',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  void _mostrarPix(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Pagamento via PIX',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Escaneie o QR Code abaixo para realizar o pagamento:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 16),
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.pink, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.qr_code_2, size: 120, color: Colors.black87),
                const SizedBox(height: 4),
                Text('QR Code PIX',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: Colors.pink.shade50,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Total: R\$ ${_preco.toStringAsFixed(2)}',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.pink.shade700,
    ),
  ),
),],),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _confirmarPedido(
              usuario: usuario,
              formaPagamento: 'PIX',
              afterPop: () => Navigator.pop(ctx),
            ),
            child: const Text('Já paguei',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalheCartao(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? tipoCartao;
        String? parcelas;
        final numCtrl     = TextEditingController();
        final validadeCtrl = TextEditingController();
        final cvcCtrl     = TextEditingController();
        final nomeCtrl    = TextEditingController();

        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Dados do Cartão',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.pink.shade700)),
            content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo de cartão',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.pink.shade700)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _cartaoTipoBtn('Débito', tipoCartao,
                          (v) => setDialogState(() => tipoCartao = v)),
                      const SizedBox(width: 10),
                      _cartaoTipoBtn('Crédito', tipoCartao,
                          (v) => setDialogState(() {
                                tipoCartao = v;
                                parcelas = null;
                              })),
                    ]),
                    const SizedBox(height: 16),
                    _cartaoInput(numCtrl, 'Número do cartão', TextInputType.number),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _cartaoInput(validadeCtrl, 'Data de vencimento',
                              TextInputType.datetime,
                              hint: 'MM/AA')),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 90,
                          child: _cartaoInput(cvcCtrl, 'CVC', TextInputType.number)),
                    ]),
                    const SizedBox(height: 10),
                    _cartaoInput(nomeCtrl, 'Nome do titular', TextInputType.name),
                    if (tipoCartao == 'Crédito') ...[
                      const SizedBox(height: 16),
                      Text('Número de parcelas',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.pink.shade700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['1x', '2x', '3x', '4x'].map((p) {
                          final valor = _preco / int.parse(p[0]);
                          final sel   = parcelas == p;
                          return GestureDetector(
                            onTap: () =>
                                setDialogState(() => parcelas = sel ? null : p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? Colors.pink : Colors.white,
                                border: Border.all(color: Colors.pink, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(children: [
                                Text(p,
                                    style: TextStyle(
                                        color: sel
                                            ? Colors.white
                                            : Colors.pink.shade700,
                                        fontWeight: FontWeight.bold)),
                                Text('R\$ ${valor.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: sel
                                            ? Colors.white70
                                            : Colors.grey.shade600,
                                        fontSize: 11)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (tipoCartao == null ||
                      numCtrl.text.isEmpty ||
                      validadeCtrl.text.isEmpty ||
                      cvcCtrl.text.isEmpty ||
                      nomeCtrl.text.isEmpty ||
                      (tipoCartao == 'Crédito' && parcelas == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Preencha todos os campos do cartão!')));
                    return;
                  }
                  final forma = tipoCartao == 'Crédito'
                      ? 'Cartão de Crédito ($parcelas)'
                      : 'Cartão de Débito';
                  _confirmarPedido(
                    usuario: usuario,
                    formaPagamento: forma,
                    afterPop: () => Navigator.pop(ctx),
                  );
                },
                child: const Text('Confirmar',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  // Itens internos no menu do cartão
  Widget _cartaoTipoBtn(
      String label, String? selecionado, void Function(String) onTap) {
    final sel = selecionado == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? Colors.pink : Colors.white,
            border: Border.all(color: Colors.pink, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: sel ? Colors.white : Colors.pink.shade700,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _cartaoInput(
    TextEditingController ctrl,
    String label,
    TextInputType tipo, {
    String? hint,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.pink.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.pink, width: 2)),
        ),
      );

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : Colors.white,
          border: Border.all(
              color: isSelected ? Colors.pink : Colors.grey.shade300,
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon,
              color: isSelected ? Colors.pink : Colors.grey.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
            ]),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Colors.pink, size: 24),
        ]),
      ),
    );
  }
// Exigência de login para prosseguir pedido
  void _loginRequired() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login necessário'),
        content: const Text('Faça login para realizar um pedido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => LoginPerfil()));
            },
            child: const Text('Fazer login',
                style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
    );
  }
// Confirmar (caso logado e confirmado o pedido)
  void _confirmacao() {
    final extrasTexto = _outrosSelecionados.isNotEmpty
        ? '\nExtras: ${_outrosSelecionados.join(', ')}'
        : '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pedido realizado! 🎂'),
        content: Text(
          'Tipo: $_tipo\n'
          'Tamanho: $_tamanho\n'
          '${_ehBoloDeAndar && _nivelAndares != null ? 'Andares: $_nivelAndares\n' : ''}'
          'Sabor: $_sabor\n'
          'Cobertura: $_cobertura\n'
          'Recheio: $_recheio'
          '$extrasTexto\n'
          '${_enderecoCtrl.text.trim().isNotEmpty ? 'Endereço: ${_enderecoCtrl.text.trim()}\n\n' : ''}'
          'Total: R\$ ${_preco.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PedidosPagina()));
            },
            child: const Text('Ver meus pedidos',
                style: TextStyle(color: Colors.pink)),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK')),
        ],
      ),
    );
  }

  // corpo da página
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : Stack(children: [
              // Fundo como um caderno quase transparente
              Positioned.fill(
                child: Center(
                  child: Image.asset('assets/images/caderno.png',
                      fit: BoxFit.contain),
                ),
              ),
              Container(
                color: Colors.pink.shade50.withOpacity(0.85),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'MONTE SEU BOLO',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Criação do bolo
                      _secao('TIPO DE BOLO', 'tipos',
                          (v) => _toggle(_tipo, v, (x) => _tipo = x), _tipo),

                      // Andares (apenas quando a opção é marcada em adm.dart em um bolo)
                      if (_ehBoloDeAndar)
                        _andaresSection(),

                      _secao('TAMANHO', 'tamanhos',
                          (v) => _toggle(_tamanho, v, (x) => _tamanho = x),
                          _tamanho),
                      _secao('SABOR', 'sabores',
                          (v) => _toggle(_sabor, v, (x) => _sabor = x), _sabor),
                      _secao('COBERTURA', 'coberturas',
                          (v) => _toggle(_cobertura, v, (x) => _cobertura = x),
                          _cobertura),
                      _secao('RECHEIO', 'recheios',
                          (v) => _toggle(_recheio, v, (x) => _recheio = x),
                          _recheio),

                      // Descrição e foto interna (do botão "?" lateral)
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _obsCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Observações (opcional)',
                                hintText: 'Ex: escrita no bolo, alergias...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.pink, width: 2)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(children: [
                            GestureDetector(
                              onTap: _podeAdicionarImagem()
                                  ? _adicionarImagem
                                  : null,
                              child: Opacity(
                                opacity:
                                    _podeAdicionarImagem() ? 1.0 : 0.5,
                                child: Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    color: _podeAdicionarImagem()
                                        ? Colors.pink
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _podeAdicionarImagem()
                                        ? [BoxShadow(
                                            color: Colors.pink.shade200,
                                            blurRadius: 4)]
                                        : [],
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 32),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_imagensObservacoes.length}/1',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _podeAdicionarImagem()
                                      ? Colors.pink.shade700
                                      : Colors.grey),
                            ),
                          ]),
                        ],
                      ),

                      // Permite adicionar imagens nas observações para decorar o bolo (que tiver a função ativa)
                      if (_imagensObservacoes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Imagens adicionadas:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.pink.shade700)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagensObservacoes.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(children: [
                                Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.pink.shade200, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(_imagensObservacoes[index].path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -8, right: -8,
                                  child: GestureDetector(
                                    onTap: () => _removerImagem(index),
                                    child: Container(
                                      width: 32, height: 32,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 4,
                                              color: Colors.black26)
                                        ],
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],

                      // Extras - itens diversos
                      if (_outrosItens.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _outrosSection(),
                      ],

                      // Total calculado
                      const SizedBox(height: 20),
                      if (_tamanho != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Valor estimado: R\$ ${_preco.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade800),
                          ),
                        ),

                      // Botão de realizar pedido
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _enviando ? null : _pedir,
                          icon: const Icon(Icons.cake, color: Colors.white),
                          label: _enviando
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Fazer pedido',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
    );
  }

  // Seção de andares (aberta quando um bolo possui tal função ativa)
  Widget _andaresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(
            'NÍVEIS DE ANDARES',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
                letterSpacing: 1.2),
          ),
        ),
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [1, 2, 3, 4].map((nivel) {
            final sel = _nivelAndares == nivel;
            return GestureDetector(
              onTap: () => setState(
                  () => _nivelAndares = sel ? null : nivel),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? Colors.pink : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.pink, width: 2),
                ),
                child: Text(
                  '$nivel ${nivel == 1 ? 'andar' : 'andares'}',
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.pink.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // Seção de extras (quando possui um item por essa categoria)
  Widget _outrosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(children: [
          Expanded(child: Divider(color: Colors.pink.shade200, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'ADICIONAIS',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                  letterSpacing: 1.2),
            ),
          ),
          Expanded(child: Divider(color: Colors.pink.shade200, thickness: 1)),
        ]),
        const SizedBox(height: 4),
        Text(
          'Selecione quantos quiser',
          style: TextStyle(fontSize: 13, color: Colors.pink.shade400),
        ),
        const SizedBox(height: 12),

        // Organização do card "outros"
        Wrap(
          spacing: 10, runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _outrosItens.map((item) {
            final nome       = item['nome'] ?? '';
            final descricao  = item['descricao'] ?? '';
            final imagemPath = item['imagem'] ?? '';
            final precoRaw   = item['preco'] ?? '';
            final preco      = double.tryParse(
                    precoRaw.replaceAll(',', '.')) ??
                0.0;
            final sel = _outrosSelecionados.contains(nome);

            return GestureDetector(
              onTap: () => _toggleOutro(nome),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 150,
                decoration: BoxDecoration(
                  color: sel ? Colors.pink.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: sel ? Colors.pink : Colors.pink.shade200,
                      width: sel ? 2.5 : 1.5),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: Colors.pink.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                ),
                child: Column(children: [
                  // Imagem (quando "outros" possui)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: imagemPath.isNotEmpty &&
                            File(imagemPath).existsSync()
                        ? Image.file(File(imagemPath),
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            height: 90,
                            width: double.infinity,
                            color: Colors.pink.shade100,
                            child: Icon(Icons.stars_rounded,
                                color: Colors.pink.shade300, size: 40),
                          ),
                  ),
                  // Texto interno ("outros")
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(nome,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: sel
                                              ? Colors.pink.shade700
                                              : Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                if (sel)
                                  const Icon(Icons.check_circle,
                                      color: Colors.pink, size: 18),
                              ]),
                          if (descricao.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(descricao,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                          if (preco > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              '+ R\$ ${preco.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.pink.shade600),
                            ),
                          ],
                        ]),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Montagem do bolo geral (botões ativos)
  Widget _secao(
    String titulo,
    String chave,
    Function(String) onSelect,
    String? selecionado,
  ) {
    final itens = _opcoes[chave] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
                letterSpacing: 1.2),
          ),
        ),
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: itens.map((item) {
            final sel = selecionado == item;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () => onSelect(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? Colors.pink : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.pink, width: 2),
                  ),
                  child: Text(item,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.pink.shade700,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              GestureDetector(
                onTap: () => _mostrarInfo(chave, item),
                child: Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink.shade100,
                    border: Border.all(
                        color: Colors.pink.shade300, width: 1.5),
                  ),
                  child: Center(
                    child: Text('?',
                        style: TextStyle(
                            color: Colors.pink.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // Barra do aplicativo (topo)
  AppBar _appBar(BuildContext context) => AppBar(
        backgroundColor: Colors.pink,
        toolbarHeight: 80, elevation: 5,
        shadowColor: Colors.pink.shade900,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 16),
          icon: const Icon(Icons.person, color: Colors.white, size: 40),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => PerfilPagina())),
        ),
        title: Center(
          child: Text('Agendar pedido',
              style: TextStyle(
                  color: Colors.white,
                  shadows: const [
                    Shadow(offset: Offset(2, 1), blurRadius: 0, color: Colors.black)
                  ])),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 16),
            icon: const Icon(Icons.list, color: Colors.white, size: 45),
            onPressed: () => _menu(context),
          ),
        ],
      );

  // Menu lateral
  void _menu(BuildContext context) => showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Menu',
        barrierColor: Colors.pink.withOpacity(0.35),
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (ctx, anim, _, child) {
          final c = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic);
          return FadeTransition(
            opacity: c,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, -0.15), end: Offset.zero)
                  .animate(c),
              child: child,
            ),
          );
        },
        pageBuilder: (ctx, _, __) => _menuContent(ctx),
      );

  Widget _menuContent(BuildContext ctx) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: MediaQuery.of(ctx).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                  image: AssetImage('assets/images/confetti.png'),
                  fit: BoxFit.cover),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('CONFIGURAÇÕES',
                  style: TextStyle(
                      shadows: const [
                        Shadow(offset: Offset(2, 1), color: Colors.black)
                      ],
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      decoration: TextDecoration.none)),
              const SizedBox(height: 16),
              _menuBtn(ctx, 'Pepito IA',
                  () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => Pepito()))),
              _menuBtn(ctx, 'Seus pedidos',
                  () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => PedidosPagina()))),
              _menuBtn(ctx, 'Agendar pedido', null),
              _menuBtn(ctx, 'Suporte',
                  () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => Suporte()))),
            ]),
          ),
          const SizedBox(height: 16),
          Opacity(
              opacity: 0.8,
              child: Image.asset('assets/images/bolo.png',
                  width: 250, height: 250)),
          const SizedBox(height: 16),
          Container(
            width: MediaQuery.of(ctx).size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) => PerfilPagina()));
              },
              child: const Text('Acessar sua conta',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      );

  Widget _menuBtn(BuildContext ctx, String label, VoidCallback? action) =>
      TextButton(
        onPressed: action == null
            ? () => Navigator.pop(ctx)
            : () {
                Navigator.pop(ctx);
                action();
              },
        child: Text(label, style: const TextStyle(fontSize: 22, color: Colors.white)),
      );
}
