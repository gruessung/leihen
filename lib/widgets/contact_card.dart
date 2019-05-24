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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              (contact.avatar != null)
                  ? CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 15,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.memory(contact.avatar)),
                    )
                  : null,
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text((contact.displayName.length > 40) ? contact.displayName.substring(0, 40) : contact.displayName,
                      style: TextStyle(
                          fontSize: 16, fontStyle: FontStyle.normal))),
            ],
          ),
        ));
  }
}
