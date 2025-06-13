import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Example: "CSE2"
  final String classId;

  CommunityService({required this.classId});

  /// Send a chat message to the group
  Future<void> sendMessage(String message) async {
    final user = _auth.currentUser;
    if (user == null || message.trim().isEmpty) return;

    await _firestore
        .collection('community_chats')
        .doc(classId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderName': user.displayName ?? 'Anonymous',
      'message': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Stream messages for the class group chat
  Stream<QuerySnapshot> getMessageStream() {
    return _firestore
        .collection('community_chats')
        .doc(classId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}
