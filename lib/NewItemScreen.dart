import 'dart:math';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:oweapp4/widgets/contact_card.dart';
import 'package:oweapp4/new_item_input.dart';
import 'package:permission_handler/permission_handler.dart';

class NewItemScreen extends StatefulWidget {
  @override
  _NewItemScreenState createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  Iterable<Contact> _contacts;

  List<String> dummyTexte = [
    "Lade Kontakte...",
    "Du kennst aber viele Leute...",
    "Wo ist die Mama?",
    "Hallo, na!"
  ];

  _getContacts() async {
    print("Lade Kontakte");
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted && _contacts == null) {
      var contacts = await ContactsService.getContacts(query: "");
      setState(() {
        _contacts = contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new Exception("PERMISSION_DENIED");
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new Exception('PERMISSION_DISABLED');
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
  Widget build(BuildContext context) {
    _getContacts();
    return Scaffold(
      appBar: AppBar(
        title: Text('Wähle einen Kontakt'),
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact contact = _contacts?.elementAt(index);
                  return GestureDetector(
                    onTap: () => Navigator.push( 
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NewItemInput(contact))),
                    child: contact.displayName != null
                        ? ContactCard(contact)
                        : null,
                  );
                })
            : Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 100),
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                  ),
                  Text(dummyTexte.elementAt(new Random().nextInt(dummyTexte.length)))
                ],
              ),
            )),
      ),
      /*floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.save),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NewItemInput(_contact))))*/
    );
  }
}


