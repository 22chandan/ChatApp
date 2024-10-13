// ignore_for_file: file_names
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;

class APIService {
  final gemini = Gemini.instance;
  Future<String> getresultfromGemini(String userInput) async {
    try {
      final value = await gemini.text(
        "You are Chatting Assistance where you are going to help the user to talk in a formal way and solve programming questions if they ask. Please answer briefly and provide only valid answers. Only reply in a paragraph. The user input is: ${userInput}",
      );

      if (value != null &&
          value.content != null &&
          value.content!.parts != null &&
          value.content!.parts!.isNotEmpty) {
        return value.content!.parts![0].text!;
      } else {
        throw Exception("Invalid response from Gemini service");
      }
    } catch (e) {
      log("Error in getresultfromGemini: $e");
      throw Exception("Failed to fetch result from Gemini. Please try again.");
    }
  }
}
