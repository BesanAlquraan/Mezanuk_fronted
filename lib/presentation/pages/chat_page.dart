import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/domain/models/faq.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../presentation/state/settings_store.dart';

class ChatAIPage extends StatefulWidget {
  const ChatAIPage({super.key});

  @override
  State<ChatAIPage> createState() => _ChatAIPageState();
}

class _ChatAIPageState extends State<ChatAIPage> {
  bool showChatList = false;
  final TextEditingController _controller = TextEditingController();
  String? selectedAnswer;

  final List<FAQ> faqs = [
    FAQ(question: 'faq_website_question', answer: 'faq_website_answer'),
    FAQ(question: 'faq_contact_question', answer: 'faq_contact_answer'),
    FAQ(question: 'faq_services_question', answer: 'faq_services_answer'),
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    print('Message sent: ${_controller.text}');
    _controller.clear();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      print('Picked file: ${file.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsStore = Provider.of<SettingsStore>(context);
    final t = settingsStore.translations;

    double screenWidth = MediaQuery.of(context).size.width;

    Widget chatList = Container(
      width: 250,
      color: kPrimaryColor,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            title: Text(t.of('chats'), style: TextStyle(color: kTextLightColor)),
            trailing: IconButton(
              icon: Icon(Icons.close, color: kTextLightColor),
              onPressed: () => setState(() => showChatList = false),
            ),
          ),
          Divider(color: kDividerColor),
          ListTile(title: Text('${t.of('chat')} 1', style: TextStyle(color: kTextLightColor))),
          ListTile(title: Text('${t.of('chat')} 2', style: TextStyle(color: kTextLightColor))),
          ListTile(title: Text('${t.of('chat')} 3', style: TextStyle(color: kTextLightColor))),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          t.of('finchat'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTextLightColor,
          ),
        ),
        elevation: 0,
      ),
      drawer: screenWidth < 800 ? Drawer(child: chatList) : null,
      body: Row(
        children: [
          if (screenWidth >= 800 && showChatList) chatList,
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Image.asset(
                        'assets/V40BV49XiZ0JQ56385-unscreen.gif',
                        height: screenWidth < 600 ? 200 : 300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.of('chat_prompt'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: kTextLightColor),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: screenWidth * 0.7 > 700 ? 700 : screenWidth * 0.7,
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: kTextDarkColor),
                        decoration: InputDecoration(
                          hintText: t.of('chat_hint'),
                          filled: true,
                          fillColor: kCardBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.image, color: kIconColor),
                                onPressed: () => print('Pick image'),
                              ),
                              IconButton(
                                icon: Icon(Icons.attach_file, color: kIconColor),
                                onPressed: _pickFile,
                              ),
                              IconButton(
                                icon: Icon(Icons.send, color: kButtonPrimaryColor),
                                onPressed: _sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: faqs.map((faq) {
                        bool isSelected = selectedAnswer == faq.answer;

                        return StatefulBuilder(
                          builder: (context, setLocalState) {
                            bool isHovered = false;
                            return MouseRegion(
                              onEnter: (_) => setLocalState(() => isHovered = true),
                              onExit: (_) => setLocalState(() => isHovered = false),
                              child: GestureDetector(
                                onTap: () => setState(() => selectedAnswer = faq.answer),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? kCategoryBlue.withOpacity(0.2)
                                        : kCardBackgroundColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? kTextLightColor.withOpacity(0.4) : kDividerColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.of(faq.question),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: kTextLightColor),
                                      ),
                                      if (isSelected)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            t.of(faq.answer),
                                            style: TextStyle(color: kTextSecondaryColor),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
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
