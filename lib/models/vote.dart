class Vote {
  final int? id;
  final int userId;
  final int electionId;
  final int partyId;
  final DateTime castAt;
  final String voteHash; // For integrity verification

  Vote({
    this.id,
    required this.userId,
    required this.electionId,
    required this.partyId,
    required this.castAt,
    required this.voteHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'electionId': electionId,
      'partyId': partyId,
      'castAt': castAt.millisecondsSinceEpoch,
      'voteHash': voteHash,
    };
  }

  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      id: map['id'],
      userId: map['userId'] ?? 0,
      electionId: map['electionId'] ?? 0,
      partyId: map['partyId'] ?? 0,
      castAt: DateTime.fromMillisecondsSinceEpoch(map['castAt'] ?? 0),
      voteHash: map['voteHash'] ?? '',
    );
  }

  Vote copyWith({
    int? id,
    int? userId,
    int? electionId,
    int? partyId,
    DateTime? castAt,
    String? voteHash,
  }) {
    return Vote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      electionId: electionId ?? this.electionId,
      partyId: partyId ?? this.partyId,
      castAt: castAt ?? this.castAt,
      voteHash: voteHash ?? this.voteHash,
    );
  }
}
