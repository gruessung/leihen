// Flutter code sample for material.Card.2

// This sample shows creation of a [Card] widget that can be tapped. When
// tapped this [Card]'s [InkWell] displays an "ink splash" that fills the
// entire card.

/**
 * Typ: 1 = verliehen
 * 0 = geliehen
 */

import 'package:flutter/material.dart';
import 'widgets/main_card.dart';
import 'package:oweapp4/NewItemScreen.dart';
import 'Database.dart';

void main() {
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ich leihe dir',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  Future<dynamic> _homeScreenData;

  _getHomeScreenData() async {
    setState(() {
      _homeScreenData = DBProvider.db.getHomeScreenCards();
    });
  }

  @override
  void initState() {
    print("Call initState()");
    _getHomeScreenData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Call build()");
    _getHomeScreenData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Ich leihe dir'),
      ),
      body: FutureBuilder<dynamic>(
          future: this._homeScreenData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    print("Index: " + index.toString());
                    Map<String, dynamic> halde = snapshot.data[index];
                    return MainCard(oHalde: halde, context: context);
                  });
            } else {
              return Center(child: Text("Keine Daten :("));
            }
          }),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NewItemScreen()))),
    );
  }
}
/*

 */
