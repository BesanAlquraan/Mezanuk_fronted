import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../state/report_store.dart';
import '../../domain/models/report_model.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../constants/colors.dart';
import '../state/settings_store.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String searchQuery = "";
  bool showIncome = true;
  bool showExpense = true;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedCategory;

  final GlobalKey incomeChartKey = GlobalKey();
  final GlobalKey expenseChartKey = GlobalKey();
  final GlobalKey netChartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final reportStore = context.watch<SiteReportStore>();
    final settingsStore = context.watch<SettingsStore>();
    final t = settingsStore.translations;
    final currency = settingsStore.currencySymbol;

    final transactions = reportStore.allTransactions.where((transaction) {
      if (!showIncome && transaction.type == TransactionType.income) return false;
      if (!showExpense && transaction.type == TransactionType.expense) return false;
      if (selectedCategory != null &&
          selectedCategory != t.of('all') &&
          transaction.categoryName != selectedCategory) return false;
      if (searchQuery.isNotEmpty &&
          !transaction.title.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      if (startDate != null && transaction.date.isBefore(startDate!)) return false;
      if (endDate != null && transaction.date.isAfter(endDate!)) return false;
      return true;
    }).toList();

    final filteredExpenses =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    final filteredIncomes =
        transactions.where((t) => t.type == TransactionType.income).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(t.of('reports')),
        backgroundColor: kAppBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: kTextLightColor),
            onPressed: () => _generateFullPdfWithCharts(
                filteredExpenses, filteredIncomes, transactions, reportStore, t, currency),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final chartWidth = isWide ? constraints.maxWidth / 2 - 32 : constraints.maxWidth - 32;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _card(t.of('income'), filteredIncomes.fold(0.0,(p,i)=>p+i.amount), kTextSuccessColor, chartWidth, currency),
                  _card(t.of('expense'), filteredExpenses.fold(0.0,(p,e)=>p+e.amount), kTextErrorColor, chartWidth, currency),
                  _card(t.of('net'), filteredIncomes.fold(0.0,(p,i)=>p+i.amount)-filteredExpenses.fold(0.0,(p,e)=>p+e.amount), kPrimaryColor, chartWidth, currency),
                  _card(t.of('largest_expense'), filteredExpenses.isEmpty?0:filteredExpenses.map((e)=>e.amount).reduce((a,b)=>a>b?a:b), kCategoryOrange, chartWidth, currency),
                ],
              ),
              const SizedBox(height: 16),
              _filters(reportStore, isWide, t),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(width: chartWidth, height: 250, child: RepaintBoundary(key: incomeChartKey, child: _barChart(filteredIncomes, true, reportStore.incomeCategories))),
                  SizedBox(width: chartWidth, height: 250, child: RepaintBoundary(key: expenseChartKey, child: _barChart(filteredExpenses, false, reportStore.expenseCategories))),
                  SizedBox(width: isWide ? chartWidth : constraints.maxWidth-32, height: 250, child: RepaintBoundary(key: netChartKey, child: _lineChart(filteredExpenses, filteredIncomes))),
                ],
              ),
              const SizedBox(height: 16),
              _transactionsTable(transactions, isWide, t, currency),
            ],
          ),
        );
      }),
    );
  }

  Widget _card(String title, double amount, Color color, double width, String currency) {
    return SizedBox(
      width: width,
      child: Card(
        color: kCardBackgroundColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDarkColor)),
              const SizedBox(height: 8),
              Text("$currency${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filters(SiteReportStore store, bool isWide, dynamic t) {
    final List<String> categories = [t.of('all')];
    categories.addAll(store.expenseCategories.map((c) => c.name).toList());
    categories.addAll(store.incomeCategories.map((c) => c.name).toList());

    return isWide
        ? Row(
            children: [
              Expanded(child: _searchField(t)),
              const SizedBox(width: 8),
              Expanded(child: _datePickerRow(t)),
              const SizedBox(width: 8),
              Expanded(child: _categorySelector(categories)),
              const SizedBox(width: 8),
              Expanded(child: _typeSelector(t)),
            ],
          )
        : Column(
            children: [
              _searchField(t),
              const SizedBox(height: 8),
              _datePickerRow(t),
              const SizedBox(height: 8),
              _categorySelector(categories),
              const SizedBox(height: 8),
              _typeSelector(t),
            ],
          );
  }

  Widget _searchField(dynamic t) => TextField(
        decoration: InputDecoration(
          labelText: t.of('search'),
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search, color: kIconColor),
        ),
        onChanged: (val) => setState(() => searchQuery = val),
      );

  Widget _datePickerRow(dynamic t) => Row(
        children: [
          Expanded(child: _datePicker(t.of('start_date'), startDate, (d) => setState(() => startDate = d))),
          const SizedBox(width: 8),
          Expanded(child: _datePicker(t.of('end_date'), endDate, (d) => setState(() => endDate = d))),
        ],
      );

  Widget _categorySelector(List<String> categories) => DropdownButton<String>(
        value: selectedCategory ?? categories.first,
        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => selectedCategory = val),
      );

  Widget _typeSelector(dynamic t) => Row(
        children: [
          Checkbox(value: showIncome, onChanged: (v) => setState(() => showIncome = v ?? true)),
          Text(t.of('show_income')),
          const SizedBox(width: 16),
          Checkbox(value: showExpense, onChanged: (v) => setState(() => showExpense = v ?? true)),
          Text(t.of('show_expense')),
        ],
      );

  Widget _datePicker(String label, DateTime? date, ValueChanged<DateTime> onPicked) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: kButtonPrimaryColor),
        foregroundColor: kTextDarkColor,
      ),
      onPressed: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (picked != null) onPicked(picked);
      },
      child: Text(date == null ? label : DateFormat('dd-MM-yyyy').format(date)),
    );
  }

  Widget _barChart(List data, bool income, List categories) {
    final colors = [kCategoryRed, kCategoryGreen, kCategoryOrange, kCategoryBlue, kCategoryPurple, kCategoryTeal, kCategoryPink, kCategoryAmber, kCategoryIndigo, kCategoryLime];
    double maxY = data.isEmpty ? 10 : data.map((d) => d.amount).reduce((a, b) => a > b ? a : b) * 1.2;

    return LayoutBuilder(builder: (context, constraints) {
      final barWidth = constraints.maxWidth / (categories.length * 2.5);

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: List.generate(12, (monthIndex) {
            final month = monthIndex + 1;
            final rods = <BarChartRodData>[];
            for (int i = 0; i < categories.length; i++) {
              final catTotal = data.where((d) => d.date.month == month && d.categoryName == categories[i]).fold(0.0, (sum, d) => sum + d.amount);
              if (catTotal > 0) {
                rods.add(BarChartRodData(toY: catTotal, color: colors[i % colors.length], width: barWidth, borderRadius: BorderRadius.circular(6)));
              }
            }
            return BarChartGroupData(x: month, barRods: rods);
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) {
              final month = DateTime(0, value.toInt());
              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(DateFormat.MMM().format(month), style: const TextStyle(fontSize: 12, color: kTextDarkColor)));
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: maxY / 5)),
          ),
          gridData: FlGridData(show: true, drawHorizontalLine: true, getDrawingHorizontalLine: (v) => FlLine(color: kDividerColor)),
          borderData: FlBorderData(show: true, border: Border.all(color: kDividerColor)),
        ),
      );
    });
  }

  Widget _lineChart(List filteredExpenses, List filteredIncomes) {
    final data = List.generate(12, (index) {
      final month = index + 1;
      final incomeTotal = filteredIncomes.where((i) => i.date.month == month).fold(0.0, (p, i) => p + i.amount);
      final expenseTotal = filteredExpenses.where((e) => e.date.month == month).fold(0.0, (p, e) => p + e.amount);
      return FlSpot(month.toDouble(), incomeTotal - expenseTotal);
    });

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: 12,
        lineBarsData: [LineChartBarData(spots: data, isCurved: true, barWidth: 3, color: kCategoryPurple, dotData: FlDotData(show: true))],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => Text(DateFormat.MMM().format(DateTime(0, val.toInt())), style: const TextStyle(color: kTextDarkColor))))),
        gridData: FlGridData(show: true, drawHorizontalLine: true, getDrawingHorizontalLine: (v) => FlLine(color: kDividerColor)),
        borderData: FlBorderData(show: true, border: Border.all(color: kDividerColor)),
      ),
    );
  }

  Widget _transactionsTable(List<SiteReportModel> transactions, bool isWide, dynamic t, String currency) {
    if (transactions.isEmpty) return Center(child: Text(t.of('no_transactions_found'), style: const TextStyle(fontSize: 18)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(kBackgroundColor),
        columns: [
          DataColumn(label: Text(t.of('date'))),
          DataColumn(label: Text(t.of('title'))),
          DataColumn(label: Text(t.of('category'))),
          DataColumn(label: Text(t.of('type'))),
          DataColumn(label: Text(t.of('amount'))),
        ],
        rows: transactions.map((tModel) => DataRow(cells: [
          DataCell(Text(DateFormat('dd-MM-yyyy').format(tModel.date))),
          DataCell(Text(tModel.title)),
          DataCell(Text(tModel.categoryName)),
          DataCell(Text(tModel.type == TransactionType.expense ? t.of('expense') : t.of('income'))),
          DataCell(Text("$currency${tModel.amount.toStringAsFixed(2)}")),
        ])).toList(),
      ),
    );
  }

  Future<void> _generateFullPdfWithCharts(List filteredExpenses, List filteredIncomes, List transactions, SiteReportStore store, dynamic t, String currency) async {
    final pdf = pw.Document();
    final incomeImage = await _captureWidget(incomeChartKey);
    final expenseImage = await _captureWidget(expenseChartKey);
    final netImage = await _captureWidget(netChartKey);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(t.of('reports'), style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(kAppBarColor.value))),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _pdfCard(t.of('income'), filteredIncomes.fold(0.0,(p,i)=>p+i.amount), currency),
              _pdfCard(t.of('expense'), filteredExpenses.fold(0.0,(p,e)=>p+e.amount), currency),
              _pdfCard(t.of('net'), filteredIncomes.fold(0.0,(p,i)=>p+i.amount) - filteredExpenses.fold(0.0,(p,e)=>p+e.amount), currency),
              _pdfCard(t.of('largest_expense'), filteredExpenses.isEmpty?0:filteredExpenses.map((e)=>e.amount).reduce((a,b)=>a>b?a:b), currency),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(t.of('income'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Image(pw.MemoryImage(incomeImage)),
          pw.SizedBox(height: 16),
          pw.Text(t.of('expense'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Image(pw.MemoryImage(expenseImage)),
          pw.SizedBox(height: 16),
          pw.Text(t.of('net'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Image(pw.MemoryImage(netImage)),
          pw.SizedBox(height: 16),
          pw.Text(t.of('transactions'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: [t.of('date'), t.of('title'), t.of('category'), t.of('type'), t.of('amount')],
            data: transactions.map((tran) => [
              DateFormat('dd-MM-yyyy').format(tran.date),
              tran.title,
              tran.categoryName,
              tran.type==TransactionType.expense?t.of('expense'):t.of('income'),
              "$currency${tran.amount.toStringAsFixed(2)}"
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<Uint8List> _captureWidget(GlobalKey key) async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  pw.Widget _pdfCard(String title, double amount, String currency) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromInt(kAppBarColor.value)),
          borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Column(children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(kAppBarColor.value))),
        pw.SizedBox(height: 4),
        pw.Text("$currency${amount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ]),
    );
  }
}
