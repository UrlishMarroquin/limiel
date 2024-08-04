class PedidoModel {
  int id;
  String codigo;
  String nombre;
  double precio;
  int cantid;
  String imagen;

  PedidoModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precio,
    required this.cantid,
    required this.imagen,
  });

  factory PedidoModel.fromDB(Map<String, dynamic> data) => PedidoModel(
        id: data["id"],
        codigo: data["codigo"],
        nombre: data["nombre"],
        precio: data["precio"],
        cantid: data["cantid"],
        imagen: data["imagen"],
      );

  Map<String, dynamic> convertiraMap() => {
        "codigo": codigo,
        "nombre": nombre,
        "precio": precio,
        "cantid": cantid,
        "imagen": imagen,
      };
}
