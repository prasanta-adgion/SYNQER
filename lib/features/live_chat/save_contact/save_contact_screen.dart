// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/core/utils/fields_validation.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';
import 'package:synqer_io/features/live_chat/save_contact/bloc/get_groups_bloc.dart';

class SaveContact extends StatefulWidget {
  final String customerNumber;

  const SaveContact({super.key, required this.customerNumber});

  @override
  State<SaveContact> createState() => _SaveContactState();
}

class _SaveContactState extends State<SaveContact> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameController;
  late final TextEditingController mobileController;
  late final TextEditingController groupController;

  final ValueNotifier<bool> _isSaving = ValueNotifier(false);

  // Store selected group details
  Map<String, dynamic>? _selectedGroup;

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController();

    mobileController = TextEditingController(
      text: AppConfig.removeCountryCode(widget.customerNumber),
    );

    groupController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();
    groupController.dispose();
    _isSaving.dispose();

    super.dispose();
  }

  Future<void> _openGroupSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) =>
              GetGroupsBloc(getGroupsRepo: AppInjector.getGroupsRepo),
          child: const GroupSelectionScreen(),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedGroup = result;
        groupController.text = result['groupName'] ?? '';
      });
    }
  }

  Future<void> _saveContact() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      _isSaving.value = true;

      final fullName = fullNameController.text.trim();
      final phone = mobileController.text.trim();
      final groupName = groupController.text.trim();

      await Future.delayed(const Duration(milliseconds: 800));

      final responseData = await AppInjector.getGroupsRepo.addContact(
        fullName: fullName,
        groupName: groupName,
        phone: phone,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (responseData['success'].toString() == 'true') {
        AppSnackbar.show(
          context,
          message: 'Contact saved successfully',
          type: SnackbarType.success,
        );
      } else {
        final errorMsg = responseData['message'];
        debugPrint("Error in contact save in: $errorMsg");

        if (errorMsg.contains("Contact already exists")) {
          AppSnackbar.show(
            context,
            message: errorMsg,
            type: SnackbarType.error,
          );
        } else {
          AppSnackbar.show(
            context,
            message: 'Error in contact save.',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      debugPrint("Save Contact Error: $e");

      if (!mounted) return;
      Navigator.pop(context);

      AppSnackbar.show(
        context,
        message: 'Error in contact save.',
        type: SnackbarType.error,
      );
    } finally {
      _isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HANDLE
                    Container(
                      width: 42,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: c.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    /// TITLE
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.person_crop_circle_badge_plus,
                          color: c.green,
                          size: 26,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Add Contact",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// NAME
                    CustomTextFormField(
                      fieldIcon: Icons.person_outline,
                      controller: fullNameController,
                      hint_text: 'Full Name',
                      keyboardType: TextInputType.name,
                      validator: Validation.validateName,
                    ),

                    const SizedBox(height: 16),

                    /// MOBILE
                    CustomTextFormField(
                      fieldIcon: Icons.phone_android_outlined,
                      controller: mobileController,
                      hint_text: 'Mobile Number',
                      keyboardType: TextInputType.phone,
                      validator: Validation.validatePhone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),

                    const SizedBox(height: 16),

                    CustomTextFormField(
                      fieldIcon: Icons.group_outlined,
                      controller: groupController,
                      onTap: _openGroupSelection,
                      hint_text: 'Select Group',
                      keyboardType: TextInputType.text,
                      // validator: Validation.validateGroup,
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_right_rounded,

                        color: c.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// SAVE BUTTON
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSaving,
                      builder: (context, isSaving, _) {
                        return AppButton(
                          text: isSaving ? 'Saving...' : 'Save Contact',
                          loading: isSaving,
                          onPressed: isSaving ? null : _saveContact,
                          icon: isSaving
                              ? CupertinoIcons.time
                              : CupertinoIcons.check_mark,
                          bgColor: c.primary,
                          textColor: Colors.white,
                          borderRadius: 5,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchGroups());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchGroups([String search = '']) =>
      context.read<GetGroupsBloc>().add(FetchGroupsEvent(search: search));

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _fetchGroups(value);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final atBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (!atBottom) return;

    final state = context.read<GetGroupsBloc>().state;
    if (state is GetGroupsLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<GetGroupsBloc>().add(
        LoadMoreGroupsEvent(
          page: state.currentPage + 1,
          limit: 20,
          search: state.search,
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _fetchGroups();
  }

  void _selectGroup(dynamic group) => Navigator.pop(context, {
    'groupName': group.groupName,
    'totalNumbers': group.totalNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Select Group',
        onBackTap: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: _onSearch,
            onClear: _clearSearch,
          ),
          Expanded(
            child: _GroupsList(
              scrollController: _scrollController,
              onSelect: _selectGroup,
              onRetry: _fetchGroups,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SearchBar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: c.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search groups…',
          hintStyle: TextStyle(color: c.textSecondary, fontSize: 15),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: c.textSecondary,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: c.textSecondary,
                    size: 20,
                  ),
                  onPressed: onClear,
                  splashRadius: 18,
                )
              : null,
          filled: true,
          fillColor: c.textSecondary.withOpacity(0.07),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(color: c.primary, width: 1.5),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: color != null
            ? BorderSide(color: color, width: width)
            : BorderSide.none,
      );
}

// ---------------------------------------------------------------------------
// _GroupsList  –  pure display widget, no state needed
// ---------------------------------------------------------------------------

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    required this.scrollController,
    required this.onSelect,
    required this.onRetry,
  });

  final ScrollController scrollController;
  final ValueChanged<dynamic> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetGroupsBloc, GetGroupsState>(
      builder: (context, state) => switch (state) {
        GetGroupsLoading() => const _LoadingView(),
        GetGroupsError() => _ErrorView(
          message: state.message,
          onRetry: onRetry,
        ),
        GetGroupsLoaded() =>
          state.groups.isEmpty
              ? const _EmptyView()
              : _LoadedList(
                  state: state,
                  scrollController: scrollController,
                  onSelect: onSelect,
                ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _LoadedList
// ---------------------------------------------------------------------------

class _LoadedList extends StatelessWidget {
  const _LoadedList({
    required this.state,
    required this.scrollController,
    required this.onSelect,
  });

  final GetGroupsLoaded state;
  final ScrollController scrollController;
  final ValueChanged<dynamic> onSelect;

  @override
  Widget build(BuildContext context) {
    final itemCount = state.groups.length + (state.isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: itemCount,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 72, endIndent: 8),
      itemBuilder: (context, index) {
        if (index >= state.groups.length) {
          return const _LoadMoreIndicator();
        }
        return _GroupTile(
          group: state.groups[index],
          onTap: () => onSelect(state.groups[index]),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _GroupTile
// ---------------------------------------------------------------------------

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onTap});

  final dynamic group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = (group.groupName as String?) ?? '';
    final count = (group.totalNumbers as int?) ?? 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: c.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Name + count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: c.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count contact${count == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 13, color: c.textSecondary),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: c.textSecondary.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State placeholder widgets
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => Center(
    child: CircularProgressIndicator(
      strokeWidth: 2.5,
      color: context.colors.primary,
    ),
  );
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.primary,
        ),
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: c.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_off_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No groups found',
            style: TextStyle(fontSize: 15, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
