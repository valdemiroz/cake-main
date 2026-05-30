import 'package:flutter/material.dart';
import '/dados/auth_service.dart';
import '/dados/pedidos_service.dart';
import '/paginas/perfil_pagina.dart';
import '/paginas/bolos_pagina.dart';
import '/conta/login_perfil.dart';
import '/paginas/pepito.dart';
import '/paginas/suporte.dart';
import 'dart:io';

class PedidosPagina extends StatefulWidget {
  @override
  State<PedidosPagina> createState() => _PedidosPaginaState();
}

class _PedidosPaginaState extends State<PedidosPagina> {
  final _auth    = AuthService();
  final _pedidos = PedidosService();

  Map<String, dynamic>?      _usuario;
  List<Map<String, dynamic>> _lista   = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final u = await _auth.getUsuarioLogado();
    if (!mounted) return;
    setState(() {
      _usuario = u;
      _lista   = u != null ? _pedidos.getPedidosDoUsuario(u['email']) : [];
      _loading = false;
    });
  }

  Future<void> _cancelarPedido(Map<String, dynamic> pedido) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido?'),
        content: Text(
          'Tem certeza que deseja cancelar este pedido?\n\n'
          '${pedido['tipoBolo']} - ${pedido['tamanho']}\n'
          'R\$ ${(pedido['preco'] as double).toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, cancelar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final sucesso = await _pedidos.cancelarPedido(pedido['id']);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso
          ? 'Pedido cancelado com sucesso'
          : 'Não foi possível cancelar o pedido'),
      backgroundColor: sucesso ? Colors.green : Colors.red,
    ));

    if (sucesso) _carregar();
  }

  Color _cor(String status) {
    switch (status) {
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
    return Scaffold(
      appBar: _appBar(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : _usuario == null
              ? _semLogin()
              : _lista.isEmpty
                  ? _vazio()
                  : _listaPedidos(),
    );
  }

  Widget _semLogin() => Container(
        color: Colors.pink.shade50,
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 80, color: Colors.pink.shade300),
                const SizedBox(height: 20),
                Text('Faça login para ver seus pedidos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => LoginPerfil()))
                      .then((_) => _carregar()),
                  child: const Text('Fazer login',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ]),
        ),
      );

  Widget _vazio() => Container(
        color: Colors.pink.shade50,
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 90, color: Colors.pink.shade300),
                const SizedBox(height: 20),
                Text('Nenhum pedido ainda!',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700)),
                const SizedBox(height: 10),
                Text('Que tal montar seu primeiro bolo?',
                    style: TextStyle(
                        fontSize: 16, color: Colors.pink.shade400)),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BolosPagina())),
                  child: const Text('Fazer pedido',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ]),
        ),
      );

  Widget _listaPedidos() => Container(
        color: Colors.pink.shade50,
        child: RefreshIndicator(
          onRefresh: _carregar,
          color: Colors.pink,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _lista.length,
            itemBuilder: (_, i) {
              final p = _lista[i];
              final dt  = DateTime.parse(p['dataPedido']);
              final fmt = '${dt.day.toString().padLeft(2, '0')}/'
                  '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
              final bool podeCancelar = p['status'] == 'Pendente';

              // Extras
              final outros = (p['outrosSelecionados'] as List?)
                      ?.cast<String>()
                      .where((s) => s.isNotEmpty)
                      .toList() ??
                  [];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────────
                        Row(children: [
                          const Icon(Icons.cake, color: Colors.pink, size: 26),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${p['tipoBolo']} · ${p['tamanho']}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade700),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: _cor(p['status']),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(p['status'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        const SizedBox(height: 8),

                        Text(
                          'Sabor: ${p['sabor']}  |  Recheio: ${p['recheio']}  |  Cobertura: ${p['cobertura']}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                        if ((p['nivelAndares'] as int?) != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Andares: ${p['nivelAndares']}',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),

                        // ── Extras row ────────────────────────────────────────
                        if (outros.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.add_shopping_cart,
                                    size: 14, color: Colors.pink.shade400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Adicionais: ${outros.join(', ')}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.pink.shade600,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if ((p['observacoes'] as String?)?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Obs: ${p['observacoes']}',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12)),
                          ),
                        if ((p['endereco'] as String?)?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Entrega: ${p['endereco']}',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12)),
                          ),

                        // ── Images ────────────────────────────────────────────
                        if (_temImagensValidas(p))
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Imagens anexadas:',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.pink.shade700)),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _getImagensValidas(p).length,
                                    itemBuilder: (context, idx) {
                                      final img =
                                          _getImagensValidas(p)[idx];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () =>
                                              _mostrarImagemGrande(img),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              width: 100, height: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.pink.shade200,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Image.file(File(img),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          Container(
                                                    color:
                                                        Colors.grey.shade200,
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ── Price + cancel ────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${(p['preco'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade700),
                            ),
                            if (podeCancelar)
                              TextButton.icon(
                                onPressed: () => _cancelarPedido(p),
                                icon: const Icon(Icons.cancel,
                                    color: Colors.red, size: 20),
                                label: const Text('Cancelar',
                                    style: TextStyle(color: Colors.red)),
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6)),
                              ),
                          ],
                        ),
                        Text(fmt,
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ]),
                ),
              );
            },
          ),
        ),
      );

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
          child: Text('Acompanhe aqui',
              style: TextStyle(
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        offset: Offset(2, 1),
                        blurRadius: 0,
                        color: Colors.black)
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
        pageBuilder: (ctx, _, __) => Center(
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
                const Text('CONFIGURAÇÕES',
                    style: TextStyle(
                        shadows: [
                          Shadow(offset: Offset(2, 1), color: Colors.black)
                        ],
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(ctx,
                          MaterialPageRoute(builder: (_) => Pepito()));
                    },
                    child: const Text('Pepito IA',
                        style: TextStyle(
                            fontSize: 22,
                            decoration: TextDecoration.none,
                            color: Colors.white))),
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Seus pedidos',
                        style: TextStyle(
                            fontSize: 22,
                            decoration: TextDecoration.none,
                            color: Colors.white))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(ctx,
                          MaterialPageRoute(builder: (_) => BolosPagina()));
                    },
                    child: const Text('Agendar pedido',
                        style: TextStyle(
                            fontSize: 22,
                            decoration: TextDecoration.none,
                            color: Colors.white))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(ctx,
                          MaterialPageRoute(builder: (_) => Suporte()));
                    },
                    child: const Text('Suporte',
                        style: TextStyle(
                            fontSize: 22,
                            decoration: TextDecoration.none,
                            color: Colors.white))),
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
        ),
      );
}