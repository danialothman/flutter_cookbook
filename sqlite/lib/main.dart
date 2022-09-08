// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'database.dart';
import 'data_model.dart';

var fido = const Dog(id: 0, name: 'Fido', age: 9);
var gongo = const Dog(id: 1, name: 'Gongo', age: 5);
var longo = const Dog(id: 2, name: 'Longo', age: 3);
var bongo = const Dog(id: 3, name: 'Bongo', age: 1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MyHomePage(title: 'Flutter Cookbook Persistence'),
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
  late List dogs;
  bool isLoading = false;

  @override
  void initState() {
    // refresh list by querying from DB on app load
    refreshDogs();

    super.initState();
  }

  Future refreshDogs() async {
    setState(() => isLoading = true);
    dogs = await DogDatabase.instance.readAllDogs();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    DogDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions:  [Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(onPressed: refreshDogs, icon: const Icon(Icons.refresh,size: 32.0,)),
        )],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){},child: const Icon(Icons.add),),
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
                isLoading ? const CircularProgressIndicator() : dogs.isEmpty ? const Text('Empty Dogs') : buildList(),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            height: 250,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: dogs.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: (){
                      print('${dogs[index].name}');
                    },
                    child: Card(
                      elevation: 8,
                      child: ListTile(
                        leading: Text('${dogs[index].id}'),
                        title: Text('${dogs[index].name}'),
                        trailing: Text('${dogs[index].age}'),
                      ),
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

  // DB FUNCTIONS
  Future<void> getDogsFromDB() async {
    setState(() {});
    print('GET FROM DB --- ${await DogDatabase.instance.readAllDogs()}');
    refreshDogs();
  }

  Future<void> addBongo() async {
    // CREATE A DOG - BONGO
    await DogDatabase.instance.insertDog(bongo);
    refreshDogs();
  }

  Future<void> addLongo() async {
    // CREATE A DOG - Longo
    await DogDatabase.instance.insertDog(longo);
    refreshDogs();
  }

  Future<void> addGongo() async {
    // CREATE A DOG - GONGO
    await DogDatabase.instance.insertDog(gongo);
    refreshDogs();
  }

  Future<void> addFido() async {
    // CREATE A DOG - FIDO
    await DogDatabase.instance.insertDog(fido);
    refreshDogs();
  }

  Future<void> deleteFido() async {
    // DELETE A DOG -- FIDO
    await DogDatabase.instance.deleteDog(fido.id);
    refreshDogs();
  }

  Future<void> updateFido() async {
    // UPDATE A DOG -- FIDO
    fido = Dog(id: fido.id, name: fido.name, age: fido.age + 7);
    setState(() {});
    await DogDatabase.instance.updateDog(fido);
    refreshDogs();
  }

  Future<void> deleteTableRows() async {
    DogDatabase.instance.deleteRows();
    refreshDogs();
  }


  // LOCAL STATE FUNCTIONS
  void getDogsFromList() {
    setState(() {});
    print('getDogsFromList() --- ${dogs.toString()}');
  }

  Future<void> clearList() async {
    // print('START - clearList()');
    dogs.clear();
    // print('END - clearList() - list length ${dogs.length}');
  }

  Future<void> addToDogList() async {
    print("addToDogList() - START");

    //clear list in the beginning to make sure only getting items from DB
    clearList();

    // get list from DB query
    var result = await DogDatabase.instance.readAllDogs();

    // iterate and add each element of result then add to local state list
    for (var element in result) {
      dogs.add(element);
    }

    print('addToDogList() - END - added to list - list length ${dogs.length}');
  }

}

