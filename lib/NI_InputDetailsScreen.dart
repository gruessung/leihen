import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oweapp4/Database.dart';
import 'package:oweapp4/HaldeModel.dart';
import 'package:oweapp4/pages/homescreen_page.dart';
import 'dart:async';

import 'package:oweapp4/widgets/contact_card.dart';

class NewItemInput extends StatefulWidget {
  final Contact contact;

  NewItemInput(this.contact);

  @override
  State<StatefulWidget> createState() {
    return NewItemInputState(contact);
  }
}

class NewItemInputState extends State<NewItemInput> {
  Contact contact;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var txt = new TextEditingController();

  String sItem;
  String sBeschreibung;
  String sDatum = '';
  bool bSwitch = true;
  int iTimestamp;
  String sKontaktNameFallback;

  NewItemInputState(this.contact);

  _onItemSavePress() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      DBProvider.db.newHalde(Halde(
          kontaktId: (contact != null) ? contact.identifier : '0',
          kontaktName: (contact != null) ? contact.displayName : sKontaktNameFallback,
          beschreibung: sBeschreibung,
          faellig: iTimestamp,
          fotoPfad: (_image == null) ? '' : _image.path,
          betreff: sItem,
          erstellt: DateTime.now().millisecondsSinceEpoch,
          typ: (bSwitch) ? 1 : 0));

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
        lastDate: new DateTime(2025));

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
  Widget build(BuildContext context) {
    String kontaktName = '';
    if (contact != null) {
      kontaktName = contact.displayName;
    }
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Neuer Eintrag'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    (contact != null) ? ContactCard(contact) : TextFormField(
                      obscureText: false,
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
                          // ignore: missing_return

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
                        title: Text(
                            'Leihst du ' + kontaktName + ' etwas aus?'),
                        value: bSwitch,
                        onChanged: (bool val) {
                          setState(() {
                            bSwitch = val;
                          });
                        },
                        secondary: const Icon(Icons.account_balance)),
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
