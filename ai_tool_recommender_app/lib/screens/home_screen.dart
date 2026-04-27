import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/ai_tool.dart';
import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/tool_card.dart';
import '../widgets/shimmer_loading.dart';
import 'tool_detail_screen.dart';
import 'auth_screen.dart';
import 'bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _searchFocus = FocusNode();
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;

  // Loaded from AppConstants — no longer hardcoded here
  final List<Map<String, dynamic>> _categories = AppConstants.categories;
  final List<String> _suggestions = AppConstants.suggestions;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _searchFocus.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  void _performSearch() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    _searchFocus.unfocus();
    final auth = context.read<AuthProvider>();
    context.read<SearchProvider>().search(q, userId: auth.user?.id);
  }

  void _onCategoryTap(String query) {
    _searchCtrl.text = query;
    _performSearch();
  }

  void _onSuggestionTap(String suggestion) {
    _searchCtrl.text = suggestion;
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final search = context.watch<SearchProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Ambient background blobs ──
          _AmbientBackground(),

          // ── Main scroll content ──
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                pinned: true,
                toolbarHeight: 56,
                backgroundColor: AppColors.bgDark.withValues(alpha: 0.85),
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.brandGradient.createShader(bounds),
                      child: const Text(
                        'ToolFinder AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (auth.isLoggedIn) ...[
                    IconButton(
                      icon: const Icon(Icons.bookmark_rounded, size: 22),
                      tooltip: 'Bookmarks',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showUserMenu(context, auth),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppColors.cyanPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            auth.user!.email[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: OutlinedButton.icon(
                        onPressed: () => _showAuthModal(context),
                        icon: const Icon(Icons.person_outline, size: 16),
                        label: const Text('Sign In'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cyan,
                          side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ── Hero + Search ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _heroFade,
                  child: _buildHero(search),
                ),
              ),

              // ── Content Area ──
              if (search.loading)
                const ShimmerLoading()
              else if (search.error != null)
                SliverToBoxAdapter(child: _buildError(search.error!))
              else if (search.results.isEmpty && search.lastQuery.isEmpty)
                SliverToBoxAdapter(child: _buildDiscoverSection())
              else if (search.results.isEmpty)
                SliverToBoxAdapter(child: _buildNoResults())
              else ...[
                _buildResultsHeader(search),
                _buildResultsList(search, size),
                if (search.hasMore || search.loadingMore)
                  _buildLoadMore(search),
              ],
              // ── Footer ──
              SliverToBoxAdapter(child: _buildFooter()),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Hero Section ──
  Widget _buildHero(SearchProvider search) {
    final chips = ['Create images', 'Write content', 'Video editing', 'Marketing', 'Code assistant'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.heroGradient.createShader(b),
          child: const Text('Find the perfect\nAI tool for your task',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15, letterSpacing: -0.8)),
        ),
        const SizedBox(height: 10),
        const Text('Discover 500+ AI tools with smart recommendations',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA0A8B8), height: 1.55)),
        const SizedBox(height: 18),
        Row(children: [
          _FeaturePill(icon: Icons.apps_rounded, label: '500+ Tools', color: AppColors.cyan),
          const SizedBox(width: 8),
          _FeaturePill(icon: Icons.psychology_rounded, label: 'AI-Powered', color: AppColors.purple),
          const SizedBox(width: 8),
          _FeaturePill(icon: Icons.bolt_rounded, label: 'Save Time', color: AppColors.pink),
        ]),
        const SizedBox(height: 22),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: AppColors.bgSurface,
            border: Border.all(color: AppColors.borderMedium),
            boxShadow: [
              BoxShadow(color: AppColors.purple.withValues(alpha: 0.06), blurRadius: 40, spreadRadius: 2),
              BoxShadow(color: AppColors.cyan.withValues(alpha: 0.04), blurRadius: 60, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _searchCtrl, focusNode: _searchFocus,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0),
              decoration: InputDecoration(
                hintText: 'Describe your task or what you want to do...',
                prefixIcon: ShaderMask(shaderCallback: (b) => AppColors.cyanPurple.createShader(b),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20)),
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              textInputAction: TextInputAction.search, onSubmitted: (_) => _performSearch(),
            )),
            Padding(padding: const EdgeInsets.only(right: 6), child: InkWell(
              onTap: search.loading ? null : _performSearch, borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))]),
                child: search.loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search_rounded, size: 22, color: Colors.white),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(height: 36, child: ListView.separated(
          scrollDirection: Axis.horizontal, itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _onSuggestionTap(chips[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.glassBg, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderMedium)),
              child: Text(chips[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.2)),
            ),
          ),
        )),
        const SizedBox(height: 20),
      ]),
    );
  }



  // ── Discover Section (shown when no search) ──
  Widget _buildDiscoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Categories Grid ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.grid_view_rounded,
                    size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'EXPLORE CATEGORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 400 ? 4 : 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _CategoryTile(
              icon: _categories[i]['icon'] as IconData,
              label: _categories[i]['label'] as String,
              color: AppColors.categoryColor(_categories[i]['query'] as String),
              onTap: () => _onCategoryTap(_categories[i]['query'] as String),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Quick suggestion chips (horizontal scroll) ──
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _onSuggestionTap(_suggestions[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bgSurface,
                      AppColors.bgCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 13,
                        color: AppColors.cyan.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      _suggestions[i],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Suggestions vertical list ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.pink],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'POPULAR SEARCHES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(_suggestions.length, (i) {
              return _SuggestionTile(
                text: _suggestions[i],
                index: i,
                onTap: () => _onSuggestionTap(_suggestions[i]),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Results Header ──
  Widget _buildResultsHeader(SearchProvider search) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.cyan.withValues(alpha: 0.12),
                    AppColors.purple.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.cyan),
                  const SizedBox(width: 6),
                  Text(
                    '${search.results.length} tools found',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyan,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _SortDropdown(
              value: search.sortBy,
              onChanged: (v) => search.setSortBy(v),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results List ──
  Widget _buildResultsList(SearchProvider search, Size size) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: size.width > 700
          ? SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.4,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => ToolCard(
                  tool: search.results[i],
                  index: i,
                  onTap: () => _openDetail(search.results[i]),
                ),
                childCount: search.results.length,
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ToolCard(
                    tool: search.results[i],
                    index: i,
                    onTap: () => _openDetail(search.results[i]),
                  ),
                ),
                childCount: search.results.length,
              ),
            ),
    );
  }

  // ── Load More Button ──
  Widget _buildLoadMore(SearchProvider search) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: search.loadingMore
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              )
            : OutlinedButton.icon(
                onPressed: () => search.loadMore(),
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                label: Text(
                  'Load more  (${search.results.length} of ${search.hasMore ? '${search.results.length}+' : search.results.length})',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(
                      color: AppColors.borderMedium.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgSurface,
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: const Icon(Icons.search_off_rounded, size: 30, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or broader terms',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA0A8B8), height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 30, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          const Text(
            'Connection failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFFA0A8B8), height: 1.5),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _openDetail(AiTool tool) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => ToolDetailScreen(tool: tool),
        transitionsBuilder: (_, anim, a3, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(children: [
        // CTA Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.purple.withValues(alpha: 0.1),
              AppColors.cyan.withValues(alpha: 0.05),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderMedium),
          ),
          child: Column(children: [
            const Text("Can't find what you're looking for?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.4)),
            const SizedBox(height: 8),
            const Text('Try describing your task in detail for better results',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA0A8B8), height: 1.55)),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () { _searchCtrl.clear(); _searchFocus.requestFocus(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))]),
                child: const Text('Try a New Search', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.1)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        // Stats row
        Row(children: [
          _StatItem(value: '500+', label: 'Tools'),
          _StatItem(value: '50+', label: 'Categories'),
          _StatItem(value: '10K+', label: 'Users'),
        ]),
      ]),
    );
  }

  void _showAuthModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuthScreen(),
    );
  }

  void _showUserMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgModal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  auth.user!.email[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              auth.user!.email,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Category Tile ──

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 23, color: color),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion Tile ──

class _SuggestionTile extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.text,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    size: 16,
                    color: AppColors.cyan.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA0A8B8),
                      height: 1.5,
                    ),
                  ),
                ),
                Icon(Icons.north_east_rounded,
                    size: 14, color: AppColors.textMuted.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sort Dropdown ──

class _SortDropdown extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.bgModal,
      offset: const Offset(0, 40),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'score', child: Text('Relevance')),
        PopupMenuItem(value: 'Rating', child: Text('Rating')),
        PopupMenuItem(value: 'Popularity', child: Text('Popularity')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              value == 'score' ? 'Relevance' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ambient Background ──

class _AmbientBackground extends StatefulWidget {
  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        return Stack(
          children: [
            Positioned(
              top: -80 + sin(t * pi * 2) * 30,
              right: -60 + cos(t * pi * 2) * 25,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.cyan.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200 + cos(t * pi * 2) * 20,
              left: -80 + sin(t * pi * 2) * 15,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.purple.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 300 + sin(t * pi * 2 + 2) * 25,
              right: -40 + cos(t * pi * 2 + 1) * 20,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.pink.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Feature Pill (hero highlights) ──
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeaturePill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.2)),
      ]),
    );
  }
}

// ── Stat Item (footer) ──
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.brandGradient.createShader(b),
            child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}
