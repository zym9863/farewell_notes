/// 扫描记录数据模型
/// 用于存储数字痕迹扫描的结果
class ScanRecord {
  final String id;
  final String targetId; // 关联的告别对象ID
  final String type; // 'photo' | 'note' | 'social'
  final String content; // 内容预览
  final String? filePath; // 文件路径
  final String? thumbnailPath; // 缩略图路径
  final String status; // 'pending' | 'archived' | 'deleted' | 'kept'
  final DateTime scannedAt;
  final Map<String, dynamic>? metadata; // 额外元数据

  ScanRecord({
    required this.id,
    required this.targetId,
    required this.type,
    required this.content,
    this.filePath,
    this.thumbnailPath,
    this.status = 'pending',
    required this.scannedAt,
    this.metadata,
  });

  /// 从数据库Map创建实例
  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id'] as String,
      targetId: map['target_id'] as String,
      type: map['type'] as String,
      content: map['content'] as String,
      filePath: map['file_path'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      status: map['status'] as String? ?? 'pending',
      scannedAt: DateTime.parse(map['scanned_at'] as String),
      metadata: null, // 简化处理，不存储复杂元数据
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_id': targetId,
      'type': type,
      'content': content,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'status': status,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  ScanRecord copyWith({
    String? id,
    String? targetId,
    String? type,
    String? content,
    String? filePath,
    String? thumbnailPath,
    String? status,
    DateTime? scannedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      scannedAt: scannedAt ?? this.scannedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 类型显示名称
  String get typeDisplay {
    switch (type) {
      case 'photo':
        return '照片';
      case 'note':
        return '备忘录';
      case 'social':
        return '社交动态';
      default:
        return type;
    }
  }

  /// 状态显示名称
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'archived':
        return '已归档';
      case 'deleted':
        return '已删除';
      case 'kept':
        return '已保留';
      default:
        return status;
    }
  }

  /// 是否为待处理状态
  bool get isPending => status == 'pending';
}
