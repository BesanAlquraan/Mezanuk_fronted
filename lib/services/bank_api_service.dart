import 'dart:convert';
import 'package:http/http.dart' as http;

class BankApiService {
  static const String baseUrl = "http://localhost:3000";

  // جلب كل الحسابات
  static Future<List<Map<String, dynamic>>> getAccounts() async {
    final url = Uri.parse("$baseUrl/accounts");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Failed to load accounts");
    }
  }

  // ربط الحساب بالمستخدم (Fake linking)
  static Future<bool> linkAccount(String accountNumber, String userId) async {
    final url = Uri.parse("$baseUrl/accounts?accountNumber=$accountNumber");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.isNotEmpty;
    } else {
      return false;
    }
  }

  // جلب كل البطاقات الخاصة بحساب معين
  static Future<List<Map<String, dynamic>>> getCards(String accountId) async {
    final url = Uri.parse("$baseUrl/cards?accountId=$accountId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      return [];
    }
  }
}
