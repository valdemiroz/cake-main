// ignore_for_file: unnecessary_type_check

import 'package:hive_flutter/hive_flutter.dart';

class CatalogoService {
  static const String _boxName = 'catalogo';
  static const String _key = 'opcoes';
  static const String _andaresKey = 'andares_precos';

  Box get _box => Hive.box(_boxName);

  // ── Checks for tipo properties ─────────────────────────────────────────
  bool isBoloDeAndar(String nomeTipo) {
    final tipos = getOpcoesComDescricao()['tipos'] ?? [];
    for (final item in tipos) {
      if (item is Map && item['nome'] == nomeTipo) {
        final valor = item['boloDeAndar'];
        return valor == 'true' || valor == true;
      }
    }
    return false;
  }

  bool podeUsarImagens(String nomeTipo) {
    final tipos = getOpcoesComDescricao()['tipos'] ?? [];
    for (final item in tipos) {
      if (item is Map && item['nome'] == nomeTipo) {
        final valor = item['podeUsarImagens'];
        return valor == 'true' || valor == true;
      }
    }
    return false;
  }

  // ── Default catalogue data ─────────────────────────────────────────────
  static const Map<String, List<Map<String, String>>> _defaults = {
    'tipos': [
      {'nome': 'Tradicional', 'descricao': 'O clássico bolo em camadas, coberto e recheado.', 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Naked Cake',  'descricao': 'Bolo sem cobertura nas laterais, visual rústico.', 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Bento Cake',  'descricao': 'Mini bolo individual, ideal para presentes.',      'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Mousse',      'descricao': 'Bolo aerado e leve, textura cremosa.',             'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
    ],
    'tamanhos': [
      {'nome': 'Pequeno (15cm)', 'descricao': 'Serve até 10 fatias.', 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Médio (20cm)',   'descricao': 'Serve até 20 fatias.', 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Grande (25cm)',  'descricao': 'Serve até 35 fatias.', 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Festa (30cm)',   'descricao': 'Serve até 50 fatias.', 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
    ],
    'sabores': [
      {'nome': 'Chocolate', 'descricao': 'Massa úmida de chocolate belga, intensa.',        'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Baunilha',  'descricao': 'Massa delicada com extrato de baunilha.',         'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Morango',   'descricao': 'Massa frutada com pedaços de morango fresco.',    'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Laranja',   'descricao': 'Massa com sabor intenso de laranja fresca.',      'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Limão',     'descricao': 'Massa cítrica e refrescante.',                    'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Coco',      'descricao': 'Massa úmida com coco ralado.',                    'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
    ],
    'coberturas': [
      {'nome': 'Brigadeiro',          'descricao': 'Cobertura cremosa de brigadeiro.',             'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Chantilly',           'descricao': 'Cobertura leve e aerada.',                     'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Ganache Branco',      'descricao': 'Cobertura de chocolate branco cremoso.',       'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Ganache Meio Amargo', 'descricao': 'Cobertura intensa de chocolate.',             'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Pasta Americana',     'descricao': 'Cobertura moldável para decorações.',         'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
    ],
    'recheios': [
      {'nome': 'Ninho',        'descricao': 'Recheio cremoso de leite em pó Ninho.',        'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Nutella',      'descricao': 'Recheio de creme de avelã com chocolate.',     'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Morango',      'descricao': 'Recheio com morangos frescos.',                'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Doce de Leite','descricao': 'Recheio cremoso de doce de leite.',            'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Maracujá',     'descricao': 'Recheio cítrico de maracujá.',                 'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
      {'nome': 'Limão',        'descricao': 'Recheio de creme de limão siciliano.',         'imagem': '', 'preco': '', 'boloDeAndar': 'false', 'podeUsarImagens': 'false'},
    ],
    // ── NEW: Outros (extras / add-ons) ─────────────────────────────────────
    'outros': [],
  };

  // ── Andares pricing ────────────────────────────────────────────────────
  Map<int, double> getPrecosAndares() {
    final dados = _box.get(_andaresKey);
    if (dados is Map) {
      return {
        1: (dados['1'] ?? 0).toDouble(),
        2: (dados['2'] ?? 0).toDouble(),
        3: (dados['3'] ?? 0).toDouble(),
        4: (dados['4'] ?? 0).toDouble(),
      };
    }
    return {1: 0, 2: 50, 3: 100, 4: 150};
  }

  Future<void> salvarPrecoAndar(int andar, double preco) async {
    final atuais = getPrecosAndares();
    atuais[andar] = preco;
    await _box.put(_andaresKey, {
      '1': atuais[1],
      '2': atuais[2],
      '3': atuais[3],
      '4': atuais[4],
    });
  }

  double obterPrecoAndar(int? andar) {
    if (andar == null) return 0;
    return getPrecosAndares()[andar] ?? 0;
  }

  // ── Initialisation ─────────────────────────────────────────────────────
  Future<void> inicializar() async {
    if (!_box.containsKey(_key)) {
      await _box.put(_key, _deepCopy(_defaults));
      return;
    }
    // Ensure the 'outros' key exists in already-initialised boxes
    final data = _box.get(_key) as Map? ?? {};
    if (!data.containsKey('outros')) {
      data['outros'] = <Map<String, String>>[];
      await _box.put(_key, data);
    }
  }

  Future<void> resetarParaPadrao() async {
    await _box.put(_key, _deepCopy(_defaults));
  }

  Map<String, List<Map<String, String>>> _deepCopy(
      Map<String, List<Map<String, String>>> source) {
    return source.map((key, list) =>
        MapEntry(key, list.map((item) => Map<String, String>.from(item)).toList()));
  }

  // ── Read helpers ───────────────────────────────────────────────────────
  Map<String, List<String>> getOpcoes() {
    final data = _box.get(_key) as Map? ?? {};
    final Map<String, List<String>> result = {};
    data.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = value
            .map((item) =>
                (item is Map ? item['nome']?.toString() ?? '' : ''))
            .toList();
      }
    });
    return result;
  }

  Map<String, List<Map<String, String>>> getOpcoesComDescricao() {
    final data = _box.get(_key) as Map? ?? {};
    final Map<String, List<Map<String, String>>> result = {};
    data.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = value
            .where((item) => item is Map)
            .map((item) => Map<String, String>.from(item as Map))
            .toList();
      }
    });
    return result;
  }

  /// Returns items in the 'outros' category as full maps.
  List<Map<String, String>> getOutros() {
    return getOpcoesComDescricao()['outros'] ?? [];
  }

  double? obterPreco(String categoria, String nome) {
    final data = _box.get(_key) as Map? ?? {};
    final lista = data[categoria] as List?;
    if (lista == null) return null;
    for (final item in lista) {
      if (item is Map && item['nome'] == nome) {
        final precoTexto = (item['preco'] ?? '').toString().trim();
        if (precoTexto.isEmpty) return null;
        return double.tryParse(precoTexto.replaceAll(',', '.'));
      }
    }
    return null;
  }

  // ── Write helpers ──────────────────────────────────────────────────────
  Future<void> adicionarItem(
    String categoria,
    String nome,
    String descricao,
    String imagem,
    String preco,
    bool boloDeAndar,
    bool podeUsarImagens,
  ) async {
    final opcoes = getOpcoesComDescricao();
    opcoes.putIfAbsent(categoria, () => []);
    opcoes[categoria]!.add({
      'nome': nome.trim(),
      'descricao': descricao.trim(),
      'imagem': imagem.trim(),
      'preco': preco.trim(),
      'boloDeAndar': boloDeAndar.toString(),
      'podeUsarImagens': podeUsarImagens.toString(),
    });
    await _box.put(_key, opcoes);
  }

  Future<void> atualizarItem(
    String categoria,
    String nomeAntigo,
    String nomeNovo,
    String descricaoNova,
    String imagemNova,
    String precoNova,
    bool boloDeAndar,
    bool podeUsarImagens,
  ) async {
    final opcoes = getOpcoesComDescricao();
    final lista = opcoes[categoria];
    if (lista == null) return;
    final index = lista.indexWhere((item) => item['nome'] == nomeAntigo);
    if (index != -1) {
      lista[index] = {
        'nome': nomeNovo.trim(),
        'descricao': descricaoNova.trim(),
        'imagem': imagemNova.trim(),
        'preco': precoNova.trim(),
        'boloDeAndar': boloDeAndar.toString(),
        'podeUsarImagens': podeUsarImagens.toString(),
      };
      await _box.put(_key, opcoes);
    }
  }

  Future<void> removerItem(String categoria, String nome) async {
    final opcoes = getOpcoesComDescricao();
    final lista = opcoes[categoria];
    if (lista == null) return;
    final int antes = lista.length;
    lista.removeWhere((item) => item['nome'] == nome);
    if (lista.length < antes) {
      await _box.put(_key, opcoes);
    }
  }
}