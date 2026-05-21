import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:loomflow/core/common/loading_screen.dart';
import 'package:loomflow/models/job_model.dart';
import 'package:loomflow/models/user_model.dart';
import '../bloc/job_bloc.dart';
import '../bloc/job_event.dart';
import '../bloc/job_state.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<UserModel> weavers = [];
  UserModel? selectedWeaver;

  bool dialogOpened = false;

  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(FetchJobEvent());
    context.read<JobBloc>().repository.fetchWeavers().then((value) {
      setState(() {
        weavers = value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;

    final shouldOpen = uri.queryParameters['create'];
    if (shouldOpen == 'true' && !dialogOpened) {
      dialogOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("LoomFlow"),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         FirebaseAuth.instance.signOut();
      //       },
      //       icon: Icon(Icons.logout),
      //     ),
      //   ],
      // ),
      body: BlocBuilder<JobBloc, JobState>(
        // builder: (a, b) => Text('data'),
        builder: (context, state) {
          if (state.status == JobStatus.loading) {
            return const LoomLoadingWidget();
          }

          if (state.status == JobStatus.success) {
            return ListView.builder(
              itemCount: state.jobs.length,
              itemBuilder: (_, i) {
                final job = state.jobs[i];
                final weaver = weavers.firstWhere(
                  (w) => w.id == job.weaverId,
                  orElse: () => UserModel(
                    id: '',
                    name: job.weaverName,
                    role: 'weaver',
                    isActive: false,
                  ),
                );
                return Card(
                  child: ListTile(
                    title: Text(
                      weaver.isActive
                          ? job.weaverName
                          : '${job.weaverName} (Inactive)',
                    ),
                    subtitle: Text(job.status),
                    trailing: Text("₹${job.totalAmount}"),
                    onTap: () {
                      context.pushNamed('jobDetails', extra: job);
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Error"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    final m = TextEditingController();
    final a = TextEditingController();
    final t = TextEditingController();
    final activeWeavers = weavers
        .where((element) => element.isActive == true)
        .toList();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Create Job"),
        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // DropdownButtonFormField<String>(items: namesss, onChanged: onChanged)
            DropdownButtonFormField<UserModel>(
              value: selectedWeaver,
              hint: const Text("Select Weaver"),
              items: activeWeavers.map((w) {
                return DropdownMenuItem(value: w, child: Text(w.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWeaver = value;
                });
              },
            ),

            TextField(
              controller: m,
              decoration: const InputDecoration(labelText: "Material"),
            ),
            TextField(
              controller: a,
              decoration: const InputDecoration(labelText: "Advance"),
            ),
            TextField(
              controller: t,
              decoration: const InputDecoration(labelText: "Total"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedWeaver == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Select a weaver")),
                );
                return;
              }
              final job = JobModel(
                id: '',
                weaverId: selectedWeaver!.id,
                sellerId: FirebaseAuth.instance.currentUser!.uid,
                weaverName: selectedWeaver!.name,
                materialDetails: m.text,
                advanceAmount: double.tryParse(a.text) ?? 0,
                totalAmount: double.tryParse(t.text) ?? 0,
                status: "CREATED",
                designImage: '',
                createdAt: DateTime.now(),
              );

              context.read<JobBloc>().add(CreateJobEvent(job: job));
              Navigator.pop(dialogContext);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
