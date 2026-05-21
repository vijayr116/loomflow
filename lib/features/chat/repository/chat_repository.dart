import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loomflow/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepository(this.firestore);
  Future<void> sendMessage({required MessageModel messages}) async {
    await firestore.collection('messages').add(messages.toMap());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => MessageModel.fromMap(e.data())).toList(),
        );
  }

  Future<void> deleteAllMessages() async {
    final snapshot = await firestore.collection('messages').get();

    WriteBatch batch = firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
