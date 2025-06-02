import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:asystent_ai/core/plant_detail.dart';
import 'package:asystent_ai/core/spinner.dart';
import 'package:flutter/material.dart';
import 'package:asystent_ai/style/style.dart';
import 'package:go_router/go_router.dart';
import 'package:asystent_ai/core/process_response_message.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class PredictionScreen extends StatefulWidget {
  final String? imagePath;
  final dynamic responseMessage;

  const PredictionScreen({
    Key? key,
    this.imagePath,
    required this.responseMessage,
  }) : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatHistory _chatHistory = ChatHistory();
  bool _isLoading = false;

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

  void _sendPhotoResponse() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1), () {
      final List<_ChatMessage> botMessages = [];
      final dynamic plantList = processResponseMessage(widget.responseMessage);
      if (plantList is List) {
        for (var item in plantList) {
          if (item is Map<String, dynamic>) {
            botMessages.add(_ChatMessage(plantData: item, isUser: false));
          } else if (item is String) {
            botMessages.add(_ChatMessage(text: item, isUser: false));
          }
        }
      } else {
        // Jeśli responseMessage nie jest listą, obsłuż jako pojedynczy tekst
        if (plantList is String) {
          botMessages.add(_ChatMessage(text: plantList, isUser: false));
        }
      }

      setState(() {
        _isLoading = false;
        _chatHistory.messages.addAll(botMessages);
        _chatHistory.messages.add(
          _ChatMessage(
            text: "Do you want to know something about it?",
            isUser: false,
          ),
        );
      });
    });
  }

  Future<String> _sendMessageToEndpoint(String text) async {
    try {
      final uri = Uri.parse('https://small-szyc.fly.dev/chat/generate');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {"role": "assistant", "content": text},
          ],
          "model": "gpt-4o-mini",
          "maxTokens": 5000,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        return 'Success: $responseBody';
      } else {
        return 'Failed: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error sending message: $e';
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.messages.add(_ChatMessage(text: text, isUser: true));
    });

    _sendMessageToEndpoint(
      widget.responseMessage.toString() + ' Question: ' + text,
    ).then((response) {
      String? markdownContent;

      if (response.startsWith('Success: ')) {
        try {
          final jsonPart = response.replaceFirst('Success: ', '').trim();
          log('Response: $jsonPart');
          final Map<String, dynamic> decoded = jsonDecode(jsonPart);
          markdownContent = decoded['message']['content']?.toString();
        } catch (e) {
          markdownContent = 'Error parsing response';
        }
      } else {
        markdownContent = response;
      }

      setState(() {
        _chatHistory.messages.add(
          _ChatMessage(markdown: markdownContent, isUser: false),
        );
      });
    });

    _controller.clear();
    return;

    // setState(() {
    //   _chatHistory.messages.add(_ChatMessage(text: text, isUser: true));
    //   _chatHistory.messages.add(_ChatMessage(text: response, isUser: false));
    // });

    // _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _chatHistory.messages;

    return Scaffold(
      backgroundColor:
          _isLoading
              ? AppStyles.backgroundColor
              : AppStyles.backgroundPrediction,
      body:
          _isLoading
              ? const Center(child: Spinner())
              : Stack(
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
                              message.isUser
                                  ? AppStyles.backgroundColor
                                  : Colors.grey.shade100;

                          final textColor =
                              message.isUser ? Colors.white : Colors.black87;

                          if (message.imagePath != null) {
                            // wyświetlanie obrazu (bez zmian)
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
                          } else if (message.plantData != null) {
                            // wyświetlanie danych rośliny jako widgetu
                            return Align(
                              alignment: alignment,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: AppStyles.borderRadius,
                                ),
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: PlantDetailsWidget(
                                  plant: message.plantData!,
                                ),
                              ),
                            );
                          } else if (message.markdown != null) {
                            // wyświetlanie markdown jako HTML
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
                                child: MarkdownBody(
                                  data: message.markdown ?? '',
                                ),
                              ),
                            );
                          } else {
                            // wyświetlanie zwykłego tekstu
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
                      child: Text('Chat', style: AppStyles.titleTextStyle),
                    ),
                  ),
                  Positioned(
                    top: 45,
                    left: 10,
                    child: FloatingActionButton(
                      onPressed: () => context.go('/'),
                      backgroundColor: AppStyles.backgroundColor,
                      foregroundColor: AppStyles.iconTheme.color,
                      heroTag: 'back',
                      child: Icon(
                        Icons.arrow_back,
                        size: AppStyles.iconTheme.size,
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
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Ask something...',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  fillColor: Colors.grey[300],
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
  final String? markdown;
  final String? imagePath;
  final Map<String, dynamic>? plantData;
  final bool isUser;

  _ChatMessage({
    this.text,
    this.markdown,
    this.imagePath,
    this.plantData,
    required this.isUser,
  });
}

class ChatHistory {
  static final ChatHistory _instance = ChatHistory._internal();

  factory ChatHistory() => _instance;

  ChatHistory._internal();

  final List<_ChatMessage> messages = [];
  String? lastImagePath;
}
