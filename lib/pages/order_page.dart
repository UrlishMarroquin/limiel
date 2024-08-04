import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/db/db_admin.dart';
import 'package:limielapp/models/pedido_model.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget{
  final String value;
  final double costo;
  OrderPage({required this.value, required this.costo});
  
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  CollectionReference productosReference =
      FirebaseFirestore.instance.collection("productos");     
  
  List<PedidoModel> pedidos = [];
  TextEditingController searchController = TextEditingController();
  late String displayedValue;
  late double costoCompra = 0.0;
  String productos = "";
  List<String> pedidosJuntos = [];

  @override
  void initState() {
    super.initState();
    costoCompra = widget.costo;
    displayedValue = "Generar Pedido: S/. $costoCompra";
    searchByAmount(0);
  }

  Future<void> searchByAmount(int cantid) async {
    try {
      final dbHelper = DBAdmin();
      List<PedidoModel> result = await dbHelper.buscarPedidosPorCantidad(cantid);

      pedidosJuntos = result.map((pedido) {
        return '${pedido.nombre}: ${pedido.cantid}';
      }).toList();      
      setState(() {
        pedidos = result;
      });
    } catch (e) {
      print('Error searching users: $e');
    }
  }

  Future<void> _launchUrl() async {
    
    final String phone = '51943204706';
    final String message = pedidosJuntos.join(', ') + " precio: S/.$costoCompra";
    final Uri url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          print("amigos");
          Navigator.pop(context, costoCompra);
          return false;
        },
        child: Scaffold(    
        appBar: AppBar(
        title: const Text("Orden de Pedido"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print("amigos");
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
                onPressed: () {
                  if (costoCompra != 0.0) {
                    _launchUrl();
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        behavior: SnackBarBehavior.floating,
                        content: const Text(
                          "Tiene que tener productos para un pedido",
                        ),
                      ),
                    );

                  }                  
                },                
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
                height: 8,
              ),
              Expanded(
                child: pedidos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: Image.network(pedidos[index].imagen, height: 40, width: 40,),
                          title: Text(pedidos[index].nombre),
                          subtitle: Text("Precio: ${pedidos[index].precio} soles"),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [ 
                              Text(
                                "${pedidos[index].cantid}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                )
                              ),
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.delete_sharp, size: 18, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Eliminar'),
                                          content: Text('Se desea eliminar ${pedidos[index].cantid} de ${pedidos[index].nombre}'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Aceptar'),
                                              onPressed: () {
                                                DBAdmin().updPedido(
                                                  pedidos[index].id, 0
                                                ).then((value) {
                                                  Navigator.of(context).pop();
                                                  searchByAmount(0);                                             
                                                  setState(() {
                                                    costoCompra = costoCompra - (pedidos[index].precio * pedidos[index].cantid);
                                                    displayedValue = "Generar Pedido: S/. $costoCompra";
                                                  });
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Cerrar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ]
                          )
                        )
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}
