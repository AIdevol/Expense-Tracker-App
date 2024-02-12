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

  @override
  void initState() {
    Provider.of<Expensedatabase>(context, listen: false).readExpenses();
    super.initState();
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
          _editExpenseButtton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Expensedatabase>(
      builder: (
        context,
        value,
        child,
      ) =>
          Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.allExpense.length,
          itemBuilder: (context, index) {
            Expense individualExpense = value.allExpense[index];

            return MyListTile(
              title: individualExpense.name,
              trailing: formatAmount(individualExpense.amount),
              onEditPressed: (context) => openEditBox,
              onDeletePressed: (context) => openDeleteBox,
            );
          },
        ),
      ),
    );
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

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _editExpenseButton(Expense expense) {
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
      },
    );
  }
}
