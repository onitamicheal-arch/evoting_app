import 'package:flutter/material.dart';

class VoteConfirmationScreen extends StatelessWidget {
  final int electionId;
  final int partyId;
  final String partyName;
  final String candidateName;
  
  const VoteConfirmationScreen({
    super.key,
    required this.electionId,
    required this.partyId,
    required this.partyName,
    required this.candidateName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Vote'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Vote Confirmation for $partyName ($candidateName) - To be implemented'),
      ),
    );
  }
}
