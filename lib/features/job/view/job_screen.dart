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

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(FetchJobEvent());
    context.read<JobBloc>().repository.fetchWeavers().then((value) {
      setState(() {
        weavers = value;
      });
    });

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<JobModel> _filterJobs(List<JobModel> jobs) {
    if (searchQuery.isEmpty) return jobs;

    return jobs.where((job) {
      final weaverName = job.weaverName.toLowerCase();
      final material = job.materialDetails.toLowerCase();
      final status = job.status.toLowerCase();
      return weaverName.contains(searchQuery) ||
          material.contains(searchQuery) ||
          status.contains(searchQuery);
    }).toList();
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<JobBloc, JobState>(
                    builder: (context, state) {
                      return Text(
                        '${state.jobs.length} jobs',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: colorScheme.primary,
                      ),
                      onPressed: () => _showDialog(context),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by weaver, material, or status',
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => searchController.clear(),
                        ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<JobBloc, JobState>(
                builder: (context, state) {
                  if (state.status == JobStatus.loading) {
                    return const LoomLoadingWidget();
                  }

                  if (state.status == JobStatus.success) {
                    final filteredJobs = _filterJobs(state.jobs);

                    if (filteredJobs.isEmpty) {
                      return Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? 'No jobs yet'
                              : 'No jobs match "${searchQuery}"',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final job = filteredJobs[i];
                        final weaver = weavers.firstWhere(
                          (w) => w.id == job.weaverId,
                          orElse: () => UserModel(
                            id: '',
                            name: job.weaverName,
                            role: 'weaver',
                            isActive: false,
                          ),
                        );

                        final displayWeaverName = weaver.id.isNotEmpty
                            ? weaver.name
                            : job.weaverName;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 3,
                            shadowColor: colorScheme.shadow,
                            color: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor:
                                              colorScheme.primaryContainer,
                                          child: Text(
                                            displayWeaverName.isNotEmpty
                                                ? displayWeaverName[0]
                                                      .toUpperCase()
                                                : '-',
                                            style: TextStyle(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                displayWeaverName,
                                                style: textTheme.titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: weaver.isActive
                                                          ? colorScheme.primary
                                                                .withOpacity(
                                                                  0.14,
                                                                )
                                                          : colorScheme.error
                                                                .withOpacity(
                                                                  0.14,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      weaver.isActive
                                                          ? 'Active Weaver'
                                                          : 'Inactive Weaver',
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                weaver.isActive
                                                                ? colorScheme
                                                                      .primary
                                                                : colorScheme
                                                                      .error,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  _statusChip(
                                                    context,
                                                    job.status,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'edit':
                                                _showDialog(context, job);
                                                break;
                                              case 'delete':
                                                context.read<JobBloc>().add(
                                                  DeleteJobEvent(jobId: job.id),
                                                );
                                                break;
                                              case 'status':
                                                _showStatusDialog(job);
                                                break;
                                            }
                                          },
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'status',
                                              child: Text('Change Status'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Material details',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            job.materialDetails.isEmpty
                                                ? 'No material details'
                                                : job.materialDetails,
                                            style: textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Advance',
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '₹${job.advanceAmount}',
                                                  style: textTheme.titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total',
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '₹${job.totalAmount}',
                                                  style: textTheme.titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: Text(
                      'Something went wrong',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _showDialog(context),
      //   icon: const Icon(Icons.add),
      //   label: const Text('New Job'),
      // ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color = colorScheme.tertiary;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        color = colorScheme.secondary;
        break;

      case 'IN_PROGRESS':
        color = colorScheme.primary;
        break;

      case 'CREATED':
        color = colorScheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  // `job` is now optional: null when creating, non-null when editing.
  void _showDialog(BuildContext context, [JobModel? job]) {
    final m = TextEditingController(text: job?.materialDetails ?? '');
    final a = TextEditingController(text: job?.advanceAmount.toString() ?? '');
    final t = TextEditingController(text: job?.totalAmount.toString() ?? '');

    final activeWeavers = weavers
        .where((element) => element.isActive == true)
        .toList();

    // Pre-select the current weaver when editing.
    if (job != null) {
      selectedWeaver = activeWeavers.firstWhere(
        (w) => w.id == job.weaverId,
        orElse: () => activeWeavers.isNotEmpty
            ? activeWeavers.first
            : activeWeavers.first,
      );
    } else {
      selectedWeaver = null;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(job == null ? "Create Job" : "Edit Job"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserModel>(
                  value: selectedWeaver,
                  hint: const Text("Select Weaver"),
                  items: activeWeavers.map((w) {
                    return DropdownMenuItem(value: w, child: Text(w.name));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
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

                  if (job == null) {
                    // Creating a brand new job.
                    final newJob = JobModel(
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

                    context.read<JobBloc>().add(CreateJobEvent(job: newJob));
                  } else {
                    // Editing an existing job.
                    context.read<JobBloc>().add(
                      UpdateJobEvent(
                        job: job.copyWith(
                          weaverId: selectedWeaver!.id,
                          weaverName: selectedWeaver!.name,
                          materialDetails: m.text,
                          advanceAmount: double.tryParse(a.text) ?? 0,
                          totalAmount: double.tryParse(t.text) ?? 0,
                        ),
                      ),
                    );
                  }

                  Navigator.pop(dialogContext);
                },
                child: Text(job == null ? "Create" : "Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStatusDialog(JobModel job) {
    String selected = job.status;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Update Status"),
            content: DropdownButtonFormField<String>(
              value: selected,
              items: const [
                DropdownMenuItem(value: "CREATED", child: Text("Created")),
                DropdownMenuItem(
                  value: "IN_PROGRESS",
                  child: Text("In Progress"),
                ),
                DropdownMenuItem(value: "COMPLETED", child: Text("Completed")),
              ],
              onChanged: (v) {
                setDialogState(() {
                  selected = v!;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<JobBloc>().add(
                    UpdateJobEvent(job: job.copyWith(status: selected)),
                  );

                  Navigator.pop(dialogContext);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }
}
