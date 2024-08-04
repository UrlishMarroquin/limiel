import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _id = "";
  String _nombre = "";
  String _apellido = "El usuario aun no se registro";
  String _dni = "";
  String _telefono = "";
  String _correo = "";
  int _punto = 0;
  String get id => _id;
  String get nombre => _nombre;
  String get apellido => _apellido;
  String get dni => _dni;
  String get telefono => _telefono;
  String get correo => _correo;
  int get punto => _punto;

  set id(String newId) {
    _id = newId;
    notifyListeners();
  }
  set nombre(String newNombre) {
    _nombre = newNombre;
    notifyListeners();
  }
  set apellido(String newApellido) {
    _apellido = newApellido;
    notifyListeners();
  }
  set dni(String newDni) {
    _dni = newDni;
    notifyListeners();
  }
  set telefono(String newTelefono) {
    _telefono = newTelefono;
    notifyListeners();
  }
  set correo(String newCorreo) {
    _correo = newCorreo;
    notifyListeners();
  }
  set punto(int newPunto) {
    _punto = newPunto;
    notifyListeners();
  }
                   
}
