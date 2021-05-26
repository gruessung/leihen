import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oweapp4/services/AppLocalizations.dart';
import 'package:oweapp4/services/Database.dart';
import 'package:oweapp4/services/HaldeModel.dart';
import 'package:oweapp4/widgets/drawer.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AboutPage extends StatefulWidget {
  static const String routeName = '/about';

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String versionName = '';
  String appName = '';
  bool _allowWriteFile = false;

  _getBuildNumber() async {
    if (appName.isEmpty) {
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
        appBar: AppBar(
            title:
                Text(AppLocalizations.of(context).translate('pagename_about'))),
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
                AppLocalizations.of(context).translate('app_name') +
                    ' v' +
                    this.versionName,
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
              Text(AppLocalizations.of(context).translate('widmung'),
                  style: textStyle),
              Container(height: 70),
              ElevatedButton(
                  onPressed: () {
                    _getStoragePersmission();
                    final Future<List<Halde>> data =
                        DBProvider.db.getAllItems();
                    data.then((value) => {
                         export(value)


                        });



                  },
                  child: Text("Create Backup to debugging"))
            ])));
  }

  void export(value) {
    String jsonString = "[";

    value.forEach((Halde element) {
      print(element.toMap());
      jsonString = jsonString + element.toMap().toString();
    });
    jsonString = jsonString + "]";

    _writeToFile(jsonString);

    print(jsonString);
  }

  Future _writeToFile(String text) async {
    if (!_allowWriteFile) {
      return null;
    }

    final file = await _localFile;

    // Write the file

    File result = await file.writeAsString('$text');
  }

  Future get _localFile async {
    final path = await _localPath;

    return File('$path/lend-backup.json');
  }

  Future get _localPath async {
    // Application documents directory: /data/user/0/{package_name}/{app_name}

    final applicationDirectory = await getApplicationDocumentsDirectory();

    // External storage directory: /storage/emulated/0

    final externalDirectory = await getExternalStorageDirectory();

    // Application temporary directory: /data/user/0/{package_name}/cache

    final tempDirectory = await getTemporaryDirectory();

    return externalDirectory.path;
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  Future<PermissionStatus> _getStoragePersmission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      return permissionStatus[PermissionGroup.storage] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }
}
