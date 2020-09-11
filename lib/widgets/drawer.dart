import 'package:flutter/material.dart';
import 'package:oweapp4/main.dart';
import 'package:oweapp4/pages/about_page.dart';
import 'package:oweapp4/pages/changelog_screen.dart';
import 'package:oweapp4/routes/Routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:oweapp4/services/AppLocalizations.dart';

/*
class AppDrawer extends StatefulWidget {

  @override
  _AppDrawerState createState() => _AppDrawerState();
}*/

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(context),
          _createDrawerItem(
              icon: Icons.home,
              text: AppLocalizations.of(context).translate('pagename_overview'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MyApp()))),
          _createDrawerItem(
              icon: Icons.info_outline,
              text: AppLocalizations.of(context).translate('pagename_about'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AboutPage()))),
          Divider(),
          _createDrawerItem(
              icon: Icons.fiber_new_outlined,
              text:
                  AppLocalizations.of(context).translate('pagename_changelog'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ChangelogScreen()))),
          _createDrawerItem(
              icon: Icons.bug_report,
              text: AppLocalizations.of(context).translate('pagename_bug'),
              onTap: () => _launchURL()),
        ],
      ),
    );
  }

  Widget _createHeader(context) {
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
              child: Text(AppLocalizations.of(context).translate('app_name'),
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

