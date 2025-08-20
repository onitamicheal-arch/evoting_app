import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/vote.dart';
import '../models/election.dart';
import '../models/party.dart';
import 'database_helper.dart';
import 'auth_service.dart';

class VotingService {
  static final VotingService _instance = VotingService._internal();
  factory VotingService() => _instance;
  VotingService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  // Generate vote hash for integrity
  String _generateVoteHash(int userId, int electionId, int partyId, DateTime timestamp) {
    final data = '$userId:$electionId:$partyId:${timestamp.millisecondsSinceEpoch}';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Cast a vote
  Future<Map<String, dynamic>> castVote({
    required int electionId,
    required int partyId,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Check if election exists and is active
      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      if (!election.canVote) {
        return {'success': false, 'message': 'Election is not active for voting'};
      }

      // Check if party exists and belongs to this election
      final party = await _dbHelper.getPartyById(partyId);
      if (party == null || party.electionId != electionId) {
        return {'success': false, 'message': 'Invalid party selection'};
      }

      // Check if user has already voted in this election
      final existingVote = await _dbHelper.getUserVoteForElection(currentUser.id!, electionId);
      if (existingVote != null) {
        return {'success': false, 'message': 'You have already voted in this election'};
      }

      // Create vote
      final now = DateTime.now();
      final voteHash = _generateVoteHash(currentUser.id!, electionId, partyId, now);
      
      final vote = Vote(
        userId: currentUser.id!,
        electionId: electionId,
        partyId: partyId,
        castAt: now,
        voteHash: voteHash,
      );

      final voteId = await _dbHelper.insertVote(vote);
      if (voteId > 0) {
        return {
          'success': true,
          'message': 'Vote cast successfully',
          'voteId': voteId,
          'party': party,
        };
      } else {
        return {'success': false, 'message': 'Failed to cast vote'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error casting vote: ${e.toString()}'};
    }
  }

  // Get user's vote for a specific election
  Future<Vote?> getUserVoteForElection(int electionId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;

    return await _dbHelper.getUserVoteForElection(currentUser.id!, electionId);
  }

  // Get election results (only if released)
  Future<Map<String, dynamic>> getElectionResults(int electionId) async {
    try {
      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      if (!election.areResultsReleased) {
        return {'success': false, 'message': 'Results have not been released yet'};
      }

      // Get vote counts by party
      final voteResults = await _dbHelper.getElectionResults(electionId);
      
      // Get party details
      final parties = await _dbHelper.getPartiesByElection(electionId);
      
      // Combine results with party information
      List<Map<String, dynamic>> results = [];
      int totalVotes = 0;

      for (var party in parties) {
        final voteCount = voteResults[party.id] ?? 0;
        totalVotes += voteCount;
        
        results.add({
          'party': party,
          'voteCount': voteCount,
        });
      }

      // Sort by vote count (descending)
      results.sort((a, b) => b['voteCount'].compareTo(a['voteCount']));

      // Calculate percentages
      for (var result in results) {
        final voteCount = result['voteCount'] as int;
        final percentage = totalVotes > 0 ? (voteCount / totalVotes * 100) : 0.0;
        result['percentage'] = percentage;
      }

      return {
        'success': true,
        'results': results,
        'totalVotes': totalVotes,
        'election': election,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error getting results: ${e.toString()}'};
    }
  }

  // Get all elections for voting (active elections only for users)
  Future<List<Election>> getAvailableElections() async {
    final elections = await _dbHelper.getElections();
    return elections.where((election) => election.canVote).toList();
  }

  // Get election by ID
  Future<Election?> getElectionById(int electionId) async {
    return await _dbHelper.getElectionById(electionId);
  }

  // Get parties for an election
  Future<List<Party>> getPartiesForElection(int electionId) async {
    return await _dbHelper.getPartiesByElection(electionId);
  }

  // Verify vote integrity
  Future<bool> verifyVoteIntegrity(Vote vote) async {
    try {
      final expectedHash = _generateVoteHash(
        vote.userId,
        vote.electionId,
        vote.partyId,
        vote.castAt,
      );
      return vote.voteHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  // Get voting statistics for an election (admin only)
  Future<Map<String, dynamic>> getVotingStatistics(int electionId) async {
    try {
      if (!_authService.isAdminLoggedIn) {
        return {'success': false, 'message': 'Admin access required'};
      }

      final election = await _dbHelper.getElectionById(electionId);
      if (election == null) {
        return {'success': false, 'message': 'Election not found'};
      }

      final votes = await _dbHelper.getVotesByElection(electionId);
      final parties = await _dbHelper.getPartiesByElection(electionId);

      // Calculate statistics
      final totalVotes = votes.length;
      final totalParties = parties.length;
      
      // Votes by hour (for visualization)
      Map<String, int> votesByHour = {};
      for (var vote in votes) {
        final hour = '${vote.castAt.day}/${vote.castAt.month} ${vote.castAt.hour}:00';
        votesByHour[hour] = (votesByHour[hour] ?? 0) + 1;
      }

      return {
        'success': true,
        'election': election,
        'totalVotes': totalVotes,
        'totalParties': totalParties,
        'votesByHour': votesByHour,
        'averageVotesPerParty': totalParties > 0 ? totalVotes / totalParties : 0,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error getting statistics: ${e.toString()}'};
    }
  }
}
