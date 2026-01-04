import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/settings_store.dart';
import '../../constants/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSettingCard({
    required BuildContext context,
    required String title,
    required Widget trailing,
    IconData? icon,
    Color? iconColor,
  }) {
    return Card(
      color: kCardBackgroundColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? Colors.grey),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: AnimatedDefaultTextStyle(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                duration: const Duration(milliseconds: 300),
                child: Text(title),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SettingsStore>();
    final t = store.translations;

    return AnimatedTheme(
      data: store.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text(t.of('settings')),
          centerTitle: true,
          backgroundColor: kAppBarColor,
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // اختيار العملة
                      _buildSettingCard(
                        context: context,
                        title: t.of('currency'),
                        icon: Icons.attach_money,
                        trailing: DropdownButton<String>(
                          value: store.currency,
                          items: ['USD', 'JOD']
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(t.of(c)), // نص من JSON
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) store.setCurrency(val);
                          },
                        ),
                      ),

                      // اختيار اللغة
                      _buildSettingCard(
                        context: context,
                        title: t.of('language'),
                        icon: Icons.language,
                        trailing: DropdownButton<String>(
                          value: store.language,
                          items: const [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'ar', child: Text('عربي')),
                          ],
                          onChanged: (val) {
                            if (val != null) store.setLanguage(val);
                          },
                        ),
                      ),

                      // الإشعارات
                      _buildSettingCard(
                        context: context,
                        title: t.of('notifications'),
                        icon: Icons.notifications,
                        trailing: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Switch(
                            key: ValueKey(store.notificationsEnabled),
                            value: store.notificationsEnabled,
                            activeColor: kAppBarColor,
                            onChanged: (val) => store.setNotifications(val),
                          ),
                        ),
                      ),

                      // حجم النص
                      _buildSettingCard(
                        context: context,
                        title: t.of('text_size'),
                        icon: Icons.format_size,
                        trailing: DropdownButton<double>(
                          value: store.textScale,
                          items: [1.0, 1.2, 1.5, 2.0]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('$e'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) store.setTextScale(val);
                          },
                        ),
                      ),

                      // إعادة ضبط التطبيق
                      _buildSettingCard(
                        context: context,
                        title: t.of('reset_app'),
                        icon: Icons.restore,
                        iconColor: Colors.red,
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Colors.red),
                          onPressed: () => store.resetSettings(),
                        ),
                      ),

                      // نسخة التطبيق
                      _buildSettingCard(
                        context: context,
                        title: t.of('app_version'),
                        icon: Icons.info_outline,
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
