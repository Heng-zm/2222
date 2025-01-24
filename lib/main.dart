import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(TelegramBotDashboard());
}

class TelegramBotDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String botToken =
      "6939592836:AAG7n24o5-tpq9UhKVGmBNCag0nh4F60jT0"; // Replace with your Telegram bot token
  final String chatId = "1272791365"; // Replace with your chat ID

  TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  Future<void> sendMessage(String text) async {
    final url = Uri.parse("https://api.telegram.org/bot$botToken/sendMessage");
    final response = await http.post(url, body: {
      "chat_id": chatId,
      "text": text,
    });

    if (response.statusCode == 200) {
      setState(() {
        messages.add("You: $text");
      });
    } else {
      print("Failed to send message: ${response.body}");
    }
  }

  Future<void> sendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;
      final url =
          Uri.parse("https://api.telegram.org/bot$botToken/sendDocument");
      final request = http.MultipartRequest("POST", url);

      request.fields["chat_id"] = chatId;
      request.files.add(
        await http.MultipartFile.fromPath("document", file.path!),
      );

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            messages.add("File sent: ${file.name}");
          });
        } else {
          final responseData = await http.Response.fromStream(response);
          print("Failed to send file: ${responseData.body}");
        }
      } catch (e) {
        print("Error sending file: $e");
      }
    }
  }

  Future<void> sendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final url = Uri.parse("https://api.telegram.org/bot$botToken/sendPhoto");
      final request = http.MultipartRequest("POST", url);

      request.fields["chat_id"] = chatId;
      request.files.add(
        await http.MultipartFile.fromPath("photo", image.path),
      );

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            messages.add("Image sent");
          });
        } else {
          final responseData = await http.Response.fromStream(response);
          print("Failed to send image: ${responseData.body}");
        }
      } catch (e) {
        print("Error sending image: $e");
      }
    }
  }

  Future<void> getUpdates() async {
    final url = Uri.parse("https://api.telegram.org/bot$botToken/getUpdates");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        messages.addAll(
          (data["result"] as List)
              .map((update) => "Bot: ${update["message"]["text"]}")
              .toList(),
        );
      });
    } else {
      print("Failed to get updates: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Telegram Bot Dashboard"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "Enter message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(messageController.text);
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: sendFile,
                child: Text("Send File"),
              ),
              ElevatedButton(
                onPressed: sendImage,
                child: Text("Send Image"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
