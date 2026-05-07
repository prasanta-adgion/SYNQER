// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/features/profile/model/user_profile_model.dart';

class BalanceCards extends StatelessWidget {
  final User allServiceBalance;
  const BalanceCards({super.key, required this.allServiceBalance});

  @override
  Widget build(BuildContext context) {
    final totalRcsBalance =
        (allServiceBalance.rcsBalance?.text ?? 0.0) +
        (allServiceBalance.rcsBalance?.richMedia ?? 0.0);
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        _ServiceBalanceCard(
          service: 'Bulk SMS',
          balance: allServiceBalance.smsBalance ?? 0.0,
          icon: Icons.sms_rounded,
          gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        SizedBox(width: 12),
        _ServiceBalanceCard(
          service: 'WhatsApp',
          balance: allServiceBalance.whatsappBalance ?? 0.0,
          icon: Icons.chat_bubble_rounded,
          gradient: [Color(0xFF059669), Color(0xFF10B981)],
        ),
        SizedBox(width: 12),
        _ServiceBalanceCard(
          service: 'RCS',
          balance: totalRcsBalance,
          icon: Icons.message_rounded,
          gradient: [Color(0xFFDC2626), Color(0xFFF97316)],
        ),
      ],
    );
  }
}

class _ServiceBalanceCard extends StatelessWidget {
  final String service;
  final double balance;
  final IconData icon;
  final List<Color> gradient;
  const _ServiceBalanceCard({
    required this.service,
    required this.balance,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Center(
                  child: AppConfig.serviceIcon(
                    service.toLowerCase(),
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  service,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
