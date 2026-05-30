import 'package:flutter/material.dart';
import '/dados/auth_service.dart';
import 'cadastro_perfil.dart';

class LoginPerfil extends StatefulWidget {
  @override
  State<LoginPerfil> createState() => _LoginPerfilState();
}

class _LoginPerfilState extends State<LoginPerfil> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _auth      = AuthService();
  bool _loading    = false;
  bool _hide       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text.trim();
    if (email.isEmpty || senha.isEmpty) { _snack('Preencha todos os campos.'); return; }

    setState(() => _loading = true);
    final erro = await _auth.login(email, senha);
    setState(() => _loading = false);

    if (erro != null) {
      _snack(erro);
    } else {
      // Volta até a raiz do Navigator (TelaCake)
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        toolbarHeight: 80,
        elevation: 5,
        shadowColor: Colors.pink.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text('Entrar na conta',
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
              Image.asset('assets/images/bolo.png', width: 140, height: 140),
              SizedBox(height: 20),
              Text('Bem-vindo de volta!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pink.shade700)),
              SizedBox(height: 32),
              _field(_emailCtrl, 'E-mail', Icons.email, TextInputType.emailAddress, false),
              SizedBox(height: 14),
              _field(_senhaCtrl, 'Senha',  Icons.lock,  TextInputType.text,         true),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Entrar',
                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 18),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => CadastroPerfil())),
                child: Text('Não tem conta? Cadastre-se',
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