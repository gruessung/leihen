import 'package:flutter/material.dart';
import 'package:oweapp4/widgets/drawer.dart';

class AboutPage extends StatelessWidget {
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.w300,
      fontSize: 20,
    );

    return Scaffold(
        appBar: AppBar(title: Text('Über')),
        drawer: AppDrawer(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Icon(
                Icons.info,
                size: 25,
              ),
              Container(
                height: 5,
              ),
              Text(
                "Leihen v5",
                style: textStyle,
              ),
              Text("www.leihen.app", style: textStyle),
              Container(height: 50),
              Icon(
                Icons.face,
                size: 25,
              ),
              Container(height: 5),
              Text("Alexander Grüßung", style: textStyle),
              Text("www.gruessung.eu", style: textStyle),
              Container(height: 50),
              Icon(Icons.favorite, color: Colors.redAccent),
              Text("Meinem Vater gewidmet.", style: textStyle)
            ])));
  }
}
