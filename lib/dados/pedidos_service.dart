import 'package:hive_flutter/hive_flutter.dart';

class PedidosService {
  static const String _boxName = 'pedidos';
  Box get _box => Hive.box(_boxName);

  // ── Criar pedido ──────────────────────────────────────────────────────────
  Future<void> criarPedido({
  required String usuarioEmail,
  required String nomeCliente,
  required String telefoneCliente,
  required String tipoBolo,
  required String tamanho,
  required String sabor,
  required String cobertura,
  required String recheio,
  String observacoes = '',
  required double preco,
  required String formaPagamento,
  required String endereco,
  List<String> imagensObservacoes = const [],
  int? nivelAndares,
  List<String> outrosSelecionados = const [],
}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
  'id': id,
  'usuarioEmail': usuarioEmail,
  'nomeCliente': nomeCliente,
  'telefoneCliente': telefoneCliente,
  'tipoBolo': tipoBolo,
  'tamanho': tamanho,
  'sabor': sabor,
  'cobertura': cobertura,
  'recheio': recheio,
  'observacoes': observacoes,
  'endereco': endereco,
  'formaPagamento': formaPagamento,
  'status': 'Pendente',
  'dataPedido': DateTime.now().toIso8601String(),
  'preco': preco,
  'imagensObservacoes': imagensObservacoes,
  'nivelAndares': nivelAndares,
  'outrosSelecionados': outrosSelecionados,
});
  }

  // ── Cancelar pedido (exclui apenas pedidos Pendentes) ─────────────────────
  Future<bool> cancelarPedido(dynamic id) async {
    try {
      if (id == null) return false;
      final data = _box.get(id.toString());
      if (data == null) return false;
      final pedido = Map<String, dynamic>.from(data);
      // Guard: only allow cancelling Pending orders
      if (pedido['status'] != 'Pendente') return false;
      await _box.delete(id.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Pedidos de um usuário (ordenados por data desc) ───────────────────────
  List<Map<String, dynamic>> getPedidosDoUsuario(String email) =>
      _box.values
          .map((e) => Map<String, dynamic>.from(e))
          .where((p) => p['usuarioEmail'] == email)
          .toList()
        ..sort((a, b) => b['dataPedido'].compareTo(a['dataPedido']));

  // ── Todos os pedidos (admin) ──────────────────────────────────────────────
  List<Map<String, dynamic>> getTodosPedidos() =>
      _box.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
        ..sort((a, b) => b['dataPedido'].compareTo(a['dataPedido']));

  // ── Atualizar status ──────────────────────────────────────────────────────
  Future<void> atualizarStatus(String id, String novoStatus) async {
    final data = _box.get(id);
    if (data == null) return;
    final pedido = Map<String, dynamic>.from(data);
    pedido['status'] = novoStatus;
    await _box.put(id, pedido);
  }

  // ── Excluir pedido ────────────────────────────────────────────────────────
  Future<void> deletarPedido(String id) => _box.delete(id);
}