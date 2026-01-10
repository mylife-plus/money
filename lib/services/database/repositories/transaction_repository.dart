import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../../../models/transaction_model.dart';
import '../../database/database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Add a new transaction
  Future<int> addTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    try {
      final id = await db.insert(
        DatabaseHelper.tableTransactions,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('[TransactionRepository] Added transaction with ID: $id');
      return id;
    } catch (e) {
      debugPrint('[TransactionRepository] Error adding transaction: $e');
      rethrow;
    }
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        orderBy: '${DatabaseHelper.columnTransactionDate} DESC',
      );

      return List.generate(maps.length, (i) {
        return Transaction.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('[TransactionRepository] Error fetching transactions: $e');
      return [];
    }
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(int id) async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: '${DatabaseHelper.columnTransactionId} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Transaction.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint(
        '[TransactionRepository] Error fetching transaction by ID: $e',
      );
      return null;
    }
  }

  // Update a transaction
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    try {
      return await db.update(
        DatabaseHelper.tableTransactions,
        transaction.toMap(),
        where: '${DatabaseHelper.columnTransactionId} = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      debugPrint('[TransactionRepository] Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete a transaction
  Future<int> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    try {
      return await db.delete(
        DatabaseHelper.tableTransactions,
        where: '${DatabaseHelper.columnTransactionId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('[TransactionRepository] Error deleting transaction: $e');
      rethrow;
    }
  }

  // Delete all transactions
  Future<int> deleteAllTransactions() async {
    final db = await _databaseHelper.database;
    try {
      return await db.delete(DatabaseHelper.tableTransactions);
    } catch (e) {
      debugPrint('[TransactionRepository] Error deleting all transactions: $e');
      rethrow;
    }
  }
}
