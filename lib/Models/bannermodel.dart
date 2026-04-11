class BannerModel {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String buttonText;
  final String targetCategory;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.targetCategory,
    required this.isActive,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BannerModel(
      id: documentId,
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      buttonText: map['buttonText'] ?? 'Shop Now',
      targetCategory: map['targetCategory'] ?? 'All',
      isActive: map['isActive'] ?? true,
    );
  }
}