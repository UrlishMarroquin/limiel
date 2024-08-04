import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/pages/product_page.dart';
import 'package:limielapp/pages/promotion_page.dart';
import 'package:limielapp/pages/change_page.dart';
import 'package:limielapp/pages/point_page.dart';
import 'package:limielapp/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';

class HomePage extends StatelessWidget {

  CollectionReference usuariosReference =
      FirebaseFirestore.instance.collection("usuarios");

  @override
  Widget build(BuildContext context) {
    final providerUser = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Bienvenido a LIMIEL", 
          style: TextStyle(color: Colors.black, fontSize: 28),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 0,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "${providerUser.nombre} ${providerUser.apellido}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ), 
                  minimumSize: const Size(280, 44),               
                ),
                child: const Text(
                  "Realizar Pedido",
                  style: TextStyle(color: Colors.black, fontSize: 18)
                )
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PromotionPage(),
                    ),
                  );                            
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ), 
                  minimumSize: const Size(280, 44),               
                ),
                child: const Text(
                  "Promociones",
                  style: TextStyle(color: Colors.black, fontSize: 18)
                )
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PointPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ), 
                  minimumSize: const Size(280, 44),               
                ),
                child: const Text(
                  "Consigue Puntos",
                  style: TextStyle(color: Colors.black, fontSize: 18)
                )
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ), 
                  minimumSize: const Size(280, 44),               
                ),
                child: const Text(
                  "Usa tus Puntos",
                  style: TextStyle(color: Colors.black, fontSize: 18)
                )
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginPage()), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ), 
                  minimumSize: const Size(280, 44),               
                ),
                child: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(color: Colors.black, fontSize: 18)
                )
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),      
    );
  }
}