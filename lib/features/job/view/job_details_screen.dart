import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loomflow/features/job/bloc/job_bloc.dart';
import 'package:loomflow/features/job/bloc/job_event.dart';
import 'package:loomflow/features/job/bloc/job_state.dart';

import 'package:loomflow/models/job_model.dart';
import 'package:loomflow/models/user_model.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel initialJob;

  const JobDetailScreen({super.key, required this.initialJob});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Detail"),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/chat', extra: widget.initialJob);
            },
            icon: Icon(Icons.chat),
          ),

          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<JobBloc>().add(
                DeleteJobEvent(jobId: widget.initialJob.id),
              );
              context.pop(); // go_router back
            },
          ),
        ],
      ),

      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          // 👉 get latest job from bloc state
          final job = state.jobs.firstWhere(
            (j) => j.id == widget.initialJob.id,
            orElse: () => widget.initialJob,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Weaver: ${job.weaverName}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 6),

                Text("Material: ${job.materialDetails}"),
                const SizedBox(height: 6),

                Text("Advance: ₹${job.advanceAmount}"),
                const SizedBox(height: 6),

                Text("Total: ₹${job.totalAmount}"),

                const SizedBox(height: 20),

                // 🔽 STATUS DROPDOWN
                DropdownButtonFormField<String>(
                  value: job.status,
                  items: const [
                    DropdownMenuItem(value: "CREATED", child: Text("Created")),
                    DropdownMenuItem(
                      value: "IN_PROGRESS",
                      child: Text("In Progress"),
                    ),
                    DropdownMenuItem(
                      value: "COMPLETED",
                      child: Text("Completed"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    context.read<JobBloc>().add(
                      UpdateJobEvent(job: job.copyWith(status: value)),
                    );
                  },
                  decoration: const InputDecoration(labelText: "Status"),
                ),

                const SizedBox(height: 30),

                // ✏️ EDIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final repo = context.read<JobBloc>().repository;

                      final weavers = await repo.fetchWeavers();
                      if (!mounted) return;

                      UserModel? selectedWeaver;

                      if (weavers.isNotEmpty) {
                        selectedWeaver = weavers.firstWhere(
                          (w) => w.id == job.weaverId,
                          orElse: () => weavers.first,
                        );
                      }

                      final m = TextEditingController(
                        text: job.materialDetails,
                      );
                      final a = TextEditingController(
                        text: job.advanceAmount.toString(),
                      );
                      final t = TextEditingController(
                        text: job.totalAmount.toString(),
                      );

                      final activeWeavers = weavers
                          .where((w) => w.isActive)
                          .toList();

                      final dropdownWeavers = [
                        ...activeWeavers,
                        if (!activeWeavers.any((w) => w.id == job.weaverId))
                          weavers.firstWhere((w) => w.id == job.weaverId),
                      ];

                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text("Edit Job"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ✅ DROPDOWN
                                    DropdownButtonFormField<UserModel>(
                                      value: selectedWeaver,
                                      hint: const Text("Select Weaver"),
                                      items: dropdownWeavers.map((w) {
                                        return DropdownMenuItem(
                                          value: w,
                                          child: Text(w.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedWeaver = value;
                                        });
                                      },
                                    ),

                                    TextField(
                                      controller: m,
                                      decoration: const InputDecoration(
                                        labelText: "Material",
                                      ),
                                    ),
                                    TextField(
                                      controller: a,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Advance",
                                      ),
                                    ),
                                    TextField(
                                      controller: t,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Total",
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (selectedWeaver == null) return;

                                      final updatedJob = job.copyWith(
                                        weaverId: selectedWeaver!.id,
                                        weaverName: selectedWeaver!.name,
                                        materialDetails: m.text,
                                        advanceAmount:
                                            double.tryParse(a.text) ?? 0,
                                        totalAmount:
                                            double.tryParse(t.text) ?? 0,
                                      );

                                      context.read<JobBloc>().add(
                                        UpdateJobEvent(job: updatedJob),
                                      );

                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text("Update"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },

                    child: const Text("Edit Job"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
