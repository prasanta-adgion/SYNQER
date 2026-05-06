import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import '../theme/theme_scope.dart';

class AppPopoverItem {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const AppPopoverItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.isDestructive = false,
  });
}

class AppPopoverMenu {
  static Future<void> show({
    required BuildContext context,
    required BuildContext buttonContext,
    required List<AppPopoverItem> items,

    double width = 200,

    PopoverDirection direction = PopoverDirection.bottom,
  }) async {
    final c = context.colors;

    await showPopover(
      context: buttonContext,

      direction: direction,

      width: width,

      arrowHeight: 10,

      arrowWidth: 10,

      backgroundColor: Colors.transparent,

      barrierColor: Colors.black26,

      radius: 10,

      bodyBuilder: (popoverContext) {
        return Container(
          decoration: BoxDecoration(
            color: c.surfaceHigh,

            borderRadius: BorderRadius.circular(10),

            border: Border.all(color: c.border, width: 1),

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

            borderRadius: BorderRadius.circular(10),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: List.generate(items.length, (index) {
                final item = items[index];

                final isFirst = index == 0;

                final isLast = index == items.length - 1;

                return Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    InkWell(
                      borderRadius: BorderRadius.vertical(
                        top: isFirst ? const Radius.circular(10) : Radius.zero,

                        bottom: isLast
                            ? const Radius.circular(10)
                            : Radius.zero,
                      ),

                      onTap: () {
                        Navigator.pop(popoverContext);

                        item.onTap();
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        child: Row(
                          children: [
                            Icon(
                              item.icon,

                              size: 20,

                              color: item.isDestructive
                                  ? c.error
                                  : item.iconColor ?? c.green,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                item.title,

                                style: TextStyle(
                                  color: item.isDestructive
                                      ? c.error
                                      : c.textPrimary,

                                  fontSize: 14,

                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: c.dropdownDivider,
                      ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
