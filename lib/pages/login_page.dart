import 'package:firebase_auth/firebase_auth.dart';
import 'package:limielapp/pages/create_page.dart';
import 'package:limielapp/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final keyForm = GlobalKey<FormState>();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasena = TextEditingController();
  bool _isButtonDisabled = false;

  CollectionReference usuariosReference =
      FirebaseFirestore.instance.collection("usuarios");

  Future<void> fetchUsers(BuildContext context) async {
    QuerySnapshot userCollection = await usuariosReference
        .where("correo", isEqualTo: correo.text)
        .limit(1)
        .get();
    QueryDocumentSnapshot docs = userCollection.docs.first;
    final providerUser = Provider.of<UserProvider>(context, listen: false);
    providerUser.id = docs.id;
    providerUser.nombre = docs["nombre"];
    providerUser.apellido = docs["apellido"];
    providerUser.dni = docs["dni"];
    providerUser.telefono = docs["telefono"];
    providerUser.correo = docs["correo"];
    providerUser.punto = docs["punto"];  
  }

  Widget fieldCuenta(
    String titulo,
    TextEditingController controller,
    bool secreto,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 60,
          child: TextFormField(
            controller: controller,
            obscureText: secreto,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
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
          height: 16,
        ),
      ],
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> login(BuildContext context) async {
    setState(() {
      _isButtonDisabled = true;
    });    
    
    try {
      if(keyForm.currentState!.validate()){
        UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
          email: correo.text,
          password: contrasena.text,
        );
        await fetchUsers(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No existe el correo ingresado.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'La contraseña es incorrecta.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Datos ingresados incorrectos.';
      } else {
        errorMessage = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            errorMessage,
          ),
        ),
      );
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
    } finally {
      setState(() {
        _isButtonDisabled = false;
      });
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
                    height: 16,
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 240,
                    height: 240,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    "Inicia Sesión",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  fieldCuenta("Correo", correo, false),
                  fieldCuenta("Contraseña", contrasena, true),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: _isButtonDisabled ? null : () {
                      login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ), 
                      minimumSize: const Size(280, 44),               
                    ),
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(color: Colors.black, fontSize: 18)
                    )
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿No se ha registrado? ",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreatePage(),
                              ));
                        },
                        child: const Text(
                          "Regístrese",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
