import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loomflow/features/interview/bloc/iv_bloc.dart';
import 'package:loomflow/features/interview/bloc/iv_event.dart';
import 'package:loomflow/features/interview/bloc/iv_state.dart';

class IvView extends StatefulWidget {
  const IvView({super.key});

  @override
  State<IvView> createState() => _IvViewState();
}

class _IvViewState extends State<IvView> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            TextField(controller: nameController),
            TextField(controller: addressController),

            ElevatedButton(
              onPressed: () {
                context.read<IvBloc>().add(
                  IvEventAdd(
                    name: nameController.text,
                    address: addressController.text,
                  ),
                );
                nameController.clear();
                addressController.clear();
              },
              child: Icon(Icons.add),
            ),
            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: () {
                context.read<IvBloc>().add(IvEventFetch());
              },
              child: const Text("Fetch"),
            ),
            Expanded(
              child: BlocBuilder<IvBloc, IvState>(
                builder: (context, state) {
                  if (state.status == IvStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.datas.isEmpty) {
                    return const Center(child: Text("No data"));
                  }

                  return ListView.builder(
                    itemCount: state.datas.length,
                    itemBuilder: (context, index) {
                      final item = state.datas[index];
                      return Card(
                        child: ListTile(
                          title: Text(item['nameF'] ?? ''),
                          subtitle: Text(item['addressF']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
