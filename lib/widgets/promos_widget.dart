import 'package:flutter/material.dart';
import 'package:limielapp/pages/detail_page.dart';

class PromoWidget extends StatelessWidget {
  String nombre;
  String mensaj;
  double precio;
  String imagen;

  PromoWidget({
    required this.nombre,
    required this.mensaj,
    required this.precio,
    required this.imagen,   
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              nombre: nombre,
              mensaj: mensaj,
              precio: precio,
              imagen: imagen,
            )
          ),
        );
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
              Image.network(imagen, height: 75, width: 75,),
              const SizedBox(height: 4),
              Text(nombre, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),                    
            ],
          ),
        ),
      ),     
    );
  }
}
