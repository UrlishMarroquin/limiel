import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/db/db_admin.dart';
import 'package:limielapp/models/pedido_model.dart';
import 'package:limielapp/pages/order_page.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';

class PointPage extends StatefulWidget{ 
  @override
  _PointPageState createState() => _PointPageState();
}  

class _PointPageState extends State<PointPage> {

  CollectionReference usuariosReference =
      FirebaseFirestore.instance.collection("usuarios");     
  CollectionReference codigosReference =
      FirebaseFirestore.instance.collection("codigos");      
  
  List<PedidoModel> pedidos = [];
  TextEditingController searchController = TextEditingController();
  String displayedValue = "Reclamar Código";
  double costoCompra = 0.0;
  int puntos = 0;
  int canje = 0;
  String usuario = "";
  
  Future<void> fetchChange(String codigo) async {
    final providerUser = Provider.of<UserProvider>(context, listen: false);
    try{
      QuerySnapshot codigoCollection = await codigosReference
          .where("codigo", isEqualTo: codigo)
          .limit(1)
          .get();

    if (codigoCollection.docs.isEmpty) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'No hay puntos para el código: $codigo',
          ),
        ),
      );
      return; 
    }

    QueryDocumentSnapshot docs = codigoCollection.docs.first;

    if (!docs["estado"]) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'El código "$codigo", ya fue canjeado',
          ),
        ),
      );
      return; 
    }else{
      canje = docs["punto"];
      setState(() {
        puntos = puntos + canje;
      });   
      providerUser.punto = puntos;
      updateChange(docs.id, false);
      updateUsers(puntos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Felicidades por canjear el código "$codigo"',
          ),
        ),
      );
      return;      
    }

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Un error inesperado ocurrio: ${error.toString()}',
          ),
        ),
      );
      print(error.toString());
    }
  }

  Future<void> updateUsers(int cantidad) async {
    final providerUser = Provider.of<UserProvider>(context, listen: false);
    usuariosReference.doc(providerUser.id).update(
      {
        "punto": cantidad,
      },
    );
  }  

  Future<void> updateChange(String id, bool estado) async {
    codigosReference.doc(id).update(
      {
        "estado": estado,
      },
    );
  }  

  @override
  void initState() {
    super.initState();
    
    setState(() {
      final providerUser = Provider.of<UserProvider>(context, listen: false);
      puntos = providerUser.punto;
    }); 
  }

  Widget busquedaWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Ingresa el código",
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
              fetchChange(searchController.text);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(    
        appBar: AppBar(
          title: const Text("Consigue Puntos"),
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
            child: SingleChildScrollView(
              child: Column(
              children: [                       
                const SizedBox(
                  height: 0,
                ),
                busquedaWidget(),
                const SizedBox(
                  height: 16,
                ),
                Text("Consigue puntos ingresando los códigos que se envian por whatsapp al realizar la confirmación de la compra", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),                    
                const SizedBox(
                  height: 16,
                ),   
                const Text("Puntos obtenidos", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),                    
                const SizedBox(
                  height: 0,
                ),
                Text("$puntos", style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),                    
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          )
        )
      )
    );
  }
}
