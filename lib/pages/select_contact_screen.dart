import 'dart:math';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:oweapp4/services/Database.dart';
import 'package:oweapp4/widgets/contact_card.dart';
import 'package:oweapp4/pages/input_item_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oweapp4/services/AppLocalizations.dart';

class NewItemSelectContactScreen extends StatefulWidget {
  bool showAllContacts;

  NewItemSelectContactScreen(this.showAllContacts);

  @override
  _NewItemSelectContactScreenState createState() =>
      _NewItemSelectContactScreenState(showAllContacts);
}

class _NewItemSelectContactScreenState
    extends State<NewItemSelectContactScreen> {
  Iterable<Contact> _contacts;
  bool contactPermission = true;
  bool alreadyPullContacts = false;
  List _currentContacts;
  bool showAllContacts;

  _NewItemSelectContactScreenState(this.showAllContacts);

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  _getContacts() async {
    if (!alreadyPullContacts) {
      PermissionStatus permissionStatus = await _getContactPermission();
      if (permissionStatus == PermissionStatus.granted && _contacts == null) {
        Iterable<Contact> contacts =
            await ContactsService.getContacts(query: "");

        List<Contact> contactList = List<Contact>();

        contacts.forEach((element) {
          if (!isNumeric(element.displayName.trim())) {
            contactList.add(element);
          }
        });

        contactList.sort((m1, m2) {
          return m1.displayName.compareTo(m2.displayName);
        });

        setState(() {
          _contacts = contactList;
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

  _getCurrentContacts() async {
    List<Contact> c = await DBProvider.db.getCurrentUseContacts();
    setState(() {
      _currentContacts = c;
    });
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
    _getCurrentContacts();
    _getContacts();

    if (_contacts != null && _currentContacts != null) {
      List<Contact> tmp = _currentContacts;
      _contacts.forEach((element) {
        tmp.add(element);
      });
      setState(() {
        _currentContacts = tmp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showAllContacts
            ? AppLocalizations.of(context).translate('pagename_select_contact')
            : AppLocalizations.of(context).translate('last_contacts')),
      ),
      body: SafeArea(
          child: (!showAllContacts &&
                  _currentContacts != null &&
                  _currentContacts.length > 0)
              ? (LastContactsWidget(_currentContacts))
              : (contactPermission) ? ((_contacts == null)
              ? LoadingContactsWidget()
              : ListView.builder(
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
              })) : NoContactsFoundWidget(contactPermission: contactPermission)),
      floatingActionButton: FloatingActionButton(
          child: Center(
              child: Text(
                  (showAllContacts || !contactPermission)
                      ? AppLocalizations.of(context)
                          .translate('forward_without_contact_button')
                      : AppLocalizations.of(context).translate('all_contacts'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12))),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      (showAllContacts || !contactPermission)
                          ? InputItemScreen(null, null)
                          : NewItemSelectContactScreen(true)))),
    );
  }
}

class LastContactsWidget extends StatelessWidget {
  List<Contact> _currentContacts;

  LastContactsWidget(this._currentContacts);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _currentContacts?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = _currentContacts?.elementAt(index);
          print("Kontakt: " + contact.displayName);
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        InputItemScreen(contact, null))),
            child: (contact != null && contact.displayName != null)
                ? ContactCard(contact)
                : null,
          );
        });
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
