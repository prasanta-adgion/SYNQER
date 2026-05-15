// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/core/widgets/app_popover_dailog.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/features/live_chat/single_conversion/bloc/single_conversions_bloc.dart';
import 'package:synqer_io/features/live_chat/save_contact/save_contact_screen.dart';

const int _messagesPageLimit = 25;

class ChatAppbar extends StatelessWidget {
  final String customerNumber;
  final String customerName;

  const ChatAppbar({
    super.key,
    required this.customerNumber,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(color: c.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            children: [
              /// BACK BUTTON
              IconButton(
                icon: Icon(Icons.arrow_back, color: c.onBrand),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              /// AVATAR
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.onBrand, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: c.primary,
                  child: Icon(Icons.person, color: c.onBrand, size: 24),
                ),
              ),

              const SizedBox(width: 12),

              /// USER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.isNotEmpty
                          ? customerName
                          : "+$customerNumber",
                      style: TextStyle(
                        color: c.onBrand,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      customerNumber,
                      style: TextStyle(
                        color: c.onBrand.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              /// CALL BUTTON
              IconButton(
                onPressed: () => _callCustomer(context, customerNumber),
                icon: Icon(Icons.call_rounded, color: c.onBrand),
              ),

              /// MORE OPTIONS
              _buildMoreOptions(context, customerNumber, c),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _callCustomer(BuildContext context, String number) async {
  final phone = _phoneForDial(number);

  if (phone.isEmpty) {
    AppSnackbar.show(
      context,
      message: 'Phone number not available',
      type: SnackbarType.error,
    );
    return;
  }

  try {
    final launched = await AppConfig.launchCaller(
      AppConfig.removeCountryCode(phone),
    );
    if (launched || !context.mounted) return;

    AppSnackbar.show(
      context,
      message: 'Could not open phone dialer',
      type: SnackbarType.error,
    );
  } catch (_) {
    if (!context.mounted) return;
    AppSnackbar.show(
      context,
      message: 'Could not open phone dialer',
      type: SnackbarType.error,
    );
  }
}

String _phoneForDial(String rawPhone) {
  return rawPhone.replaceAll(RegExp(r'[^0-9+]'), '').trim();
}

Widget _buildMoreOptions(BuildContext context, String number, AppColors c) {
  return Builder(
    builder: (buttonContext) => IconButton(
      icon: Icon(Icons.more_vert, color: c.onBrand),
      onPressed: () {
        AppPopoverMenu.show(
          context: context,

          buttonContext: buttonContext,

          items: [
            AppPopoverItem(
              title: 'Add Contact',

              icon: Icons.person_add_alt_1,

              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: c.bottomSheet,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) {
                    return SaveContact(customerNumber: number);
                  },
                );
              },
            ),

            AppPopoverItem(
              title: 'Call',

              icon: Icons.call,

              onTap: () => _callCustomer(context, number),
            ),

            AppPopoverItem(
              title: 'Refresh Chat',

              icon: Icons.refresh,

              onTap: () {
                context.read<SingleConversionsBloc>().add(
                  SilentRefreshSingleConversionsEvent(
                    customerMobile: number,
                    limit: _messagesPageLimit,
                  ),
                );
              },
            ),
          ],
        );
      },
    ),
  );
}
