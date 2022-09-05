import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'data_model.dart';

Future<void> main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database and store the reference.
  print('OPENING DATABASE');
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
      join(await getDatabasesPath(),'doggo_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version){
        // Run the CREATE TABLE statement on the database.
        return db.execute('CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
  );

  // ---------------------------------------------------------------
  // DATABASE FUNCTIONS
  // ---------------------------------------------------------------

  // Define a function that inserts dogs into the database
  Future<void> insertDog(Dog dog) async{
    print('INSERT DOG Fn');

    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
        'dogs',
        dog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // A method that retrieves all the dogs from the dogs table.
  Future <List<Dog>> dogs() async {
    print('RETRIEVE DOGS Fn');

    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String,dynamic>> maps = await db.query('dogs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i){
      return Dog(id: maps[i]['id'], name: maps[i]['name'], age: maps[i]['age'],);
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


  // ---------------------------------------------------------------
  // USING THE FUNCTIONS
  // ---------------------------------------------------------------

  //check current dog table
  print(await dogs());



  // CREATE A DOG - FIDO
  var fido = const Dog(id: 0, name: 'Fido', age: 35);
  await insertDog(fido);

  // Now, use the method above to retrieve all the dogs.
  print(await dogs());


  // CREATE A DOG - GONGO
  var gongo = const Dog(id: 1, name: 'Gongo', age: 9);
  await insertDog(gongo);

  // Now, use the method above to retrieve all the dogs.
  print(await dogs());





  // UPDATE A DOG -- FIDO
  fido = Dog(id: fido.id, name: fido.name, age: fido.age+7);
  await updateDog(fido);

  // check console again
  print(await dogs());


  // DELETE A DOG -- FIDO
  await deleteDog(fido.id);
  // check console again - check the table
  print(await dogs());


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Cookbook Persistence SQLITE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget> [
             SizedBox(
                height: 50,
                child: Text('I am tired'),
              )

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }


}


