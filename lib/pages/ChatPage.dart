import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/apiservice.dart';
import 'package:chatapp/pages/groupInfo.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:chatapp/widgets/messageTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String UserName;
  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.UserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  final ValueNotifier<String> responseNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    super.initState();
    getChatsandAdmin();
  }

  Future<void> sendRequestToOpenAI(String userInput) async {
    isLoadingNotifier.value = true; // Start loading indicator

    try {
      String output = await APIService().getresultfromGemini(userInput);
      log('Response from OpenAI: $output');
      responseNotifier.value = output; // Update the response in the notifier
    } catch (error) {
      log('Error during API call: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI response: $error')),
      );
    } finally {
      isLoadingNotifier.value = false; // Stop loading indicator
    }
  }

  void getChatsandAdmin() {
    DataBaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });

    DataBaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.UserName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DataBaseService()
          .sendMessage(widget.groupId, chatMessageMap)
          .then((result) {
        // Ensure result is not null before proceeding
        if (result != null) {
          messageController.clear();
        } else {
          log('Send message returned null');
        }
      }).catchError((error) {
        log('Error sending message: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                context,
                GroupInfo(
                  GroupId: widget.groupId,
                  GroupName: widget.groupName,
                  adminName: admin,
                ),
              );
            },
            icon: const Icon(Icons.info),
          )
        ],
      ),
      body: Stack(
        children: [
          chatMessages(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              color: Colors.grey,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      _showAiDialog();
                    },
                    icon: const Icon(Icons.adb, color: Colors.white),
                    tooltip: 'Ask AI',
                  ),
                  IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 70),
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              index = snapshot.data.docs.length - 1 - index;
              return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sendBy: widget.UserName == snapshot.data.docs[index]['sender'],
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _showAiDialog() {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ask AI a question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          InputDecoration(hintText: 'Enter your text here'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendRequestToOpenAI(_controller.text);
                    },
                    icon:
                        Icon(Icons.send, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, _) {
                  return isLoading
                      ? CircularProgressIndicator()
                      : ValueListenableBuilder<String>(
                          valueListenable: responseNotifier,
                          builder: (context, response, _) {
                            return Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(8),
                                child: MarkdownBody(data: response),
                              ),
                            );
                          },
                        );
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.red, size: 30),
                    onPressed: () {
                      responseNotifier.value = "";
                      sendRequestToOpenAI(_controller.text);
                    },
                  ),
                  InkWell(
                    onTap: () {
                      if (responseNotifier.value.isNotEmpty) {
                        messageController.text = responseNotifier.value;
                        sendMessage();
                      } else {
                        log('AI response is empty');
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Accept",
                      style: TextStyle(color: Colors.green, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
