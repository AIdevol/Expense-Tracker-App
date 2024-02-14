// import 'package:expensetute/models/expense.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class Expensedatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  //setup `database

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // gettersetters

  List<Expense> get allExpense => _allExpenses;

  // operations
//  add database new expenses
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    await readExpenses();
  }

  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    notifyListeners();
  }

  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    await readExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    await readExpenses();
  }
/*
HELPER
*/

// calculate total expenses for each month
  Future<Map<int, double>> calculateMonthlyTotals() async {
    // ensure the expenses are read from the db
    await readExpenses();

    // create a map to keep track of total expenses per month
    Map<int, double> monthlyTotals = {};

    // iterate over all expenses
    for (var expense in _allExpenses) {
      // extract the month from the date of the expense
      int month = expense.date.month;

      // if the month is not yet in the map , initialize to 0
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }
      //  add the expense amount to the total for the month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }
    return monthlyTotals;
  }

// calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    // ensure expenses are read from db first
    await readExpenses();

    // get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // filter the expenses to include only those for this month this year

    List<Expense> currentMonthExpreses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    //  calculate total amount for the current month
    double total =
        currentMonthExpreses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  // get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .month; // default to current month is no expenses are recorded
    }

    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
  }

  // get start year

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .year; // defualt to current year is no expenses are recorded
    }

    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.year;
  }
}
