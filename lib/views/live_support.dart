import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kanglei_taxi/conts/firebase/color_constants.dart';
import 'package:kanglei_taxi/conts/firebase/firestore_constants.dart';
import 'package:kanglei_taxi/conts/firebase/size_constants.dart';
import 'package:kanglei_taxi/conts/resposive_settings.dart';
import 'package:kanglei_taxi/models/chat_messages.dart';
import 'package:kanglei_taxi/providers/ChatProvider.dart';
import 'package:kanglei_taxi/providers/auth_provider.dart';
import 'package:kanglei_taxi/views/signin_page.dart';
import 'package:kanglei_taxi/widget/common_widgets.dart';
import 'package:provider/provider.dart';

class LiveSupport extends StatefulWidget {
  const LiveSupport({Key? key}) : super(key: key);

  @override
  State<LiveSupport> createState() => _LiveSupportState();
}

class _LiveSupportState extends State<LiveSupport> {
  TextEditingController _messageController = TextEditingController();
  late ChatProvider chatProvider;
  late AuthProviderlocal authProvider;
  final firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebasestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  String currentUserId = '';
  int _limit = 20;
  final int _limitIncrement = 20;
  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  late bool showEmojiKeyboard;
  String imageUrl = '';
  List<QueryDocumentSnapshot> listMessages = [];

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProviderlocal>();
    focusNode.addListener(onFocusChanged);
    scrollController.addListener(_scrollListener);
    readLocal();
  }

  @override
  void dispose() {
    _messageController;
    scrollController;
    super.dispose();
  }

  void readLocal() {
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Get.offAll(SignInPage());
    }
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadImageFile();
      }
    }
  }

  void uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String id = currentUserId;
    UploadTask uploadTask =
    chatProvider.uploadImageFile(imageFile!, fileName, id);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, MessageType.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, String type) {
    if (content.trim().isNotEmpty) {
      _messageController.clear();
      chatProvider.sendChatMessage(content, type, currentUserId);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

// checking if received message
  bool isMessageReceived(int index) {
    if ((index > 0 &&
        listMessages[index - 1].get(FirestoreConstants.userId) ==
            currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // checking if sent message
  bool isMessageSent(int index) {
    if ((index > 0 &&
        listMessages[index - 1].get(FirestoreConstants.userId) !=
            currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.dimen_8),
          child: Column(
            children: [
              buildListMessage(),
              isLoading == true
                  ? LoadingWithoutProgress("Uploading")
                  : buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: currentUserId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
          stream: chatProvider.getChatMessage(currentUserId, _limit),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              listMessages = snapshot.data!.docs;
              if (listMessages.isNotEmpty) {
                return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: scrollController,
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]));
              } else {
                return const Center(
                  child: Text('No messages...'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.burgundy,
                ),
              );
            }
          })
          : const Center(
        child: CircularProgressIndicator(
          color: AppColors.burgundy,
        ),
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
    final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null) {
      ChatMessages chatMessages = ChatMessages.fromDocument(documentSnapshot);
      if (chatMessages.userId == currentUserId) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatMessages.type == MessageType.text
                    ? messageBubbleSender(
                    chatContent: chatMessages.message,
                    color: AppColors.spaceLight,
                    textColor: AppColors.white,
                    margin: const EdgeInsets.only(right: Sizes.dimen_10),
                    timeText: DateFormat('hh:mm a dd/mm/yyyy')
                        .format(chatMessages.date.toDate()))
                    : Container(
                  margin: const EdgeInsets.only(
                      right: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: chatImage(
                      imageSrc: chatMessages.message,
                      onTap: () {},
                      dateText: DateFormat('hh:mm a dd/mm/yyyy')
                          .format(chatMessages.date.toDate())),
                ),
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.dimen_20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: firebaseAuth.currentUser?.photoURL ?? 'fallback_url',
                    width: Sizes.dimen_40,
                    height: Sizes.dimen_40,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.account_circle),
                  ),
                ),
              ],
            ),
            if (chatMessages.reply != null && chatMessages.reply.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Sizes.dimen_20),
                      ),
                      child: Image.asset(
                        "images/logo.png",
                        width: Sizes.dimen_40,
                        height: Sizes.dimen_40,
                        fit: BoxFit.contain,
                      )),
                  messageBubbleRecever(
                      chatContent: chatMessages.reply,
                      color: Colors.deepPurpleAccent,
                      textColor: AppColors.white,
                      margin: const EdgeInsets.only(left: Sizes.dimen_10),
                      timeText: DateFormat('hh:mm a dd/mm/yyyy')
                          .format(chatMessages.replydate.toDate())),
                ],
              )
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildMessageInput() {
    return Container(
      margin: EdgeInsets.all(ResponsiveFile.height10 / 2),
      width: double.infinity,
      height: ResponsiveFile.height50,
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              expands: true,
              cursorColor: Colors.black54,
              textInputAction: TextInputAction.newline,
              maxLines: null,
              minLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              controller: _messageController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(ResponsiveFile.height10 / 1.5),
                focusColor: Colors.black54,
                hintStyle: const TextStyle(
                  color: Colors.black54,
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2), width: 2.0),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Sizes.dimen_50))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2), width: 2.0),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Sizes.dimen_50))),
                hintText: 'Write here...',
                prefixIconColor: Colors.grey,
                prefixIcon: Padding(
                  padding:
                  const EdgeInsetsDirectional.only(start: Sizes.dimen_6),
                  child: IconButton(
                    splashRadius: Sizes.dimen_18,
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    onPressed: () {
                      getSticker();
                    },
                  ),
                ),
                suffixIconColor: Colors.grey,
                suffixIcon: Padding(
                  padding:
                  const EdgeInsetsDirectional.only(end: Sizes.dimen_10),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      IconButton(
                        splashRadius: Sizes.dimen_18,
                        icon: const Icon(Icons.attach_file),
                        onPressed: getImage,
                      ),
                      IconButton(
                        splashRadius: Sizes.dimen_18,
                        icon: const Icon(Icons.camera_alt),
                        onPressed: getImage,
                      ),
                    ],
                  ),
                ),
              ),
              onFieldSubmitted: (value) {
                onSendMessage(_messageController.text, MessageType.text);
              },
            ),
          ),
          SizedBox(
            width: ResponsiveFile.height10 / 2,
          ),
          Container(
            padding: EdgeInsets.all(ResponsiveFile.height10 / 3),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: IconButton(
              splashRadius: ResponsiveFile.height15,
              onPressed: () {
                onSendMessage(_messageController.text, MessageType.text);
              },
              icon: const Icon(Icons.send_rounded),
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
