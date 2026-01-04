import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/constants/colors.dart';
import 'package:my_app/presentation/state/settings_store.dart';
import 'package:my_app/presentation/pages/chat_page.dart';

class AdvisorPage extends StatelessWidget {
  const AdvisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<SettingsStore>(context);
    final t = store.translations; // استدعاء الترجمات

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          t.of('advisor'),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1100;
          final isTablet = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : 20,
              vertical: 40,
            ),
            child: Column(
              children: [
                _HeaderSection(isDesktop: isDesktop, t: t),
                const SizedBox(height: 50),
                _FeaturesGrid(
                  crossAxisCount: isDesktop
                      ? 3
                      : isTablet
                          ? 2
                          : 1,
                  t: t,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/* ===================== HEADER ===================== */
class _HeaderSection extends StatelessWidget {
  final bool isDesktop;
  final dynamic t;
  const _HeaderSection({required this.isDesktop, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: isDesktop ? 420 : 260,
          child: Image.asset(
            'assets/67ee6a417cbff236e9.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          t.of('advisor_header_title'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 32 : 22,
            fontWeight: FontWeight.bold,
            color: kTextDarkColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t.of('advisor_header_subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 14,
            color: kTextSecondaryColor,
          ),
        ),
      ],
    );
  }
}

/* ===================== GRID ===================== */
class _FeaturesGrid extends StatelessWidget {
  final int crossAxisCount;
  final dynamic t;
  const _FeaturesGrid({required this.crossAxisCount, required this.t});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      children: [
        AdvisorFeatureCard(
          icon: Icons.smart_toy_outlined,
          title: t.of('chat_with_ai'),
          description: t.of('chat_with_ai_desc'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatAIPage()),
            );
          },
        ),
        AdvisorFeatureCard(
          icon: Icons.support_agent,
          title: t.of('contact_advisor'),
          description: t.of('contact_advisor_desc'),
        ),
        AdvisorFeatureCard(
          icon: Icons.help_outline,
          title: t.of('faq_help'),
          description: t.of('faq_help_desc'),
        ),
      ],
    );
  }
}

/* ===================== FEATURE CARD ===================== */
class AdvisorFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const AdvisorFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  State<AdvisorFeatureCard> createState() => _AdvisorFeatureCardState();
}

class _AdvisorFeatureCardState extends State<AdvisorFeatureCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kShadowColor,
                blurRadius: isHover ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isHover ? kPrimaryColor : kDividerColor,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 48, color: kPrimaryColor),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDarkColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style:
                    const TextStyle(fontSize: 14, color: kTextSecondaryColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
