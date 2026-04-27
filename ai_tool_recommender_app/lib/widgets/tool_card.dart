import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/ai_tool.dart';

class ToolCard extends StatefulWidget {
  final AiTool tool;
  final int index;
  final VoidCallback onTap;

  const ToolCard({super.key, required this.tool, required this.index, required this.onTap});

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 80), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final cat = AppColors.categoryColor(tool.category);
    final score = (tool.score * 100).clamp(0, 100).toInt();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.diagonal3Values(
              _pressed ? 0.98 : 1.0, _pressed ? 0.98 : 1.0, 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _pressed ? cat.withValues(alpha: 0.35) : AppColors.borderSubtle,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 4)),
                if (_pressed) BoxShadow(color: cat.withValues(alpha: 0.08), blurRadius: 24, spreadRadius: 2),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient accent bar
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(colors: [cat, cat.withValues(alpha: 0.3), Colors.transparent]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header row ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                                colors: [cat.withValues(alpha: 0.2), cat.withValues(alpha: 0.06)],
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: cat.withValues(alpha: 0.2)),
                            ),
                            child: Center(child: Text(
                              tool.name.isNotEmpty ? tool.name[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cat),
                            )),
                          ),
                          const SizedBox(width: 14),
                          // Name + Company
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(child: Text(tool.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.35),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    )),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyan.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.verified_rounded, size: 13, color: AppColors.cyan.withValues(alpha: 0.8)),
                                    ),
                                  ],
                                ),
                                if (tool.company.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(tool.company,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFA0A8B8).withValues(alpha: 0.8)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Score
                          if (score > 0) _ScorePill(score: score, color: cat),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // ── Description ──
                      Text(tool.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5, color: const Color(0xFFA0A8B8).withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: 14),
                      // ── Bottom: Tags + Rating + CTA ──
                      Row(
                        children: [
                          _Pill(label: tool.category, color: cat),
                          const SizedBox(width: 6),
                          _Pill(label: tool.cost, color: tool.isFree ? AppColors.success : AppColors.warning),
                          const Spacer(),
                          if (tool.rating > 0) ...[
                            Icon(Icons.star_rounded, size: 15, color: AppColors.warning.withValues(alpha: 0.9)),
                            const SizedBox(width: 3),
                            Text(tool.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0),
                            ),
                            const SizedBox(width: 10),
                          ],
                          // View Details mini CTA
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [cat.withValues(alpha: 0.15), cat.withValues(alpha: 0.05)]),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cat.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cat, letterSpacing: 0.2)),
                                const SizedBox(width: 3),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: cat),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score; final Color color;
  const _ScorePill({required this.score, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06)]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bolt_rounded, size: 12, color: color),
        const SizedBox(width: 2),
        Text('$score%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.2)),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label; final Color color;
  const _Pill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color.withValues(alpha: 0.9), letterSpacing: 0.2)),
    );
  }
}
