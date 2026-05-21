import 'package:flutter/material.dart';

class LoomLoadingWidget extends StatelessWidget {
  const LoomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/gifs/loadingGif.gif', height: 180),

          const SizedBox(height: 20),

          const Text(
            'Weaving your data...',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),

          const SizedBox(height: 6),

          const Text(
            'Please wait a moment',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
