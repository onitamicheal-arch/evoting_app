import 'package:flutter/material.dart';
import '../models/election.dart';
import '../models/party.dart';
import '../models/vote.dart';
import '../services/voting_service.dart';
import '../services/database_helper.dart';

class ElectionProvider with ChangeNotifier {
  final VotingService _votingService = VotingService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Election> _elections = [];
  List<Party> _parties = [];
  Election? _selectedElection;
  bool _isLoading = false;

  List<Election> get elections => _elections;
  List<Party> get parties => _parties;
  Election? get selectedElection => _selectedElection;
  bool get isLoading => _isLoading;

  // Alias method for loadAvailableElections (used by home screen)
  Future<void> loadElections() async {
    await loadAvailableElections();
  }

  // Load available elections for users
  Future<void> loadAvailableElections() async {
    _isLoading = true;
    notifyListeners();

    try {
      _elections = await _votingService.getAvailableElections();
    } catch (e) {
      debugPrint('Error loading elections: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all elections (for admin)
  Future<void> loadAllElections() async {
    _isLoading = true;
    notifyListeners();

    try {
      _elections = await _dbHelper.getElections();
    } catch (e) {
      debugPrint('Error loading all elections: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load parties for an election
  Future<void> loadPartiesForElection(int electionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _parties = await _votingService.getPartiesForElection(electionId);
      _selectedElection = await _votingService.getElectionById(electionId);
    } catch (e) {
      debugPrint('Error loading parties: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cast vote
  Future<Map<String, dynamic>> castVote({
    required int electionId,
    required int partyId,
  }) async {
    return await _votingService.castVote(
      electionId: electionId,
      partyId: partyId,
    );
  }

  // Get election results
  Future<Map<String, dynamic>> getElectionResults(int electionId) async {
    return await _votingService.getElectionResults(electionId);
  }

  // Get user's vote for election
  Future<Vote?> getUserVoteForElection(int electionId) async {
    return await _votingService.getUserVoteForElection(electionId);
  }

  // Admin functions
  Future<Map<String, dynamic>> createElection({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final election = Election(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        createdAt: DateTime.now(),
      );

      final electionId = await _dbHelper.insertElection(election);
      if (electionId > 0) {
        await loadAllElections(); // Refresh elections list
        return {'success': true, 'message': 'Election created successfully', 'electionId': electionId};
      } else {
        return {'success': false, 'message': 'Failed to create election'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating election: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> addParty({
    required String name,
    required String description,
    required String candidateName,
    required int electionId,
  }) async {
    try {
      final party = Party(
        name: name,
        description: description,
        candidateName: candidateName,
        electionId: electionId,
        createdAt: DateTime.now(),
      );

      final partyId = await _dbHelper.insertParty(party);
      if (partyId > 0) {
        if (_selectedElection?.id == electionId) {
          await loadPartiesForElection(electionId); // Refresh parties if viewing this election
        }
        return {'success': true, 'message': 'Party added successfully', 'partyId': partyId};
      } else {
        return {'success': false, 'message': 'Failed to add party'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error adding party: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> removeParty(int partyId) async {
    try {
      await _dbHelper.deleteParty(partyId);
      
      // Refresh parties list if we're viewing an election
      if (_selectedElection != null) {
        await loadPartiesForElection(_selectedElection!.id!);
      }
      
      return {'success': true, 'message': 'Party removed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error removing party: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> startElection(int electionId) async {
    try {
      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      final now = DateTime.now();
      if (now.isBefore(election.startTime)) {
        return {'success': false, 'message': 'Election start time has not arrived yet'};
      }

      if (now.isAfter(election.endTime)) {
        return {'success': false, 'message': 'Election end time has already passed'};
      }

      final updatedElection = election.copyWith(status: ElectionStatus.active);
      await _dbHelper.updateElection(updatedElection);
      await loadAllElections(); // Refresh elections list

      return {'success': true, 'message': 'Election started successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error starting election: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> endElection(int electionId) async {
    try {
      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      if (election.status != ElectionStatus.active) {
        return {'success': false, 'message': 'Election is not active'};
      }

      final updatedElection = election.copyWith(status: ElectionStatus.ended);
      await _dbHelper.updateElection(updatedElection);
      await loadAllElections(); // Refresh elections list

      return {'success': true, 'message': 'Election ended successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error ending election: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> releaseResults(int electionId) async {
    try {
      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      if (election.status != ElectionStatus.ended) {
        return {'success': false, 'message': 'Election must be ended before releasing results'};
      }

      final updatedElection = election.copyWith(
        status: ElectionStatus.resultsReleased,
        resultsReleasedAt: DateTime.now(),
      );
      await _dbHelper.updateElection(updatedElection);
      await loadAllElections(); // Refresh elections list

      return {'success': true, 'message': 'Results released successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error releasing results: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateElectionTimes({
    required int electionId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      if (election.status == ElectionStatus.active) {
        return {'success': false, 'message': 'Cannot modify active election times'};
      }

      final updatedElection = election.copyWith(
        startTime: startTime,
        endTime: endTime,
      );
      await _dbHelper.updateElection(updatedElection);
      await loadAllElections(); // Refresh elections list

      return {'success': true, 'message': 'Election times updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error updating election times: ${e.toString()}'};
    }
  }

  // Get voting statistics
  Future<Map<String, dynamic>> getVotingStatistics(int electionId) async {
    return await _votingService.getVotingStatistics(electionId);
  }
}
