import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/ai_tool.dart';

import 'bookmarks_screen.dart';

class ToolDetailScreen extends StatefulWidget {
  final AiTool tool;
  const ToolDetailScreen({super.key, required this.tool});

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final _commentCtrl = TextEditingController();
  int _selectedRating = 0;
  int _feedback = 0; // 0=none, 1=liked, -1=disliked
  bool _bookmarked = false;

  AiTool get tool => widget.tool;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback({
    int? feedback,
    int? rating,
    String? comment,
    bool? bookmark,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (bookmark != null) {
        final added = await BookmarksScreen.toggleBookmark(tool);
        setState(() => _bookmarked = added);
        messenger.showSnackBar(SnackBar(
          content: Text(added ? 'Bookmarked!' : 'Bookmark removed'),
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
        ));
      } else {
        messenger.showSnackBar(SnackBar(
          content: const Text('Saved locally!'),
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
        ));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(tool.category);
    final scorePercent = (tool.score * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // ── App bar with gradient ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.bgDark,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      catColor.withValues(alpha: 0.2),
                      AppColors.bgDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // Logo circle
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    catColor,
                                    catColor.withValues(alpha: 0.6)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: catColor.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  tool.name.isNotEmpty
                                      ? tool.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tool.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [tool.company, tool.category]
                                        .where((e) => e.isNotEmpty)
                                        .join(' • '),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Stats Row ──
                  Row(
                    children: [
                      if (tool.rating > 0)
                        _StatCard(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.warning,
                          label: 'Rating',
                          value: tool.rating.toStringAsFixed(1),
                        ),
                      if (scorePercent > 0) ...[
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.speed_rounded,
                          iconColor: AppColors.cyan,
                          label: 'Match',
                          value: '$scorePercent%',
                        ),
                      ],
                      if (tool.popularity > 0) ...[
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.trending_up_rounded,
                          iconColor: AppColors.pink,
                          label: 'Popularity',
                          value: tool.popularity.toStringAsFixed(1),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Description ──
                  _SectionTitle(title: 'Description'),
                  const SizedBox(height: 8),
                  Text(
                    tool.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (tool.reasoning.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.psychology,
                              size: 18, color: AppColors.purple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tool.reasoning,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Capabilities ──
                  if (_hasCapabilities()) ...[
                    _SectionTitle(title: 'Capabilities'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (tool.inputType.isNotEmpty)
                          _DetailChip(
                              icon: Icons.input, label: 'Input: ${tool.inputType}'),
                        if (tool.outputType.isNotEmpty)
                          _DetailChip(
                              icon: Icons.output,
                              label: 'Output: ${tool.outputType}'),
                        if (tool.integration.isNotEmpty)
                          _DetailChip(
                              icon: Icons.extension,
                              label: tool.integration),
                        if (tool.trainingDomain.isNotEmpty)
                          _DetailChip(
                              icon: Icons.school,
                              label: tool.trainingDomain),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Details Grid ──
                  _SectionTitle(title: 'Details'),
                  const SizedBox(height: 10),
                  _buildDetailsGrid(catColor),
                  const SizedBox(height: 24),

                  // ── Website Link ──
                  if (tool.link.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(tool.link);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Visit Website'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cyan,
                          side: BorderSide(
                              color: AppColors.cyan.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Divider ──
                  Container(
                    height: 1,
                    color: AppColors.borderSubtle,
                  ),
                  const SizedBox(height: 24),

                  // ── Engagement: Like / Dislike ──
                  _SectionTitle(title: 'Was this helpful?'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _EngageButton(
                        icon: Icons.thumb_up_rounded,
                        label: 'Like',
                        active: _feedback == 1,
                        activeColor: AppColors.success,
                        onTap: () {
                          setState(() => _feedback = 1);
                          _sendFeedback(feedback: 1);
                        },
                      ),
                      const SizedBox(width: 12),
                      _EngageButton(
                        icon: Icons.thumb_down_rounded,
                        label: 'Dislike',
                        active: _feedback == -1,
                        activeColor: AppColors.error,
                        onTap: () {
                          setState(() => _feedback = -1);
                          _sendFeedback(feedback: -1);
                        },
                      ),
                      const Spacer(),
                      _EngageButton(
                        icon: _bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        label: 'Save',
                        active: _bookmarked,
                        activeColor: AppColors.warning,
                        onTap: () {
                          setState(() => _bookmarked = !_bookmarked);
                          _sendFeedback(bookmark: _bookmarked);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Star Rating ──
                  _SectionTitle(title: 'Rate this tool'),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedRating = starIndex);
                          _sendFeedback(rating: starIndex);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            starIndex <= _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 36,
                            color: starIndex <= _selectedRating
                                ? AppColors.warning
                                : AppColors.textMuted.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // ── Comment ──
                  _SectionTitle(title: 'Leave a comment'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    maxLength: 500,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts about this tool...',
                      fillColor: AppColors.glassBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderMedium),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _commentCtrl.text.trim();
                        if (text.isEmpty) return;
                        _sendFeedback(comment: text);
                        _commentCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: const Text('Send Comment'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasCapabilities() {
    return tool.inputType.isNotEmpty ||
        tool.outputType.isNotEmpty ||
        tool.integration.isNotEmpty ||
        tool.trainingDomain.isNotEmpty;
  }

  Widget _buildDetailsGrid(Color catColor) {
    final items = <MapEntry<String, String>>[];
    if (tool.cost.isNotEmpty) items.add(MapEntry('Cost', tool.cost));
    if (tool.languages.isNotEmpty) {
      items.add(MapEntry('Language', tool.languages));
    }
    if (tool.easeOfUse.isNotEmpty) {
      items.add(MapEntry('Ease of Use', tool.easeOfUse));
    }
    if (tool.speed.isNotEmpty) items.add(MapEntry('Speed', tool.speed));
    if (tool.category.isNotEmpty) {
      items.add(MapEntry('Category', tool.category));
    }
    if (tool.subcategory.isNotEmpty) {
      items.add(MapEntry('Subcategory', tool.subcategory));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map((e) => SizedBox(
                    width: itemWidth,
                    child: _MetaItem(label: e.key, value: e.value),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ── Detail Widgets ──

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCard(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EngageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _EngageButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.1)
              : AppColors.glassBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.3)
                : AppColors.borderMedium,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: active ? activeColor : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? activeColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
