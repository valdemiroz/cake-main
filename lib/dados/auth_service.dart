import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _boxName   = 'usuarios';
  static const String _sessionKey = 'usuario_logado';

  Box get _box => Hive.box(_boxName);

  // ── Cadastro ──────────────────────────────────────────────────────────────
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String telefone = '',
  }) async {
    if (_box.containsKey(email)) return 'E-mail já cadastrado.';
    await _box.put(email, {
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
      'isAdmin': false,
      'dataCadastro': DateTime.now().toIso8601String(),
    });
    return null; // null = sucesso
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<String?> login(String email, String senha) async {
    final data = _box.get(email);
    if (data == null) return 'Usuário não encontrado.';
    final usuario = Map<String, dynamic>.from(data);
    if (usuario['senha'] != senha) return 'Senha incorreta.';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
    return null;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── Sessão atual ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    final data = _box.get(email);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // ── Atualizar dados ───────────────────────────────────────────────────────
  Future<void> atualizarUsuario(String email, Map<String, dynamic> dados) async {
    final data = _box.get(email);
    if (data == null) return;
    final usuario = Map<String, dynamic>.from(data)..addAll(dados);
    await _box.put(email, usuario);
  }

  // ── Excluir conta ─────────────────────────────────────────────────────────
  Future<void> deletarConta(String email) async {
    await _box.delete(email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── Listar todos (admin) ──────────────────────────────────────────────────
  List<Map<String, dynamic>> listarTodos() =>
      _box.values.map((e) => Map<String, dynamic>.from(e)).toList();

  // ── Admin padrão (criado na primeira execução) ────────────────────────────
  Future<void> criarAdminPadrao() async {
    if (_box.containsKey('admin@cakemain.com')) return;
    await _box.put('admin@cakemain.com', {
      'nome': 'Administrador',
      'email': 'admin@cakemain.com',
      'senha': 'admin123',
      'telefone': '',
      'isAdmin': true,
      'dataCadastro': DateTime.now().toIso8601String(),
    });
  }
}