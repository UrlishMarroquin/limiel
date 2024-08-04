import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/db/db_admin.dart';
import 'package:limielapp/models/canje_model.dart';
import 'package:limielapp/widgets/canje_widget.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';

class ChangePage extends StatefulWidget{
  @override
  _ChangePageState createState() => _ChangePageState();
}  

class _ChangePageState extends State<ChangePage> {

  CollectionReference canjesReference =
      FirebaseFirestore.instance.collection("canjes");     
  
  List<CanjeModel> canjesList = [];
  TextEditingController searchController = TextEditingController();
  String displayedValue = "Completar Pedido";
  double costoCompra = 0.0;
  int puntitos = 0;

  @override
  void initState() {
    super.initState();
    fetchAndStoreUsers();
  }

  Future<void> fetchAndStoreUsers() async {
    try {
      final dbHelper = DBAdmin();
      await dbHelper.vaciarPedidos();

      QuerySnapshot canjeCollection = await canjesReference.get();
      List<QueryDocumentSnapshot> docs = canjeCollection.docs;
      
      canjesList = [];
      for (var doc in docs) {
        CanjeModel promo = CanjeModel(
          nombre: doc["nombre"],
          puntos: doc["punto"],
        );        
        canjesList.add(promo);
      }
      setState(() {});        
    } catch (e) {
      print('Error fetching or storing users: $e');
    }
  }

  Future<void> searchByName(String name) async {
    try {
      QuerySnapshot canjeCollection = await canjesReference.get();      
      List<QueryDocumentSnapshot> docs = canjeCollection.docs;
      
      canjesList = [];
      for (var doc in docs) {
        if(doc["nombre"].toString().toUpperCase().contains(name.toUpperCase())){
          CanjeModel promo = CanjeModel(
            nombre: doc["nombre"],
            puntos: doc["punto"],
          );        
          canjesList.add(promo);
        }
      }
      setState(() {});        
    } catch (e) {
      print('Error fetching or storing users: $e');
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
        title: const Text("Productos para Canjear"),
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
              busquedaWidget(),
              const SizedBox(
                height: 8,
              ),
              StreamBuilder<int>(
                stream: getPointsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return Text("Puntos obtenidos:\n0", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,);
                  }
                  int puntos = snapshot.data!;
                  if(puntitos != puntos){
                    searchByName(searchController.text);
                  }
                  puntitos = puntos;
                  return Text("Puntos obtenidos:\n$puntos", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,);
                },
              ),              
              const SizedBox(
                height: 8,
              ),              
              CanjeList(canjesList: canjesList, puntitos: puntitos),
            ],
          ),
      )
    );
  }

  Stream<int> getPointsStream() {
    final providerUser = Provider.of<UserProvider>(context);

    return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(providerUser.id)
      .snapshots()
      .map((snapshot) => snapshot.data()?['punto'] ?? 3);
  }
}

class CanjeList extends StatelessWidget {

  final List<CanjeModel> canjesList;
  final int puntitos;

  CanjeList({
    required this.canjesList, 
    required this.puntitos,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          ...canjesList.map(
            (e) => CanjeWidget(
              nombre: e.nombre,
              puntos: e.puntos,
              puntitos: puntitos,
            ),
          ),
        ],
      ),
      ),
    );
  }
} 