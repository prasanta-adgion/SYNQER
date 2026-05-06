// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/app_popover_dailog.dart';
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

              onTap: () {
                debugPrint("Call: $number");
              },
            ),

            AppPopoverItem(
              title: 'Refresh Chat',

              icon: Icons.refresh,

              onTap: () {
                context.read<SingleConversionsBloc>().add(
                  SilentRefreshSingleConversionsEvent(
                    customerMobile: number,
                    limit: 50,
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
