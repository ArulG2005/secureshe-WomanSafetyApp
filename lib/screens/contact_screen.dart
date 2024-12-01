import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Map<String, String>> trustedContacts = [];

  @override
  void initState() {
    super.initState();
    _loadTrustedContacts();
  }

  Future<void> _loadTrustedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedContacts = prefs.getStringList('trustedContacts');

    if (savedContacts != null) {
      setState(() {
        trustedContacts = savedContacts.map((contact) {
          var parts = contact.split(':');
          return {
            'name': parts[0].trim(),
            'phone': parts[1].trim(),
          };
        }).toList();
      });
    }
  }

  Future<void> _addTrustedContact(String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      trustedContacts.add({'name': name, 'phone': phone});
      List<String> contactStrings = trustedContacts
          .map((contact) => "${contact['name']}: ${contact['phone']}")
          .toList();
      prefs.setStringList('trustedContacts', contactStrings);
    });
  }

  Future<void> _removeTrustedContact(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      trustedContacts.removeAt(index);
      List<String> contactStrings = trustedContacts
          .map((contact) => "${contact['name']}: ${contact['phone']}")
          .toList();
      prefs.setStringList('trustedContacts', contactStrings);
    });
  }

  void _showAddTrustedContactDialog() {
    String name = '';
    String phone = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Trusted Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(hintText: "Enter name"),
              ),
              TextField(
                onChanged: (value) {
                  phone = value;
                },
                decoration: InputDecoration(hintText: "Enter phone number"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (name.isNotEmpty && phone.isNotEmpty) {
                  _addTrustedContact(name, phone);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both fields')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text(
              'Are you sure you want to delete ${trustedContacts[index]['name']}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                _removeTrustedContact(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trusted Contacts'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: trustedContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(trustedContacts[index]['name']!),
                  subtitle: Text(trustedContacts[index]['phone']!),
                  onLongPress: () {
                    _showDeleteConfirmationDialog(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTrustedContactDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Trusted Contact',
      ),
    );
  }
}
