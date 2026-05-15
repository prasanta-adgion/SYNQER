// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';

class RcsReportDashboard extends StatelessWidget {
  final bool showAppBar;

  const RcsReportDashboard({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = AppConfig.serviceColor('rcs');

    return Scaffold(
      backgroundColor: c.bg,
      appBar: showAppBar
          ? CustomAppBar(
              title: 'RCS Report',
              subtitle: 'Campaign performance dashboard',
              backgroundColor: c.surface,
              titleColor: c.textPrimary,
              subtitleColor: c.textSecondary,
              onBack: () => Navigator.pop(context),
            )
          : null,
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
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: AppConfig.serviceIcon('rcs', size: 24, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RCS Report',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Overview of message delivery and engagement',
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: const [
                _ReportMetricCard(
                  title: 'Campaigns',
                  value: '0',
                  icon: Icons.campaign_outlined,
                ),
                _ReportMetricCard(
                  title: 'Delivered',
                  value: '0',
                  icon: Icons.mark_email_read_outlined,
                ),
                _ReportMetricCard(
                  title: 'Read',
                  value: '0',
                  icon: Icons.visibility_outlined,
                ),
                _ReportMetricCard(
                  title: 'Responses',
                  value: '0',
                  icon: Icons.touch_app_outlined,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ReportPanel(
              title: 'Recent Campaign Activity',
              subtitle:
                  'Campaign performance will appear here once you start sending RCS messages.',
              icon: Icons.insights_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: c.primary, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ReportPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
