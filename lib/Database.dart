import 'package:oweapp4/HaldeModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String documentsDirectory = await getDatabasesPath();
    print(documentsDirectory);
    String path = join(documentsDirectory, "oweapp.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Halde ("
          "id INTEGER PRIMARY KEY,"
          "kontaktId TEXT,"
          "kontaktName TEXT,"
          "betreff TEXT,"
          "beschreibung TEXT,"
          "fotoPfad TEXT,"
          "erstellt INTEGER(13),"
          "faellig INTEGER(13),"
          "typ INTEGER(1)"
          ")");
    });
  }

  newHalde(Halde halde) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Halde");
    int id = table.first["id"];
    halde.id = id;
    db.insert("Halde", halde.toMap());
  }

  deleteHalde(Halde halde) async {
    final db = await database;
    db.delete('Halde', where: 'id = ' + halde.id.toString());
    return true;
  }

  Future<dynamic> getHomeScreenCards() async {
    final db = await database;
    var res = await db.rawQuery('SELECT t.kontaktName, '
        '(SELECT COUNT(*) FROM Halde h WHERE h.kontaktName = t.kontaktName AND h.typ = 0) AS geliehen, '
        '(SELECT COUNT(*) FROM Halde h WHERE h.kontaktName = t.kontaktName AND h.typ = 1) AS verliehen FROM Halde t GROUP BY t.kontaktName');

    var list = <Map>[];
    res.forEach((c) {
      list.add(c);
    });
    return list;
  }

  /**
   * Holt alle Datensätze zu einem Kontakt aus der Datenbank
   * @return List<Halde>
   */
  Future<List<Halde>> getContactItems({String kontaktName}) async {
    final db = await database;
    var res =
        await db.query('Halde', where: "kontaktName = '" + kontaktName + "'");

    print("Starte: getContactItems");

    List<Halde> list;
    print("Anzahl Gesamt: " + res.length.toString());
    if (res.isNotEmpty) {
      print("res.isNotEmpty");
      list = res.map((c) {
        return Halde.fromJson(c);
      }).toList();
    } else {
      print('res.empty!');
      list = [];
    }

    print("Anzahl der gefundenen Datensätze: " + list.length.toString());

    return list;
  }
}
