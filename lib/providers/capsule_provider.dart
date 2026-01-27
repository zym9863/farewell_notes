import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 胶囊状态管理
class CapsuleProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notifications = NotificationService();

  List<TimeCapsule> _capsules = [];
  bool _isLoading = false;
  String? _error;

  List<TimeCapsule> get capsules => _capsules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 已解锁的胶囊
  List<TimeCapsule> get unlockedCapsules =>
      _capsules.where((c) => c.isUnlocked || c.canUnlock).toList();

  /// 待解锁的胶囊
  List<TimeCapsule> get lockedCapsules =>
      _capsules.where((c) => !c.isUnlocked && !c.canUnlock).toList();

  /// 加载所有胶囊
  Future<void> loadCapsules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _capsules = await _db.getAllCapsules();

      // 检查并解锁到期的胶囊
      await _checkAndUnlockCapsules();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 检查并解锁到期的胶囊
  Future<void> _checkAndUnlockCapsules() async {
    final unlockable = await _db.getUnlockableCapsules();
    for (final capsule in unlockable) {
      await _db.unlockCapsule(capsule.id);
    }
    if (unlockable.isNotEmpty) {
      _capsules = await _db.getAllCapsules();
    }
  }

  /// 创建新胶囊
  Future<void> createCapsule(TimeCapsule capsule) async {
    try {
      await _db.insertCapsule(capsule);

      // 调度解锁通知
      await _notifications.scheduleCapsuleNotification(
        capsuleId: capsule.id,
        title: capsule.title,
        unlockTime: capsule.unlockAt,
      );

      _capsules.insert(0, capsule);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 更新胶囊
  Future<void> updateCapsule(TimeCapsule capsule) async {
    try {
      await _db.updateCapsule(capsule);

      final index = _capsules.indexWhere((c) => c.id == capsule.id);
      if (index != -1) {
        _capsules[index] = capsule;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 标记胶囊为已读
  Future<void> markAsRead(String capsuleId) async {
    final capsule = _capsules.firstWhere((c) => c.id == capsuleId);
    if (!capsule.isRead) {
      final updated = capsule.copyWith(isRead: true);
      await updateCapsule(updated);
    }
  }

  /// 删除胶囊
  Future<void> deleteCapsule(String id) async {
    try {
      await _db.deleteCapsule(id);
      try {
        await _notifications.cancelCapsuleNotification(id);
      } catch (_) {
        // 某些平台不支持通知取消，忽略即可
      }

      _capsules.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
