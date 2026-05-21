import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loomflow/models/job_model.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalJobs() async {
    final snapshot = await _firestore.collection('jobs').get();

    return snapshot.docs.length;
  }

  Future<int> getCompletedJobs() async {
    final snapshot = await _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'COMPLETED')
        .get();

    return snapshot.docs.length;
  }

  Future<int> getActiveWeavers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'weaver')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  Future<List<JobModel>> getRecentJobs() async {
    final snapshot = await _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((d) => JobModel.fromMap(d.data(), d.id)).toList();
  }
}
