import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/db/db_admin.dart';
import 'package:limielapp/models/pedido_model.dart';
import 'package:limielapp/pages/order_page.dart';

class ProductPage extends StatefulWidget{
  @override
  _ProductPageState createState() => _ProductPageState();
}  

class _ProductPageState extends State<ProductPage> {

  CollectionReference productosReference =
      FirebaseFirestore.instance.collection("productos");     
  
  List<PedidoModel> pedidos = [];
  TextEditingController searchController = TextEditingController();
  String displayedValue = "Completar Pedido";
  double costoCompra = 0.0;

  @override
  void initState() {
    super.initState();
    fetchAndStoreUsers();
  }

  Future<void> fetchAndStoreUsers() async {
    try {
      final dbHelper = DBAdmin();
      await dbHelper.vaciarPedidos();

      QuerySnapshot producCollection = await productosReference.get();
      List<QueryDocumentSnapshot> docs = producCollection.docs;
      
      List<PedidoModel> newPedidos = [];
      for (var doc in docs) {
        PedidoModel pedido = PedidoModel(
          id: 0,
          codigo: doc["codigo"],
          nombre: doc["nombre"],
          precio: doc["precio"],
          cantid: 0,
          imagen: doc["imagen"],
        );        
        await dbHelper.insertarPedido(pedido);
        newPedidos.add(pedido);
      }
      pedidos = await dbHelper.obtenerPedidos();  
      setState(() {});      
    } catch (e) {
      print('Error fetching or storing users: $e');
    }
  }

  Future<void> searchByName(String name) async {
    try {
      final dbHelper = DBAdmin();
      List<PedidoModel> result = await dbHelper.buscarPedidosPorNombre(name);

      setState(() {
        pedidos = result;
      });
    } catch (e) {
      print('Error searching users: $e');
    }
  }  

  Widget busquedaWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Buscar por título",
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.4),
            fontSize: 18,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              searchByName(searchController.text);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      appBar: AppBar(
        title: const Text("Lista de Productos"),
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
              onPressed: () async {
                if (costoCompra != 0.0) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(value: displayedValue, costo: costoCompra),
                    ),
                  );
                  if (result != null) {
                    searchByName(searchController.text);
                    setState(() {
                      costoCompra = result;
                      displayedValue = "Completar Pedido: S/. $result";               
                    });
                  }    
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      behavior: SnackBarBehavior.floating,
                      content: const Text(
                        "Tiene que elegir para completar el pedido",
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
            busquedaWidget(),
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
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.add_circle_sharp, size: 18, color: Colors.blue),
                                onPressed: () {
                                  DBAdmin().updPedido(
                                    pedidos[index].id, pedidos[index].cantid + 1
                                  ).then((value) {
                                    searchByName(searchController.text);
                                    setState(() {
                                      costoCompra = costoCompra + pedidos[index].precio;
                                      displayedValue = "Completar Pedido: S/. $costoCompra";
                                    });
                                  });                                
                                },
                              ),
                            ),
                            Text(
                              "${pedidos[index].cantid}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              )
                            ),
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.remove_circle_sharp, size: 18, color: Colors.blue),
                                onPressed: () {
                                  if(pedidos[index].cantid > 0){
                                    DBAdmin().updPedido(
                                      pedidos[index].id, pedidos[index].cantid - 1
                                    ).then((value) {
                                      searchByName(searchController.text);
                                      setState(() {
                                        costoCompra = costoCompra - pedidos[index].precio;
                                        displayedValue = "Completar Pedido: S/. $costoCompra";
                                      });                                    
                                    }); 
                                  }                               
                                },
                              ),
                            ),
                          ]
                        )
                      ),                        
                    )
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}
