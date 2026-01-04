import 'package:flutter/material.dart';
import '../../services/bank_api_service.dart';

class BankLinkStore extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Map<String, dynamic>? linkedAccount; // <-- هنا التعريف
  List<Map<String, dynamic>> cards = [];

  // ربط الحساب
  Future<bool> linkAccount(String accountNumber, {String userId = "u10"}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await BankApiService.linkAccount(accountNumber, userId);

      if (!success) {
        error = "Account not found.";
        isLoading = false;
        notifyListeners();
        return false;
      }

      // بعد الربط جلب الحساب
      final accounts = await BankApiService.getAccounts();
      linkedAccount = accounts.firstWhere((a) => a['accountNumber'] == accountNumber);

      // جلب البطاقات
      cards = await BankApiService.getCards(linkedAccount!['id']);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
