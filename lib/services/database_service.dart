import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// 数据库服务
/// 管理SQLite数据库的所有CRUD操作
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'farewell_notes.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 时空胶囊表
    await db.execute('''
      CREATE TABLE time_capsules (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        recipient_type TEXT NOT NULL,
        recipient_name TEXT,
        created_at TEXT NOT NULL,
        unlock_at TEXT NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        is_read INTEGER DEFAULT 0,
        mood TEXT
      )
    ''');

    // 告别对象表
    await db.execute('''
      CREATE TABLE farewell_targets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        keywords TEXT NOT NULL,
        created_at TEXT NOT NULL,
        match_count INTEGER DEFAULT 0,
        avatar_path TEXT,
        note TEXT
      )
    ''');

    // 扫描记录表
    await db.execute('''
      CREATE TABLE scan_records (
        id TEXT PRIMARY KEY,
        target_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        file_path TEXT,
        thumbnail_path TEXT,
        status TEXT DEFAULT 'pending',
        scanned_at TEXT NOT NULL,
        FOREIGN KEY (target_id) REFERENCES farewell_targets (id)
      )
    ''');
  }

  // ============ 时空胶囊操作 ============

  /// 插入新胶囊
  Future<void> insertCapsule(TimeCapsule capsule) async {
    final db = await database;
    await db.insert('time_capsules', capsule.toMap());
  }

  /// 获取所有胶囊
  Future<List<TimeCapsule>> getAllCapsules() async {
    final db = await database;
    final maps = await db.query('time_capsules', orderBy: 'created_at DESC');
    return maps.map((map) => TimeCapsule.fromMap(map)).toList();
  }

  /// 获取单个胶囊
  Future<TimeCapsule?> getCapsule(String id) async {
    final db = await database;
    final maps = await db.query(
      'time_capsules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TimeCapsule.fromMap(maps.first);
  }

  /// 更新胶囊
  Future<void> updateCapsule(TimeCapsule capsule) async {
    final db = await database;
    await db.update(
      'time_capsules',
      capsule.toMap(),
      where: 'id = ?',
      whereArgs: [capsule.id],
    );
  }

  /// 删除胶囊
  Future<void> deleteCapsule(String id) async {
    final db = await database;
    await db.delete('time_capsules', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取可解锁的胶囊
  Future<List<TimeCapsule>> getUnlockableCapsules() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'time_capsules',
      where: 'unlock_at <= ? AND is_unlocked = 0',
      whereArgs: [now],
    );
    return maps.map((map) => TimeCapsule.fromMap(map)).toList();
  }

  /// 解锁胶囊
  Future<void> unlockCapsule(String id) async {
    final db = await database;
    await db.update(
      'time_capsules',
      {'is_unlocked': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ 告别对象操作 ============

  /// 插入新告别对象
  Future<void> insertTarget(FarewellTarget target) async {
    final db = await database;
    await db.insert('farewell_targets', target.toMap());
  }

  /// 获取所有告别对象
  Future<List<FarewellTarget>> getAllTargets() async {
    final db = await database;
    final maps = await db.query('farewell_targets', orderBy: 'created_at DESC');
    return maps.map((map) => FarewellTarget.fromMap(map)).toList();
  }

  /// 获取单个告别对象
  Future<FarewellTarget?> getTarget(String id) async {
    final db = await database;
    final maps = await db.query(
      'farewell_targets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FarewellTarget.fromMap(maps.first);
  }

  /// 更新告别对象
  Future<void> updateTarget(FarewellTarget target) async {
    final db = await database;
    await db.update(
      'farewell_targets',
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );
  }

  /// 删除告别对象
  Future<void> deleteTarget(String id) async {
    final db = await database;
    // 同时删除相关的扫描记录
    await db.delete('scan_records', where: 'target_id = ?', whereArgs: [id]);
    await db.delete('farewell_targets', where: 'id = ?', whereArgs: [id]);
  }

  // ============ 扫描记录操作 ============

  /// 插入扫描记录
  Future<void> insertScanRecord(ScanRecord record) async {
    final db = await database;
    await db.insert('scan_records', record.toMap());
  }

  /// 批量插入扫描记录
  Future<void> insertScanRecords(List<ScanRecord> records) async {
    final db = await database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert('scan_records', record.toMap());
    }
    await batch.commit();
  }

  /// 获取指定对象的扫描记录
  Future<List<ScanRecord>> getScanRecordsByTarget(String targetId) async {
    final db = await database;
    final maps = await db.query(
      'scan_records',
      where: 'target_id = ?',
      whereArgs: [targetId],
      orderBy: 'scanned_at DESC',
    );
    return maps.map((map) => ScanRecord.fromMap(map)).toList();
  }

  /// 获取待处理的扫描记录
  Future<List<ScanRecord>> getPendingScanRecords(String targetId) async {
    final db = await database;
    final maps = await db.query(
      'scan_records',
      where: 'target_id = ? AND status = ?',
      whereArgs: [targetId, 'pending'],
    );
    return maps.map((map) => ScanRecord.fromMap(map)).toList();
  }

  /// 更新扫描记录状态
  Future<void> updateScanRecordStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'scan_records',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 批量更新扫描记录状态
  Future<void> batchUpdateScanRecordStatus(
    List<String> ids,
    String status,
  ) async {
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        'scan_records',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit();
  }

  /// 删除扫描记录
  Future<void> deleteScanRecord(String id) async {
    final db = await database;
    await db.delete('scan_records', where: 'id = ?', whereArgs: [id]);
  }

  /// 清除指定对象的所有扫描记录
  Future<void> clearScanRecords(String targetId) async {
    final db = await database;
    await db.delete(
      'scan_records',
      where: 'target_id = ?',
      whereArgs: [targetId],
    );
  }
}
