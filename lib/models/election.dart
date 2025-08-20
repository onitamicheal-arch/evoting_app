enum ElectionStatus {
  upcoming,
  active,
  ended,
  resultsReleased,
}

class Election {
  final int? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final ElectionStatus status;
  final DateTime createdAt;
  final DateTime? resultsReleasedAt;

  Election({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.status = ElectionStatus.upcoming,
    required this.createdAt,
    this.resultsReleasedAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && 
           now.isBefore(endTime) && 
           status == ElectionStatus.active;
  }

  bool get canVote {
    return isActive;
  }

  bool get areResultsReleased {
    return status == ElectionStatus.resultsReleased;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'resultsReleasedAt': resultsReleasedAt?.millisecondsSinceEpoch,
    };
  }

  factory Election.fromMap(Map<String, dynamic> map) {
    return Election(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      status: ElectionStatus.values[map['status'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      resultsReleasedAt: map['resultsReleasedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['resultsReleasedAt'])
          : null,
    );
  }

  Election copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    ElectionStatus? status,
    DateTime? createdAt,
    DateTime? resultsReleasedAt,
  }) {
    return Election(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resultsReleasedAt: resultsReleasedAt ?? this.resultsReleasedAt,
    );
  }
}
