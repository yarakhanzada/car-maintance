// chat_controller.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_project/model/chatbot_model.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/token_service.dart';

import '../../services/api_helper.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<ChatQuestion>> fetchQuestions() async {
    try {
      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/chatbot/questions",
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        return data.map((q) => ChatQuestion.fromJson(q)).toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<String> fetchAnswer(int id) async {
    try {
      final response = await ApiHelper.get(
        "${ApiConfig.baseUrl}/v1/chatbot/questions/$id",
      );
      print(response.body);
      print(
        "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&777777777777777",
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['data']['answer'];
      }
    } catch (e) {
      print(e);
    }
    return "I'm sorry, I couldn't fetch the answer right now.";
  }

  Future<void> saveMessage(String text, bool isMe) async {
    String? currentUserId = await TokenService.getID();
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('messages')
          .add({
            'text': text,
            'isMe': isMe,
            'createdAt': FieldValue.serverTimestamp(),
          });

      print("Firebase logic bypassed for testing.");
    } catch (e) {
      print("Error: $e");
    }
  }

  Stream<QuerySnapshot> getMessagesStream() async* {
    String? currentUserId = await TokenService.getID();

    if (currentUserId != null) {
      yield* _firestore
          .collection('users')
          .doc(currentUserId.trim())
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }
}
