import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:oweapp4/services/AppLocalizations.dart';
import 'package:oweapp4/widgets/drawer.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangelogScreen extends StatelessWidget {
  static const String routeName = '/changelog';



  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: "https://leihen.app/changelog.php?lang=" + AppLocalizations.of(context).getLanguageCode(),
      clearCache: true,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('pagename_changelog')),
      ),
    );
  }
}
