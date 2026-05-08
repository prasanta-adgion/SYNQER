// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/app_export.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/widgets/loading_screen.dart';
import 'package:synqer_io/features/live_chat/save_contact/save_contact_screen.dart';
import 'package:synqer_io/features/manage_contacts/bloc/get_contacts_bloc.dart';
import 'package:synqer_io/features/manage_contacts/model/contacts_model.dart';

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
    return BlocProvider(
      create: (_) =>
          GetContactsBloc(repo: AppInjector.getContactsRepo)
            ..add(const FetchContactsEvent(page: 1, limit: 20)),
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
  Timer? _debounce;
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<Set<String>> _selected = ValueNotifier({});
  final ValueNotifier<bool> _selectionMode = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchQuery.dispose();
    _selected.dispose();
    _selectionMode.dispose();
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = value.trim();
      _searchQuery.value = query;
      context.read<GetContactsBloc>().add(
        FetchContactsEvent(
          page: 1,
          limit: _pageSize,
          searchValue: query.isEmpty ? null : query,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocBuilder<GetContactsBloc, GetContactsState>(
      builder: (context, state) {
        final contacts = state is GetContactsLoaded
            ? state.contacts
            : <ContactsDataModel>[];
        final groups = contacts
            .map((ct) => ct.groupName)
            .whereType<String>()
            .toSet()
            .toList();

        return ListenableBuilder(
          listenable: Listenable.merge([
            _selected,
            _selectionMode,
            _searchQuery,
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
                          _GroupsTab(groups: groups, contacts: contacts),
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
                  return SaveContact(customerNumber: '');
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
            hintText: 'Search by name or number…',
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
        height: 44,
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(10),
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

  void _showEditDialog(ContactsDataModel c) => _showContactFormDialog(c);

  void _showContactFormDialog(ContactsDataModel? contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ContactFormSheet(contact: contact, isEdit: contact != null),
    );
  }

  void _showDeleteDialog(ContactsDataModel contact) {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Contact',
        message:
            'Remove ${contact.fullName} from your contacts? This cannot be undone.',
        confirmLabel: 'Delete',
        confirmColor: c.error,
        onConfirm: () => Navigator.pop(context),
      ),
    );
  }

  void _showBulkDeleteDialog() {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
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
  final List<String> groups;
  final List<ContactsDataModel> contacts;

  const _GroupsTab({required this.groups, required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const _EmptyState(message: 'No groups found');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final groupContacts = contacts
            .where((c) => c.groupName == groups[i])
            .toList();
        return _GroupCard(groupName: groups[i], contacts: groupContacts);
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String groupName;
  final List<ContactsDataModel> contacts;

  const _GroupCard({required this.groupName, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activeCount = contacts.where((x) => x.status == 'active').length;

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
                        '$activeCount active · ${contacts.length} total',
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: '${contacts.length}',
                  color: c.primary,
                  bg: c.accentSoft,
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 20),
              ],
            ),
          ),
          if (contacts.isNotEmpty) ...[
            Divider(height: 1, color: c.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  ...contacts.take(5).map((x) => _MiniAvatar(contact: x)),
                  if (contacts.length > 5)
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border),
                      ),
                      child: Center(
                        child: Text(
                          '+${contacts.length - 5}',
                          style: TextStyle(fontSize: 9, color: c.textSecondary),
                        ),
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

class _MiniAvatar extends StatelessWidget {
  final ContactsDataModel contact;
  const _MiniAvatar({required this.contact});

  String get _initial => (contact.fullName?.isNotEmpty ?? false)
      ? contact.fullName![0].toUpperCase()
      : '?';

  Color get _color {
    final idx = (contact.sId?.hashCode ?? 0).abs() % _avatarPalette.length;
    return _avatarPalette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: c.surface, width: 1.5),
      ),
      child: Center(
        child: Text(
          _initial,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _color,
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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

class _ContactFormSheet extends StatefulWidget {
  final ContactsDataModel? contact;
  final bool isEdit;

  const _ContactFormSheet({this.contact, required this.isEdit});

  @override
  State<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<_ContactFormSheet> {
  static const _statusOptions = ['active', 'inactive', 'pending'];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _groupCtrl;
  late final ValueNotifier<String> _statusNotifier;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.contact?.fullName ?? '');
    _phoneCtrl = TextEditingController(
      text: widget.contact?.mobileNumber ?? '',
    );
    _groupCtrl = TextEditingController(text: widget.contact?.groupName ?? '');
    _statusNotifier = ValueNotifier(widget.contact?.status ?? 'active');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _groupCtrl.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            widget.isEdit ? 'Edit Contact' : 'New Contact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _FormField(
            label: 'Full Name',
            hint: 'Enter full name',
            controller: _nameCtrl,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          _FormField(
            label: 'Mobile Number',
            hint: '+91 XXXXX XXXXX',
            controller: _phoneCtrl,
            icon: Icons.phone_rounded,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _FormField(
            label: 'Group',
            hint: 'Enter group name',
            controller: _groupCtrl,
            icon: Icons.group_rounded,
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String>(
            valueListenable: _statusNotifier,
            builder: (context, statusValue, _) => _DropdownField(
              label: 'Status',
              value: statusValue,
              items: _statusOptions,
              onChanged: (v) => _statusNotifier.value = v!,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.isEdit ? 'Save Changes' : 'Add Contact',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.onBrand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboard;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: TextStyle(color: c.inputText, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.inputHint),
            prefixIcon: Icon(icon, size: 18, color: c.inputIcon),
            filled: true,
            fillColor: c.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.inputBorderFocus),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(i, style: TextStyle(color: c.textPrimary)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: c.dropdown,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.inputBorderFocus),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: c.textSecondary),
        ),
      ],
    );
  }
}

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

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: c.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: confirmColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: confirmColor.withOpacity(0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: TextStyle(
                            color: confirmColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
