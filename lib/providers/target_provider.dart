import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 告别对象和扫描状态管理
class TargetProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final ScanService _scanService = ScanService();

  List<FarewellTarget> _targets = [];
  List<ScanRecord> _currentScanRecords = [];
  bool _isLoading = false;
  bool _isScanning = false;
  double _scanProgress = 0;
  String _scanMessage = '';
  String? _error;

  List<FarewellTarget> get targets => _targets;
  List<ScanRecord> get currentScanRecords => _currentScanRecords;
  List<ScanRecord> get currentRecords => _currentScanRecords;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  String get scanMessage => _scanMessage;
  String? get error => _error;

  /// 待处理的扫描记录
  List<ScanRecord> get pendingRecords =>
      _currentScanRecords.where((r) => r.isPending).toList();

  /// 加载所有告别对象
  Future<void> loadTargets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _targets = await _db.getAllTargets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建告别对象
  Future<void> createTarget(FarewellTarget target) async {
    try {
      await _db.insertTarget(target);
      _targets.insert(0, target);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 添加告别对象 (createTarget 别名)
  Future<void> addTarget(FarewellTarget target) => createTarget(target);

  /// 通过 ID 扫描告别对象
  Future<void> scanTarget(String targetId) async {
    final target = _targets.firstWhere((t) => t.id == targetId);
    await scanTargetObject(target);
  }

  /// 更新扫描记录状态
  Future<void> updateRecordStatus(String recordId, String status) async {
    try {
      await _db.updateScanRecordStatus(recordId, status);
      final index = _currentScanRecords.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        _currentScanRecords[index] = _currentScanRecords[index].copyWith(
          status: status,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 更新告别对象
  Future<void> updateTarget(FarewellTarget target) async {
    try {
      await _db.updateTarget(target);
      final index = _targets.indexWhere((t) => t.id == target.id);
      if (index != -1) {
        _targets[index] = target;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 删除告别对象
  Future<void> deleteTarget(String id) async {
    try {
      await _db.deleteTarget(id);
      _targets.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 扫描告别对象 (通过对象)
  Future<void> scanTargetObject(FarewellTarget target) async {
    _isScanning = true;
    _scanProgress = 0;
    _scanMessage = '准备扫描...';
    _error = null;
    notifyListeners();

    try {
      _currentScanRecords = await _scanService.scanForTarget(
        target,
        onProgress: (progress, message) {
          _scanProgress = progress;
          _scanMessage = message;
          notifyListeners();
        },
      );

      // 更新目标对象的匹配数量
      final index = _targets.indexWhere((t) => t.id == target.id);
      if (index != -1) {
        _targets[index] = target.copyWith(
          matchCount: _currentScanRecords.length,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// 加载告别对象的扫描记录
  Future<void> loadScanRecords(String targetId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentScanRecords = await _db.getScanRecordsByTarget(targetId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 归档选中的记录
  Future<void> archiveRecords(List<String> recordIds) async {
    try {
      await _scanService.archiveRecords(recordIds);
      for (final id in recordIds) {
        final index = _currentScanRecords.indexWhere((r) => r.id == id);
        if (index != -1) {
          _currentScanRecords[index] = _currentScanRecords[index].copyWith(
            status: 'archived',
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 删除选中的记录
  Future<void> deleteRecords(List<String> recordIds) async {
    try {
      await _scanService.deleteRecords(recordIds);
      for (final id in recordIds) {
        final index = _currentScanRecords.indexWhere((r) => r.id == id);
        if (index != -1) {
          _currentScanRecords[index] = _currentScanRecords[index].copyWith(
            status: 'deleted',
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 保留选中的记录
  Future<void> keepRecords(List<String> recordIds) async {
    try {
      await _scanService.keepRecords(recordIds);
      for (final id in recordIds) {
        final index = _currentScanRecords.indexWhere((r) => r.id == id);
        if (index != -1) {
          _currentScanRecords[index] = _currentScanRecords[index].copyWith(
            status: 'kept',
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
