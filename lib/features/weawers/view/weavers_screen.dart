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
  @override
  void initState() {
    super.initState();
    context.read<WeaverBloc>().add(FetchWeaversEvent());
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
    return Scaffold(
      // appBar: AppBar(title: const Text("Weavers")),
      body: BlocBuilder<WeaverBloc, WeaverState>(
        builder: (context, state) {
          if (state.status == WeaverStatus.loading) {
            return LoomLoadingWidget();
          }

          if (state.weavers.isEmpty) {
            return const Center(child: Text("No weavers found"));
          }

          return ListView.builder(
            itemCount: state.weavers.length,
            itemBuilder: (_, i) {
              final weaver = state.weavers[i];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(weaver.name),
                  subtitle: Text(weaver.role),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✏️ EDIT
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showWeaverDialog(context, weaver: weaver);
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<WeaverBloc>().add(
                            DeleteWeaverEvent(id: weaver.id),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWeaverDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔥 ADD / EDIT DIALOG
  void _showWeaverDialog(BuildContext context, {UserModel? weaver}) {
    final controller = TextEditingController(text: weaver?.name ?? '');

    showDialog(
      context: context,
      builder: (dlcontext) => AlertDialog(
        title: Text(weaver == null ? "Add Weaver" : "Edit Weaver"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Name"),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlcontext),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();

              if (name.isEmpty) return;

              if (weaver == null) {
                // ➕ ADD
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
                // ✏️ UPDATE
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
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
