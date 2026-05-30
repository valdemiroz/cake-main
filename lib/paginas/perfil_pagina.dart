import 'package:flutter/material.dart';
import '/dados/auth_service.dart';
import '/conta/login_perfil.dart';
import 'admin_paginas/adm.dart';
import '/conta/pedidos_pagina.dart';
import 'pepito.dart';
import 'suporte.dart';
import 'bolos_pagina.dart';

// Menu lateral
void _abrirMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.pink.withOpacity(0.35),
    transitionDuration: Duration(milliseconds: 300),
    transitionBuilder: (context, animation, _, child) {
      final c = CurvedAnimation(
          parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
          opacity: c,
          child: SlideTransition(
              position: Tween<Offset>(begin: Offset(0, -0.15), end: Offset.zero).animate(c),
              child: child));
    },
    pageBuilder: (context, _, __) => _MenuContent(context: context),
  );
}

class _MenuContent extends StatefulWidget {
  final BuildContext context;
  const _MenuContent({required this.context});

  @override
  State<_MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<_MenuContent> {
  Future<void> _pedirSenhaAdmin(BuildContext ctx) async {
    final ctrl = TextEditingController();
    bool hide = true;
    String? erro;

// Caixa de admin (quando aberta)
    await showDialog(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Icon(Icons.admin_panel_settings, color: Colors.amber.shade700),
            SizedBox(width: 8),
            Text('Acesso Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Digite a senha de administrador:',
                style: TextStyle(color: Colors.grey.shade700)),
            SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: hide,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Senha',
                prefixIcon: Icon(Icons.lock, color: Colors.amber.shade700),
                suffixIcon: IconButton(
                  icon: Icon(hide ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () => setD(() => hide = !hide),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber.shade700, width: 2)),
                errorText: erro,
              ),
              onSubmitted: (_) => _validarSenha(ctrl.text, dCtx, ctx, setD, (e) => erro = e),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => _validarSenha(ctrl.text, dCtx, ctx, setD, (e) => erro = e),
              child: Text('Entrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _validarSenha(
    String senha,
    BuildContext dialogCtx,
    BuildContext menuCtx,
    StateSetter setD,
    Function(String?) setErro,
  ) {
    if (senha == '123@admin') {
      Navigator.pop(dialogCtx);
      Navigator.pop(menuCtx);
      Navigator.push(
          widget.context, MaterialPageRoute(builder: (_) => AdminPagina()));
    } else {
      setD(() => setErro('Senha incorreta. Tente novamente.'));
    }
  }
// Demais conteúdos do menu
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: AssetImage('assets/images/confetti.png'), fit: BoxFit.cover), 
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('CONFIGURAÇÕES',
                style: TextStyle(
                    shadows: [Shadow(offset: Offset(2, 1), blurRadius: 0, color: Colors.black)],
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    decoration: TextDecoration.none)),
            SizedBox(height: 16),

            _btn('Pepito IA', () => Navigator.push(context, MaterialPageRoute(builder: (_) => Pepito()))),
            _btn('Seus pedidos', () => Navigator.push(context, MaterialPageRoute(builder: (_) => PedidosPagina()))),
            _btn('Agendar pedido', () => Navigator.push(context, MaterialPageRoute(builder: (_) => BolosPagina()))),
            _btn('Suporte', () => Navigator.push(context, MaterialPageRoute(builder: (_) => Suporte()))),

            Divider(color: Colors.white38, height: 24),

            TextButton.icon(
              onPressed: () => _pedirSenhaAdmin(context),
              icon: Icon(Icons.admin_panel_settings, color: Colors.amber.shade200, size: 20),
              label: Text('Admin',
                  style: TextStyle(
                      fontSize: 20,
                      decoration: TextDecoration.none,
                      color: Colors.amber.shade200,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        SizedBox(height: 16),
        Opacity(opacity: 0.8, child: Image.asset('assets/images/bolo.png', width: 250, height: 250)),
        SizedBox(height: 16),

        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilPagina()));
            },
            child: Text('Acessar sua conta',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _btn(String label, VoidCallback action) => TextButton(
        onPressed: () {
          Navigator.pop(context);
          action();
        },
        child: Text(label,
            style: TextStyle(fontSize: 22, decoration: TextDecoration.none, color: Colors.white)),
      );
}

// Página do perfil
class PerfilPagina extends StatefulWidget {
  @override
  State<PerfilPagina> createState() => _PerfilPaginaState();
}

class _PerfilPaginaState extends State<PerfilPagina> {
  final _auth = AuthService();
  Map<String, dynamic>? _usuario;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    final u = await _auth.getUsuarioLogado();
    setState(() {
      _usuario = u;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _auth.logout();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _editar(String campo, String titulo, String valorAtual,
      {bool isPassword = false}) async {
    final ctrl = TextEditingController(text: isPassword ? '' : valorAtual);
    bool hide = true;

    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Editar $titulo'),
          content: TextField(
            controller: ctrl,
            obscureText: isPassword && hide,
            decoration: InputDecoration(
              hintText: isPassword ? 'Nova senha (mín. 6 caracteres)' : 'Novo valor',
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => set(() => hide = !hide))
                  : null,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: Text('Salvar', style: TextStyle(color: Colors.pink))),
          ],
        ),
      ),
    );

    if (resultado == null || resultado.isEmpty) return;
    if (isPassword && resultado.length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Senha deve ter pelo menos 6 caracteres.')));
      return;
    }
    await _auth.atualizarUsuario(_usuario!['email'], {campo: resultado});
    _carregar();
  }

  Future<void> _excluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir conta'),
        content: Text('Esta ação não pode ser desfeita. Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    await _auth.deletarConta(_usuario!['email']);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.pink)));

    if (_usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPerfil())));
      return Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.pink)));
    }

    final bool isAdmin = _usuario!['isAdmin'] == true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        toolbarHeight: 80,
        elevation: 5,
        shadowColor: Colors.pink.shade900,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context)),
        title: Center(
          child: Text('Meu Perfil',
              style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(2, 1), blurRadius: 0, color: Colors.black)])),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 14),
            icon: Icon(Icons.menu, color: Colors.white, size: 32),
            onPressed: () => _abrirMenu(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.pink.shade50,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            SizedBox(height: 10),
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.pink.shade200,
              child: Icon(Icons.person, size: 64, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(_usuario!['nome'] ?? '',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink.shade700)),
            if (isAdmin) ...[
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                child: Text('Administrador',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              ),
            ],
            SizedBox(height: 28),

            _infoCard('Nome', _usuario!['nome'] ?? '', Icons.person,
                () => _editar('nome', 'Nome', _usuario!['nome'] ?? '')),
            _infoCard('E-mail', _usuario!['email'] ?? '', Icons.email, null),
            _infoCard(
                'Telefone',
                (_usuario!['telefone']?.isEmpty ?? true) ? 'Não informado' : _usuario!['telefone'],
                Icons.phone,
                () => _editar('telefone', 'Telefone', _usuario!['telefone'] ?? '')),
            _infoCard('Senha', '••••••••', Icons.lock,
                () => _editar('senha', 'Senha', '', isPassword: true)),

            SizedBox(height: 24),

            if (isAdmin) ...[
              _btn(
                label: 'Painel Admin',
                icon: Icons.admin_panel_settings,
                color: Colors.amber.shade700,
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPagina())),
              ),
              SizedBox(height: 12),
            ],

            _btn(
              label: 'Sair da conta',
              icon: Icons.logout,
              color: Colors.pink,
              onPressed: _logout,
            ),
            SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: Icon(Icons.delete_forever, color: Colors.red),
                label: Text('Excluir conta',
                    style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: _excluir,
              ),
            ),
            SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, VoidCallback? onEdit) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        Icon(icon, color: Colors.pink, size: 26),
        SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.pink.shade700)),
          ]),
        ),
        if (onEdit != null)
          IconButton(icon: Icon(Icons.edit, color: Colors.pink.shade300, size: 22), onPressed: onEdit),
      ]),
    );
  }

  Widget _btn({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: onPressed,
      ),
    );
  }
}
