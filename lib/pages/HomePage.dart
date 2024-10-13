import 'dart:convert';
import 'dart:typed_data';

import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/Addvedio.dart';
import 'package:chatapp/pages/InviteUser.dart';
import 'package:chatapp/pages/Search_page.dart';
import 'package:chatapp/pages/auth/login_page.dart';
import 'package:chatapp/pages/profile_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/GroupTile.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  String email = "";
  Stream? groups;
  String PhoneNumber = "";
  bool _isloading = false;
  String groupName = "";
  AuthService authService = new AuthService();
  @override
  void initState() {
    super.initState();
    GetUserDetails();
    getUserPhoto();
    getContacts();
    getapikey();
  }

  getapikey() async {
    DocumentSnapshot documentSnapshot = await DataBaseService().getapi();
    String s = documentSnapshot.get('api');
    String model = documentSnapshot.get('model');
    print(s);
    await HelperFunctions().saveapi(s);
    await HelperFunctions().savemodel(model);
    HelperFunctions.getapikey().then((value) {
      print("api key is $value");
    });
  }

  Future<void> getContacts() async {
    PermissionStatus status = await Permission.contacts.request();
    if (status.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();

      HelperFunctions().saveContact(contacts.cast<String>().toList());
    } else {}
  }

  Widget? imagePreview;

  void getUserPhoto() async {
    DocumentReference userDocumentReference = DataBaseService()
        .userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    // Check if the document exists and has a profilePic field
    if (documentSnapshot.exists && documentSnapshot['profilePic'] != null) {
      var encode = documentSnapshot['profilePic'];

      try {
        final List<int> decodedBytes = base64Decode(encode);

        // Check if the decoded bytes represent a valid image
        if (decodedBytes.isNotEmpty) {
          setState(() {
            imagePreview = Image.memory(
              Uint8List.fromList(decodedBytes),
              fit: BoxFit.cover,
              width: 190,
              height: 190,
            );
          });
        } else {
          // If decoded bytes are empty, show default icon
          setState(() {
            imagePreview = Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey[700],
            );
          });
        }
      } catch (e) {
        print("Error decoding image: $e"); // Log the error
        // If decoding fails, show default icon
        setState(() {
          imagePreview = Icon(
            Icons.account_circle,
            size: 200,
            color: Colors.grey[700],
          );
        });
      }
    } else {
      // Handle the case where the image is null or doesn't exist
      setState(() {
        imagePreview = Icon(
          Icons.account_circle,
          size: 200,
          color: Colors.grey[700],
        );
      });
    }
  }

  GetUserDetails() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        name = value;
      });
    });
    await HelperFunctions.getUseremail().then((value) {
      setState(() {
        email = value;
      });
    });
    await HelperFunctions.getUserNumber().then((value) {
      setState(() {
        PhoneNumber = value;
      });
    });
    //Getting All the user in stream
    await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .GetUserGroup()
        .then((value) {
      setState(() {
        groups = value;
      });
    });
  }

  String GetId(String Res) {
    return Res.substring(0, Res.indexOf("_"));
  }

  String GetName(String Res) {
    return Res.substring(Res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, Search_page());
              },
              icon: const Icon(Icons.search))
        ],
        title: const Text(
          "Groups",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              selected: true,
              selectedTileColor: Theme.of(context).primaryColor,
              onTap: () {},
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreen(
                    context,
                    ProfilePage(
                      name: name,
                      email: email,
                      phoneNumber: PhoneNumber,
                    ));
              },
              selected: false,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("Share with your friends"),
            ),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text("Support"),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text("Privacy Policy"),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Log out"),
                        content: Text("Are you sure you want to log out"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await authService.SignOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (route) => false);
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      );
                    });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: Container(
        // height: 60,
        // width: 80,
        child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ContactListPage(
                          UserName: name,
                        )),
              );
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => VideoRecordingScreen()),
              // );
              // popupDailog(context);
            },
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.comment_sharp,
              color: Colors.white,
              size: 30,
            )),
      ),
    );
  }

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
                                name,
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

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length > 0) {
                return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (BuildContext context, int index) {
                    int reverseIndex =
                        snapshot.data['groups'].length - index - 1;
                    return GroupTile(
                      UserName: snapshot.data['fullName'],
                      GroupId: GetId(snapshot.data['groups'][reverseIndex]),
                      groupName: GetName(snapshot.data['groups'][reverseIndex]),
                    );
                  },
                );
              } else {
                return NoGroupWidget();
              }
            } else {
              return NoGroupWidget();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }

  NoGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                popupDailog(context);
              },
              child: Icon(
                Icons.add_circle,
                color: Colors.grey[700],
                size: 75,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "You've not joined any groups, tap on add icon to create a group or you can also search from top search button.",
              textAlign: TextAlign.center,
              style: TextStyle(),
            )
          ]),
    );
  }
}
