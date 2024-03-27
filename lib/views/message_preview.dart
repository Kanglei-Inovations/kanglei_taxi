import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kanglei_taxi/widget/common_widgets.dart';


class MessagePreview extends StatefulWidget {
  final String message;
  final String messageId;
  final String profile;
  final String name;
  final String type;
  final String date;

  MessagePreview({
    Key? key,
    required this.messageId,
    required this.message,
    required this.profile,
    required this.name, required this.type, required this.date,
  }) : super(key: key);

  @override
  _MessagePreviewState createState() => _MessagePreviewState();
}

class _MessagePreviewState extends State<MessagePreview> {
  late TextEditingController replyController;
  String reply = "";

  @override
  void initState() {
    super.initState();
    replyController = TextEditingController();
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply(String replyMessage, String messageId) async {
    try {
      await FirebaseFirestore.instance.collection('chat').doc('$messageId').update({
        'reply': replyMessage,
        'replydate': DateTime.now(),
        // Add other fields or identifiers if needed
      });
    } catch (error) {
      print('Error submitting reply: $error');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF836FFF),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
        automaticallyImplyLeading: true, // Add this line
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profile),
            ),
            SizedBox(width: 8),
            Text(widget.name),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            widget.type=="text"?
            Text(
              'User: ${widget.message}',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
              ),
            ):
            Container(
              margin: const EdgeInsets.only(
                  right: 10, top: 10),
              child: chatImage(
                  imageSrc: widget.message,
                  onTap: () {},
                  dateText: widget.date,
            ),
            ),
            SizedBox(height: 16),
            if (reply.isNotEmpty) ...[
              Text(
                'Admin: $reply',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
            ],
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: InputDecoration(
                          hintText: 'Type your reply here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        _submitReply(replyController.text, widget.messageId);
                        setState(() {
                          reply = replyController.text;
                        });
                        replyController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
