import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_model.dart';

/// Local database service using SQLite for storing notifications
class NotificationDatabase {
  static final NotificationDatabase _instance = NotificationDatabase._internal();
  static Database? _database;

  factory NotificationDatabase() {
    return _instance;
  }

  NotificationDatabase._internal();

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'centralis_notifications.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Upgrade the database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if the recipientIds column exists
      final tables = await db.rawQuery("PRAGMA table_info(notifications)");
      final hasRecipientIds = tables.any((col) => col['name'] == 'recipientIds');

      if (!hasRecipientIds) {
        // Add recipientIds column if it doesn't exist
        await db.execute('ALTER TABLE notifications ADD COLUMN recipientIds TEXT NOT NULL DEFAULT ""');
      }
    }
  }

  /// Create the notifications table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        recipientIds TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  /// Insert a notification into the database
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple notifications
  Future<void> insertNotifications(List<NotificationModel> notifications) async {
    final db = await database;
    final batch = db.batch();

    for (var notification in notifications) {
      batch.insert(
        'notifications',
        notification.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notifications',
        where: 'recipientIds LIKE ?',
        whereArgs: ['%$userId%'], // Check if userId is in the recipientIds list
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return NotificationModel.fromMap(maps[i]);
      });
    } catch (e) {
      // If there's a schema error, recreate the database
      if (e.toString().contains('no such column')) {
        await _recreateDatabase();
        return [];
      }
      rethrow;
    }
  }

  /// Recreate the database (drop and create new)
  Future<void> _recreateDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'centralis_notifications.db');
      await deleteDatabase(path);
      _database = null;
      await database; // This will recreate the database
    } catch (e) {
      print('Error recreating database: $e');
    }
  }

  /// Get unread notifications for a user
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notifications',
        where: 'recipientIds LIKE ? AND status != ?',
        whereArgs: ['%$userId%', 'READ'],
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return NotificationModel.fromMap(maps[i]);
      });
    } catch (e) {
      if (e.toString().contains('no such column')) {
        await _recreateDatabase();
        return [];
      }
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE recipientIds LIKE ? AND status != ?',
        ['%$userId%', 'READ'],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      if (e.toString().contains('no such column')) {
        await _recreateDatabase();
        return 0;
      }
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'status': 'READ'},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final db = await database;
      await db.update(
        'notifications',
        {'status': 'READ'},
        where: 'recipientIds LIKE ?',
        whereArgs: ['%$userId%'],
      );
    } catch (e) {
      if (e.toString().contains('no such column')) {
        await _recreateDatabase();
      } else {
        rethrow;
      }
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final db = await database;
      await db.delete(
        'notifications',
        where: 'recipientIds LIKE ?',
        whereArgs: ['%$userId%'],
      );
    } catch (e) {
      if (e.toString().contains('no such column')) {
        await _recreateDatabase();
      } else {
        rethrow;
      }
    }
  }

  /// Clear all data from the database (for testing)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('notifications');
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

