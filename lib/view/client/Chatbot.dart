import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:senior_project/controller/ChatController.dart';
import 'package:senior_project/model/chatbot_model.dart';


class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ChatController _controller = ChatController();
  final TextEditingController _messageController = TextEditingController();
  List<ChatQuestion> _apiQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final questions = await _controller.fetchQuestions();
    setState(() => _apiQuestions = questions);
  }

  void _handleSendMessage(String text, {int? questionId}) async {
    if (text.trim().isEmpty) return;

    String userMsg = text.trim();
    _messageController.clear();

    await _controller.saveMessage(userMsg, true);

    String botReply;
    if (questionId != null) {
      botReply = await _controller.fetchAnswer(questionId);
    } else {
      botReply = "I'm sorry, I didn't quite catch that. Please use the suggested questions.";
    }

    Future.delayed(const Duration(seconds: 1), () async {
      await _controller.saveMessage(botReply, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _buildAppBar(isTablet),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _controller.getMessagesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return _buildChatBubble(data['text'] ?? '', data['isMe'] ?? false, screenWidth);
                      },
                    );
                  },
                ),
              ),
              _buildQuickReplies(),
              _buildInputArea(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _apiQuestions.length,
        itemBuilder: (context, index) {
          final q = _apiQuestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(q.question),
              onPressed: () => _handleSendMessage(q.question, questionId: q.id),
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(color: Color(0xFFE55757), fontSize: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(double screenWidth) {
    return Container(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 10, screenWidth * 0.05, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (val) => _handleSendMessage(val),
                decoration: const InputDecoration(hintText: "Ask me something...", border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _handleSendMessage(_messageController.text),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF1A1A1A),
              radius: 25,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE55757),
            child: Icon(Icons.support_agent, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Garage Support", style: TextStyle(color: Colors.black, fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold)),
              const Text("Bot Assistant", style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, double screenWidth) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 12),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: screenWidth < 350 ? 13 : 15)),
      ),
    );
  }
}