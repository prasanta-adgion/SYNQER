import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';

class TempleteDisplayScreen extends StatelessWidget {
  const TempleteDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: CustomAppBar(
        title: 'Manage Template',
        subtitle: 'Manage approved RCS templates',
        backgroundColor: c.surface,
        titleColor: c.textPrimary,
        subtitleColor: c.textSecondary,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 10),
        child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.accentSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        color: c.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Template',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'View, review, and organize RCS templates',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: c.surfaceHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.border),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: c.textSecondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No templates yet',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Approved RCS templates will appear here once they are created.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
