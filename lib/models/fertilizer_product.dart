class FertilizerProduct {
  final String id;
  final String name;
  final String npkRatio; // e.g., "10-10-10"
  final String description;
  final String category; // 'organic', 'synthetic', 'liquid', 'granular'
  final List<String> suitablePlants;
  final String applicationMethod;
  final String frequency;
  final double price;
  final String brand;
  final String imageUrl;

  FertilizerProduct({
    required this.id,
    required this.name,
    required this.npkRatio,
    required this.description,
    required this.category,
    required this.suitablePlants,
    required this.applicationMethod,
    required this.frequency,
    required this.price,
    required this.brand,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'npkRatio': npkRatio,
      'description': description,
      'category': category,
      'suitablePlants': suitablePlants,
      'applicationMethod': applicationMethod,
      'frequency': frequency,
      'price': price,
      'brand': brand,
      'imageUrl': imageUrl,
    };
  }

  factory FertilizerProduct.fromJson(Map<String, dynamic> json) {
    return FertilizerProduct(
      id: json['id'],
      name: json['name'],
      npkRatio: json['npkRatio'],
      description: json['description'],
      category: json['category'],
      suitablePlants: List<String>.from(json['suitablePlants']),
      applicationMethod: json['applicationMethod'],
      frequency: json['frequency'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      imageUrl: json['imageUrl'],
    );
  }
}
