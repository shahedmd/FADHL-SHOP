class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String benefits;
  final String usage;
  final List<String> images;
  final List<dynamic> reviews;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.benefits,
    required this.usage,
    required this.images,
    required this.reviews,
    required this.category, // <-- Added here
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? 'Unknown Product',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      benefits: map['benefits'] ?? '',
      usage: map['usage'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      reviews: List<dynamic>.from(map['reviews'] ?? []),
      category: map['category'] ?? 'General', // <-- Added here
    );
  }

  // Converts your Dart Object back into Text so we can save it to the hard drive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'benefits': benefits,
      'usage': usage,
      'images': images,
      'reviews': reviews,
      'category': category,
    };
  }
}
