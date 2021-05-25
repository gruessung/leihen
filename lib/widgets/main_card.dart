import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oweapp4/pages/show_items_to_contact_screen.dart';
import 'package:oweapp4/services/AppLocalizations.dart';
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
  bool alreadySearched = false;

  Future<PermissionStatus> _getContactPermission() async {
    try {
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
    } catch(e) {
      print('Error: ' + e.toString());
      return PermissionStatus.unknown;
    }
  }

  _loadContact() async {
    if (permissionStatusHolder == null) {
      PermissionStatus permissionStatus = await _getContactPermission();
      permissionStatusHolder = permissionStatus;
    }

    if (contact == null && !alreadySearched) {
      print(oHalde);
      if (oHalde["kontaktId"] != '0' &&
          permissionStatusHolder == PermissionStatus.granted) {
        Future<Iterable<Contact>> contacts = ContactsService.getContacts(
            query: oHalde["kontaktName"], withThumbnails: true);
        contacts.then((val) {
          setState(() {
            contact = val.elementAt(0);
            sKontaktName = oHalde["kontaktName"];
            alreadySearched = true;
          });
        });
      } else {
        setState(() {
          contact = null;
          sKontaktName = oHalde['kontaktName'];
          alreadySearched = true;
        });
      }
    }
  }

  void _onTapped() {
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
                            Text(AppLocalizations.of(context).translate(
                                _getTranslationText(
                                    'borrow', oHalde['geliehen']),
                                [oHalde['geliehen'].toString()])),
                            Text(AppLocalizations.of(context).translate(
                                _getTranslationText(
                                    'lend', oHalde['verliehen']),
                                [oHalde['verliehen'].toString()]))
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

  /**
   * Erzeugt den Translation Key für die Main Card
   */
  String _getTranslationText(String type, int cntItems) {
    String transTextKey = '';
    if (cntItems > 1) {
      transTextKey = 'overview_contact_summary_${type}_more';
    } else {
      transTextKey = 'overview_contact_summary_${type}_${cntItems.toString()}';
    }
    return transTextKey;
  }
}
