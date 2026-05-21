import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loomflow/models/job_model.dart';
import 'package:loomflow/models/user_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<JobModel> createJob(JobModel job) async {
    final doc = await _firestore.collection('jobs').add(job.toMap());
    return job.copyWith(id: doc.id);
  }

  Future<List<JobModel>> fetchJobs() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('jobs')
        .where('sellerId', isEqualTo: uid)
        .get();

    return snapshot.docs.map((d) => JobModel.fromMap(d.data(), d.id)).toList();
  }

  Stream<List<JobModel>> streamJobs() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('jobs')
        .where('sellerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateJob(JobModel job) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(job.id)
        .update(job.toMap());
  }

  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
    print('record deleted !!!!!  : $jobId');
  }

  Future<List<UserModel>> fetchWeavers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'weaver')
        .get();

    return snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }
}
