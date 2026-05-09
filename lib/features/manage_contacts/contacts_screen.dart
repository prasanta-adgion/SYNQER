// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/loading_screen.dart';
import 'package:synqer_io/features/live_chat/save_contact/bloc/get_groups_bloc.dart';
import 'package:synqer_io/features/live_chat/save_contact/model/groups_model.dart';
import 'package:synqer_io/features/live_chat/save_contact/save_contact_screen.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/features/manage_contacts/bloc/get_contacts_bloc.dart';
import 'package:synqer_io/features/manage_contacts/model/contacts_model.dart';
import 'package:synqer_io/features/manage_contacts/widgets/delete_dailog.dart';

const List<Color> _avatarPalette = [
  Color(0xFF6366F1),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
];

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetContactsBloc(repo: AppInjector.manageContactsRepo)
                ..add(const FetchContactsEvent(page: 1, limit: 20)),
        ),
        BlocProvider(
          create: (_) =>
              GetGroupsBloc(getGroupsRepo: AppInjector.getGroupsRepo),
        ),
      ],
      child: const _ContactsView(),
    );
  }
}

class _ContactsView extends StatefulWidget {
  const _ContactsView();

  @override
  State<_ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<_ContactsView>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 20;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _groupsScrollController = ScrollController();
  Timer? _debounce;
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<Set<String>> _selected = ValueNotifier({});
  final ValueNotifier<bool> _selectionMode = ValueNotifier(false);
  final ValueNotifier<bool> _isDeleting = ValueNotifier(false);
  bool _hasFetchedGroups = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _groupsScrollController.addListener(_onGroupsScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _groupsScrollController.dispose();
    _searchQuery.dispose();
    _selected.dispose();
    _selectionMode.dispose();
    _isDeleting.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 200) {
      final state = context.read<GetContactsBloc>().state;
      if (state is GetContactsLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<GetContactsBloc>().add(
          LoadMoreContactsEvent(
            page: state.currentPage + 1,
            limit: _pageSize,
            searchValue: _searchQuery.value.isEmpty ? null : _searchQuery.value,
          ),
        );
      }
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging || _tabController.index != 1) return;
    if (_hasFetchedGroups) return;
    _fetchGroups(search: _searchQuery.value);
  }

  void _fetchGroups({String search = ''}) {
    _hasFetchedGroups = true;
    context.read<GetGroupsBloc>().add(
      FetchGroupsEvent(page: 1, limit: _pageSize, search: search),
    );
  }

  void _refreshGroupsIfNeeded() {
    _hasFetchedGroups = false;
    if (_tabController.index == 1) {
      _fetchGroups(search: _searchQuery.value);
    }
  }

  void _onGroupsScroll() {
    if (!_groupsScrollController.hasClients) return;
    final maxScroll = _groupsScrollController.position.maxScrollExtent;
    final current = _groupsScrollController.position.pixels;
    if (current < maxScroll - 200) return;

    final state = context.read<GetGroupsBloc>().state;
    if (state is GetGroupsLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<GetGroupsBloc>().add(
        LoadMoreGroupsEvent(
          page: state.currentPage + 1,
          limit: _pageSize,
          search: state.search,
        ),
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = value.trim();
      _searchQuery.value = query;

      if (_tabController.index == 1) {
        _hasFetchedGroups = true;
        context.read<GetGroupsBloc>().add(
          FetchGroupsEvent(page: 1, limit: _pageSize, search: query),
        );
      } else {
        context.read<GetContactsBloc>().add(
          FetchContactsEvent(
            page: 1,
            limit: _pageSize,
            searchValue: query.isEmpty ? null : query,
          ),
        );
      }
    });
  }

  void _toggleSelection(String id) {
    final newSelected = Set<String>.from(_selected.value);
    if (newSelected.contains(id)) {
      newSelected.remove(id);
      _selected.value = newSelected;
      if (newSelected.isEmpty) _selectionMode.value = false;
    } else {
      newSelected.add(id);
      _selected.value = newSelected;
      _selectionMode.value = true;
    }
  }

  void _clearSelection() {
    _selected.value = {};
    _selectionMode.value = false;
  }

  Future<void> _refreshContacts() async {
    context.read<GetContactsBloc>().add(
      FetchContactsEvent(
        page: 1,
        limit: _pageSize,
        searchValue: _searchQuery.value.isEmpty ? null : _searchQuery.value,
      ),
    );
  }

  Future<void> _refreshContactsAndGroups() async {
    await _refreshContacts();
    _refreshGroupsIfNeeded();
  }

  Future<void> _deleteContact(String deleteId) async {
    FocusScope.of(context).unfocus();

    try {
      _isDeleting.value = true;

      await Future.delayed(const Duration(milliseconds: 800));

      final responseData = await AppInjector.manageContactsRepo.deleteContact(
        contactId: deleteId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (responseData['success'].toString() == 'true') {
        await _refreshContactsAndGroups();

        if (!mounted) return;

        AppSnackbar.show(
          context,
          message: 'Contact deleted successfully',
          type: SnackbarType.success,
        );
      } else {
        final errorMsg = responseData['message'];
        debugPrint("Error in contact delete: $errorMsg");

        if (errorMsg is String && errorMsg.contains("Contact already exists")) {
          AppSnackbar.show(
            context,
            message: errorMsg,
            type: SnackbarType.error,
          );
        } else {
          AppSnackbar.show(
            context,
            message: 'Error in contact delete.',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      debugPrint("Delete Contact Error: $e");

      if (!mounted) return;
      Navigator.pop(context);

      AppSnackbar.show(
        context,
        message: 'Error in contact delete.',
        type: SnackbarType.error,
      );
    } finally {
      _isDeleting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocBuilder<GetContactsBloc, GetContactsState>(
      builder: (context, state) {
        final contacts = state is GetContactsLoaded
            ? state.contacts
            : <ContactsDataModel>[];
        return ListenableBuilder(
          listenable: Listenable.merge([
            _selected,
            _selectionMode,
            _searchQuery,
            _tabController,
          ]),
          builder: (context, _) {
            return Scaffold(
              backgroundColor: c.bg,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(c, contacts.length),
                    _buildSearchBar(c),
                    _buildTabBar(c),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAllContactsContent(c, state, contacts),
                          _GroupsTab(scrollController: _groupsScrollController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: _selectionMode.value
                  ? _BulkActionFab(
                      count: _selected.value.length,
                      onDelete: _showBulkDeleteDialog,
                      onCancel: _clearSelection,
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildAllContactsContent(
    AppColors c,
    GetContactsState state,
    List<ContactsDataModel> contacts,
  ) {
    if (state is GetContactsLoading) {
      // return Center(child: CircularProgressIndicator(color: c.primary));
      return FullScreenLoader(message: 'Contacts loading...');
    }
    if (state is GetContactsError) {
      return _EmptyState(message: state.message);
    }
    if (contacts.isEmpty) {
      return const _EmptyState(message: 'No contacts found');
    }
    return _AllContactsTab(
      contacts: contacts,
      selected: _selected.value,
      selectionMode: _selectionMode.value,
      onToggleSelect: _toggleSelection,
      onEdit: _showEditDialog,
      onDelete: _showDeleteDialog,
      scrollController: _scrollController,
      isLoadingMore: state is GetContactsLoaded && state.isLoadingMore,
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppColors c, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count total contacts',
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          _ActionButton(
            icon: Icons.upload_file_rounded,
            label: 'Excel',
            color: c.green,
            onTap: _showBulkUploadDialog,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.person_add_rounded,
            label: 'Add new',
            color: c.textPrimary,
            // onTap: _showAddContactDialog,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: c.bottomSheet,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) {
                  return SaveContact(
                    customerNumber: '',
                    onSaved: _refreshContactsAndGroups,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppColors c) {
    final isGroupsTab = _tabController.index == 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.inputBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(color: c.inputText, fontSize: 15),
          decoration: InputDecoration(
            hintText: isGroupsTab
                ? 'Search groups…'
                : 'Search by name or number…',
            hintStyle: TextStyle(color: c.inputHint, fontSize: 15),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: c.inputIcon,
              size: 20,
            ),
            suffixIcon: _searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: c.inputIcon,
                      size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: c.border),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(35),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelColor: c.onBrand,
          unselectedLabelColor: c.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('All Contacts'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_work_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Groups'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showEditDialog(ContactsDataModel contact) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.bottomSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SaveContact(
        customerNumber: contact.mobileNumber ?? '',
        contactId: contact.sId,
        initialName: contact.fullName,
        initialMobile: contact.mobileNumber,
        initialGroup: contact.groupName,
        onSaved: _refreshContactsAndGroups,
      ),
    );
  }

  void _showDeleteDialog(ContactsDataModel contact) {
    final c = context.colors;
    final contactId = contact.sId;

    if (contactId == null || contactId.isEmpty) {
      AppSnackbar.show(
        context,
        message: 'Unable to delete contact.',
        type: SnackbarType.error,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => DeleteDialog(
        title: 'Delete Contact',
        message:
            'Remove ${contact.fullName} from your contacts? This cannot be undone.',
        confirmLabel: 'Delete',
        confirmColor: c.error,
        isLoading: _isDeleting,
        onConfirm: () => _deleteContact(contactId),
      ),
    );
  }

  void _showBulkDeleteDialog() {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (_) => DeleteDialog(
        title: 'Delete ${_selected.value.length} Contacts',
        message: 'This will permanently remove all selected contacts.',
        confirmLabel: 'Delete All',
        confirmColor: c.error,
        onConfirm: () {
          _clearSelection();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showBulkUploadDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BulkUploadSheet(),
    );
  }
}

// ── All Contacts Tab ─────────────────────────────────────────────────────────

class _AllContactsTab extends StatelessWidget {
  final List<ContactsDataModel> contacts;
  final Set<String> selected;
  final bool selectionMode;
  final void Function(String) onToggleSelect;
  final void Function(ContactsDataModel) onEdit;
  final void Function(ContactsDataModel) onDelete;
  final ScrollController scrollController;
  final bool isLoadingMore;

  const _AllContactsTab({
    required this.contacts,
    required this.selected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onEdit,
    required this.onDelete,
    required this.scrollController,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: contacts.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == contacts.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(
                color: c.primary,
                strokeWidth: 1,
              ),
            ),
          );
        }
        return _ContactCard(
          contact: contacts[i],
          isSelected: selected.contains(contacts[i].sId),
          selectionMode: selectionMode,
          onToggleSelect: () => onToggleSelect(contacts[i].sId!),
          onEdit: () => onEdit(contacts[i]),
          onDelete: () => onDelete(contacts[i]),
        );
      },
    );
  }
}

// ── Contact Card ─────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final ContactsDataModel contact;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onEdit,
    required this.onDelete,
  });

  String get _initials {
    final parts = (contact.fullName ?? '?').trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  Color get _avatarColor {
    final idx = (contact.sId?.hashCode ?? 0).abs() % _avatarPalette.length;
    return _avatarPalette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onLongPress: onToggleSelect,
      onTap: selectionMode ? onToggleSelect : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? c.accentSoft : c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? c.primary : c.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (selectionMode)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? c.primary : c.surfaceHigh,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? c.primary : c.border,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, color: c.onBrand, size: 18)
                      : null,
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _avatarColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _avatarColor,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.fullName ?? '—',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          contact.date ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: c.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.mobileNumber ?? '—',
                      style: TextStyle(
                        fontSize: 13,
                        color: c.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (contact.groupName != null)
                      Row(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: 11,
                            color: c.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact.groupName!,
                            style: TextStyle(fontSize: 11, color: c.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!selectionMode) ...[
                const SizedBox(width: 8),
                _IconBtn(
                  icon: Icons.edit_rounded,
                  color: c.primary,
                  bg: c.accentSoft,
                  onTap: onEdit,
                ),
                const SizedBox(width: 6),
                _IconBtn(
                  icon: Icons.delete_rounded,
                  color: c.error,
                  bg: c.dangerSoft,
                  onTap: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Groups Tab ───────────────────────────────────────────────────────────────

class _GroupsTab extends StatelessWidget {
  final ScrollController scrollController;

  const _GroupsTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetGroupsBloc, GetGroupsState>(
      builder: (context, state) {
        if (state is GetGroupsInitial) {
          return const SizedBox.shrink();
        }
        if (state is GetGroupsLoading) {
          return FullScreenLoader(message: 'Groups loading...');
        }
        if (state is GetGroupsError) {
          return _EmptyState(message: state.message);
        }
        if (state is! GetGroupsLoaded || state.groups.isEmpty) {
          return const _EmptyState(message: 'No groups found');
        }

        final itemCount = state.groups.length + (state.isLoadingMore ? 1 : 0);

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: itemCount,
          itemBuilder: (_, i) {
            if (i == state.groups.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                    strokeWidth: 1,
                  ),
                ),
              );
            }

            return _GroupCard(group: state.groups[i]);
          },
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupsDataModel group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final groupName = group.groupName ?? 'Unknown Group';
    final totalNumbers = group.totalNumbers ?? 0;
    final activityParts = [
      if (group.date?.isNotEmpty ?? false) group.date!,
      if (group.time?.isNotEmpty ?? false) group.time!,
    ];
    final activityText = activityParts.isEmpty
        ? 'No recent activity'
        : 'Last activity ${activityParts.join(' - ')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.group_rounded, color: c.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activityText,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: '$totalNumbers',
                  color: c.primary,
                  bg: c.accentSoft,
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 20),
              ],
            ),
          ),
          if (totalNumbers > 0) ...[
            Divider(height: 1, color: c.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.contacts_rounded, size: 15, color: c.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '$totalNumbers contact${totalNumbers == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Reusable Small Widgets ────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkActionFab extends StatelessWidget {
  final int count;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _BulkActionFab({
    required this.count,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.4),
        //     blurRadius: 20,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count selected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.dangerSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 15, color: c.error),
                  const SizedBox(width: 5),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13,
                      color: c.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCancel,
            child: Icon(Icons.close_rounded, size: 20, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 34,
              color: c.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: c.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

// ── Contact Form Bottom Sheet ─────────────────────────────────────────────────

// ── Bulk Upload Sheet ─────────────────────────────────────────────────────────

class _BulkUploadSheet extends StatelessWidget {
  const _BulkUploadSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.bottomSheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Bulk Upload Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload an Excel (.xlsx) or CSV file to import contacts in bulk.',
            style: TextStyle(color: c.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.successSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.green.withOpacity(0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 36, color: c.green),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select Excel file',
                    style: TextStyle(
                      color: c.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '.xlsx · .csv supported',
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.download_rounded,
                  label: 'Download Template',
                  color: c.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Upload Guide',
                  color: c.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Confirm Dialog ────────────────────────────────────────────────────────────
