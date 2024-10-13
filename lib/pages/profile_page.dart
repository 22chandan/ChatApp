import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/auth/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phoneNumber;

  ProfilePage({
    super.key,
    required this.email,
    required this.name,
    required this.phoneNumber,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  Widget? imagePreview;

  @override
  void initState() {
    super.initState();
    getUserPhoto();
  }

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        List<int> compressedData = await FlutterImageCompress.compressWithList(
          await file.readAsBytes(),
          quality: 50, // Adjust the quality to control the level of compression
        );
        final encoded = base64Encode(compressedData);
        await HelperFunctions.SaveUserPhoto(encoded);
        await DataBaseService()
            .userCollection
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"profilePic": encoded});
        getUserPhoto(); // Refresh the image after updating
      }
    } catch (e) {
      // Handle error, if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
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
            const SizedBox(height: 15),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Divider(height: 2),
            ListTile(
              onTap: () {
                nextScreen(context, HomePage());
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title:
                  const Text("Groups", style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person),
              title:
                  const Text("Profile", style: TextStyle(color: Colors.black)),
            ),
            const ListTile(
              leading: Icon(Icons.share),
              title: Text("Share with your friends"),
            ),
            const ListTile(
              leading: Icon(Icons.support_agent),
              title: Text("Support"),
            ),
            const ListTile(
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
                      title: const Text("Log out"),
                      content: const Text("Are you sure you want to log out"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () async {
                            await authService.SignOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false,
                            );
                          },
                          child: const Text("OK",
                              style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    );
                  },
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title:
                  const Text("Logout", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Positioned(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: imagePreview ??
                        Icon(
                          Icons.account_circle,
                          size: 200,
                          color: Colors.grey[700],
                        ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          content: Container(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _pickImage(ImageSource.camera);
                                    },
                                    icon: const Icon(Icons.camera_alt_outlined,
                                        size: 50),
                                  ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    onPressed: () {
                                      _pickImage(ImageSource.gallery);
                                    },
                                    icon: const Icon(
                                        Icons.browse_gallery_outlined,
                                        size: 50),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name", style: TextStyle(fontSize: 17)),
                Text(widget.name, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Phone Number", style: TextStyle(fontSize: 17)),
                Text(widget.phoneNumber, style: const TextStyle(fontSize: 17)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Log out"),
                          content:
                              const Text("Are you sure you want to log out"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel",
                                  style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () async {
                                await authService.SignOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (route) => false,
                                );
                              },
                              child: const Text("OK",
                                  style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Log Out", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
