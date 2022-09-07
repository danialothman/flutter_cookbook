import 'package:flutter/material.dart';
import 'database.dart';
import 'data_model.dart';

var fido = const Dog(id: 0, name: 'Fido', age: 9);
var gongo = const Dog(id: 1, name: 'Gongo', age: 5);
var longo = const Dog(id: 2, name: 'Longo', age: 3);
var bongo = const Dog(id: 3, name: 'Bongo', age: 1);

List dogs = [];

Future<void> main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // // Open the database and store the reference.
  // print('OPENING DATABASE');
  // final database = openDatabase(
  //   // Set the path to the database. Note: Using the `join` function from the
  //   // `path` package is best practice to ensure the path is correctly
  //   // constructed for each platform.
  //     join(await getDatabasesPath(),'doggo_database.db'),
  //     // When the database is first created, create a table to store dogs.
  //     onCreate: (db, version){
  //       // Run the CREATE TABLE statement on the database.
  //       return db.execute('CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)');
  //     },
  //     // Set the version. This executes the onCreate function and provides a
  //     // path to perform database upgrades and downgrades.
  //     version: 1,
  // );

  // ---------------------------------------------------------------
  // DATABASE FUNCTIONS
  // ---------------------------------------------------------------

  // // Define a function that inserts dogs into the database
  // Future<void> insertDog(Dog dog) async{
  //   print('INSERT DOG Fn');
  //
  //   // Get a reference to the database.
  //   final db = await database;
  //
  //   // Insert the Dog into the correct table. You might also specify the
  //   // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //   //
  //   // In this case, replace any previous data.
  //   await db.insert(
  //       'dogs',
  //       dog.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }
  //
  // // A method that retrieves all the dogs from the dogs table.
  // Future <List<Dog>> dogs() async {
  //   print('RETRIEVE DOGS Fn');
  //
  //   // Get a reference to the database.
  //   final db = await database;
  //
  //   // Query the table for all The Dogs.
  //   final List<Map<String,dynamic>> maps = await db.query('dogs');
  //
  //   // Convert the List<Map<String, dynamic> into a List<Dog>.
  //   return List.generate(maps.length, (i){
  //     return Dog(id: maps[i]['id'], name: maps[i]['name'], age: maps[i]['age'],);
  //   });
  // }
  //
  //
  // // UPDATE A DOG
  // Future<void> updateDog(Dog dog) async {
  //   print('UPDATE DOG Fn');
  //
  //   final db = await database;
  //
  //   await db.update(
  //     'dogs',
  //     dog.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [dog.id],
  //   );
  // }
  //
  // // DELETE DOG
  // Future<void> deleteDog(int id) async {
  //   print('DELETE DOG Fn');
  //
  //   final db = await database;
  //
  //   await db.delete(
  //     'dogs',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  //check current dog table
  print(await DogDatabase.instance.dogs());
  //query from DB then add to local state on app run
  addToDogList();

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
        primarySwatch: Colors.deepPurple,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('BUILD LIST',
                    style: Theme.of(context).textTheme.headline4),
                buildList(),
                const Divider(thickness: 2),
                Text('SQFLITE', style: Theme.of(context).textTheme.headline4),
                const Text('CREATE'),
                SizedBox(
                  height: 50,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: addFido, child: const Text('add Fido'))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: addGongo,
                            child: const Text('add Gongo'))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: addLongo,
                            child: const Text('add Longo'))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: addBongo,
                            child: const Text('add Bongo'))),
                  ]),
                ),
                const Divider(thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('READ'),
                        ElevatedButton(
                            onPressed: getDogsFromDB,
                            child: const Text('Get List DB')),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('UPDATE'),
                        ElevatedButton(
                            onPressed: updateFido,
                            child: const Text('update Fido')),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('DELETE'),
                        ElevatedButton(
                            onPressed: deleteFido,
                            child: const Text('delete Fido')),
                      ],
                    )
                  ],
                ),
                const Divider(thickness: 2),
                const Text('DELETE TABLE ROWS'),
                ElevatedButton(
                    onPressed: deleteTableRows,
                    child: const Text('delete Table Rows')),
                const Divider(thickness: 2),
                Text('LOCAL STATE',
                    style: Theme.of(context).textTheme.headline4),
                ElevatedButton(
                    onPressed: getDogsFromList, child: const Text('Get List')),
                const ElevatedButton(
                    onPressed: addToDogList, child: Text('Add to List')),
                const ElevatedButton(
                    onPressed: clearList, child: Text('Clear List')),
                const Divider(thickness: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

//-----------------------------------------------------------------------
// WIDGET FUNCTIONS, which returns a widget that's rendered in the view.
//-----------------------------------------------------------------------

  Widget buildList() {
    if (dogs.isEmpty) {
      return const Text('Empty List');
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('ListView.builder + ListTile'),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: dogs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 8,
                    child: ListTile(
                      leading: Text('${dogs[index].id}'),
                      title: Text('${dogs[index].name}'),
                      trailing: Text('${dogs[index].age}'),
                    ),
                  );
                }),
          ),
        ],
      );
    }
  }

//-----------------------------------------------------------------------
// VOID FUNCTIONS, which perform logical actions, change state, etc.
//-----------------------------------------------------------------------

  void getDogsFromList() {
    setState(() {});
    print('GET FROM LIST -- ${dogs.toString()}');
  }

  Future<void> getDogsFromDB() async {
    setState(() {});
    print('GET FROM DB --- ${await DogDatabase.instance.dogs()}');
  }

  Future<void> addBongo() async {
    // CREATE A DOG - BONGO
    await DogDatabase.instance.insertDog(bongo);
  }

  Future<void> addLongo() async {
    // CREATE A DOG - Longo
    await DogDatabase.instance.insertDog(longo);
  }

  Future<void> addGongo() async {
    // CREATE A DOG - GONGO
    await DogDatabase.instance.insertDog(gongo);
  }

  Future<void> addFido() async {
    // CREATE A DOG - FIDO
    await DogDatabase.instance.insertDog(fido);
  }

  Future<void> deleteFido() async {
    // DELETE A DOG -- FIDO
    await DogDatabase.instance.deleteDog(fido.id);
  }

  Future<void> updateFido() async {
    // UPDATE A DOG -- FIDO
    fido = Dog(id: fido.id, name: fido.name, age: fido.age + 7);
    setState(() {});
    await DogDatabase.instance.updateDog(fido);
  }

  Future<void> deleteTableRows() async {
    DogDatabase.instance.deleteRows();
  }
}

//-----------------------------------------------------------------------
// GLOBAL VOID FUNCTIONS, which perform logical actions, change state, etc.
//-----------------------------------------------------------------------

Future<void> clearList() async {
  dogs.clear();
  print('Clear list - list length ${dogs.length}');
}

Future<void> addToDogList() async {
  //clear list in the beginning to make sure only getting items from DB
  clearList();

  // get list from DB query
  var result = await DogDatabase.instance.dogs();

  // iterate and add each element of result then add to local state list
  for (var element in result) {
    dogs.add(element);
  }

  print('added to list - list length ${dogs.length}');
}
