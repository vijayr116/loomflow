import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loomflow/core/common/loading_screen.dart';
import 'package:loomflow/features/weawers/bloc/weaver_bloc.dart';
import 'package:loomflow/features/weawers/bloc/weaver_event.dart';
import 'package:loomflow/features/weawers/bloc/weaver_state.dart';
import 'package:loomflow/models/user_model.dart';

class WeaverListScreen extends StatefulWidget {
  const WeaverListScreen({super.key});

  @override
  State<WeaverListScreen> createState() => _WeaverListScreenState();
}

class _WeaverListScreenState extends State<WeaverListScreen> {
  bool dialogOpened = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<WeaverBloc>().add(FetchWeaversEvent());

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

  List<UserModel> _filterWeavers(List<UserModel> weavers) {
    if (searchQuery.isEmpty) return weavers;

    return weavers.where((weaver) {
      final name = weaver.name.toLowerCase();
      final role = weaver.role.toLowerCase();
      return name.contains(searchQuery) || role.contains(searchQuery);
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
        _showWeaverDialog(context);
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
                  BlocBuilder<WeaverBloc, WeaverState>(
                    builder: (context, state) {
                      return Text(
                        '${state.weavers.length} weavers',
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
                      onPressed: () => _showWeaverDialog(context),
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
                  hintText: 'Search by name or role...',
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
                style: textTheme.bodyMedium,
              ),
            ),

            // List Section
            Expanded(
              child: BlocBuilder<WeaverBloc, WeaverState>(
                builder: (context, state) {
                  if (state.status == WeaverStatus.loading) {
                    // return _buildLoadingState(context);
                    return LoomLoadingWidget();
                  }

                  final filteredWeavers = _filterWeavers(state.weavers);

                  if (filteredWeavers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isEmpty
                                ? Icons.groups_outlined
                                : Icons.search_off,
                            size: 80,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              .35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No Weavers Found'
                                : 'No matches for "$searchQuery"',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (searchQuery.isEmpty)
                            Text(
                              'Add a new weaver to start',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  .75,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWeavers.length,
                    itemBuilder: (_, i) {
                      final weaver = filteredWeavers[i];
                      final isActive = weaver.isActive;

                      return _WeaverCard(
                        weaver: weaver,
                        isActive: isActive,
                        onEdit: () =>
                            _showWeaverDialog(context, weaver: weaver),
                        onDelete: () {
                          context.read<WeaverBloc>().add(
                            DeleteWeaverEvent(id: weaver.id),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _showWeaverDialog(context),
      //   icon: const Icon(Icons.add),
      //   label: const Text("Add Weaver"),
      //   elevation: 6,
      // ),
    );
  }

  // 🔥 ADD / EDIT DIALOG
  void _showWeaverDialog(BuildContext context, {UserModel? weaver}) {
    final controller = TextEditingController(text: weaver?.name ?? '');

    showDialog(
      context: context,
      builder: (dlcontext) {
        final theme = Theme.of(dlcontext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            weaver == null ? "Add Weaver" : "Edit Weaver",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlcontext),
              child: Text(
                "Cancel",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(dlcontext).showSnackBar(
                    const SnackBar(content: Text("Name cannot be empty")),
                  );
                  return;
                }

                if (weaver == null) {
                  // ➕ ADD NEW
                  final newWeaver = UserModel(
                    id: '',
                    name: name,
                    role: 'weaver',
                    isActive: true,
                  );

                  context.read<WeaverBloc>().add(
                    AddWeaverEvent(weaver: newWeaver),
                  );
                } else {
                  // ✏️ UPDATE EXISTING
                  final updated = UserModel(
                    id: weaver.id,
                    name: name,
                    role: weaver.role,
                    isActive: weaver.isActive,
                  );

                  context.read<WeaverBloc>().add(
                    UpdateWeaverEvent(weaver: updated),
                  );
                }

                Navigator.pop(dlcontext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      weaver == null
                          ? "Weaver added successfully!"
                          : "Weaver updated successfully!",
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_mosaic,
                  size: 52,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading weaving machines...',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please wait while the LoomFlow system prepares your weavers.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connecting the loom network and your team.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Professional Weaver Card
class _WeaverCard extends StatelessWidget {
  final UserModel weaver;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WeaverCard({
    required this.weaver,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final indicatorColor = isActive ? colorScheme.secondary : colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: colorScheme.shadow,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      child: Text(
                        weaver.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    // Active/Inactive indicator
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weaver.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weaver.role.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: indicatorColor.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? "ACTIVE" : "INACTIVE",
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: indicatorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: colorScheme.onSurfaceVariant,
                  onPressed: () => _showActionsBottomSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        final sheetColorScheme = sheetTheme.colorScheme;
        final sheetTextTheme = sheetTheme.textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weaver.name,
                  style: sheetTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: sheetColorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weaver.role.toUpperCase(),
                  style: sheetTextTheme.bodySmall?.copyWith(
                    color: sheetColorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: Icon(Icons.edit, color: sheetColorScheme.primary),
                  title: const Text("Edit Weaver"),
                  onTap: () {
                    onEdit();
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: sheetColorScheme.error),
                  title: const Text("Delete Weaver"),
                  onTap: () {
                    onDelete();
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
