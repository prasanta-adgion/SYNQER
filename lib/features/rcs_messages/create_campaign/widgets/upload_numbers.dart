import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';
import 'package:synqer_io/features/live_chat/save_contact/bloc/get_groups_bloc.dart';
import 'package:synqer_io/features/live_chat/save_contact/save_contact_screen.dart';

class UploadNumbersData {
  final List<String> numbers;
  final UploadAudienceMode mode;
  final String? groupName;

  const UploadNumbersData({
    this.numbers = const [],
    this.mode = UploadAudienceMode.manual,
    this.groupName,
  });

  UploadNumbersData copyWith({
    List<String>? numbers,
    UploadAudienceMode? mode,
    String? groupName,
    bool clearGroupName = false,
  }) {
    return UploadNumbersData(
      numbers: numbers ?? this.numbers,
      mode: mode ?? this.mode,
      groupName: clearGroupName ? null : groupName ?? this.groupName,
    );
  }
}

enum UploadAudienceMode { manual, bulk, group }

class UploadNumbers extends StatefulWidget {
  final UploadNumbersData initialData;
  final ValueChanged<UploadNumbersData>? onChanged;

  const UploadNumbers({
    super.key,
    this.initialData = const UploadNumbersData(),
    this.onChanged,
  });

  @override
  State<UploadNumbers> createState() => UploadNumbersState();
}

class UploadNumbersState extends State<UploadNumbers> {
  late final TextEditingController _manualNumbersController;
  late final ValueNotifier<UploadNumbersData> _dataNotifier;
  final ValueNotifier<String?> _errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isLoadingGroupNumbers = ValueNotifier(false);

  UploadNumbersData get _data => _dataNotifier.value;

  @override
  void initState() {
    super.initState();
    _dataNotifier = ValueNotifier(widget.initialData);
    _manualNumbersController = TextEditingController();
  }

  @override
  void dispose() {
    _manualNumbersController.dispose();
    _dataNotifier.dispose();
    _errorNotifier.dispose();
    _isLoadingGroupNumbers.dispose();
    super.dispose();
  }

  void _updateData(UploadNumbersData data) {
    _dataNotifier.value = data;
    widget.onChanged?.call(data);
  }

  void _setMode(UploadAudienceMode mode) {
    _errorNotifier.value = null;
    _updateData(_data.copyWith(mode: mode));
  }

  bool validateAndSave() {
    if (_data.mode == UploadAudienceMode.group) {
      if (_data.numbers.isEmpty) {
        _errorNotifier.value = 'Select a group with at least one number.';
        return false;
      }
      _errorNotifier.value = null;
      return true;
    }

    if (_data.mode != UploadAudienceMode.manual) return true;

    if (_manualNumbersController.text.trim().isNotEmpty) {
      return _addManualNumbers();
    }

    if (_data.numbers.isEmpty) {
      _errorNotifier.value = 'Add at least one recipient number.';
      return false;
    }

    _errorNotifier.value = null;
    return true;
  }

  bool _addManualNumbers() {
    final extractedNumbers = RegExp(r'(?<!\d)\d{10}(?!\d)')
        .allMatches(_manualNumbersController.text)
        .map((match) => match.group(0)!)
        .toList();

    if (extractedNumbers.isEmpty) {
      _errorNotifier.value = 'Enter at least one valid 10-digit number.';
      return false;
    }

    final numbers = [..._data.numbers];
    for (final number in extractedNumbers) {
      if (!numbers.contains(number)) numbers.add(number);
    }

    _errorNotifier.value = null;
    _manualNumbersController.clear();
    _updateData(_data.copyWith(numbers: numbers, clearGroupName: true));
    return true;
  }

  void _removeNumber(String number) {
    final numbers = _data.numbers.where((item) => item != number).toList();
    if (numbers.isNotEmpty) _errorNotifier.value = null;
    _updateData(_data.copyWith(numbers: numbers));
  }

  Future<void> _openGroupSelection() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) =>
              GetGroupsBloc(getGroupsRepo: AppInjector.getGroupsRepo),
          child: const GroupSelectionScreen(),
        ),
      ),
    );

    if (!mounted || result == null) return;

    final groupName = (result['groupName'] as String?)?.trim();
    if (groupName == null || groupName.isEmpty) return;

    _isLoadingGroupNumbers.value = true;
    _errorNotifier.value = null;

    try {
      final totalNumbers = result['totalNumbers'] as int? ?? 1000;
      final response = await AppInjector.manageContactsRepo.fetchContacts(
        page: 1,
        limit: totalNumbers <= 0 ? 1000 : totalNumbers,
        search: groupName,
      );

      if (!mounted) return;

      final numbers = response.data
          .where((contact) => contact.groupName?.trim() == groupName)
          .map((contact) => contact.mobileNumber?.trim() ?? '')
          .where((number) => RegExp(r'^\d{10}$').hasMatch(number))
          .toSet()
          .toList();

      if (numbers.isEmpty) {
        _errorNotifier.value = 'No valid 10-digit numbers found in this group.';
        _updateData(_data.copyWith(numbers: const [], groupName: groupName));
        return;
      }

      _updateData(
        _data.copyWith(
          mode: UploadAudienceMode.group,
          numbers: numbers,
          groupName: groupName,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _errorNotifier.value = 'Unable to load numbers for this group.';
    } finally {
      _isLoadingGroupNumbers.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ValueListenableBuilder<UploadNumbersData>(
      valueListenable: _dataNotifier,
      builder: (context, data, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Audience',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AudienceModeChip(
                    label: 'Add Manually',
                    selected: data.mode == UploadAudienceMode.manual,
                    onTap: () => _setMode(UploadAudienceMode.manual),
                  ),
                  _AudienceModeChip(
                    label: 'Bulk Upload',
                    selected: data.mode == UploadAudienceMode.bulk,
                    onTap: () => _setMode(UploadAudienceMode.bulk),
                  ),
                  _AudienceModeChip(
                    label: 'Send by Group',
                    selected: data.mode == UploadAudienceMode.group,
                    onTap: () => _setMode(UploadAudienceMode.group),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<String?>(
                valueListenable: _errorNotifier,
                builder: (context, errorText, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isLoadingGroupNumbers,
                    builder: (context, isLoadingGroupNumbers, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: switch (data.mode) {
                          UploadAudienceMode.manual => _ManualAudienceForm(
                            key: const ValueKey('manual'),
                            controller: _manualNumbersController,
                            errorText: errorText,
                            numbers: data.numbers,
                            onAdd: _addManualNumbers,
                            onRemove: _removeNumber,
                          ),
                          UploadAudienceMode.bulk => const _BulkUploadForm(
                            key: ValueKey('bulk'),
                          ),
                          UploadAudienceMode.group => _GroupAudienceForm(
                            key: const ValueKey('group'),
                            groupName: data.groupName,
                            numbers: data.numbers,
                            errorText: errorText,
                            isLoading: isLoadingGroupNumbers,
                            onTap: _openGroupSelection,
                            onRemove: _removeNumber,
                          ),
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              const _AudienceInstructions(),
            ],
          ),
        );
      },
    );
  }
}

class _AudienceModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AudienceModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? c.textPrimary : c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? c.textPrimary : c.borderStrong),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c.surface : c.textPrimary,
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ManualAudienceForm extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final List<String> numbers;
  final bool Function() onAdd;
  final ValueChanged<String> onRemove;

  const _ManualAudienceForm({
    super.key,
    required this.controller,
    required this.errorText,
    required this.numbers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add numbers manually',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: controller,
                hint_text: 'Paste or enter 10-digit number(s)',
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  onAdd();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: c.textPrimary,
                  foregroundColor: c.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 7),
          Text(errorText!, style: TextStyle(color: c.error, fontSize: 11.5)),
        ],
        if (numbers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Added Numbers (${numbers.length})',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: numbers
                .map(
                  (number) => _NumberChip(
                    number: number,
                    onRemove: () => onRemove(number),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _NumberChip extends StatelessWidget {
  final String number;
  final VoidCallback onRemove;

  const _NumberChip({required this.number, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Icon(Icons.close_rounded, color: c.textSecondary, size: 16),
          ),
        ],
      ),
    );
  }
}

class _BulkUploadForm extends StatelessWidget {
  const _BulkUploadForm({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload recipient file',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('Choose File'),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textPrimary,
            side: BorderSide(color: c.borderStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupAudienceForm extends StatelessWidget {
  final String? groupName;
  final List<String> numbers;
  final String? errorText;
  final bool isLoading;
  final VoidCallback onTap;
  final ValueChanged<String> onRemove;

  const _GroupAudienceForm({
    super.key,
    required this.groupName,
    required this.numbers,
    required this.errorText,
    required this.isLoading,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select contact group',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: c.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.inputBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.group_outlined, color: c.inputIcon, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    groupName?.isNotEmpty == true
                        ? groupName!
                        : 'Choose a saved group',
                    style: TextStyle(
                      color: groupName?.isNotEmpty == true
                          ? c.inputText
                          : c.inputHint,
                      fontSize: 13,
                      fontWeight: groupName?.isNotEmpty == true
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: c.primary,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: c.textSecondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 7),
          Text(
            errorText!,
            style: TextStyle(color: c.error, fontSize: 11.5),
          ),
        ],
        if (numbers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Group Numbers (${numbers.length})',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: numbers
                .map(
                  (number) => _NumberChip(
                    number: number,
                    onRemove: () => onRemove(number),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _AudienceInstructions extends StatelessWidget {
  const _AudienceInstructions();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        border: Border(left: BorderSide(color: c.textPrimary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          _InstructionLine(
            parts: [
              const TextSpan(text: 'Numbers must be '),
              TextSpan(
                text: '10 digits',
                style: TextStyle(
                  color: c.error,
                  backgroundColor: c.dangerSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: ' (no country code).'),
            ],
          ),
          const SizedBox(height: 4),
          const _InstructionLine(
            parts: [
              TextSpan(text: 'Supported formats: CSV, XLS, XLSX - Max 50MB.'),
            ],
          ),
          const SizedBox(height: 4),
          const _InstructionLine(
            parts: [TextSpan(text: 'Duplicates are automatically removed.')],
          ),
        ],
      ),
    );
  }
}

class _InstructionLine extends StatelessWidget {
  final List<InlineSpan> parts;

  const _InstructionLine({required this.parts});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('- ', style: TextStyle(color: c.textSecondary, fontSize: 12)),
        Expanded(
          child: Text.rich(
            TextSpan(children: parts),
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 11.5,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
