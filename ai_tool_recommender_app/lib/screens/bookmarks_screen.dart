import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../models/ai_tool.dart';
import '../widgets/tool_card.dart';
import 'tool_detail_screen.dart';

/// Offline bookmarks — stored locally in SharedPreferences as JSON.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  /// Static helper to add/remove bookmarks from anywhere in the app
  static Future<bool> toggleBookmark(AiTool tool) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookmarks') ?? [];
    final existing = raw.indexWhere((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return (j['ai_id'] ?? j['ID']) == tool.aiId;
    });
    if (existing >= 0) {
      raw.removeAt(existing);
      await prefs.setStringList('bookmarks', raw);
      return false;
    } else {
      raw.add(jsonEncode({
        'ai_id': tool.aiId, 'Name': tool.name, 'Company': tool.company,
        'Category': tool.category, 'Subcategory': tool.subcategory,
        'Task Description': tool.description, 'Cost': tool.cost,
        'Rating': tool.rating, 'Link': tool.link, 'score': tool.score,
      }));
      await prefs.setStringList('bookmarks', raw);
      return true;
    }
  }

  static Future<bool> isBookmarked(int aiId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookmarks') ?? [];
    return raw.any((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return (j['ai_id'] ?? j['ID']) == aiId;
    });
  }

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<AiTool>? _bookmarks;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('bookmarks') ?? [];
      final tools = raw.map((s) {
        final json = jsonDecode(s) as Map<String, dynamic>;
        return AiTool.fromJson(json);
      }).toList();
      setState(() { _bookmarks = tools; _loading = false; });
    } catch (_) {
      setState(() { _bookmarks = []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2.5))
          : _bookmarks == null || _bookmarks!.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.bookmark_border_rounded, size: 56, color: AppColors.textMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    const Text('No bookmarks yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('Save tools from search results to find them here', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.cyan,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _bookmarks!.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ToolCard(
                        tool: _bookmarks![i], index: i,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ToolDetailScreen(tool: _bookmarks![i])),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
