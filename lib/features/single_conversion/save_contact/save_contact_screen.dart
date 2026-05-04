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
import 'package:synqer_io/core/widgets/custom_text_fields.dart';
import 'package:synqer_io/features/single_conversion/save_contact/bloc/get_groups_bloc.dart';

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
      final mobile = mobileController.text.trim();
      final group = groupController.text.trim();

      debugPrint("Saving Contact");
      debugPrint("Name: $fullName");
      debugPrint("Mobile: $mobile");
      debugPrint("Group: $group");
      debugPrint("Selected Group Details: $_selectedGroup");

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Contact saved successfully"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Save Contact Error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save contact"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                          color: c.primary,
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

class GroupSelectionField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const GroupSelectionField({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: "Select Group",
        prefixIcon: const Icon(Icons.group_outlined),
        suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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

    // Fetch groups when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetGroupsBloc>().add(const FetchGroupsEvent());
    });

    _scrollController.addListener(_onScroll);
  }

  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<GetGroupsBloc>().add(FetchGroupsEvent(search: value));
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= (max - 200)) {
      final state = context.read<GetGroupsBloc>().state;

      if (state is GetGroupsLoaded) {
        if (state.hasMore && !state.isLoadingMore) {
          context.read<GetGroupsBloc>().add(
            LoadMoreGroupsEvent(
              page: state.currentPage + 1,
              limit: 20,
              search: state.search,
            ),
          );
        }
      }
    }
  }

  void _selectGroup(dynamic group) {
    // Return selected group data back to previous screen
    Navigator.pop(context, {
      'groupName': group.groupName,
      'totalNumbers': group.totalNumbers,
      // Add any other properties you need from the group object
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _onSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Group",
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search groups...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// GROUPS LIST
          Expanded(
            child: BlocBuilder<GetGroupsBloc, GetGroupsState>(
              builder: (context, state) {
                /// LOADING
                if (state is GetGroupsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// ERROR
                if (state is GetGroupsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GetGroupsBloc>().add(
                                const FetchGroupsEvent(),
                              );
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                /// LOADED
                if (state is GetGroupsLoaded) {
                  if (state.groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No groups found",
                            style: TextStyle(
                              fontSize: 16,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        state.groups.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= state.groups.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = state.groups[index];

                      return InkWell(
                        onTap: () => _selectGroup(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: c.primary.withOpacity(0.1),
                                child: Text(
                                  (item.groupName ?? '').isNotEmpty
                                      ? item.groupName![0].toUpperCase()
                                      : 'G',
                                  style: TextStyle(
                                    color: c.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.groupName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: c.textPrimary,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "${item.totalNumbers ?? 0} contacts",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(Icons.chevron_right, color: c.textSecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
