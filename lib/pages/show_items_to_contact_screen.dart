import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:oweapp4/Database.dart';
import 'package:oweapp4/HaldeModel.dart';
import 'package:intl/intl.dart';
import 'package:oweapp4/pages/input_item_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:image_crop/image_crop.dart';

import '../main.dart';

class ShowItemsToContactScreen extends StatefulWidget {
  final String kontaktName;

  ShowItemsToContactScreen(this.kontaktName);

  @override
  State<StatefulWidget> createState() {
    return ShowItemsToContactScreenState(kontaktName);
  }
}

class ShowItemsToContactScreenState extends State<ShowItemsToContactScreen> {
  final String kontaktName;
  Contact contact = null;

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


    if (contact == null && data == null) {

      /*
      Future<Iterable<Contact>> contacts =
          ContactsService.getContacts(query: kontaktName, withThumbnails: true);
      contacts.then((val) {
        print(val.elementAt(0).displayName);
        setState(() {
          contact = val.elementAt(0);
        });
      });*/

      setState(() {
        data = DBProvider.db.getContactItems(kontaktName: kontaktName);
      });
    }
  }

  ShowItemsToContactScreenState(this.kontaktName);

  Future<List<Halde>> data;

  Color _getColor(Halde halde) {
    print("getColor called");

    //catch null object
    if (halde == null || halde.faellig == null) {
      return Colors.white;
    }

    DateTime faellig = DateTime.fromMillisecondsSinceEpoch(halde.faellig);
    print(halde.faellig);

    int daysDiff = faellig.difference(DateTime.now()).inDays;
    print("Days Diff: " + daysDiff.toString());

    if (daysDiff < 2) {
      return Colors.red;
    }
    if (daysDiff <= 5) {
      return Colors.yellow;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    _loadContact();

    return Scaffold(
        appBar: AppBar(
          title: Text(kontaktName),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
        ),
        body: FutureBuilder<List<Halde>>(
            future: this.data,
            builder:
                (BuildContext context, AsyncSnapshot<List<Halde>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      print("Index: " + index.toString());
                      Halde halde = snapshot.data[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => InputItemScreen(null, halde)));
                        },
                        child: Dismissible(
                            key: Key(halde.betreff),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 5),
                                  child: Card(
                                      child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 5,
                                        child: LinearProgressIndicator(
                                          backgroundColor: _getColor(halde),
                                          value: 0,
                                        ),
                                      ),
                                      (halde.fotoPfad.isNotEmpty ||
                                              (halde.fotoPfad.isEmpty &&
                                                  halde.beschreibung.isNotEmpty))
                                          ? (ItemPictureWidget(
                                              fotoPfad: halde.fotoPfad,
                                              beschreibung: halde.beschreibung,
                                            ))
                                          : Container(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(children: <Widget>[
                                                    (halde.typ == 1)
                                                        ? Icon(Icons.redo)
                                                        : Icon(Icons.undo),
                                                    Container(
                                                        width: 10, height: 1),
                                                    Text(halde.betreff,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontStyle:
                                                                FontStyle.normal))
                                                  ]),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5,
                                                          horizontal: 0)),
                                                  DatumsZeile(
                                                    halde: halde,
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                )
                              ],
                            ),
                            confirmDismiss: (direction) {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Eintrag löschen'),
                                    content: Text('Bist du sicher?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          // Navigator.pop(context, false);
                                          Navigator.of(
                                            context,
                                            // rootNavigator: true,
                                          ).pop(false);
                                        },
                                        child: Text('Nein'),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          // Navigator.pop(context, true);
                                          Navigator.of(
                                            context,
                                            // rootNavigator: true,
                                          ).pop(true);
                                        },
                                        child: Text('Ja'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              // Eintrag aus DB entfernen
                              DBProvider.db.deleteHalde(halde);

                              //Datensatz aus dem aktuellen Snapshot löschen, da ansonsten das Dismissible nicht entfernt wird ^.^
                              snapshot.data.removeAt(index);

                              //Notification zeigen
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text('Gelöscht!')));

                              //Daten neu laden und State neu setzen
                              setState(() {
                                data = DBProvider.db
                                    .getContactItems(kontaktName: kontaktName);
                              });

                              if (snapshot.data.length == 0) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MyApp()));
                              }
                            },
                            background: Container(
                              color: Colors.red,
                              child: Center(child: Icon(Icons.delete_forever)),
                            )),
                      );
                    });
              } else {
                return Center(child: Text("Keine Daten :("));
              }
            }));
  }
}

class DatumsZeile extends StatelessWidget {
  final Halde halde;

  DatumsZeile({Key key, @required this.halde}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (halde != null && halde.faellig != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            size: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          ),
          Text(
              DateFormat('dd.MM.yyyy')
                  .format(DateTime.fromMillisecondsSinceEpoch(halde.faellig)),
              style: TextStyle(fontSize: 15))
        ],
      );
    } else {
      return Container();
    }
  }
}

/// Widget zum anzeigen des HeaderImages
/// @param String fotoPfad
class ItemPictureWidget extends StatelessWidget {
  final String fotoPfad;
  final String beschreibung;

  ItemPictureWidget(
      {Key key, @required this.fotoPfad, @required this.beschreibung})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (SizedBox(
        height: 184.0,
        child: Stack(children: <Widget>[
          Positioned.fill(
            child: Ink.image(
              image: (fotoPfad.isNotEmpty)
                  ? Image.file(File(fotoPfad)).image
                  : Image.asset('assets/background.jpg').image,
              fit: BoxFit.cover,
              child: Container(),
              colorFilter: (this.beschreibung.isNotEmpty)
                  ? (ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.srcOver))
                  : null,
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 16.0,
            right: 16.0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Text(
                this.beschreibung,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ])));
  }
}
