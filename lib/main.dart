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
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
