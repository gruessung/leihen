import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:oweapp4/Database.dart';
import 'package:oweapp4/HaldeModel.dart';
import 'package:intl/intl.dart';
import 'package:swipedetector/swipedetector.dart';

class ShowContactScreen extends StatefulWidget {
  final String kontaktName;

  ShowContactScreen(this.kontaktName);

  @override
  State<StatefulWidget> createState() {
    return ShowContactScreenState(kontaktName);
  }
}

class ShowContactScreenState extends State<ShowContactScreen> {
  final String kontaktName;
  Contact contact = null;

  _loadContact() async {
    if (contact == null) {
      print("lade Kontakt");
      Future<Iterable<Contact>> contacts =
          ContactsService.getContacts(query: kontaktName, withThumbnails: true);
      contacts.then((val) {
        print(val.elementAt(0).displayName);
        setState(() {
          contact = val.elementAt(0);
          data = DBProvider.db.getContactItems(kontaktName: kontaktName);
        });
      });
    }
  }

  ShowContactScreenState(this.kontaktName);

  Future<List<Halde>> data;

  Color _getColor(Halde halde) {
    print("getColor called");

    //catch null object
    if (halde == null) {
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
                      return Dismissible(
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("BILD"),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(halde.betreff,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                                Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 5,
                                                        horizontal: 0)),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 15,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 0,
                                                          horizontal: 2),
                                                    ),
                                                    Text(
                                                        (halde != null)
                                                            ? DateFormat(
                                                                    'dd.MM.yyyy')
                                                                .format(DateTime
                                                                    .fromMillisecondsSinceEpoch(
                                                                        halde
                                                                            .faellig))
                                                            : '',
                                                        style: TextStyle(
                                                            fontSize: 15))
                                                  ],
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
                          onDismissed: (direction) {
                            DBProvider.db.deleteHalde(halde);

                            //Datensatz aus dem aktuellen Snapshot löschen, da ansonsten das Dismissible nicht entfernt wird ^.^
                            snapshot.data.removeAt(index);

                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Gelöscht!')));

                            setState(() {
                              data = DBProvider.db
                                  .getContactItems(kontaktName: kontaktName);
                            });
                          },
                          background: Container(color: Colors.red));
                    });
              } else {
                return Center(child: Text("Keine Daten :("));
              }
            }));
  }
}
