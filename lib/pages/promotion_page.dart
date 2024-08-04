import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/db/db_admin.dart';
import 'package:limielapp/models/promo_model.dart';
import 'package:limielapp/widgets/promos_widget.dart';

class PromotionPage extends StatefulWidget{
  @override
  _PromotionPageState createState() => _PromotionPageState();
}  

class _PromotionPageState extends State<PromotionPage> {

  CollectionReference promocionesReference =
      FirebaseFirestore.instance.collection("promociones");     
  
  List<PromoModel> promosList = [];
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

      QuerySnapshot userCollection = await promocionesReference.get();
      List<QueryDocumentSnapshot> docs = userCollection.docs;
      
      promosList = [];
      for (var doc in docs) {
        PromoModel promo = PromoModel(
          nombre: doc["nombre"],
          mensaj: doc["mensaje"],
          precio: doc["precio"],
          imagen: doc["imagen"],
        );        
        promosList.add(promo);
      }
      setState(() {});        
    } catch (e) {
      print('Error fetching or storing users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      appBar: AppBar(
        title: const Text("Lista de Promociones"),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
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
            PromoList(promosList: promosList),              
          ],
        ),
      )
    );
  }
}

class PromoList extends StatelessWidget {

  final List<PromoModel> promosList;

  PromoList({required this.promosList});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          ...promosList.map(
            (e) => PromoWidget(
              nombre: e.nombre,
              mensaj: e.mensaj,
              precio: e.precio,
              imagen: e.imagen,
            ),
          ),
        ],
      ),
      ),
    );
  }
} 