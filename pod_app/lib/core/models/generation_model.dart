import 'dart:convert';

enum GenerationStatus { 
  pending, 
  processing, 
  succeeded, 
  failed, 
  cancelled 
}

enum GenerationQuality {
  standard,
  hd,
  ultra
}

class GenerationModel {
  final String id;
  final String userId;
  final String prompt;
  final String? imageUrl;
  final GenerationStatus status;
  final GenerationQuality? quality;
  final String style;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int width;
  final int height;
  final bool isFavorite;
  final String? errorMessage;
  
  GenerationModel({
    required this.id,
    required this.userId,
    required this.prompt,
    this.imageUrl,
    required this.status,
    this.quality,
    required this.style,
    required this.createdAt,
    this.completedAt,
    this.width = 4500,
    this.height = 5400,
    this.isFavorite = false,
    this.errorMessage,
  });

  GenerationModel copyWith({
    String? id,
    String? userId,
    String? prompt,
    String? imageUrl,
    GenerationStatus? status,
    GenerationQuality? quality,
    String? style,
    DateTime? createdAt,
    DateTime? completedAt,
    int? width,
    int? height,
    bool? isFavorite,
    String? errorMessage,
  }) {
    return GenerationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      quality: quality ?? this.quality,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      width: width ?? this.width,
      height: height ?? this.height,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'prompt': prompt,
      'imageUrl': imageUrl,
      'status': status.name.toUpperCase(),
      'quality': quality?.name.toUpperCase(),
      'style': style,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'width': width,
      'height': height,
      'isFavorite': isFavorite,
      'errorMessage': errorMessage,
    };
  }

  factory GenerationModel.fromMap(Map<String, dynamic> map) {
    // Handle status enum case-insensitively
    final statusString = (map['status'] as String? ?? 'pending').toLowerCase();
    final status = GenerationStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => GenerationStatus.pending,
    );

    return GenerationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      prompt: map['prompt'] as String,
      imageUrl: map['imageUrl'] as String?,
      status: status,
      style: map['style'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'] as String) 
          : null,
      width: map['width'] as int? ?? 4500,
      height: map['height'] as int? ?? 5400,
      errorMessage: map['error'] as String?,
    );
  }
  
  String toJson() => json.encode(toMap());
  
  factory GenerationModel.fromJson(String source) => 
      GenerationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}