import 'package:flutter/material.dart';
import 'package:oweapp4/services/AppLocalizations.dart';
import 'package:oweapp4/widgets/drawer.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  static const String routeName = '/about';

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String versionName = '';
  String appName = '';

  _getBuildNumber() async {
    if(appName.isEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        versionName = packageInfo.version;
        appName = packageInfo.appName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _getBuildNumber();
    TextStyle textStyle = TextStyle(
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.w300,
      fontSize: 20,
    );

    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).translate('pagename_about'))),
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
                AppLocalizations.of(context).translate('app_name') + ' v' + this.versionName,
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
              Text(AppLocalizations.of(context).translate('widmung'), style: textStyle)
            ])));
  }
}
