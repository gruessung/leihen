import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oweapp4/services/Database.dart';
import 'package:oweapp4/services/HaldeModel.dart';
import 'package:oweapp4/pages/homescreen_page.dart';
import 'dart:async';

import 'package:oweapp4/widgets/contact_card.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class InputItemScreen extends StatefulWidget {
  final Contact contact;
  final Halde editItem;

  InputItemScreen(this.contact, this.editItem);

  @override
  State<StatefulWidget> createState() {
    return InputItemScreenState(this.contact, this.editItem);
  }
}

class InputItemScreenState extends State<InputItemScreen> {
  Contact contact;
  Halde editItem;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var txt = new TextEditingController();

  String sItem;
  String sBeschreibung;
  String sDatum = '';
  bool bSwitch = true;
  int iTimestamp;
  String sKontaktNameFallback;
  bool bSwitchCal = false;

  InputItemScreenState(this.contact, this.editItem) {}

  _onItemSavePress() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Halde haldeToSave;

      if (this.editItem != null) {
        this.editItem.faellig = iTimestamp;
        this.editItem.beschreibung = sBeschreibung;
        this.editItem.betreff = sItem;
        this.editItem.fotoPfad = (_image == null) ? '' : _image.path;
        this.editItem.typ = (bSwitch) ? 1 :0;
        haldeToSave = this.editItem;
        DBProvider.db.deleteHalde(this.editItem);
      }
      else {
        haldeToSave = Halde(
            kontaktId: (contact != null) ? contact.identifier : '0',
            kontaktName:
            (contact != null) ? contact.displayName : sKontaktNameFallback,
            beschreibung: sBeschreibung,
            faellig: iTimestamp,
            fotoPfad: (_image == null) ? '' : _image.path,
            betreff: sItem,
            erstellt: DateTime.now().millisecondsSinceEpoch,
            typ: (bSwitch) ? 1 : 0);
      }


      //Kalendereintrag speichern
      if (iTimestamp != null && iTimestamp > 1000 && bSwitchCal)  {
        Event event = Event(
          title: haldeToSave.kontaktName + ': ' + haldeToSave.betreff,
          description: haldeToSave.beschreibung,
          startDate: DateTime.fromMillisecondsSinceEpoch(haldeToSave.faellig),
          endDate: DateTime.fromMillisecondsSinceEpoch(haldeToSave.faellig),
          allDay: true,
        );

        Add2Calendar.addEvent2Cal(event);
      }

      DBProvider.db.newHalde(haldeToSave);

      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Gespeichert!')));

      sleep1();
    }
  }

  Future sleep1() {
    return new Future.delayed(
        const Duration(seconds: 1),
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen())));
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2010),
        lastDate: new DateTime(2050));

    if (picked != null)
      setState(() {
        iTimestamp = picked.millisecondsSinceEpoch;
        sDatum = picked.day.toString() +
            '.' +
            picked.month.toString() +
            '.' +
            picked.year.toString();
        txt.text = sDatum;
      });
  }

  File _image = null;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (this.editItem != null) {
      print(this.editItem.typ);
      setState(() {
        this.bSwitch = (this.editItem.typ == 1) ? true : false;
        if (this.editItem.fotoPfad.isNotEmpty) {
          this._image = File(this.editItem.fotoPfad);
        }
        if (this.editItem.faellig != null) {
          this.txt.text = DateFormat('dd.MM.yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(this.editItem.faellig));
          this.iTimestamp = this.editItem.faellig;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String kontaktName = '';
    if (contact != null) {
      kontaktName = contact.displayName;
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: (this.editItem == null)
              ? Text('Neuer Eintrag')
              : Text('Eintrag bearbeiten'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    (contact != null)
                        ? ContactCard(contact)
                        : TextFormField(
                            obscureText: false,
                            initialValue: (this.editItem == null)
                                ? ''
                                : this.editItem.kontaktName,
                            enabled: (this.editItem == null) ? true : false,

                            // ignore: missing_return
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Bitte gib etwas ein.';
                              }
                            },
                            onSaved: (val) => sKontaktNameFallback = val,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Kontaktname'),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                    ),
                    TextFormField(
                      obscureText: false,
                      // ignore: missing_return
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Bitte gib etwas ein.';
                        }
                      },
                      onSaved: (val) => sItem = val,
                      initialValue:
                          (this.editItem == null) ? '' : this.editItem.betreff,

                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Worum geht es?'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                    ),
                    TextFormField(
                      obscureText: false,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      initialValue: (this.editItem == null)
                          ? ''
                          : this.editItem.beschreibung,
                      onSaved: (val) => sBeschreibung = val,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Beschreibung'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                    ),
                    GestureDetector(
                      onTap: _selectDate,
                      behavior: HitTestBehavior.opaque,
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: txt,
                          obscureText: false,
                          onSaved: (val) =>
                              sDatum = (val.isNotEmpty) ? val : '01.01.2050',
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Rückgabedatum'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                    ),
                    SwitchListTile(
                        title: Text('Leihst du ' + kontaktName + ' etwas aus?'),
                        value: bSwitch,
                        onChanged: (bool val) {
                          setState(() {
                            bSwitch = val;
                          });
                        },
                        secondary: const Icon(Icons.account_balance)),
                   /* SwitchListTile(
                        title: Text('Kalendereintrag erstellen'),
                        value: bSwitchCal,
                        onChanged: (bool val) {
                          setState(() {
                            bSwitchCal = val;
                          });
                        },
                        secondary: const Icon(Icons.calendar_today)),*/

                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 5)),
                    Divider(),
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: (_image == null)
                          ? (CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 20,
                              child: Icon(Icons.camera)))
                          : (Image.file(
                              _image,
                              width: 200,
                            )),
                    ),
                  ],
                ),
              )),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.save),
            onPressed: () => _onItemSavePress()));
  }
}
