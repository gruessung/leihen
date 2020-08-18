import 'package:flutter/material.dart';
import 'package:oweapp4/Database.dart';
import 'package:oweapp4/NI_InputDetailsScreen.dart';
import 'package:oweapp4/NI_SelectContactScreen.dart';
import 'package:oweapp4/pages/about_page.dart';
import 'package:oweapp4/widgets/drawer.dart';
import 'package:oweapp4/widgets/main_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  static const String routeName = '/';
  Future<dynamic> _homeScreenData;
  String _lastVersionNumber;
  bool firstStart = false;

  _getHomeScreenData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _homeScreenData = DBProvider.db.getHomeScreenCards();
      _lastVersionNumber = prefs.getString('lastVersionNumber');
    });
  }

  @override
  void initState() {
    print("Call initState()");
    _getHomeScreenData();
    super.initState();
  }

  _checkContactPermission() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus != PermissionStatus.granted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => AboutPage()));
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  _checkFirstStart() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('firstStart')) {
      setState(() {
        firstStart = prefs.getBool('firstStart');
      });
    } else {
      setState(() {
        firstStart = true;
      });
    }

  }

  _showFirstStartScreen() {
    TextStyle textStyle = TextStyle(
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.w300,
      fontSize: 20,
    );

    return Center(
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
                "Diese App braucht die Berechtigung zum Lesen deiner Kontakte.",
                style: textStyle,
              ),
              Container(height: 50),

              Icon(Icons.favorite, color: Colors.redAccent),
              Text("Deine Daten bleiben auf deinem Gerät, versprochen!", style: textStyle)
            ]));
  }

  @override
  Widget build(BuildContext context) {
    //_checkContactPermission();
    _checkFirstStart();
    _getHomeScreenData();
    //_checkChangelogDialog(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Übersicht'),
      ),
      drawer: AppDrawer(),
      body: /*(firstStart) ? _showFirstStartScreen() :*/ FutureBuilder<dynamic>(
          future: this._homeScreenData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot != null &&
                snapshot.data != null &&
                snapshot.data.length > 0) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> halde = snapshot.data[index];
                    return MainCard(oHalde: halde, context: context);
                  });
            } else {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    Icon(
                      Icons.face,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    Container(height: 20),
                    Text(
                      "Leg gleich los",
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.w300,
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  ]));
            }
          }),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NewItemSelectContactScreen()))),
    );
  }
}
