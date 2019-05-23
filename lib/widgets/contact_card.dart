import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContactCard extends StatelessWidget {
  Contact contact;

  ContactCard(this.contact);

  @override
  Widget build(BuildContext context) {

    if (contact == null) {
      return Text("Fehler beim Laden");
    }

    return Card(
        child: Row(
          children: <Widget>[
            (contact.avatar != null)
                ? CircleAvatar(
              radius: 35,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.memory(contact.avatar)),
            )
                : CircleAvatar(
              radius: 35,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Icon(
                    Icons.people_outline,
                    color: Colors.white,
                  )),
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(contact.displayName,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal))),
          ],
        ));
  }
}
