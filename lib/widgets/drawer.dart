import 'package:flutter/material.dart';
import 'package:oweapp4/main.dart';
import 'package:oweapp4/pages/about_page.dart';
import 'package:oweapp4/routes/Routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class AppDrawer extends StatefulWidget {

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  String versionName = '';

  Future<String> _getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionName = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getVersionName();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
              icon: Icons.home,
              text: 'Übersicht',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MyApp()))),
          _createDrawerItem(
              icon: Icons.info_outline,
              text: 'Über',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AboutPage()))),
          Divider(),
          _createDrawerItem(
              icon: Icons.bug_report,
              text: 'Fehler melden',
              onTap: () => _launchURL()),
          ListTile(
            title: Text(versionName),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage('assets/background.jpg'))),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Leihen",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  _launchURL() async {
    const url = 'mailto:info@gruessung.eu';
    // if (await canLaunch(url)) {
    await launch(url);
    //} else {
    // throw 'Could not launch $url';
    //}
  }
}
