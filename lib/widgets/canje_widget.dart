import 'package:flutter/material.dart';
import 'package:limielapp/pages/change_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';

class CanjeWidget extends StatelessWidget {
  String nombre;
  int puntos;
  int puntitos;

  CanjeWidget({
    required this.nombre,
    required this.puntos, 
    required this.puntitos,
  });

  CollectionReference usuariosReference =
      FirebaseFirestore.instance.collection("usuarios");     

  Future<void> _launchUrl() async {

    final String phone = '51943204706';
    final String message = "$nombre puntos: P/.$puntos";
    final Uri url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> updateUsers(String id, int cantidad) async {
    usuariosReference.doc(id).update(
      {
        "punto": cantidad,
      },
    );
  }  

  @override
  Widget build(BuildContext context) {

    final providerUser = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () {
        if(puntitos > puntos){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Canjear Puntos'),
                content: Text('Se desea canjear $nombre con $puntos puntos'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {  
                      updateUsers(providerUser.id, puntitos - puntos);           
                      _launchUrl();
                      Navigator.of(context).pop();
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
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              behavior: SnackBarBehavior.floating,
              content: const Text(
                "No tienes suficientes puntos para el canje",
              ),
            ),
          );
        }

      },        
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$puntos p", style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              const SizedBox(height: 4),
              Text(nombre, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal), textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),     
    );
  }
}
