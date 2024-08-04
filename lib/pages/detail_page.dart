import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/db/db_admin.dart';
import 'package:limielapp/models/pedido_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget{
  final String nombre;
  final String mensaj;
  final double precio;
  final String imagen;
  DetailPage({
    required this.nombre, 
    required this.mensaj,
    required this.precio,
    required this.imagen,
  });
  
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  
  List<PedidoModel> pedidos = [];
  late String displayedValue;
  late double costoCompra = 0.0;
  List<String> pedidosJuntos = [];

  @override
  void initState() {
    super.initState();
    costoCompra = widget.precio;
    displayedValue = "Generar Pedido: S/. $costoCompra";
  }

  Future<void> _launchUrl() async {
    
    final String phone = '51943204706';
    final String message = "${widget.nombre} precio: S/.$costoCompra";
    final Uri url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      appBar: AppBar(
      title: const Text("Orden de Pedido"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, costoCompra);
          },
        ),        
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 0, 120),
              Color.fromARGB(255, 0, 200, 255),
            ],
          ),
        ),
        child: Column(
          children: [                       
            const SizedBox(
              height: 0,
            ),
            ElevatedButton(
              onPressed: _launchUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ), 
                minimumSize: const Size(320, 44),               
              ),
              child: Text(
                displayedValue,
                style: const TextStyle(color: Colors.black, fontSize: 18)
              )
            ),
            const SizedBox(
              height: 16,
            ),                
            Image.network(widget.imagen, height: 200, width: 200,),
            const SizedBox(
              height: 16,
            ),
            Text(widget.nombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),                    
            const SizedBox(
              height: 16,
            ),
            Text(widget.mensaj, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal), textAlign: TextAlign.center,),                                    
          ],
        ),
      )
    );
  }
}
