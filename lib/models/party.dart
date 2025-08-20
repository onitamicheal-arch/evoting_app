class Party {
  final int? id;
  final String name;
  final String description;
  final String? logoPath;
  final String candidateName;
  final int electionId;
  final DateTime createdAt;

  Party({
    this.id,
    required this.name,
    required this.description,
    this.logoPath,
    required this.candidateName,
    required this.electionId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoPath': logoPath,
      'candidateName': candidateName,
      'electionId': electionId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      logoPath: map['logoPath'],
      candidateName: map['candidateName'] ?? '',
      electionId: map['electionId'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Party copyWith({
    int? id,
    String? name,
    String? description,
    String? logoPath,
    String? candidateName,
    int? electionId,
    DateTime? createdAt,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoPath: logoPath ?? this.logoPath,
      candidateName: candidateName ?? this.candidateName,
      electionId: electionId ?? this.electionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
