part of '../main.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: gradient == null ? AppColors.line : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ScreenShell extends StatelessWidget {
  const ScreenShell({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class SegmentTabs extends StatelessWidget {
  const SegmentTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LevelSelector extends StatelessWidget {
  const LevelSelector({
    super.key,
    required this.levels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> levels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: levels.map((level) {
          final active = level == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: active,
              label: Text(level),
              selectedColor: _levelColor(level).withValues(alpha: 0.16),
              labelStyle: TextStyle(
                color: active ? _levelColor(level) : AppColors.muted,
                fontWeight: FontWeight.w900,
              ),
              onSelected: (_) => onSelected(level),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.inverted = false, this.showText = false});

  final bool inverted;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final fg = inverted ? Colors.white : AppColors.cinnabar;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: inverted
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.cinnabar.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: inverted
                  ? Colors.white24
                  : AppColors.cinnabar.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            '文',
            style: TextStyle(
              color: fg,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VNChinese',
                style: TextStyle(
                  color: inverted ? Colors.white : AppColors.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'AI HSK Coach',
                style: TextStyle(
                  color: inverted ? Colors.white70 : AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class VisualBadge extends StatelessWidget {
  const VisualBadge({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFFD178)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.cinnabar.withValues(alpha: 0.12),
      child: const Text(
        'T',
        style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, this.icon, required this.label, this.color});

  final IconData? icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.cinnabar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: c),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class FeatureItem {
  const FeatureItem(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.onTap,
  );
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.items});

  final List<FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(8),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: item.color),
                      const SizedBox(height: 14),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class DashboardMetric {
  const DashboardMetric(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class MetricWrap extends StatelessWidget {
  const MetricWrap({super.key, required this.metrics});

  final List<DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics.map((metric) {
            return SizedBox(
              width: width,
              child: AppCard(
                color: metric.color.withValues(alpha: 0.09),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(metric.icon, color: metric.color),
                    const SizedBox(height: 14),
                    Text(
                      metric.value,
                      style: TextStyle(
                        color: metric.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      metric.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class LearningJourneyDashboard extends StatelessWidget {
  const LearningJourneyDashboard({
    super.key,
    required this.progress,
    required this.onOpenPractice,
  });

  final LearningProgressSnapshot progress;
  final VoidCallback onOpenPractice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7 ngày gần nhất',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progress.weeklyStudyMinutes} phút · '
                          '${progress.weeklyWords} từ mới',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  _ProgressRing(value: progress.weeklyGoalProgress),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 620 ? 4 : 2;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 14,
                    children: [
                      _JourneyMetric(
                        width: width,
                        icon: Icons.calendar_month_outlined,
                        color: AppColors.blue,
                        value: '${progress.activeDaysThisWeek}/7',
                        label: 'Ngày hoạt động',
                      ),
                      _JourneyMetric(
                        width: width,
                        icon: Icons.local_fire_department_outlined,
                        color: AppColors.cinnabar,
                        value: '${progress.streakDays} ngày',
                        label: 'Chuỗi hiện tại',
                      ),
                      _JourneyMetric(
                        width: width,
                        icon: Icons.task_alt,
                        color: AppColors.jade,
                        value: '${progress.accuracy}%',
                        label: 'Độ chính xác',
                      ),
                      _JourneyMetric(
                        width: width,
                        icon: Icons.refresh,
                        color: AppColors.amber,
                        value: '${progress.dueReviewWords}',
                        label: 'Từ cần ôn',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Thời lượng mỗi ngày',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _WeeklyActivityChart(
                days: progress.lastSevenDays,
                dailyGoalMinutes: progress.dailyGoalMinutes,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_outlined, color: AppColors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Năng lực hiện tại',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenPractice,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Luyện tập'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SkillProgress(
                label: 'Từ vựng',
                score: progress.vocabularyScore,
                color: AppColors.cinnabar,
              ),
              _SkillProgress(
                label: 'Ngữ pháp',
                score: progress.grammarScore,
                color: AppColors.blue,
              ),
              _SkillProgress(
                label: 'Nghe và nói',
                score: progress.speakingScore,
                color: AppColors.jade,
              ),
              _SkillProgress(
                label: 'Đọc hiểu',
                score: progress.readingScore,
                color: AppColors.plum,
                showBottomSpacing: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hoạt động gần đây',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (progress.recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Hoàn thành một bài học để bắt đầu nhật ký tiến độ.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              else
                ...progress.recentActivities
                    .take(5)
                    .map((item) => _RecentActivityRow(item: item)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              backgroundColor: AppColors.line,
              color: AppColors.jade,
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: AppColors.jade,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyMetric extends StatelessWidget {
  const _JourneyMetric({
    required this.width,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final double width;
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart({
    required this.days,
    required this.dailyGoalMinutes,
  });

  final List<LearningDayStat> days;
  final int dailyGoalMinutes;

  @override
  Widget build(BuildContext context) {
    final values = days.isEmpty
        ? List.generate(
            7,
            (index) => LearningDayStat(
              date: DateTime.now().subtract(Duration(days: 6 - index)),
            ),
          )
        : days;
    final maxMinutes = max(
      dailyGoalMinutes,
      values.fold<int>(1, (peak, day) => max(peak, day.studyMinutes)),
    );
    return SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((day) {
          final ratio = day.studyMinutes <= 0
              ? 0.0
              : (day.studyMinutes / maxMinutes).clamp(0.0, 1.0);
          final reachedGoal =
              dailyGoalMinutes > 0 && day.studyMinutes >= dailyGoalMinutes;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    day.studyMinutes == 0 ? '' : '${day.studyMinutes}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: reachedGoal ? AppColors.jade : AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: max(4.0, ratio * 80),
                    decoration: BoxDecoration(
                      color: day.studyMinutes == 0
                          ? AppColors.line
                          : reachedGoal
                          ? AppColors.jade
                          : AppColors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    day.weekdayLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SkillProgress extends StatelessWidget {
  const _SkillProgress({
    required this.label,
    required this.score,
    required this.color,
    this.showBottomSpacing = true,
  });

  final String label;
  final int score;
  final Color color;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    final safeScore = score.clamp(0, 100);
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpacing ? 14 : 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$safeScore%',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: safeScore / 100,
              minHeight: 8,
              backgroundColor: AppColors.line,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({required this.item});

  final LearningActivityItem item;

  Color get color {
    return switch (item.kind) {
      'vocabulary' => AppColors.cinnabar,
      'grammar' || 'quiz' => AppColors.blue,
      'speaking' => AppColors.jade,
      'reading' => AppColors.plum,
      _ => AppColors.amber,
    };
  }

  IconData get icon {
    return switch (item.kind) {
      'vocabulary' => Icons.translate,
      'grammar' => Icons.auto_fix_high_outlined,
      'quiz' => Icons.fact_check_outlined,
      'speaking' => Icons.mic_none,
      'reading' => Icons.menu_book_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (item.detail.isNotEmpty)
                  Text(
                    item.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.timeLabel, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Icon(icon, size: 50, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.cinnabar, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExampleTile extends StatelessWidget {
  const ExampleTile({super.key, required this.example});

  final ExampleSentenceData example;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.cn,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            example.py,
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            example.vi,
            style: const TextStyle(
              color: AppColors.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class CompactWordCard extends StatelessWidget {
  const CompactWordCard({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  final VocabEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Text(
            entry.simplified,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.pinyin,
                  style: const TextStyle(
                    color: AppColors.cinnabar,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  entry.meaning,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Bỏ khỏi sổ tay',
            onPressed: onRemove,
            icon: const Icon(Icons.bookmark_remove_outlined),
          ),
        ],
      ),
    );
  }
}

class PronunciationScoreCard extends StatelessWidget {
  const PronunciationScoreCard({
    super.key,
    required this.score,
    required this.onNext,
  });

  final int score;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final color = score >= 85
        ? AppColors.jade
        : score >= 60
        ? AppColors.amber
        : AppColors.cinnabar;
    final title = score >= 85
        ? 'Phát âm tốt'
        : score >= 60
        ? 'Khá ổn'
        : 'Cần luyện thêm';
    final feedback = score >= 85
        ? 'Bạn đọc rất gần với câu mẫu.'
        : score >= 60
        ? 'Hãy nghe mẫu thêm một lần và chú ý thanh điệu.'
        : 'Đọc chậm hơn, rõ từng âm tiết và thử lại.';
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 5),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(feedback),
              ],
            ),
          ),
          TextButton(onPressed: onNext, child: const Text('Câu tiếp')),
        ],
      ),
    );
  }
}
