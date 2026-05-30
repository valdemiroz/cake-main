import 'package:flutter/material.dart';
import 'perfil_pagina.dart';
import 'bolos_pagina.dart';
import '../conta/pedidos_pagina.dart';
import 'pepito.dart';
import 'package:url_launcher/url_launcher.dart';

class Suporte extends StatefulWidget {
  @override
  State<Suporte> createState() => _SuporteState();
}

class _SuporteState extends State<Suporte> {
  bool mostrarSobre = false;
  bool mostrarEndereco = false;

  Future<void> abrirWhatsapp() async {
    final Uri url = Uri.parse(
      'https://wa.me/5551991628190',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> abrirMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/place/QI+Faculdade+e+Escola+T%C3%A9cnica+-+Canoas/@-29.9041797,-51.1788828,19z/data=!4m15!1m8!3m7!1s0x95197aa7ee67b891:0x39995d5fc0419785!2sAv.+Victor+Barreto+-+Centro,+Canoas+-+RS,+92010-000!3b1!8m2!3d-29.9135048!4d-51.1821502!16s%2Fg%2F1ymx70qr2!3m5!1s0x95197aa082c34d17:0x9f37f87b90b37665!8m2!3d-29.9041481!4d-51.1781234!16s%2Fg%2F11gzt7wnp?entry=ttu&g_ep=EgoyMDI2MDUyNy4wIKXMDSoASAFQAw%3D%3D',
    ); // Localização da Faculdade & Escola técnica QI

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Abrir URL do Google Maps
    }
  }

  // Barra do aplicativo (topo)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.pink,
      toolbarHeight: 80.0,
      elevation: 5,
      shadowColor: Colors.pink.shade900,
      title: Center(child: Text('Central de Suporte', style: TextStyle(shadows: [Shadow(offset: Offset(2, 1),blurRadius: 0,color: Colors.black,),],color: Colors.white),)),
      leading: IconButton(padding: EdgeInsets.only(left: 16.0, right: 8.0),

      // Perfil
      icon: Icon(Icons.person, color: Colors.white, size: 40),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilPagina()));
      },),
      
      // Menu lateral
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 16.0, left: 8.0),
            icon: Icon(Icons.list, color: Colors.white, size: 45),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Menu',
                barrierColor: Colors.pink.withOpacity(0.35),
                transitionDuration: Duration(milliseconds: 300),
                transitionBuilder: (context, animation, secondaryAnimation, child) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                  position: Tween<Offset>(
                  begin: Offset(0, -0.15),
                  end: Offset.zero,).animate(curvedAnimation),child: child,),);},
                  pageBuilder: (context, animation, secondaryAnimation) {

                  return Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.pink,borderRadius: BorderRadius.circular(20),image: DecorationImage(image: AssetImage('assets/images/confetti.png'),fit: BoxFit.cover,),),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center,children: [

                  Text('CONFIGURAÇÕES', style: TextStyle(shadows: [Shadow(offset: Offset(2, 1),blurRadius: 0,color: Colors.black,),],fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none)),],),SizedBox(height: 16),

                  TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Pepito()));}, child: Text('Pepito IA', style: TextStyle(fontSize: 22, decoration: TextDecoration.none, color: Colors.white))),
                  TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => PedidosPagina()));}, child: Text('Seus pedidos', style: TextStyle(fontSize: 22, decoration: TextDecoration.none, color: Colors.white))),
                  TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => BolosPagina()));}, child: Text('Agendar pedido', style: TextStyle(fontSize: 22, decoration: TextDecoration.none, color: Colors.white))),
                  TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Suporte()));}, child: Text('Suporte', style: TextStyle(fontSize: 22, decoration: TextDecoration.none, color: Colors.white))),],),),

        // bolo decorativo
                  SizedBox(height: 16),

                  Opacity(opacity: 0.8,child: Image.asset('assets/images/bolo.png', width: 250, height: 250),),

                  SizedBox(height: 16),

        // botão de acessar conta
        Container(width: MediaQuery.of(context).size.width * 0.85,padding: EdgeInsets.symmetric(vertical: 10),decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(10),),child: 
        TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilPagina()));},

        child: Text('Acessar sua conta', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),),),],),);},);},),],),

      body: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          image: DecorationImage(
            opacity: 0.3,
            image: AssetImage('assets/images/confetti.png'), // decoração da caixa de menu
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
  Icon(
    Icons.help_outline,
    size: 100,
    color: Colors.pink.shade400,
  ),

  SizedBox(height: 20),

  Text(
    'Suporte e Dúvidas',
    style: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.pink.shade700,
    ),
  ),

  SizedBox(height: 10),

  Text(
    'Tire suas dúvidas e entre em contato conosco!',
    style: TextStyle(
      fontSize: 16,
      color: Colors.pink.shade600,
    ),
    textAlign: TextAlign.center,
  ),

  SizedBox(height: 40),

  // Botão de fale conosco, o qual abre o Whatsapp
  SizedBox(
    width: 250,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: abrirWhatsapp,
      icon: Icon(Icons.chat, color: Colors.white),
      label: Text(
        'Fale Conosco',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  ),

  SizedBox(height: 15),

  // Botão sobre nós, falando um breve resumo da empresa
  SizedBox(
    width: 250,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () {
        setState(() {
          mostrarSobre = !mostrarSobre;
        });
      },
      icon: Icon(Icons.info, color: Colors.white),
      label: Text(
        'Sobre Nós',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  ),

  if (mostrarSobre)
    Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(15),
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Text(
        'Somos uma confeitaria especializada em bolos artesanais, '
        'trabalhando com ingredientes selecionados para tornar seus '
        'momentos ainda mais especiais.',
        textAlign: TextAlign.center,
      ),
    ),

  SizedBox(height: 15),

  // Botão de endereço, abre o Google Maps
  SizedBox(
    width: 250,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () {
        setState(() {
          mostrarEndereco = !mostrarEndereco;
        });
      },
      icon: Icon(Icons.location_on, color: Colors.white),
      label: Text(
        'Endereço',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  ),

  if (mostrarEndereco)
    Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(15),
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Av. Victor Barreto, 780 - Mathias Velho, Canoas - RS, 92010-000',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          Text(
            'Clique abaixo para abrir a localização no Google Maps.',
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: abrirMaps,
            icon: Icon(Icons.map),
            label: Text('Abrir no Maps'),
          ),
        ],
      ),
    ),
],),),),);
  }
}
