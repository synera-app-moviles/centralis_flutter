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
      version: 1,
      onCreate: _onCreate,
    );
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
  }

  /// Get unread notifications for a user
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
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
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE recipientIds LIKE ? AND status != ?',
      ['%$userId%', 'READ'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
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
    final db = await database;
    await db.update(
      'notifications',
      {'status': 'READ'},
      where: 'recipientIds LIKE ?',
      whereArgs: ['%$userId%'],
    );
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
    final db = await database;
    await db.delete(
      'notifications',
      where: 'recipientIds LIKE ?',
      whereArgs: ['%$userId%'],
    );
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

