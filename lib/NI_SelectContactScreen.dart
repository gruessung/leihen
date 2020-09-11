import 'dart:math';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:oweapp4/widgets/contact_card.dart';
import 'package:oweapp4/pages/input_item_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oweapp4/services/AppLocalizations.dart';

class NewItemSelectContactScreen extends StatefulWidget {
  @override
  _NewItemSelectContactScreenState createState() =>
      _NewItemSelectContactScreenState();
}

class _NewItemSelectContactScreenState
    extends State<NewItemSelectContactScreen> {
  Iterable<Contact> _contacts;
  bool contactPermission = true;
  bool alreadyPullContacts = false;

  _getContacts() async {
    if (!alreadyPullContacts) {
      PermissionStatus permissionStatus = await _getContactPermission();
      if (permissionStatus == PermissionStatus.granted && _contacts == null) {
        var contacts = await ContactsService.getContacts(query: "");
        /*contacts.toList().sort((a, b) {
        return a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase());
      });*/

        setState(() {
          _contacts = contacts;
          contactPermission = true;
          alreadyPullContacts = true;
        });
      } else {
        setState(() {
          contactPermission = false;
          alreadyPullContacts = true;
        });
      }
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

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('pagename_select_contact')),
      ),
      body: SafeArea(
          child: (_contacts != null || !contactPermission)
              ? ((_contacts != null && _contacts?.length > 0)
                  ? (ListView.builder(
                      itemCount: _contacts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = _contacts?.elementAt(index);
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      InputItemScreen(contact, null))),
                          child: contact.displayName != null
                              ? ContactCard(contact)
                              : null,
                        );
                      }))
                  : (NoContactsFoundWidget(
                      contactPermission: contactPermission,
                    )))
              : (LoadingContactsWidget())),
      floatingActionButton: FloatingActionButton(
          child: Center(
              child: Text(
                  AppLocalizations.of(context)
                      .translate('forward_without_contact_button'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12))),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      InputItemScreen(null, null)))),
    );
  }
}

class NoContactsFoundWidget extends StatelessWidget {
  final bool contactPermission;

  NoContactsFoundWidget({Key key, @required this.contactPermission})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 100),
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Icon(
              Icons.error,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            Container(height: 20),
            Text(
              (contactPermission)
                  ? AppLocalizations.of(context).translate('no_contacts')
                  : AppLocalizations.of(context)
                      .translate('no_contacts_permission'),
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w300,
                fontSize: 25,
                fontStyle: FontStyle.italic,
              ),
            ),
            FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => InputItemScreen(
                                null,
                                null,
                              )));
                },
                child: Text(AppLocalizations.of(context)
                    .translate('forward_without_contact')))
          ])),
    ));
  }
}

class LoadingContactsWidget extends StatelessWidget {
  List<String> dummyTexte = [
    "Lade Kontakte...",
    "Du kennst aber viele Leute...",
    "Hallo, na!"
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 100),
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(10),
            ),
            Text(dummyTexte.elementAt(new Random().nextInt(dummyTexte.length))),
            FlatButton(
                highlightColor: Colors.lightGreen,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              InputItemScreen(null, null)));
                },
                child: Text(AppLocalizations.of(context)
                    .translate('forward_without_contact')))
          ],
        ),
      ),
    );
  }
}
