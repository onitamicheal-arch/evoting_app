import 'package:flutter/material.dart';

class VotingScreen extends StatelessWidget {
  final int electionId;
  
  const VotingScreen({super.key, required this.electionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Voting Screen for Election $electionId - To be implemented'),
      ),
    );
  }
}
