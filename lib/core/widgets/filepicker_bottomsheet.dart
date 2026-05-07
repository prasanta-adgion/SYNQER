import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:synqer_io/core/utils/any_file_picker.dart';

class FilePickerBottomSheet {
  static Future<AppPickedFile?> show(BuildContext context) async {
    return showModalBottomSheet<AppPickedFile>(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (_) {
        return const _FilePickerSheet();
      },
    );
  }
}

class _FilePickerSheet extends StatelessWidget {
  const _FilePickerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 44,
            height: 4,

            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),

              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Choose File',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _PickerItem(
                  icon: Icons.camera_alt_rounded,

                  label: 'Camera',

                  color: const Color(0xFF3B82F6),

                  onTap: () async {
                    final file = await AppFilePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _PickerItem(
                  icon: Icons.photo_library_rounded,

                  label: 'Gallery',

                  color: const Color(0xFF10B981),

                  onTap: () async {
                    final file = await AppFilePicker.pickImage();

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _PickerItem(
                  icon: Icons.video_library_rounded,

                  label: 'Video',

                  color: const Color(0xFFF97316),

                  onTap: () async {
                    final file = await AppFilePicker.pickVideo();

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _PickerItem(
                  icon: Icons.description_rounded,

                  label: 'Document',

                  color: const Color(0xFF8B5CF6),

                  onTap: () async {
                    final file = await AppFilePicker.pickDocument();

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerItem extends StatelessWidget {
  final IconData icon;

  final String label;

  final Color color;

  final VoidCallback onTap;

  const _PickerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),

          decoration: BoxDecoration(
            color: color.withOpacity(0.08),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: color.withOpacity(0.18)),
          ),

          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),

                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: color, size: 26),
              ),

              const SizedBox(height: 12),

              Text(
                label,

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
