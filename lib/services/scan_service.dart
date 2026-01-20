import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'database_service.dart';

/// 扫描进度回调类型
typedef ScanProgressCallback = void Function(double progress, String message);

/// 扫描服务
/// 负责数字痕迹的扫描和处理
class ScanService {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  /// 扫描告别对象相关的数字痕迹
  /// 由于权限限制，这里使用模拟数据演示功能
  Future<List<ScanRecord>> scanForTarget(
    FarewellTarget target, {
    ScanProgressCallback? onProgress,
  }) async {
    final results = <ScanRecord>[];

    // 模拟扫描过程
    onProgress?.call(0.1, '正在扫描相册...');
    await Future.delayed(const Duration(milliseconds: 800));
    results.addAll(await _mockPhotoScan(target));

    onProgress?.call(0.4, '正在扫描备忘录...');
    await Future.delayed(const Duration(milliseconds: 600));
    results.addAll(await _mockNoteScan(target));

    onProgress?.call(0.7, '正在扫描社交动态...');
    await Future.delayed(const Duration(milliseconds: 800));
    results.addAll(await _mockSocialScan(target));

    onProgress?.call(0.9, '正在保存扫描结果...');

    // 保存到数据库
    if (results.isNotEmpty) {
      await _db.insertScanRecords(results);

      // 更新匹配数量
      await _db.updateTarget(target.copyWith(matchCount: results.length));
    }

    onProgress?.call(1.0, '扫描完成');

    return results;
  }

  /// 模拟相册扫描
  Future<List<ScanRecord>> _mockPhotoScan(FarewellTarget target) async {
    final random = Random();
    final count = random.nextInt(5); // 0-4张照片

    return List.generate(count, (index) {
      return ScanRecord(
        id: _uuid.v4(),
        targetId: target.id,
        type: 'photo',
        content: '与 ${target.name} 相关的照片 #${index + 1}',
        scannedAt: DateTime.now(),
        metadata: {
          'date': DateTime.now()
              .subtract(Duration(days: random.nextInt(365)))
              .toIso8601String(),
          'location': ['北京', '上海', '杭州', '成都'][random.nextInt(4)],
        },
      );
    });
  }

  /// 模拟备忘录扫描
  Future<List<ScanRecord>> _mockNoteScan(FarewellTarget target) async {
    final random = Random();
    final count = random.nextInt(3); // 0-2条备忘

    final templates = [
      '关于${target.name}的想法：...',
      '和${target.name}的计划清单',
      '${target.name}推荐的书单/歌单',
      '与${target.name}的约定',
    ];

    return List.generate(count, (index) {
      return ScanRecord(
        id: _uuid.v4(),
        targetId: target.id,
        type: 'note',
        content: templates[random.nextInt(templates.length)],
        scannedAt: DateTime.now(),
      );
    });
  }

  /// 模拟社交动态扫描
  Future<List<ScanRecord>> _mockSocialScan(FarewellTarget target) async {
    final random = Random();
    final count = random.nextInt(4); // 0-3条动态

    final templates = [
      '与${target.name}共同参与的朋友圈动态',
      '@${target.name} 的微博互动',
      '与${target.name}的聊天记录摘要',
      '${target.name}点赞的内容',
    ];

    return List.generate(count, (index) {
      return ScanRecord(
        id: _uuid.v4(),
        targetId: target.id,
        type: 'social',
        content: templates[random.nextInt(templates.length)],
        scannedAt: DateTime.now(),
      );
    });
  }

  /// 归档记录
  Future<void> archiveRecords(List<String> recordIds) async {
    await _db.batchUpdateScanRecordStatus(recordIds, 'archived');
  }

  /// 删除记录
  Future<void> deleteRecords(List<String> recordIds) async {
    await _db.batchUpdateScanRecordStatus(recordIds, 'deleted');
  }

  /// 保留记录
  Future<void> keepRecords(List<String> recordIds) async {
    await _db.batchUpdateScanRecordStatus(recordIds, 'kept');
  }

  /// 获取扫描统计
  Future<Map<String, int>> getScanStats(String targetId) async {
    final records = await _db.getScanRecordsByTarget(targetId);

    return {
      'total': records.length,
      'pending': records.where((r) => r.status == 'pending').length,
      'archived': records.where((r) => r.status == 'archived').length,
      'deleted': records.where((r) => r.status == 'deleted').length,
      'kept': records.where((r) => r.status == 'kept').length,
      'photo': records.where((r) => r.type == 'photo').length,
      'note': records.where((r) => r.type == 'note').length,
      'social': records.where((r) => r.type == 'social').length,
    };
  }
}
