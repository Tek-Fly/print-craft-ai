import 'dart:convert';

enum GenerationStatus { 
  pending, 
  processing, 
  succeeded, 
  failed, 
  cancelled 
}

enum GenerationQuality {
  standard, // 2250x2700
  hd,       // 3000x3600  
  ultra     // 4500x5400 - POD Ready
}

class GenerationModel {
  final String id;
  final String userId;
  final String prompt;
  final String? negativePrompt;
  final String? imageUrl;
  final String? localPath;
  final String? thumbnailUrl;
  final GenerationStatus status;
  final GenerationQuality quality;
  final String style;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int width;
  final int height;
  final String mimeType;
  final int? fileSize;
  final bool hasTransparentBackground;
  final bool countedAgainstQuota;
  final Map<String, dynamic>? settings;
  final bool isFavorite;
  final List<String>? tags;
  final String? errorMessage;
  final double? progress;
  final String? seedUsed;
  
  GenerationModel({
    required this.id,
    required this.userId,
    required this.prompt,
    this.negativePrompt,
    this.imageUrl,
    this.localPath,
    this.thumbnailUrl,
    required this.status,
    required this.quality,
    required this.style,
    required this.createdAt,
    this.completedAt,
    this.width = 4500,
    this.height = 5400,
    this.mimeType = 'image/png',
    this.fileSize,
    this.hasTransparentBackground = true,
    this.countedAgainstQuota = true,
    this.settings,
    this.isFavorite = false,
    this.tags,
    this.errorMessage,
    this.progress,
    this.seedUsed,
  });
  
  GenerationModel copyWith({
    String? id,
    String? userId,
    String? prompt,
    String? negativePrompt,
    String? imageUrl,
    String? localPath,
    String? thumbnailUrl,
    GenerationStatus? status,
    GenerationQuality? quality,
    String? style,
    DateTime? createdAt,
    DateTime? completedAt,
    int? width,
    int? height,
    String? mimeType,
    int? fileSize,
    bool? hasTransparentBackground,
    bool? countedAgainstQuota,
    Map<String, dynamic>? settings,
    bool? isFavorite,
    List<String>? tags,
    String? errorMessage,
    double? progress,
    String? seedUsed,
  }) {
    return GenerationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      quality: quality ?? this.quality,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      hasTransparentBackground: hasTransparentBackground ?? this.hasTransparentBackground,
      countedAgainstQuota: countedAgainstQuota ?? this.countedAgainstQuota,
      settings: settings ?? this.settings,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      seedUsed: seedUsed ?? this.seedUsed,
    );
  }
  
  bool get isComplete => status == GenerationStatus.succeeded && imageUrl != null;
  bool get isProcessing => status == GenerationStatus.processing;
  bool get hasFailed => status == GenerationStatus.failed;
  bool get isPending => status == GenerationStatus.pending;
  bool get isUltraQuality => quality == GenerationQuality.ultra;
  
  String get formattedSize {
    if (fileSize == null) return 'Unknown';
    final mb = fileSize! / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }
  
  String get aspectRatio => '$width:$height';
  
  String get qualityLabel {
    switch (quality) {
      case GenerationQuality.standard:
        return 'Standard (2250x2700)';
      case GenerationQuality.hd:
        return 'HD (3000x3600)';
      case GenerationQuality.ultra:
        return 'Ultra POD (4500x5400)';
    }
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'prompt': prompt,
      'negativePrompt': negativePrompt,
      'imageUrl': imageUrl,
      'localPath': localPath,
      'thumbnailUrl': thumbnailUrl,
      'status': status.name,
      'quality': quality.name,
      'style': style,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'width': width,
      'height': height,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'hasTransparentBackground': hasTransparentBackground,
      'countedAgainstQuota': countedAgainstQuota,
      'settings': settings,
      'isFavorite': isFavorite,
      'tags': tags,
      'errorMessage': errorMessage,
      'progress': progress,
      'seedUsed': seedUsed,
    };
  }
  
  factory GenerationModel.fromMap(Map<String, dynamic> map) {
    return GenerationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      prompt: map['prompt'] as String,
      negativePrompt: map['negativePrompt'] as String?,
      imageUrl: map['imageUrl'] as String?,
      localPath: map['localPath'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      status: GenerationStatus.values.byName(map['status'] as String),
      quality: GenerationQuality.values.byName(map['quality'] as String),
      style: map['style'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'] as String) 
          : null,
      width: map['width'] as int? ?? 4500,
      height: map['height'] as int? ?? 5400,
      mimeType: map['mimeType'] as String? ?? 'image/png',
      fileSize: map['fileSize'] as int?,
      hasTransparentBackground: map['hasTransparentBackground'] as bool? ?? true,
      countedAgainstQuota: map['countedAgainstQuota'] as bool? ?? true,
      settings: map['settings'] as Map<String, dynamic>?,
      isFavorite: map['isFavorite'] as bool? ?? false,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>(),
      errorMessage: map['errorMessage'] as String?,
      progress: (map['progress'] as num?)?.toDouble(),
      seedUsed: map['seedUsed'] as String?,
    );
  }
  
  String toJson() => json.encode(toMap());
  
  factory GenerationModel.fromJson(String source) => 
      GenerationModel.fromMap(json.decode(source) as Map<String, dynamic>);
  
  // Factory for creating a new pending generation
  factory GenerationModel.pending({
    required String id,
    required String userId,
    required String prompt,
    String? negativePrompt,
    required String style,
    required GenerationQuality quality,
    Map<String, dynamic>? settings,
  }) {
    return GenerationModel(
      id: id,
      userId: userId,
      prompt: prompt,
      negativePrompt: negativePrompt,
      status: GenerationStatus.pending,
      quality: quality,
      style: style,
      createdAt: DateTime.now(),
      settings: settings,
      progress: 0.0,
    );
  }
  
  @override
  String toString() {
    return 'GenerationModel(id: $id, userId: $userId, prompt: $prompt, status: $status, quality: $quality, style: $style, createdAt: $createdAt)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is GenerationModel &&
        other.id == id &&
        other.userId == userId &&
        other.prompt == prompt &&
        other.status == status &&
        other.quality == quality &&
        other.style == style &&
        other.createdAt == createdAt &&
        other.isFavorite == isFavorite;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        prompt.hashCode ^
        status.hashCode ^
        quality.hashCode ^
        style.hashCode ^
        createdAt.hashCode ^
        isFavorite.hashCode;
  }
}
