// ignore_for_file: avoid_print

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'data_model.dart';

class DogDatabase {
  static final DogDatabase instance = DogDatabase._init();
  static Database? _database;
  DogDatabase._init();

  // getter - ???
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('dogdog.db');
    return _database!;
  }

  // initialize DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //  create DB
  Future _createDB(Database db, int version) async {
    print('************ CREATING TABLE DOGS ************');

    await db.execute('''
    CREATE TABLE dogs(
    id INTEGER PRIMARY KEY, 
    name TEXT, 
    age INTEGER
    )
    ''');
  }

  // CRUD FUNCTIONS
  // CRUD FUNCTIONS
  // CRUD FUNCTIONS

  // INSERT DATA
  Future<void> insertDog(Dog dog) async {
    print('INSERT DOG Fn');

    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert('dogs', dog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ DATA
  // A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> dogs() async {
    print('RETRIEVE DOGS Fn');

    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  // UPDATE A DOG
  Future<void> updateDog(Dog dog) async {
    print('UPDATE DOG Fn');

    final db = await database;

    await db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  // DELETE DOG
  Future<void> deleteDog(int id) async {
    print('DELETE DOG Fn');

    final db = await database;

    await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ROWS, preserves table
  Future<void> deleteRows() async {
    print('DELETE ROWS');

    final db = await database;

    await db.execute('DELETE FROM dogs');
  }

  // CLOSE db
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
