import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/enums/rcstemplate_filter_enum.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/bloc/manage_templete_bloc.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/widgets/rcs_template_card.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/widgets/rcs_template_empty.dart';
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

  @override
  void dispose() {
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
    setState(() {
      _filterNotifier.value = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocProvider(
      create: (_) =>
          ManageTempleteBloc(repo: AppInjector.manageTemplateRepo)
            ..add(const FetchManageTempleteEvent()),
      child: Builder(
        builder: (context) {
          return Scaffold(
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
            body: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(top: 10),
              child: _TemplateDisplayView(filterNotifier: _filterNotifier),
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

  void _showTemplateDetails(RcsTemplateData template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _TemplateDetailSheet(template: template),
    );
  }

  void _showDeleteUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delete template API is not available yet.'),
        behavior: SnackBarBehavior.floating,
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
                        onDelete: _showDeleteUnavailable,
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

class _TemplateDetailSheet extends StatelessWidget {
  final RcsTemplateData template;

  const _TemplateDetailSheet({required this.template});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variables = template.templateDetails?.variables ?? const <String>[];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: BorderRadius.circular(16),
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
                  template.name.isEmpty ? 'Untitled Template' : template.name,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
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
          const SizedBox(height: 10),
          _DetailLine(label: 'Type', value: template.type),
          _DetailLine(label: 'Status', value: template.status),
          _DetailLine(
            label: 'Category',
            value: template.templateDetails?.category ?? '',
          ),
          if (variables.isNotEmpty)
            _DetailLine(label: 'Variables', value: variables.join(', ')),
          if (template.textMessageContent.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Message',
              style: TextStyle(
                color: c.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              template.textMessageContent,
              style: TextStyle(color: c.textPrimary, fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: TextStyle(color: c.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '--' : value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
