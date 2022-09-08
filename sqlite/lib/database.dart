// ignore_for_file: avoid_print

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'data_model.dart';

class DogDatabase {
  // Create Singleton for instance
  static final DogDatabase instance = DogDatabase._init();
  static Database? _database;
  DogDatabase._init();

  // database reference getter
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('dogdog.db');
    return _database!;
  }

  // initialize DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform. see var path above.
        path,
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
        // When the database is first created, create a table to store dogs.
        onCreate: _createDB);
  }

  // create DB
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

//-----------------------------------------------------------------------
// CRUD FUNCTIONS
//-----------------------------------------------------------------------

  // INSERT DATA
  Future<void> insertDog(Dog dog) async {
    print('INSERT DOG Fn');
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    // In this case, replace any previous data.
    await db.insert('dogs', dog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ DATA
  // A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> readAllDogs() async {
    print('readAllDogs() - START');
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs, which is of type Map.
    final List<Map<String, dynamic>> result = await db.query('dogs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(result.length, (i) {
      return Dog(
        id: result[i]['id'],
        name: result[i]['name'],
        age: result[i]['age'],
      );
    });
  }

  // UPDATE A DOG
  Future<void> updateDog(Dog dog) async {
    print('updateDog() - START');
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
    print('deleteDog() - START');
    final db = await database;

    await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ROWS, preserves table
  Future<void> deleteRows() async {
    print('deleteRows() - START');
    final db = await database;

    await db.execute('DELETE FROM dogs');
  }

  // CLOSE db
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
