class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.restaurantId,
    required this.restaurantName,
    required this.rating,
    required this.title,
    required this.description,
    required this.visitDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String restaurantId;
  final String restaurantName;
  final int rating;
  final String title;
  final String description;
  final DateTime visitDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Review.fromMap(String id, Map<dynamic, dynamic> map) {
    return Review(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      restaurantId: map['restaurantId'] as String? ?? '',
      restaurantName: map['restaurantName'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      visitDate: DateTime.fromMillisecondsSinceEpoch(
        (map['visitDate'] as num?)?.toInt() ?? 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'rating': rating,
      'title': title,
      'description': description,
      'visitDate': visitDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
