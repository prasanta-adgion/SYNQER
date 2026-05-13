import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/rcs_messages/create_campaign/widgets/campaign_details.dart';
import 'package:synqer_io/features/rcs_messages/create_campaign/widgets/upload_numbers.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CreateCampaignView extends StatefulWidget {
  const CreateCampaignView({super.key});

  @override
  State<CreateCampaignView> createState() => _CreateCampaignViewState();
}

class _CreateCampaignViewState extends State<CreateCampaignView> {
  final _currentStep = ValueNotifier<int>(0);
  final _campaignDetailsFormKey = GlobalKey<FormState>();
  final _uploadNumbersKey = GlobalKey<UploadNumbersState>();
  final _campaignDetails = ValueNotifier<CampaignDetailsData>(
    const CampaignDetailsData(),
  );
  final _uploadNumbers = ValueNotifier<UploadNumbersData>(
    const UploadNumbersData(),
  );

  static const _steps = [
    _CampaignStep('Campaign Details', Icons.edit_note_rounded),
    _CampaignStep('Upload Numbers', Icons.upload_file_rounded),
    _CampaignStep('Preview Campaign', Icons.visibility_outlined),
    _CampaignStep('Send RCS', Icons.send_rounded),
  ];

  @override
  void dispose() {
    _currentStep.dispose();
    _campaignDetails.dispose();
    _uploadNumbers.dispose();
    super.dispose();
  }

  bool _canLeaveCampaignDetails() {
    return _campaignDetailsFormKey.currentState?.validate() ?? true;
  }

  bool _canLeaveUploadNumbers() {
    return _uploadNumbersKey.currentState?.validateAndSave() ??
        _uploadNumbers.value.numbers.isNotEmpty;
  }

  void _goToStep(int index) {
    if (index > 0 && _currentStep.value == 0) {
      if (!_canLeaveCampaignDetails()) return;
      if (index > 1 && _uploadNumbers.value.numbers.isEmpty) {
        _currentStep.value = 1;
        return;
      }
    }
    if (index > 1 && _currentStep.value == 1 && !_canLeaveUploadNumbers()) {
      return;
    }
    _currentStep.value = index;
  }

  void _goToNextStep() {
    if (_currentStep.value == 0 && !_canLeaveCampaignDetails()) return;
    if (_currentStep.value == 1 && !_canLeaveUploadNumbers()) return;
    _currentStep.value = _currentStep.value + 1;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        top: true,
        child: ValueListenableBuilder<int>(
          valueListenable: _currentStep,
          builder: (context, currentStep, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _CampaignTimeline(
                  steps: _steps,
                  currentStep: currentStep,
                  onStepTap: _goToStep,
                ),
                const SizedBox(height: 22),
                if (currentStep == 0)
                  CampaignDetails(
                    formKey: _campaignDetailsFormKey,
                    initialData: _campaignDetails.value,
                    onChanged: (data) => _campaignDetails.value = data,
                  )
                else if (currentStep == 1)
                  UploadNumbers(
                    key: _uploadNumbersKey,
                    initialData: _uploadNumbers.value,
                    onChanged: (data) => _uploadNumbers.value = data,
                  )
                else
                  _StepContentCard(
                    step: _steps[currentStep],
                    index: currentStep,
                  ),
                const SizedBox(height: 16),
                _StepNavigation(
                  currentStep: currentStep,
                  totalSteps: _steps.length,
                  onPrevious: currentStep == 0
                      ? null
                      : () => _currentStep.value = currentStep - 1,
                  onNext: currentStep == _steps.length - 1
                      ? null
                      : _goToNextStep,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CampaignStep {
  final String title;
  final IconData icon;

  const _CampaignStep(this.title, this.icon);
}

class _CampaignTimeline extends StatelessWidget {
  final List<_CampaignStep> steps;
  final int currentStep;
  final ValueChanged<int> onStepTap;

  const _CampaignTimeline({
    required this.steps,
    required this.currentStep,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: SizedBox(
              height: 82,
              child: TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.start,
                isFirst: index == 0,
                isLast: index == steps.length - 1,
                beforeLineStyle: LineStyle(
                  color: index <= currentStep ? c.primary : c.border,
                  thickness: 1.4,
                ),
                afterLineStyle: LineStyle(
                  color: index < currentStep ? c.primary : c.border,
                  thickness: 1.4,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 36,
                  height: 36,
                  indicator: GestureDetector(
                    onTap: () => onStepTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? c.textPrimary
                            : c.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive || isCompleted
                              ? c.textPrimary
                              : c.borderStrong,
                          width: 1.2,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              color: c.surface,
                              size: 17,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? c.surface : c.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
                endChild: GestureDetector(
                  onTap: () => onStepTap(index),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _firstLine(step.title),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive ? c.textPrimary : c.textSecondary,
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          _secondLine(step.title),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive ? c.textPrimary : c.textSecondary,
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _firstLine(String title) {
    final words = title.split(' ');
    return words.first;
  }

  String _secondLine(String title) {
    final words = title.split(' ');
    if (words.length == 1) return '';
    return words.skip(1).join(' ');
  }
}

class _StepContentCard extends StatelessWidget {
  final _CampaignStep step;
  final int index;

  const _StepContentCard({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(step.icon, color: c.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${index + 1}: ${step.title}',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _descriptionFor(index),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _descriptionFor(int index) {
    return switch (index) {
      0 => 'Add campaign name, template, sender details, and message setup.',
      1 => 'Upload or select recipient mobile numbers for this campaign.',
      2 => 'Review recipients, template content, and campaign settings.',
      _ => 'Confirm everything and send the RCS campaign.',
    };
  }
}

class _StepNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _StepNavigation({
    required this.currentStep,
    required this.totalSteps,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPrevious,
            style: OutlinedButton.styleFrom(
              foregroundColor: c.textPrimary,
              side: BorderSide(color: c.borderStrong),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: c.primary,
              foregroundColor: c.onBrand,
              disabledBackgroundColor: c.surfaceHigh,
              disabledForegroundColor: c.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(currentStep == totalSteps - 1 ? 'Ready' : 'Next'),
          ),
        ),
      ],
    );
  }
}
