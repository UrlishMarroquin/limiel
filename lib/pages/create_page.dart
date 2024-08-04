import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limielapp/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';
import 'package:flutter/services.dart';

class CreatePage extends StatelessWidget {
  final keyForm = GlobalKey<FormState>();
  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellido = TextEditingController();
  final TextEditingController dni = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasena = TextEditingController();

  CollectionReference usuariosReference =
      FirebaseFirestore.instance.collection("usuarios");  

  Widget fieldCuenta(
    String titulo,
    TextEditingController controller,
    TextInputType tipo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 60,
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(26),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(26),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: tipo,
            inputFormatters: [
              FilteringTextInputFormatter.singleLineFormatter,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              if (titulo == "DNI" && value.length != 8) {
                return 'Ingrese un dni de 8 dígitos';
              }  
              if (titulo == "DNI" && int.tryParse(value) == null) {
                return 'Ingrese solo números';
              }                  
              if (titulo == "Telefono" && value.length != 9) {
                return 'Ingrese un teléfono de 9 dígitos';
              }
              if (titulo == "Telefono" && int.tryParse(value) == null) {
                return 'Ingrese solo números';
              }   
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );              
              if (titulo == "Correo" && !emailRegex.hasMatch(value)) {
                return 'Ingrese un correo electrónico válido';
              }                   
              return null;
            },            
          ),
        ),
        const SizedBox(
          height: 0,
        ),
      ],
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String mapErrorAuth(String errorMessage) {
    if (errorMessage.contains("email-already-in-use")) {
      return "La dirección de correo ya esta en uso";
    } else if (errorMessage.contains("invalid-email")) {
      return "El correo es inválido";
    } else if (errorMessage.contains("weak-password")) {
      return "La contraseña no cumple con los estándares";
    } else {
      return "ocurrio un problema al crear la cuenta";
    }
  }

  Future<void> createAccount(BuildContext context) async {
    try {
      if(keyForm.currentState!.validate()){
        UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
          email: correo.text,
          password: contrasena.text,
        );
        if(userCredential.user != null){
          usuariosReference.add({
            "nombre": nombre.text,
            "apellido": apellido.text,
            "dni": dni.text,
            "telefono": telefono.text,
            "correo": correo.text,
            "cotrasena ": contrasena.text,
            "dinero": 0,
            "punto": 0,
          }).then((value) {
            final providerUser = Provider.of<UserProvider>(context, listen: false);
            providerUser.id = value.id;
            providerUser.nombre = nombre.text;
            providerUser.apellido = apellido.text;
            providerUser.dni = dni.text;
            providerUser.telefono = telefono.text;
            providerUser.correo = correo.text;
            providerUser.punto = 0;              
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> HomePage()), (route) => false);
          });
        }
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
            mapErrorAuth(error.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

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
            child: Form(
              key: keyForm,
              child: Column(
                children: [
                  const SizedBox(
                    height: 0,
                  ),
                  const Text(
                    "Regístrate",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  fieldCuenta("Nombre", nombre, TextInputType.text),
                  fieldCuenta("Apellido", apellido, TextInputType.text),
                  fieldCuenta("DNI", dni, TextInputType.number),
                  fieldCuenta("Telefono", telefono, TextInputType.number),
                  fieldCuenta("Correo", correo, TextInputType.text),
                  fieldCuenta("Contraseña", contrasena, TextInputType.text),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      createAccount(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ), 
                      minimumSize: const Size(280, 44),               
                    ),
                    child: const Text(
                      "Crear Cuenta",
                      style: TextStyle(color: Colors.black, fontSize: 18)
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
