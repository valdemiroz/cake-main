import 'package:flutter/material.dart';
import '/dados/auth_service.dart';
import 'login_perfil.dart';

class CadastroPerfil extends StatefulWidget {
  @override
  State<CadastroPerfil> createState() => _CadastroPerfilState();
}

class _CadastroPerfilState extends State<CadastroPerfil> {
  final _nomeCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _senhaCtrl    = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _auth         = AuthService();
  bool _loading       = false;
  bool _hide          = true;

  @override
  void dispose() {
    _nomeCtrl.dispose(); _emailCtrl.dispose();
    _senhaCtrl.dispose(); _telefoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome     = _nomeCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final senha    = _senhaCtrl.text.trim();
    final telefone = _telefoneCtrl.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      _snack('Preencha os campos obrigatórios.'); return;
    }
    if (!email.contains('@')) { _snack('E-mail inválido.'); return; }
    if (senha.length < 6)     { _snack('A senha deve ter pelo menos 6 caracteres.'); return; }

    setState(() => _loading = true);
    final erro = await _auth.cadastrar(nome: nome, email: email, senha: senha, telefone: telefone);
    setState(() => _loading = false);

    if (erro != null) {
      _snack(erro);
    } else {
      _snack('Conta criada com sucesso!');
      await Future.delayed(Duration(milliseconds: 800));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPerfil()));
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        toolbarHeight: 80, elevation: 5,
        shadowColor: Colors.pink.shade900,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context)),
        title: Center(
          child: Text('Criar conta',
              style: TextStyle(color: Colors.white,
                  shadows: [Shadow(offset: Offset(2, 1), blurRadius: 0, color: Colors.black)])),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          image: DecorationImage(
              image: AssetImage('assets/images/confetti.png'), fit: BoxFit.cover, opacity: 0.3),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(28),
            child: Column(children: [
              Image.asset('assets/images/bolo.png', width: 110, height: 110),
              SizedBox(height: 16),
              Text('Crie sua conta',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pink.shade700)),
              SizedBox(height: 4),
              Text('* campos obrigatórios', style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(height: 22),
              _field(_nomeCtrl,     'Nome completo *',              Icons.person, TextInputType.text,          false),
              SizedBox(height: 12),
              _field(_emailCtrl,    'E-mail *',                     Icons.email,  TextInputType.emailAddress,  false),
              SizedBox(height: 12),
              _field(_senhaCtrl,    'Senha * (mín. 6 caracteres)',  Icons.lock,   TextInputType.text,          true),
              SizedBox(height: 12),
              _field(_telefoneCtrl, 'Telefone (opcional)',          Icons.phone,  TextInputType.phone,         false),
              SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _loading ? null : _cadastrar,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Cadastrar',
                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginPerfil())),
                child: Text('Já tem conta? Faça login',
                    style: TextStyle(fontSize: 16, color: Colors.pink.shade700, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      TextInputType tipo, bool isPassword) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && _hide,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pink),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, color: Colors.pink),
                onPressed: () => setState(() => _hide = !_hide))
            : null,
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.pink, width: 2)),
      ),
    );
  }
}