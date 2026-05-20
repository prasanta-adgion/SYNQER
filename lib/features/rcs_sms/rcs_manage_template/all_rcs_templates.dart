// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/enums/rcstemplate_filter_enum.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/features/manage_contacts/widgets/delete_dailog.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/bloc/manage_templete_bloc.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/widgets/rcs_template_card.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/widgets/rcs_template_empty.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/widgets/template_view_details.dart';
import 'package:synqer_io/features/rcs_sms/template_create/richcard_rcs/richcard_rcs_create_screen.dart';
import 'package:synqer_io/features/rcs_sms/template_create/text_rcs/text_rcs_create.dart';
import 'package:synqer_io/features/search_bar/search_bar_screen.dart';

class AllRcsTemplateScreen extends StatefulWidget {
  final bool showAppBar;

  const AllRcsTemplateScreen({super.key, this.showAppBar = true});

  @override
  State<AllRcsTemplateScreen> createState() => _AllRcsTemplateScreenState();
}

class _AllRcsTemplateScreenState extends State<AllRcsTemplateScreen> {
  final _filterNotifier = ValueNotifier<RCSTemplateFilterEnum>(
    RCSTemplateFilterEnum.all,
  );
  final _fabNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _fabNotifier.dispose();
    _filterNotifier.dispose();
    super.dispose();
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<RCSTemplateFilterEnum>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _TemplateFilterSheet(selectedFilter: _filterNotifier.value),
    );

    if (selected == null || selected == _filterNotifier.value) return;

    _filterNotifier.value = selected;
  }

  void _showCreateTemplateUnavailable(
    BuildContext context,
    String templateType,
  ) {
    AppSnackbar.show(
      context,
      message: '$templateType template creation is coming soon.',
      type: SnackbarType.info,
    );
  }

  Future<void> _openTextTemplateCreate(BuildContext context) async {
    _fabNotifier.value = false;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const TextRcsCreateScreen()),
    );

    if (!context.mounted || created != true) return;

    final filter = _filterNotifier.value;
    context.read<ManageTempleteBloc>().add(
      FetchManageTempleteEvent(
        templateType: filter == RCSTemplateFilterEnum.all
            ? null
            : filter.apiValue,
      ),
    );
  }

  Future<void> _openRichCardTemplateCreate(BuildContext context) async {
    _fabNotifier.value = false;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RichCardRcsCreateScreen()),
    );

    if (!context.mounted || created != true) return;

    final filter = _filterNotifier.value;
    context.read<ManageTempleteBloc>().add(
      FetchManageTempleteEvent(
        templateType: filter == RCSTemplateFilterEnum.all
            ? null
            : filter.apiValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocProvider(
      create: (_) =>
          ManageTempleteBloc(repo: AppInjector.rcsTemplateRepo)
            ..add(const FetchManageTempleteEvent()),
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: c.bg,
              appBar: widget.showAppBar
                  ? CustomAppBar(
                      title: 'Manage Template',
                      subtitle: _appBarSubtitle(context),
                      backgroundColor: c.surface,
                      titleColor: c.textPrimary,
                      subtitleColor: c.textSecondary,
                      onBack: () => Navigator.pop(context),
                      trailing: _FilterButton(
                        filterNotifier: _filterNotifier,
                        onTap: () => _showFilterSheet(context),
                      ),
                    )
                  : null,
              body: ValueListenableBuilder<bool>(
                valueListenable: _fabNotifier,
                builder: (context, fabOpen, _) {
                  return SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(top: 10),
                    child: Stack(
                      children: [
                        _TemplateDisplayView(filterNotifier: _filterNotifier),

                        if (fabOpen)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                _fabNotifier.value = false;
                              },

                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 4,
                                  sigmaY: 4,
                                  tileMode: TileMode.clamp,
                                ),

                                child: Container(
                                  color: Colors.black.withOpacity(
                                    context.isDark ? 0.25 : 0.08,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              floatingActionButton: ValueListenableBuilder<bool>(
                valueListenable: _fabNotifier,
                builder: (context, fabOpen, _) {
                  return SpeedDial(
                    openCloseDial: _fabNotifier,
                    icon: Icons.add_rounded,
                    activeIcon: Icons.close_rounded,
                    label: const Text('Create Template'),
                    activeLabel: const Text('Close'),
                    tooltip: 'Create Template',
                    backgroundColor: c.primary,
                    foregroundColor: c.onBrand,
                    elevation: 0,
                    spacing: 10,
                    spaceBetweenChildren: 0,
                    animationCurve: Curves.easeOutCubic,
                    animationDuration: const Duration(milliseconds: 260),
                    overlayColor: Colors.black,
                    overlayOpacity: 0.35,
                    childrenButtonSize: const Size(56, 56),
                    buttonSize: const Size(50, 50),
                    shape: const CircleBorder(),
                    children: [
                      _buildDialChild(
                        context: context,
                        c: c,
                        icon: Icons.sms_outlined,
                        iconColor: c.primary,
                        label: 'Text RCS',
                        subtitle: 'Create text message',
                        onTap: () {
                          _openTextTemplateCreate(context);
                        },
                      ),
                      _buildDialChild(
                        context: context,
                        c: c,
                        icon: Icons.view_agenda_outlined,
                        iconColor: c.primary,
                        label: 'Rich Card',
                        subtitle: 'Create media card',
                        onTap: () => _openRichCardTemplateCreate(context),
                      ),
                      _buildDialChild(
                        context: context,
                        c: c,
                        icon: Icons.view_carousel_outlined,
                        iconColor: c.primary,
                        label: 'Carousal',
                        subtitle: 'Create card carousel',
                        onTap: () =>
                            _showCreateTemplateUnavailable(context, 'Carousal'),
                      ),
                    ],
                  );
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            ),
          );
        },
      ),
    );
  }

  String _appBarSubtitle(BuildContext context) {
    final state = context.watch<ManageTempleteBloc>().state;
    final filter = _filterNotifier.value;
    if (state is ManageTempleteLoading || state is ManageTempleteInitial) {
      return 'Loading templates...';
    }
    if (state is ManageTempleteLoaded) {
      final total = state.totalItems;
      final label = total == 1 ? 'template' : 'templates';
      if (filter == RCSTemplateFilterEnum.all) return '$total $label';
      return '$total ${filter.label} $label';
    }
    return filter == RCSTemplateFilterEnum.all
        ? '0 templates'
        : '0 ${filter.label} templates';
  }

  SpeedDialChild _buildDialChild({
    required BuildContext context,
    required AppColors c,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      backgroundColor: Colors.transparent,
      elevation: 0,
      labelWidget: Container(
        margin: const EdgeInsets.only(right: 70),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: c.borderStrong, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                letterSpacing: 0.1,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: c.textPrimary.withOpacity(0.55),
                fontWeight: FontWeight.w400,
                fontSize: 11,
                letterSpacing: 0.1,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
      shape: const CircleBorder(),

      onTap: onTap,
    );
  }
}

class _TemplateDisplayView extends StatefulWidget {
  final ValueNotifier<RCSTemplateFilterEnum> filterNotifier;

  const _TemplateDisplayView({required this.filterNotifier});

  @override
  State<_TemplateDisplayView> createState() => _TemplateDisplayViewState();
}

class _TemplateDisplayViewState extends State<_TemplateDisplayView> {
  static const int _pageSize = 20;
  static const double _scrollTriggerOffset = 220;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int? _trackedLoadPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.filterNotifier.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    widget.filterNotifier.removeListener(_onFilterChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    _fetchFirstPage();
  }

  void _fetchFirstPage() {
    _trackedLoadPage = null;
    context.read<ManageTempleteBloc>().add(
      FetchManageTempleteEvent(
        searchValue: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        templateType: widget.filterNotifier.value.apiValue,
        limit: _pageSize,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final max = _scrollController.position.maxScrollExtent;
    if (offset < max - _scrollTriggerOffset) return;

    final bloc = context.read<ManageTempleteBloc>();
    final state = bloc.state;
    if (state is! ManageTempleteLoaded ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    if (_trackedLoadPage == nextPage) return;
    _trackedLoadPage = nextPage;
    bloc.add(
      LoadMoreManageTempleteEvent(
        page: nextPage,
        templateType: widget.filterNotifier.value.apiValue,
      ),
    );
  }

  void _onSearchChanged(String value) {
    _fetchFirstPage();
  }

  void _retry() {
    _fetchFirstPage();
  }

  Future<void> _refresh() async {
    _retry();
  }

  void _showTemplateDetails(RcsTemplateDataModel template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TemplateViewDetails(templateData: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableSearchBar(
                controller: _searchController,
                hintText: 'Search template by name...',
                onChanged: _onSearchChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<ManageTempleteBloc, ManageTempleteState>(
            listenWhen: (previous, current) {
              return current is ManageTempleteLoaded &&
                  current.loadMoreError != null &&
                  current.loadMoreError !=
                      (previous is ManageTempleteLoaded
                          ? previous.loadMoreError
                          : null);
            },
            listener: (context, state) {
              if (state is ManageTempleteLoaded &&
                  state.loadMoreError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.loadMoreError!),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: c.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ManageTempleteInitial ||
                  state is ManageTempleteLoading) {
                return const _TemplateLoadingList();
              }
              if (state is ManageTempleteError) {
                return _TemplateErrorView(
                  message: state.message,
                  onRetry: _retry,
                );
              }
              if (state is ManageTempleteLoaded) {
                if (state.templates.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: c.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: const [RcsTemplateEmpty()],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: c.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount:
                        state.templates.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= state.templates.length) {
                        return const _LoadMoreIndicator();
                      }
                      final template = state.templates[index];
                      return RcsTemplateCard(
                        template: template,
                        onView: () => _showTemplateDetails(template),
                        onDelete: () =>
                            _showDeleteDialog(context, template, () async {
                              _fetchFirstPage();
                            }),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  RcsTemplateDataModel templateData,
  final Future<void> Function()? onRefresh,
) {
  final c = context.colors;

  final isDeleting = ValueNotifier(false);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ValueListenableBuilder<bool>(
        valueListenable: isDeleting,
        builder: (context, deleting, _) {
          return DeleteDialog(
            title: 'Delete Template',
            message:
                'Are you sure you want to delete "${templateData.name}"? This action cannot be undone.',

            confirmLabel: deleting ? 'Deleting...' : 'Delete',
            confirmColor: c.error,

            onConfirm: () async {
              if (deleting) return;

              isDeleting.value = true;

              try {
                final response = await AppInjector.rcsTemplateRepo
                    .deleteRcsTemplate(id: templateData.id.toString());
                if (!context.mounted) return;

                Navigator.pop(dialogContext);

                if (response['success'].toString() == 'true') {
                  AppSnackbar.show(
                    context,
                    message: 'Template deleted successfully',
                    type: SnackbarType.success,
                  );

                  await onRefresh?.call();
                } else {
                  debugPrint("${response['message'] ?? 'Delete failed'}");
                  AppSnackbar.show(
                    context,
                    message: 'Template Delete failed',
                    type: SnackbarType.error,
                  );
                }
              } catch (e) {
                if (!context.mounted) return;

                Navigator.pop(dialogContext);
                debugPrint("Error in Delete Template $e");

                AppSnackbar.show(
                  context,
                  message: 'Something went wrong',
                  type: SnackbarType.error,
                );
              } finally {
                isDeleting.dispose();
              }
            },
          );
        },
      );
    },
  );
}

class _FilterButton extends StatelessWidget {
  final ValueNotifier<RCSTemplateFilterEnum> filterNotifier;
  final VoidCallback onTap;

  const _FilterButton({required this.filterNotifier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ValueListenableBuilder<RCSTemplateFilterEnum>(
      valueListenable: filterNotifier,
      builder: (_, filter, _) {
        final isFiltered = filter != RCSTemplateFilterEnum.all;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isFiltered ? c.accentSoft : c.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isFiltered ? c.primary : c.border),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: isFiltered ? c.primary : c.textSecondary,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

class _TemplateFilterSheet extends StatelessWidget {
  final RCSTemplateFilterEnum selectedFilter;

  const _TemplateFilterSheet({required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SafeArea(
      child: Container(
        // /margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Templates',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: c.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...RCSTemplateFilterEnum.values.map((filter) {
              final isSelected = filter == selectedFilter;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? c.primary : c.textSecondary,
                ),
                title: Text(
                  filter.label,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(context, filter),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TemplateLoadingList extends StatelessWidget {
  const _TemplateLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const _TemplateLoadingCard(),
    );
  }
}

class _TemplateLoadingCard extends StatelessWidget {
  const _TemplateLoadingCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          _LoadingBone(width: 40, height: 40, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoadingBone(width: 160, height: 12),
                const SizedBox(height: 9),
                _LoadingBone(height: 10),
                const SizedBox(height: 7),
                _LoadingBone(width: 110, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _LoadingBone({this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: c.primary),
        ),
      ),
    );
  }
}

class _TemplateErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TemplateErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: c.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, color: c.error, size: 29),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load templates',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: c.primary,
                foregroundColor: c.onBrand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
