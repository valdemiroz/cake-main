import 'package:cakemain/paginas/perfil_pagina.dart';
import 'package:flutter/material.dart';
import '/dados/auth_service.dart';
import 'bolos_pagina.dart';
import '/conta/pedidos_pagina.dart';
import 'suporte.dart';
import '/paginas/admin_paginas/adm.dart';

class Pepito extends StatefulWidget {
  const Pepito({super.key});

  @override
  State<Pepito> createState() => _PepitoState();
}

class _PepitoState extends State<Pepito> {
  // ignore: unused_field (Ignora função não-usada)
  final _auth = AuthService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _mensagens = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _adicionarMensagemBot(
        "Olá! Eu sou o Pepito, seu assistente virtual da CakeMain.\n\nComo posso te ajudar hoje?");
  }

  void _adicionarMensagemBot(String texto) {
    setState(() {
      _mensagens.add({"tipo": "bot", "texto": texto});
    });
  }

  Future<void> _enviarMensagem() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add({"tipo": "user", "texto": texto});
      _isTyping = true;
    });
    _controller.clear();

    // Simula o pensamento 
    await Future.delayed(const Duration(milliseconds: 800));

    String resposta = _gerarResposta(texto.toLowerCase());

    setState(() {
      _mensagens.add({"tipo": "bot", "texto": resposta});
      _isTyping = false;
    });
  }

  // Possíveis respostas do Pepito (se houver um item de cada)
  String _gerarResposta(String msg) {
    if (msg.contains("contato") || msg.contains("whatsapp") || msg.contains("conversar")) {
      return "Caso você queira um contato com a empresa, aqui vai o número!.\n\n"
          "+55 51991628190 (número de WhatsApp)";
    }

  if (msg.contains("pedido") || msg.contains("ver pedido") || msg.contains("andamento")) {
      return "Para ver o seu pedido, basta clicar em ''meus pedidos'' e verificar tudo o que você realizou dentro do App. \n\n"
      "Caso não contenha nada, você pode fazer seu pedido manualmente em ''fazer bolo'' e aproveitar a variedade dos nossos produtos!";
    }

    if (msg.contains("cancelar") || msg.contains("cancelamento")) {
      return "Para cancelar um pedido, vá em Meus Pedidos, toque no pedido desejado e escolha a opção 'Cancelar Pedido'.\n\n"
          "Lembre-se: cancelamentos só são possíveis enquanto o status estiver 'Pendente'.";
    }

    if (msg.contains("pagamento") || msg.contains("pagar")) {
      return "Aceitamos as seguintes formas de pagamento:\n\n"
          "• Cartão de Crédito\n"
          "• PIX\n"
          "• Dinheiro (na entrega)";
    }

    if (msg.contains("reembolso") || msg.contains("devolver dinheiro")) {
      return "O reembolso é permitido apenas quando atingir os seguintes critérios: \n\n"
          "• Não é o seu pedido\n"
          "• O pedido foi realizado em menos de 24 horas\n"
          "• O estado do bolo/item é inadequado ou indesejado pelo cliente. \n\n"
          "Portanto, caso atinja um desses critérios, entre em contato conosco pelo WhatsApp para solicitar seu reembolso: \n"
          "+55 51991628190 (número de WhatsApp)";
    }

    if (msg.contains("montagem") || msg.contains("marcar tudo")|| msg.contains("dúvida em montar")) {
      return "Os bolos podem ser montados à sua maneira, conforme você seleciona um item de nosso cardápio. \n"
      "Há muitas opções de montagem, desde que você marque todas as categorias (tipo de bolo, tamanho, recheio, cobertura, sabor e adicionais), que podem ser desfrutadas!";
    }

    // Caso fora dos itens listados acima
    return "Desculpe, tente elaborar uma pergunta relacionada ao App. No que deseja? \n\n"
          "Quer ajuda com:\n• Fazer um pedido?\n• Acompanhar seus pedidos?\n• Cancelamento?\n• Formas de pagamento?";
  }

  // Pepito como uma "mini I.A." simulando conversa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.pink.shade50,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _mensagens.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _mensagens.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text("Pepito está digitando...", style: TextStyle(color: Colors.grey)), 
                      ),
                    );
                  }

                  final msg = _mensagens[index];
                  final bool isUser = msg["tipo"] == "user";

                  return Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Image.asset('assets/images/pepitoz.png', width: 42, height: 42), // Foto do Pepito
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.pink : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            msg["texto"],
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 50), // espaço para alinhar
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Digite sua mensagem...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _enviarMensagem(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.pink,
                  onPressed: _enviarMensagem,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Barra do aplicativo (topo)
  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.pink,
      toolbarHeight: 80,
      elevation: 5,
      shadowColor: Colors.pink.shade900,
      leading: IconButton(
        padding: const EdgeInsets.only(left: 16),
        icon: const Icon(Icons.person, color: Colors.white, size: 40),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilPagina())),
      ),
      title: const Center(
        child: Text('Pepito IA', style: TextStyle(color: Colors.white)),
      ),
      actions: [
        IconButton(
          padding: const EdgeInsets.only(right: 16),
          icon: const Icon(Icons.list, color: Colors.white, size: 45),
          onPressed: () => _abrirMenu(context),
        ),
      ],
    );
  }

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
}

// Menu lateral - lógica
class _MenuContent extends StatefulWidget {
  final BuildContext context;
  const _MenuContent({required this.context});

  @override
  State<_MenuContent> createState() => _MenuContentState();
}

  // Processo de admin com senha
class _MenuContentState extends State<_MenuContent> {
  Future<void> _pedirSenhaAdmin(BuildContext ctx) async {
    final ctrl = TextEditingController();
    bool hide  = true;
    String? erro;

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
      Navigator.pop(dialogCtx); // fecha o diálogo de senha
      Navigator.pop(menuCtx);  // fecha o menu
      Navigator.push(
          widget.context, MaterialPageRoute(builder: (_) => AdminPagina()));
    } else {
      setD(() => setErro('Senha incorreta. Tente novamente.'));
    }
  }
// demais itens do menu lateral
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

            _btn('Pepito IA',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Pepito()))),
            _btn('Seus pedidos',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => PedidosPagina()))),
            _btn('Agendar pedido',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => BolosPagina()))),
            _btn('Suporte',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Suporte()))),

            Divider(color: Colors.white38, height: 24),

            // Botão admin
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
        Opacity(opacity: 0.8,
            child: Image.asset('assets/images/bolo.png', width: 250, height: 250)),
        SizedBox(height: 16),

        // Botão de acessar conta
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
    onPressed: () { Navigator.pop(context); action(); },
    child: Text(label,
        style: TextStyle(fontSize: 22, decoration: TextDecoration.none, color: Colors.white)),
  );
}
