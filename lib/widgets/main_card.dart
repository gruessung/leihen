import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oweapp4/pages/show_items_to_contact_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class MainCard extends StatefulWidget {
  final Map<String, dynamic> oHalde;
  final BuildContext context;

  MainCard({@required this.oHalde, @required this.context});

  @override
  State<StatefulWidget> createState() {
    return MainCardState(oHalde: oHalde, context: context);
  }
}

class MainCardState extends State<MainCard> {
  MainCardState({@required this.oHalde, @required this.context});

  final Map<String, dynamic> oHalde;
  final BuildContext context;
  Contact contact;
  String sKontaktName;
  PermissionStatus permissionStatusHolder = null;


  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled &&
    permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  _loadContact() async {

    if (permissionStatusHolder == null) {
      PermissionStatus permissionStatus = await _getContactPermission();
      permissionStatusHolder = permissionStatus;
    }


    if (contact == null ) {

      if (oHalde["kontaktId"] !=  '0' && permissionStatusHolder == PermissionStatus.granted) {

        Future<Iterable<Contact>> contacts = ContactsService.getContacts(
            query: oHalde["kontaktName"], withThumbnails: true);
        contacts.then((val) {
          setState(() {
            contact = val.elementAt(0);
            sKontaktName = val
                .elementAt(0)
                .displayName;
          });
        });
      } else {
        setState(() {
          contact = null;
          sKontaktName = oHalde['kontaktName'];
        });
      }
    }
  }

  void _onTapped() {
    /*showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Tapped!"),
          content: new Text("ID: " + oHalde["kontaktName"]),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );*/
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ShowItemsToContactScreen(oHalde["kontaktName"])));
  }

  @override
  Widget build(BuildContext context) {
    _loadContact();

    if (sKontaktName != null) {
     // print("Name: " + sKontaktName);
      return InkWell(
          onTap: _onTapped,
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    (contact != null && contact.avatar != null)
                        ? CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 35,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.memory(contact.avatar)),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 35,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Icon(
                                  Icons.people_outline,
                                  color: Colors.black,
                                )),
                          ),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(sKontaktName,
                                style: TextStyle(
                                    fontSize: 20, fontStyle: FontStyle.normal)),
                            Text("Du hast dir " +
                                ((oHalde["geliehen"] == 0)
                                    ? "keinen Gegenstand"
                                    : ((oHalde["geliehen"] == 1)
                                        ? "einen Gegenstand"
                                        : oHalde["geliehen"].toString() +
                                            " Gegenstände ")) +
                                " geliehen."),
                            Text("Du hast " +
                                ((oHalde["verliehen"] == 0)
                                    ? "keinen Gegenstand"
                                    : ((oHalde["verliehen"] == 1)
                                        ? "einen Gegenstand"
                                        : oHalde["verliehen"].toString() +
                                            " Gegenstände ")) +
                                " verliehen.")
                          ],
                        )),
                  ],
                ),
              )));
    } else {
      return Card(
          child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CircularProgressIndicator()),
          ),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text('Lade...',
                      style:
                          TextStyle(fontSize: 20, fontStyle: FontStyle.normal)),
                ],
              )),
        ],
      ));
    }
  }
}
