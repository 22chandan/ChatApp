import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseService {
  final String? uid;
  DataBaseService({this.uid});
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference apicollection =
      FirebaseFirestore.instance.collection("OpenApi");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  Future<void> updataUserData(
      String fullName, String email, String Phone) async {
    await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
      "PhoneNumber": Phone,
      "Status": "",
    });
  }

  Future GettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  GetUserGroup() async {
    return await userCollection.doc(uid).snapshots();
  }

  getapi() async {
    return await apicollection.doc('api').get();
  }

  Future CreateGroup(
    String UserName,
    String UserId,
    String GroupName,
  ) async {
    DocumentReference GroupdocumentReference = await groupCollection.add({
      "groupName": GroupName,
      "groupIcons": "",
      "members": [],
      "admin": "${UserId}_${UserName}",
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime": ""
    });
    await GroupdocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_${UserName}"]),
      "groupId": GroupdocumentReference.id
    });
    DocumentReference UserDocumentReference = await userCollection.doc(uid);
    return await UserDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${GroupdocumentReference.id}_${GroupName}"])
    });
  }

  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  SearchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  Future<bool> IsUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future ToggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  Future sendMessage(String groupId, Map<String, dynamic> msg) async {
    await groupCollection.doc(groupId).collection('messages').add(msg);
    await groupCollection.doc(groupId).update({
      "recentMessage": msg['message'],
      "recentMessageSender": msg['sender'],
      "recentMessageTime": msg['time'].toString(),
    });
  }
}
