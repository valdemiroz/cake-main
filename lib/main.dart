import 'package:flutter/material.dart'; // acesso ao material decorativo do FLutter
import 'paginas/perfil_pagina.dart'; // página de perfil
import 'package:url_launcher/url_launcher.dart'; // permite rodar links globais
import 'paginas/bolos_pagina.dart'; // página de montagem dos pedidos
import 'conta/pedidos_pagina.dart'; // página de pedidos do usuário
import 'paginas/pepito.dart'; // mini I.A. "Pepito"
import 'paginas/suporte.dart'; // página de suporte
import 'package:hive_flutter/hive_flutter.dart'; // banco de dados - HIVE
import 'dados/auth_service.dart'; // banco de dados - autenticação do usuário
import 'dados/catalogo_service.dart'; // banco de dados - bolos e demais produtos
import 'paginas/admin_paginas/adm.dart'; // página de admin

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
   // Aqui é onde carregam os usuários, pedidos e catálogo antes mesmo do usuário entrar no App
  await Hive.initFlutter();
  await Hive.openBox('usuarios');
  await Hive.openBox('pedidos');   
  await Hive.openBox('catalogo');

  // Cria admin padrão e opções de catálogo na primeira execução
  await AuthService().criarAdminPadrao();
  await CatalogoService().inicializar();

  runApp(CakeApp());
}

class CakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cake Main',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: TelaCake(),
    );
  }
}

class TelaCake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra do aplicativo (Topo da tela)
      appBar: AppBar(
        backgroundColor: Colors.pink,
        toolbarHeight: 80.0,
        elevation: 5,
        shadowColor: Colors.pink.shade900,
        title: Center(
          child: Text('Seja bem vindo!',
              style: TextStyle(
                  shadows: [Shadow(offset: Offset(2, 1), blurRadius: 0, color: Colors.black)],
                  color: Colors.white)),
        ),
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 8.0),
          icon: Icon(Icons.person, color: Colors.white, size: 40),
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => PerfilPagina())), // Botão de perfil
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 16.0, left: 8.0),
            icon: Icon(Icons.list, color: Colors.white, size: 45),
            onPressed: () => _abrirMenu(context),
          ),
        ],
      ),

      // Corpo da página
      body: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          image: DecorationImage(
              opacity: 0.5,
              image: AssetImage('assets/images/confetti.png'), // fundo da página
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('CAKE MAIN',
                        style: TextStyle(
                            shadows: [Shadow(offset: Offset(1, 5), blurRadius: 0, color: Colors.pink.shade500)], 
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  ), // título da tela
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.75,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      // Botões da tela - Fazer pedido, Ver pedidos, Suporte e Pepito
                      children: [
                        _buildButtonCard(context, 'Faça seu bolo', 'assets/images/icon1.png',
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => BolosPagina()))), 
                        _buildButtonCard(context, 'Ver pedidos', 'assets/images/icon2.png',
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => PedidosPagina()))),
                        _buildButtonCard(context, 'Suporte', 'assets/images/icon3.png',
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => Suporte()))),
                        _buildButtonCard(context, 'Dúvidas/FAQ', 'assets/images/icon4.png',
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => Pepito()))),
                      ],                    ),
                  ),
                  SizedBox(height: 40),
                ]),
              ),
            ),

            // Rodapé (parte inferior da tela)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.pink,
                boxShadow: [BoxShadow(color: Colors.pink.shade900, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                    icon: Icon(Icons.message, color: Colors.white, size: 30),
                    onPressed: () => _launchURLGlobal(context, 'https://wa.me/5551991628190'), // Link do whatsapp
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.facebook, color: Colors.white, size: 30),
                    onPressed: () => _launchURLGlobal(context, 'https://www.facebook.com/lipao.yt.31'), // Link do facebook
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                    onPressed: () => _launchURLGlobal(context, 'https://www.instagram.com/1whitedud/'), // Link do instagram
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    onPressed: () =>
                        _launchURLGlobal(context, 'https://www.youtube.com/@Whatdoiputhereinthisthing'), // Link do youtube
                  ),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.copyright, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text('CakeMain 2026, todos os direitos reservados.',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // Menu lateral (canto superior direito da tela)
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
// Abertura do menu
class _MenuContent extends StatefulWidget {
  final BuildContext context;
  const _MenuContent({required this.context});

  @override
  State<_MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<_MenuContent> {
  
  // Senha do admin - lógica
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        
        // Outros itens do menu - Fazer pedido, Ver pedidos, Pepito, Suporte e Acessar conta
        
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: AssetImage('assets/images/confetti.png'), fit: BoxFit.cover), // Fundo da caixa de menu
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

            // Itens do menu decorado
            _btn('Pepito IA',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Pepito()))),
            _btn('Seus pedidos',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => PedidosPagina()))),
            _btn('Agendar pedido',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => BolosPagina()))),
            _btn('Suporte',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => Suporte()))),

            Divider(color: Colors.white38, height: 24),

            // Botão do Admin
            
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
            child: Image.asset('assets/images/bolo.png', width: 250, height: 250)), // Bolo decorativo no menu
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

// LINKS GLOBAIS - Lógica
void _launchURLGlobal(BuildContext context, String url) async {
  final Uri uri = Uri.parse(url);
  try {
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Não foi possível abrir o link: $url')));
    }
  } catch (e) {
    debugPrint('Erro ao abrir URL: $e');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Erro ao abrir o link')));
  }
}

Widget _buildButtonCard(
  BuildContext context,
  String label,
  String imagePath,
  VoidCallback onTap,
) {
  final larguraTela = MediaQuery.of(context).size.width;

  return GestureDetector(
    onTap: onTap,
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 1),
                        blurRadius: 0,
                        color: Colors.pink.shade500,
                      ),
                    ],
                    fontSize: larguraTela < 400 ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 188, 143),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
