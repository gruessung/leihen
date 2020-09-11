// Flutter code sample for material.Card.2

// This sample shows creation of a [Card] widget that can be tapped. When
// tapped this [Card]'s [InkWell] displays an "ink splash" that fills the
// entire card.

/**
 * Typ: 1 = verliehen
 * 0 = geliehen
 */

import 'package:flutter/material.dart';
import 'package:oweapp4/pages/homescreen_page.dart';
import 'package:oweapp4/services/AppLocalizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {

  _getDBPath() async {
    print("DB Test");
    var databasesPath = await getDatabasesPath();
    print(databasesPath);
    Database db = await openDatabase(databasesPath + '/oweapp.db');
    print(db.path);
    List<Map> result = await db.rawQuery("SELECT  name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%';");
    print(result);

  }


  @override
  Widget build(BuildContext context) {


    return MaterialApp(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('de', 'DE'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        title: 'Leihen',
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightGreen[800],
          accentColor: Colors.green[600],
          cardColor: Colors.white,

        ));
  }
}
