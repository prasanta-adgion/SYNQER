// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popover/popover.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/live_chat/single_conversion/bloc/single_conversions_bloc.dart';
import 'package:synqer_io/features/live_chat/save_contact/save_contact_screen.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              /// BACK BUTTON
              IconButton(
                icon: Icon(Icons.arrow_back, color: c.onBrand),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(width: 8),

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

              /// REFRESH BUTTON
              BlocBuilder<SingleConversionsBloc, SingleConversionsState>(
                builder: (context, state) {
                  final isRefreshing =
                      state is SingleConversionsLoaded && state.isRefreshing;

                  return IconButton(
                    onPressed: isRefreshing
                        ? null
                        : () {
                            context.read<SingleConversionsBloc>().add(
                              SilentRefreshSingleConversionsEvent(
                                customerMobile: customerNumber,
                                limit: 50,
                              ),
                            );
                          },
                    icon: isRefreshing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onBrand,
                            ),
                          )
                        : Icon(Icons.refresh, color: c.onBrand),
                  );
                },
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

Widget _buildMoreOptions(BuildContext context, String number, AppColors c) {
  return Builder(
    builder: (buttonContext) => IconButton(
      icon: Icon(Icons.more_vert, color: c.onBrand),
      onPressed: () {
        showPopover(
          context: buttonContext,
          direction: PopoverDirection.bottom,
          width: 190,
          arrowHeight: 10,
          arrowWidth: 10,
          backgroundColor: Colors.transparent,
          radius: 5,
          barrierColor: Colors.black26,

          bodyBuilder: (popoverContext) {
            return Container(
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(5),

                // Border
                border: Border.all(color: c.border, width: 1),

                // Shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ADD CONTACT
                    InkWell(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                      onTap: () {
                        Navigator.pop(popoverContext);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: c.bottomSheet,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return SaveContact(customerNumber: number);
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add_alt_1,
                              size: 20,
                              color: c.green,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'Add Contact',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 0.6,
                      color: c.dropdownDivider,
                    ),

                    /// CALL
                    InkWell(
                      onTap: () {
                        Navigator.pop(popoverContext);

                        debugPrint("Call: $number");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.call, size: 20, color: c.green),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'Call',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 0.6,
                      color: c.dropdownDivider,
                    ),

                    /// REFRESH CHAT
                    InkWell(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(14),
                      ),
                      onTap: () {
                        Navigator.pop(popoverContext);

                        context.read<SingleConversionsBloc>().add(
                          SilentRefreshSingleConversionsEvent(
                            customerMobile: number,
                            limit: 50,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 20, color: c.green),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'Refresh Chat',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
