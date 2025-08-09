import 'package:flutter/material.dart';

class AIAgentScreen extends StatefulWidget {
  const AIAgentScreen({super.key});

  @override
  State<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends State<AIAgentScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages =
      []; // {role: 'user'/'bot', text: '...'}

  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({'role': 'bot', 'text': 'Tôi có thể giúp gì cho bạn?'});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal : Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Ô nhập tin nhắn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
