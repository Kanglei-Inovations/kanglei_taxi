
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kanglei_taxi/conts/firebase/firestore_constants.dart';

class ChatMessages {
  String userId;
  String reply;
  Timestamp replydate;
  Timestamp date;
  String message;
  String type;

  ChatMessages(
      {required this.userId,
      required this.reply,
        required this.replydate,
      required this.date,
      required this.message,
      required this.type});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.userId: userId,
      FirestoreConstants.reply: reply,
      FirestoreConstants.replydate: replydate,
      FirestoreConstants.date: date,
      FirestoreConstants.message: message,
      FirestoreConstants.type: type,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String userId = documentSnapshot.get(FirestoreConstants.userId);
    String reply = documentSnapshot.get(FirestoreConstants.reply);
    Timestamp replydate = documentSnapshot.get(FirestoreConstants.replydate);
    Timestamp date = documentSnapshot.get(FirestoreConstants.date);
    String message = documentSnapshot.get(FirestoreConstants.message);
    String type = documentSnapshot.get(FirestoreConstants.type);

    return ChatMessages(
        userId: userId,
        reply: reply,
        replydate: replydate,
        date: date,
      message: message,
        type: type,
    );
  }
}
