import 'package:hive/hive.dart';

part 'channel.g.dart';

@HiveType(typeId: 0)
class Channel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final String logo;
  
  @HiveField(4)
  bool isFavorite;

  Channel({
    required this.id,
    required this.name,
    required this.category,
    required this.logo,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'logo': logo,
      'isFavorite': isFavorite,
    };
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      logo: json['logo'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Channel copyWith({
    String? id,
    String? name,
    String? category,
    String? logo,
    bool? isFavorite,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      logo: logo ?? this.logo,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
