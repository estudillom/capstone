import 'dart:async';

import 'package:CapstoneProject/models/chat_item.dart';
import 'package:CapstoneProject/models/conversation.dart';
import 'package:CapstoneProject/models/generated_question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DatabaseService _singleton = DatabaseService._internal();

  factory DatabaseService() {
    return _singleton;
  }

  DatabaseService._internal();

  Future<QuerySnapshot> getUsers() {
    return _firestore.collection("users").get();
  }

  Future<DocumentSnapshot> getUserById(String id) {
    return _firestore.collection("users").doc(id).get();
  }

  Future<void> addUser() async {
    await _firestore.collection("users").add({
      "email": "example@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "profilePicture": "",
      "conversations": List<String>(),
    }).then((value) => print("New user id: ${value.id}"));
  }

  Future<QuerySnapshot> getCategories() {
    return _firestore.collection("categories").get();
  }

  Stream<QuerySnapshot> getDecksByCategory(String name) async* {
    QuerySnapshot query = await _firestore
        .collection("categories")
        .where("name", isEqualTo: name)
        .limit(1)
        .get();
    String categoryId = query.docs.first.id;
    yield* _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("decks")
        .snapshots();
  }

  Future<DocumentSnapshot> getCategoryById(String id) {
    return _firestore.collection("categories").doc(id).get();
  }

  Stream<DocumentSnapshot> getQuestion(String cid, String did, String qid) {
    return _firestore
        .collection("conversations/$cid/decks/$did/questions")
        .doc(qid)
        .snapshots();
  }

  Stream<QuerySnapshot> getConversations(User user) {
    return _firestore
        .collection("conversations")
        .where(FieldPath.documentId, whereIn: user.conversations)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatItems(String conversationId) {
    return _firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("chatItems")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getDecks(String conversationId) {
    return _firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("chatItems")
        .orderBy("timestamp")
        .snapshots();
  }

  Future<void> addMessage(Conversation conversation, ChatItem chatItem,
      {GeneratedQuestion question}) async {
    if (chatItem.question == "") {
      Map<String, dynamic> data = chatItem.toJsonMessage();
      await _firestore
          .collection("conversations/${conversation.id}/chatItems")
          .add(data)
          .then((value) => print("New message created!"));
    } else {
      Map<String, dynamic> responseData = chatItem.toJsonResponse();
      if (question.answered) {
        await _firestore
            .collection(
                "conversations/${conversation.id}/decks/${chatItem.deck}/questions")
            .doc(chatItem.question)
            .update({
          "replies": FieldValue.arrayUnion([responseData])
        }).then((value) => print("New reply created!"));
      } else {
        bool answered =
            (question.answers.length + 1 == conversation.users.length);
        print(
            "Users: ${conversation.users.length}. Answers: ${question.answers.length + 1}. $answered.");
        await _firestore
            .collection(
                "conversations/${conversation.id}/decks/${chatItem.deck}/questions")
            .doc(chatItem.question)
            .update({
          "answers": FieldValue.arrayUnion([responseData]),
          "answered":
              (question.answers.length + 1 == conversation.users.length),
        }).then((value) => print("New answer created!"));
      }
    }
  }
}