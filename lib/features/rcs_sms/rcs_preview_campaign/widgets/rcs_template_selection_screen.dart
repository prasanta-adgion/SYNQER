// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';

class RcsTemplateSelectionItem {
  final String id;
  final String name;
  final String type;
  final IconData icon;

  const RcsTemplateSelectionItem({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  String get label => '$name -- $type';
}

class RcsTemplateSelectionScreen extends StatelessWidget {
  final List<RcsTemplateSelectionItem> templates;
  final String? selectedTemplateId;

  const RcsTemplateSelectionScreen({
    super.key,
    required this.templates,
    this.selectedTemplateId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,

      appBar: CustomAppBar(
        title: 'Select RCS Template',
        subtitle: 'All templetes in one place',
        backgroundColor: c.surface,
        titleColor: c.textPrimary,
        subtitleColor: c.textSecondary,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: templates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final template = templates[index];
            final isSelected = template.id == selectedTemplateId;

            return _TemplateTile(
              template: template,
              isSelected: isSelected,
              onTap: () => Navigator.pop(context, template),
            );
          },
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final RcsTemplateSelectionItem template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? c.primary.withOpacity(0.08) : c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? c.primary : c.border,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.border),
              ),
              child: Icon(template.icon, color: c.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      template.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey('selected'),
                      color: c.green,
                      size: 22,
                    )
                  : Icon(
                      Icons.keyboard_arrow_right_rounded,
                      key: const ValueKey('open'),
                      color: c.textMuted,
                      size: 22,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
