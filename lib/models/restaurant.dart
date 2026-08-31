class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.openingHours,
    required this.phone,
    required this.website,
    required this.featured,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String openingHours;
  final String phone;
  final String website;
  final bool featured;

  factory Restaurant.fromMap(String id, Map<dynamic, dynamic> map) {
    return Restaurant(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      openingHours: map['openingHours'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      website: map['website'] as String? ?? '',
      featured: map['featured'] as bool? ?? false,
    );
  }
}
