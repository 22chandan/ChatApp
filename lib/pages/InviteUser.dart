import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class ContactListPage extends StatefulWidget {
  final String UserName;
  ContactListPage({required this.UserName});
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  bool Granted = false;
  bool isloading = true;
  Future<void> _getContacts() async {
    PermissionStatus status = await Permission.contacts.request();
    if (status.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
      });
      isloading = false;
    } else {
      Get.snackbar("Denied the Contact permission",
          "Please Allow the Permission to Access the Contact");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Contact List'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  "Create A Community",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    popupDailog(context);
                  },
                  iconSize: 50,
                ),
              ),
            ),
            Divider(
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  "Invite Your Friends to Join your Groups",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Divider(
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            isloading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        Contact contact = _contacts[index];
                        return contact.phones?.isNotEmpty == true &&
                                contact.displayName != null
                            ? ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/login.png'),
                                ),
                                title: Text(contact.displayName ?? ''),
                                subtitle:
                                    Text(contact.phones?.first?.value ?? ''),
                                trailing: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () {
                                    _inviteContact(contact);
                                  },
                                  child: Text('Invite'),
                                ))
                            : Container();
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _inviteContact(Contact contact) {
    String message =
        'Hello, ${contact.displayName}! Check out this amazing app. Here you can Create Community and talk to each other , Here you Get Many Paid Courses for Free . App:-  ';
    Share.share(message);
  }

  String groupName = "";
  bool _isloading = false;
  popupDailog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text(
                "Create a Groups",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isloading == true
                      ? const CircularProgressIndicator()
                      : TextField(
                          onChanged: (value) {
                            setState(() {
                              groupName = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20))),
                        )
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: () async {
                      if (groupName != "") {
                        setState(() {
                          _isloading = true;
                        });
                        await DataBaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .CreateGroup(
                                widget.UserName,
                                FirebaseAuth.instance.currentUser!.uid,
                                groupName)
                            .whenComplete(() {
                          setState(() {
                            _isloading = false;
                          });
                        });
                        Navigator.pop(context);
                        showsnackbar(context, Colors.green,
                            "Group Created Successfully");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    child: Text("Create "))
              ],
            );
          });
        });
  }
}
