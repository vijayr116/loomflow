import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loomflow/models/user_model.dart';

class WeaverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> fetchWeavers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'weaver')
        .get();

    return snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> fetchActiveWeavers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'weaver')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> addWeaver(UserModel user) async {
    await _firestore.collection('users').add(user.toMap());
  }

  Future<void> updateWeaver(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteWeaver(String id) async {
    await _firestore.collection('users').doc(id).update({"isActive": false});
  }
}
