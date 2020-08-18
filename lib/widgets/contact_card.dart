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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 15,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: (contact.avatar.isNotEmpty)
                        ? Image.memory(contact.avatar)
                        : Icon(Icons.face_outlined, color: Colors.white)),
              ),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      (contact.displayName.length > 40)
                          ? contact.displayName.substring(0, 40)
                          : contact.displayName,
                      style: TextStyle(
                          fontSize: 16, fontStyle: FontStyle.normal))),
            ],
          ),
        ));
  }
}
