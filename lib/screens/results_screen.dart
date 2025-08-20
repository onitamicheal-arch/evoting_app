import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final int electionId;
  
  const ResultsScreen({super.key, required this.electionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Results Screen for Election $electionId - To be implemented'),
      ),
    );
  }
}
