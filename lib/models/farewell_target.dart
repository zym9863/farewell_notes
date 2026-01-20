/// 告别对象数据模型
/// 用于数字痕迹清理功能中标识需要告别的对象
class FarewellTarget {
  final String id;
  final String name;
  final List<String> keywords;
  final DateTime createdAt;
  final int matchCount;
  final String? avatarPath; // 可选的头像路径
  final String? note; // 备注

  FarewellTarget({
    required this.id,
    required this.name,
    required this.keywords,
    required this.createdAt,
    this.matchCount = 0,
    this.avatarPath,
    this.note,
  });

  /// 从数据库Map创建实例
  factory FarewellTarget.fromMap(Map<String, dynamic> map) {
    return FarewellTarget(
      id: map['id'] as String,
      name: map['name'] as String,
      keywords: (map['keywords'] as String)
          .split(',')
          .where((k) => k.isNotEmpty)
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
      matchCount: map['match_count'] as int? ?? 0,
      avatarPath: map['avatar_path'] as String?,
      note: map['note'] as String?,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'keywords': keywords.join(','),
      'created_at': createdAt.toIso8601String(),
      'match_count': matchCount,
      'avatar_path': avatarPath,
      'note': note,
    };
  }

  /// 复制并修改部分字段
  FarewellTarget copyWith({
    String? id,
    String? name,
    List<String>? keywords,
    DateTime? createdAt,
    int? matchCount,
    String? avatarPath,
    String? note,
  }) {
    return FarewellTarget(
      id: id ?? this.id,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      matchCount: matchCount ?? this.matchCount,
      avatarPath: avatarPath ?? this.avatarPath,
      note: note ?? this.note,
    );
  }

  /// 检查文本是否匹配关键词
  bool matchesText(String text) {
    final lowerText = text.toLowerCase();
    return keywords.any(
          (keyword) => lowerText.contains(keyword.toLowerCase()),
        ) ||
        lowerText.contains(name.toLowerCase());
  }
}
