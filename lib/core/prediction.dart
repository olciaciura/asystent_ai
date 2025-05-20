import 'dart:io';
import 'package:flutter/material.dart';
import 'package:asystent_ai/style/style.dart';

class PredictionScreen extends StatefulWidget {
  final String? imagePath;

  const PredictionScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatHistory _chatHistory = ChatHistory();

  @override
  void initState() {
    super.initState();

    if (widget.imagePath != null &&
        widget.imagePath != _chatHistory.lastImagePath) {
      _chatHistory.messages.add(
        _ChatMessage(imagePath: widget.imagePath, isUser: true),
      );

      _chatHistory.lastImagePath = widget.imagePath;

      _sendPhotoResponse();
    }
  }

  void _sendPhotoResponse() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _chatHistory.messages.add(
          _ChatMessage(
            text:
                "I see the photo you sent! What would you like to know about it?",
            isUser: false,
          ),
        );
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.messages.add(_ChatMessage(text: text, isUser: true));
      _chatHistory.messages.add(
        _ChatMessage(text: "Bot response to: \"$text\"", isUser: false),
      );
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _chatHistory.messages;

    return Scaffold(
      backgroundColor: Colors.white30,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final alignment =
                      message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                  final background =
                      message.isUser ? Colors.blue[200] : Colors.grey.shade300;

                  final textColor =
                      message.isUser ? Colors.white : Colors.black87;

                  if (message.imagePath != null) {
                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(message.imagePath!),
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: AppStyles.borderRadius,
                        ),
                        child: Text(
                          message.text ?? '',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              padding: AppStyles.padding,
              decoration: BoxDecoration(
                color: AppStyles.backgroundColor,
                borderRadius: AppStyles.borderRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text('Prediction Chat', style: AppStyles.titleTextStyle),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask something...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          fillColor: Colors.white10,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _sendMessage,
                      backgroundColor: AppStyles.backgroundColor,
                      foregroundColor: AppStyles.iconTheme.color,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String? text;
  final String? imagePath;
  final bool isUser;

  _ChatMessage({this.text, this.imagePath, required this.isUser});
}

class ChatHistory {
  static final ChatHistory _instance = ChatHistory._internal();

  factory ChatHistory() => _instance;

  ChatHistory._internal();

  final List<_ChatMessage> messages = [];
  String? lastImagePath;
}
