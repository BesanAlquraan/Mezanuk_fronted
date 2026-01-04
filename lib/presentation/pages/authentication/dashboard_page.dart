import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/bank_link_store.dart';
import '../../../constants/colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BankLinkStore(),
      child: Consumer<BankLinkStore>(
        builder: (context, store, _) {
          final account = store.linkedAccount;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Dashboard"),
              backgroundColor: kPrimaryColor,
            ),
            body: account == null
                ? _buildEmptyState(context, store)
                : _buildAccountView(account, store),
          );
        },
      ),
    );
  }

  // ---------------- Empty State ----------------
  Widget _buildEmptyState(BuildContext context, BankLinkStore store) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No Bank Account Linked",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please link your bank account to view balance and cards.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _showLinkBankDialog(context, store);
              },
              child: const Text("Link Bank Account"),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- Account View ----------------
  Widget _buildAccountView(Map<String, dynamic> account, BankLinkStore store) {
    final cards = store.cards;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Info
          Text(
            "Account Number: ${account['accountNumber']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "Balance: ${account['balance']} ${account['currency']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Cards
          const Text(
            "Cards",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          cards.isEmpty
              ? const Text("No cards linked")
              : Column(
                  children: cards.map((card) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text(card['cardNumber']),
                        subtitle:
                            Text("${card['type']} • Exp: ${card['expiry']}"),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // ---------------- Link Bank Dialog ----------------
  void _showLinkBankDialog(BuildContext context, BankLinkStore store) {
    final accountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Link Bank Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountController,
              decoration: const InputDecoration(
                labelText: "Account Number",
              ),
            ),
            if (store.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  store.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await store.linkAccount(accountController.text.trim());
              if (success) Navigator.pop(context);
            },
            child: store.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Link"),
          ),
        ],
      ),
    );
  }
}
