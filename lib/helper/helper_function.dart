import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String profileImage = "";
  static String UserNumber = "USERNUMBERKEY";
  static String ProfileImage = "USER";
  static String apikey = "apikey";
  static String model = "model";
  static List<String> contact = [];

  // ignore: non_constant_identifier_names
  static Future<bool> SaveUserLoggedInStatus(bool isUserloggedin) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserloggedin);
  }

  static Future<bool> SaveUserEmail(String UserEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, UserEmail);
  }

  Future<void> saveContact(List<String> contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(contact as String, contact);
  }

  static Future<bool> SaveUserName(String UserName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, UserName);
  }

  static Future<bool> SaveUserPhone(String UserNum) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(UserNumber, UserNum);
  }

  static Future<bool> SaveUserPhoto(String Userphoto) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(ProfileImage, Userphoto);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<List<String>?> GetContacts() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getStringList(contact as String);
  }

  static Future<String?> getapikey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(apikey);
  }

  Future<void> saveapi(String apiKey1) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(apikey, apiKey1);
  }

  static Future<String?> getmodel() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(model);
  }

  Future<void> savemodel(String apiKey1) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(model, apiKey1);
  }

  static Future getUserName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future getUserPhoto() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(ProfileImage);
  }

  static Future getUseremail() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future getUserNumber() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(UserNumber);
  }

  Future<List<String>> getChatMessages(String groupId, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messages =
        prefs.getStringList('chatMessages_${groupId}_$userId');
    return messages ?? [];
  }

  //Will implement
  // sendMessage() async {
  //   if (messageController.text.isNotEmpty) {
  //     String groupId = widget.groupId;
  //     String userId = widget.UserName;
  //     String message = messageController.text;

  //     // Retrieve existing messages
  //     List<String> messages = await getChatMessages(groupId, userId);

  //     // Insert the new message at the beginning of the list
  //     messages.insert(0, message);

  //     // Save the messages in reverse order
  //     await saveChatMessages(groupId, userId, messages.reversed.toList());

  //     // Send the message to the database
  //     // ...

  //     setState(() {
  //       messageController.clear();
  //     });
  //   }
  // }

  // Future<List<String>> getChatMessages(String groupId, String userId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String>? messages =
  //       prefs.getStringList('chatMessages_$groupId_$userId');
  //   return messages?.reversed.toList() ?? [];
  // }
  // Future<void> saveChatMessages(
  //     String groupId, String userId, List<String> messages) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setStringList(
  //       'chatMessages_$groupId_$userId', messages.reversed.toList());
  // }
}
