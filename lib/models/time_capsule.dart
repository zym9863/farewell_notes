/// 时空胶囊数据模型
/// 用于存储用户写给未来的告别信
class TimeCapsule {
  final String id;
  final String title;
  final String content;
  final String recipientType; // 'self' | 'person' | 'memory'
  final String? recipientName;
  final DateTime createdAt;
  final DateTime unlockAt;
  final bool isUnlocked;
  final bool isRead;
  final String? mood; // 心情标签

  TimeCapsule({
    required this.id,
    required this.title,
    required this.content,
    required this.recipientType,
    this.recipientName,
    required this.createdAt,
    required this.unlockAt,
    this.isUnlocked = false,
    this.isRead = false,
    this.mood,
  });

  /// 从数据库Map创建实例
  factory TimeCapsule.fromMap(Map<String, dynamic> map) {
    return TimeCapsule(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      recipientType: map['recipient_type'] as String,
      recipientName: map['recipient_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      unlockAt: DateTime.parse(map['unlock_at'] as String),
      isUnlocked: (map['is_unlocked'] as int) == 1,
      isRead: (map['is_read'] as int) == 1,
      mood: map['mood'] as String?,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'recipient_type': recipientType,
      'recipient_name': recipientName,
      'created_at': createdAt.toIso8601String(),
      'unlock_at': unlockAt.toIso8601String(),
      'is_unlocked': isUnlocked ? 1 : 0,
      'is_read': isRead ? 1 : 0,
      'mood': mood,
    };
  }

  /// 复制并修改部分字段
  TimeCapsule copyWith({
    String? id,
    String? title,
    String? content,
    String? recipientType,
    String? recipientName,
    DateTime? createdAt,
    DateTime? unlockAt,
    bool? isUnlocked,
    bool? isRead,
    String? mood,
  }) {
    return TimeCapsule(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      recipientType: recipientType ?? this.recipientType,
      recipientName: recipientName ?? this.recipientName,
      createdAt: createdAt ?? this.createdAt,
      unlockAt: unlockAt ?? this.unlockAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isRead: isRead ?? this.isRead,
      mood: mood ?? this.mood,
    );
  }

  /// 检查是否可以解锁
  bool get canUnlock => DateTime.now().isAfter(unlockAt);

  /// 获取剩余时间
  Duration get remainingTime {
    if (canUnlock) return Duration.zero;
    return unlockAt.difference(DateTime.now());
  }

  /// 收件人类型显示名称
  String get recipientTypeDisplay {
    switch (recipientType) {
      case 'self':
        return '给未来的自己';
      case 'person':
        return '给 $recipientName';
      case 'memory':
        return '告别一段回忆';
      default:
        return recipientType;
    }
  }
}
