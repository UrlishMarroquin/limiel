import 'dart:io';

import 'package:limielapp/models/pedido_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBAdmin {
  Database? myDatabase;

  static final DBAdmin _instance = DBAdmin._();
  DBAdmin._();

  factory DBAdmin() {
    return _instance;
  }

  Future<Database?> _checkDatabase() async {
    if (myDatabase == null) {
      myDatabase = await _initDatabase();
    }
    return myDatabase;

  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String pathDatabase = join(directory.path, "PedidoDB.db");
    return await openDatabase(
      pathDatabase,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE PEDIDOS(
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        codigo TEXT,
        nombre TEXT, 
        precio REAL, 
        cantid INTEGER, 
        imagen TEXT
      )
    """);
  }

  Future<void> vaciarPedidos() async {
    final db = await _checkDatabase();
    await db!.execute('DROP TABLE IF EXISTS PEDIDOS');
    _onCreate(db, 1);
  }

  Future<int> insertarPedido(PedidoModel gasto) async {
    Database? db = await _checkDatabase();
    int res = await db!.insert(
      "PEDIDOS",
      gasto.convertiraMap(),
    );
    return res;
  }

  Future<List<PedidoModel>> obtenerPedidos() async {
    Database? db = await _checkDatabase();
    List<Map<String, dynamic>> data = await db!.query("PEDIDOS");

    List<PedidoModel> pedidosList =
        data.map((e) => PedidoModel.fromDB(e)).toList();

    return pedidosList;
  }

  Future<List<PedidoModel>> buscarPedidosPorNombre(String nombre) async {
    Database? db = await _checkDatabase();
    List<Map<String, dynamic>> data = await db!.query(
      "PEDIDOS",
      where: "nombre LIKE ?",
      whereArgs: ["%$nombre%"],
    );

    List<PedidoModel> pedidosList =
        data.map((e) => PedidoModel.fromDB(e)).toList();

    return pedidosList;
  }

  Future<List<PedidoModel>> buscarPedidosPorCantidad(int cantid) async {
    Database? db = await _checkDatabase();
    List<Map<String, dynamic>> data = await db!.query(
      "PEDIDOS",
      where: "cantid != ?",
      whereArgs: [cantid],
    );

    List<PedidoModel> pedidosList =
        data.map((e) => PedidoModel.fromDB(e)).toList();

    return pedidosList;
  }

  updPedido(int id, int cantid) async {
    Database? db = await _checkDatabase();
    int res = await db!.update(
      "PEDIDOS",
      {
        "cantid": cantid,
      },
      where: 'id=$id'
    );
  }

  delPedido(int id) async {
    Database? db = await _checkDatabase();
    int res = await db!.delete("PEDIDOS", where: 'id=$id');
  }
  
}
