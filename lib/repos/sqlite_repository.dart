import 'dart:async';
import 'dart:io' as io;
import 'package:finamoonproject/components/category/categories.class.dart';
import 'package:finamoonproject/components/transaction/transaction.class.dart';
import 'package:finamoonproject/repos/repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

class SqliteRepository extends Repository{
  static Database _db;

  /// Open database
  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  /// Create database & tables
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "budget.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  /// Create database tables
  void _onCreate(Database db, int version) async {
    await db.execute(
        "create table transactions("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "type TEXT,"
            "amount REAL,"
            "name TEXT,"
            "description TEXT DEFAULT NULL,"
            "transaction_date DATE, "
            "expiry_date DATE DEFAULT NULL, "
            "recurring INTEGER DEFAULT NULL"
            ")");

    await db.execute(
        "create table categories("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "type VARCHAR(250), "
            "category VARCHAR(250) UNIQUE"
            ")");
  }

  /// Get transactions for a given month
  Future<List<Transactions>> getTransactions(DateTime datetime) async {
    var currentMonth = DateFormat('MM').format(datetime);
    var currentYear = DateFormat('yyyy').format(datetime);
    var currentYMD = DateFormat('yyyy-MM-dd').format(datetime);
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "select *, strftime('%d/%m/%Y',transaction_date) as transaction_date,"
            "strftime('%Y-%m-%d',expiry_date) as expiry_date "
            "from transactions "
            "where recurring = 0 "
            "and strftime('%m',transaction_date)='$currentMonth' "
            "and strftime('%Y',transaction_date)='$currentYear'"
            " UNION ALL "
            "select *, strftime('%d/%m/%Y',transaction_date) as transaction_date,"
            "strftime('%Y-%m-%d',expiry_date) as expiry_date "
            "from transactions "
            "where recurring = 1 "
            "and expiry_date != '' "
            "and expiry_date >= '$currentYMD'"
            "and transaction_date <= '$currentYMD'"
            " UNION ALL "
            "select *, strftime('%d/%m/%Y',transaction_date) as transaction_date, expiry_date "
            "from transactions "
            "where recurring = 1 "
            "and expiry_date == '' "
            "and transaction_date <= '$currentYMD'"
    );
    List<Transactions> transactions = new List();
    for (int i = 0; i < list.length; i++) {
      transactions.add(
          new Transactions(
              list[i]["id"],
              list[i]["type"],
              list[i]["amount"],
              list[i]["name"],
              list[i]["description"],
              list[i]["transaction_date"],
              list[i]["expiry_date"],
              list[i]["recurring"]
          )
      );
    }
    return transactions;
  }

  /// Get transaction by id
  Future<Transactions> getTransactionById(id) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "select *, strftime('%Y-%m-%d',transaction_date) as transaction_date,"
            "strftime('%Y-%m-%d',expiry_date) as expiry_date "
            "from transactions where id='$id'");
    Transactions transactions = new Transactions(
        list[0]["id"],
        list[0]["type"],
        list[0]["amount"],
        list[0]["name"],
        list[0]["description"],
        list[0]["transaction_date"],
        list[0]["expiry_date"],
        list[0]["recurring"]
    );
    return transactions;
  }

  /// Get transactions by category for the given month
  Future <List<Map>> getTransactionsByCategory(DateTime datetime) async {
    var currentMonth = DateFormat('MM').format(datetime);
    var currentYear = DateFormat('yyyy').format(datetime);
    var currentYMD = DateFormat('yyyy-MM-dd').format(datetime);
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "select name as category, sum(amount) as total "
            "from transactions "
            "where recurring = 0 "
            "and strftime('%m',transaction_date)='$currentMonth' "
            "and strftime('%Y',transaction_date)='$currentYear' "
            "group by name "
            " UNION ALL "
            "select name as category, sum(amount) as total "
            "from transactions "
            "where recurring = 1 "
            "and expiry_date != '' "
            "and expiry_date >= '$currentYMD' "
            "and transaction_date <= '$currentYMD' "
            "group by name "
            " UNION ALL "
            "select name as category, sum(amount) as total "
            "from transactions "
            "where recurring = 1 "
            "and expiry_date == '' "
            "and transaction_date <= '$currentYMD' "
            "group by name "
    );
    return list;
  }

  /// Get sum amount of transactions per type (Income, Expenses and Savings)
  /// for the given month
  Future <List<Map>> getTransactionsSum(DateTime datetime) async {
    var currentMonth = DateFormat('MM').format(datetime);
    var currentYear = DateFormat('yyyy').format(datetime);
    var currentYMD = DateFormat('yyyy-MM-dd').format(datetime);
    var dbClient = await db;
    List<Map> sumIncome = await dbClient.rawQuery(
        "select sum(amount) as total from transactions "
            "where type like '%income%' "
            "and recurring = 0 "
            "and strftime('%m',transaction_date)='$currentMonth' "
            "and strftime('%Y',transaction_date)='$currentYear'"
            " UNION ALL "
            "select sum(amount) as total from transactions "
            "where type like '%income%' "
            "and recurring = 1 "
            "and expiry_date != '' "
            "and expiry_date >= '$currentYMD' "
            "and transaction_date <= '$currentYMD'"
            " UNION ALL "
            "select sum(amount) as total from transactions "
            "where type like '%income%' "
            "and recurring = 1 "
            "and expiry_date == '' "
            "and transaction_date <= '$currentYMD'"
    );

    List<Map> sumExpense = await dbClient.rawQuery(
        "select sum(amount) as total from transactions "
            "where type like '%expense%' "
            "and recurring = 0 "
            "and strftime('%m',transaction_date)='$currentMonth' "
            "and strftime('%Y',transaction_date)='$currentYear'"
            " UNION ALL "
            "select sum(amount) as total from transactions "
            "where type like '%expense%' "
            "and recurring = 1 "
            "and expiry_date != '' "
            "and expiry_date >= '$currentYMD' "
            "and transaction_date <= '$currentYMD'"
            " UNION ALL "
            "select sum(amount) as total from transactions "
            "where type like '%expense%' "
            "and recurring = 1 "
            "and expiry_date == '' "
            "and transaction_date <= '$currentYMD'"
    );

    List<Map> sumSavings = await dbClient.rawQuery(
        "select sum(amount) as total from transactions "
            "where type like '%saving%' "
            "and recurring = 0 "
            "and strftime('%m',transaction_date)='$currentMonth' "
            "and strftime('%Y',transaction_date)='$currentYear'"
            " UNION ALL "
            "select sum(amount) as total from transactions "
            "where type like '%saving%' "
            "and recurring = 1 "
            "and expiry_date != '' "
            "and expiry_date >= '$currentYMD' "
            "and transaction_date <= '$currentYMD'"
            " UNION ALL "
            "select sum(amount) as total from transactions "
            "where type like '%saving%' "
            "and recurring = 1 "
            "and expiry_date == '' "
            "and transaction_date <= '$currentYMD'"
    );
    var totalIncome = (sumIncome[0]["total"] != null ? sumIncome[0]["total"] : 0)
        + (sumIncome[1]["total"] != null ? sumIncome[1]["total"] : 0)
        + (sumIncome[2]["total"] != null ? sumIncome[2]["total"] : 0);
    var totalExpenses = (sumExpense[0]["total"] != null ? sumExpense[0]["total"] : 0)
        + (sumExpense[1]["total"] != null ? sumExpense[1]["total"] : 0)
        + (sumExpense[2]["total"] != null ? sumExpense[2]["total"] : 0);
    var totalSavings = (sumSavings[0]["total"] != null ? sumSavings[0]["total"] : 0)
        + (sumSavings[1]["total"] != null ? sumSavings[1]["total"] : 0)
        + (sumSavings[2]["total"] != null ? sumSavings[2]["total"] : 0);
    List<Map> totals = <Map>[{
      'income': (totalIncome != null) ? totalIncome : 0,
      'expenses': (totalExpenses != null) ? totalExpenses : 0,
      'savings': (totalSavings != null) ? totalSavings : 0
    }];
    return totals;
  }

  /// Insert a transaction to database
  Future<void> createTransaction(BuildContext context, Transactions transaction) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      int result = await txn.rawInsert(
          'INSERT INTO transactions (id, type, amount, name, description, transaction_date, expiry_date, recurring) VALUES(NULL, ' +
              '\'' +
              transaction.type + '\'' + ',' + '\'' +
              transaction.amount.toString() + '\'' + ',' + '\'' +
              transaction.name + '\'' + ',' + '\'' +
              transaction.description + '\'' + ',' + '\'' +
              transaction.transactionDate + '\'' + ',' + '\'' +
              transaction.expiryDate + '\'' + ',' + '\'' +
              transaction.recurring.toString() + '\'' +
              ')');
      if(result > 0) {
        Toast.show("Transaction successfully added", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
      else {
        Toast.show("Transaction failed", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
    });
  }

  /// Update transaction
  Future<void> updateTransaction(BuildContext context, int transactionId, Transactions transaction) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      int result = await txn.rawUpdate(
          'UPDATE transactions '
              'SET type = ?, amount = ?, name = ?, description = ?, '
              'transaction_date = ?, expiry_date = ? '
              'WHERE id = ?',
          [transaction.type, transaction.amount, transaction.name, transaction.description,
            transaction.transactionDate, transaction.expiryDate,
            transactionId
          ]
      );
      if(result == 1) {
        Toast.show("Transaction successfully updated", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
      else {
        Toast.show("Transaction update failed", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
    });
  }

  /// Delete transaction from database
  Future<void> deleteTransaction(BuildContext context, int transactionId) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      int result = await txn.rawDelete(
          'DELETE FROM transactions WHERE id = ?', [transactionId]);
      if (result == 1) {
        Toast.show("Transaction successfully deleted", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return true;
      } else {
        Toast.show("Transaction delete failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return false;
      }
    });
  }

  /// Get categories from database
  Future<List<Categories>> getCategories() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "select * from categories order by category asc"
    );
    List<Categories> categories = new List();
    for (int i = 0; i < list.length; i++) {
      categories.add(
          new Categories(
            list[i]["id"],
            list[i]["type"],
            list[i]["category"],
          )
      );
    }
    return categories;
  }

  /// Get categories from database
  Future <List<Map>> getCategoriesList() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("select * from categories");
    return list;
  }

  /// Get categories for a given type (Income, Expense, Saving)
  Future <List<String>> getCategoriesByType(String type) async {
    var dbClient = await db;
    var listCategories = new List<String>();
    List<Map> list = await dbClient.rawQuery(
        "select category from categories "
            "where type like '%$type%' order by category"
    );
    for (int i = 0; i < list.length; i++) {
      listCategories.add( list[i]["category"] );
    }
    return listCategories;
  }

  /// Insert a category to database
  Future<void> createCategory(BuildContext context, String type, String category) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT OR IGNORE INTO categories (id, type, category) VALUES(NULL, ' +
              '\'' + type + '\'' + ',' + '\'' + category + '\'' +
              ')');
      if(id != null && id > 0) {
        Toast.show("Category successfully added", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
      else {
        Toast.show("Category failed", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
    });
  }

  /// Update a category
  Future<void> updateCategory(BuildContext context, Categories category) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      int result = await txn.rawUpdate(
          'UPDATE categories '
              'SET type = ?, category = ? '
              'WHERE id = ?',
          [category.categoryType, category.categoryName, category.categoryId]
      );
      if(result == 1) {
        Toast.show("Category successfully updated", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
      else {
        Toast.show("Category update failed", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      }
    });
  }

  ///Delete a category from database
  Future<void> deleteCategory(BuildContext context, int categoryId) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      int result = await txn.rawDelete('DELETE FROM categories WHERE id = ?', [categoryId]);
      if(result == 1) {
        Toast.show("Category successfully deleted", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        return true;
      } else {
        Toast.show("Category delete failed", context,
            duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        return false;
      }
    });
  }

}