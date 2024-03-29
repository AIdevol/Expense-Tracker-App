import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_fn.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load graph data & monthly total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    // read db on initial startup
    Provider.of<Expensedatabase>(context, listen: false).readExpenses();

    // load futures
    refreshData();

    super.initState();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<Expensedatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<Expensedatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // user input -> expense name
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButtton(),
          // save button
          _createExpenseButtton(),
        ],
      ),
    );
  }

  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // user input -> expense name
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButtton(),
          // save button
          _editExpenseButtton(expense),
        ],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete expense'),
        actions: [
          // cancel button
          _cancelButtton(),
          // delete button
          _deleteExpenseButtton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Expensedatabase>(builder: (
      context,
      value,
      child,
    ) {
      // get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      // calculate the number of months since the first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      // only display the expenses for the the current month
      List<Expense> currentMonthExpense = value.allExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();

      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey.shade700,
          onPressed: openNewExpenseBox,
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                // loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // amount total
                      Text('\$${snapshot.data!.toStringAsFixed(2)}'),

                      // month
                      Text(getCurrentMonthName()),
                    ],
                  );
                }
                // loading
                else {
                  return const Text("loading..");
                }
              },
            )),
        body: SafeArea(
          child: Column(
            children: [
              // graph ui
              SizedBox(
                height: 250,
                child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      // data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        // create the list monthly summary
                        List<double> monthlySummery =
                            List.generate(monthCount, (index) {
                          // calculate year-monthconsidering startMonth & index
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;

                          // create the key in the format 'year - month'
                          String yearMonthKey = '$year-$month';

                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        });

                        return MyBarGraph(
                            monthlySummery: monthlySummery,
                            startMonth: startMonth);
                      }
                      // loading...
                      else {
                        return const Center(
                          child: Text('loading..'),
                        );
                      }
                    }),
              ),

              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentMonthExpense.length,
                  itemBuilder: (context, index) {
                    // reverse the index to latest items first
                    int reversedIndex = currentMonthExpense.length - 1 - index;
                    Expense individualExpense =
                        currentMonthExpense[reversedIndex];

                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _cancelButtton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);

        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  Widget _createExpenseButtton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          await context.read<Expensedatabase>().createNewExpense(newExpense);

          refreshData();

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _editExpenseButtton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty || amountController.text.isNotEmpty)
          Navigator.pop(context);

        Expense updatedExpense = Expense(
          name: nameController.text.isNotEmpty
              ? nameController.text
              : expense.name,
          amount: amountController.text.isNotEmpty
              ? convertStringToDouble(amountController.text)
              : expense.amount,
          date: DateTime.now(),
        );
        // old expeneses id

        int existingId = expense.id;

        await context
            .read<Expensedatabase>()
            .updateExpense(existingId, updatedExpense);
        refreshData();
      },
      child: const Text('Save'),
    );
  }

  Widget _deleteExpenseButtton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);

        await context.read<Expensedatabase>().deleteExpense(id);

        refreshData();
      },
      child: const Text('Delete'),
    );
  }
}
