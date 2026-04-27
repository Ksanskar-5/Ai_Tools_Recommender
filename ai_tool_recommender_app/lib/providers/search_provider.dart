import 'package:flutter/material.dart';
import '../models/ai_tool.dart';
import '../services/local_search_service.dart';
import '../config/constants.dart';

class SearchProvider extends ChangeNotifier {
  final LocalSearchService _local = LocalSearchService();

  SearchProvider();

  List<AiTool> _results = [];
  List<AiTool> _allResults = []; // full result set for pagination
  bool _loading = false;
  bool _loadingMore = false;
  String _lastQuery = '';
  String? _error;
  String _sortBy = 'score';

  // Filters
  String? _costFilter;
  String? _categoryFilter;
  int _topK = AppConstants.defaultTopK;

  // Pagination
  static const int _pageSize = 5;
  int _displayCount = _pageSize;

  List<AiTool> get results => _results;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String get lastQuery => _lastQuery;
  String? get error => _error;
  String get sortBy => _sortBy;
  String? get costFilter => _costFilter;
  String? get categoryFilter => _categoryFilter;
  int get topK => _topK;
  bool get hasMore => _displayCount < _allResults.length;

  void setCostFilter(String? v) {
    _costFilter = v;
    notifyListeners();
  }

  void setCategoryFilter(String? v) {
    _categoryFilter = v;
    notifyListeners();
  }

  void setTopK(int v) {
    _topK = v;
    notifyListeners();
  }

  void setSortBy(String v) {
    _sortBy = v;
    _sortResults();
    _applyPage();
    notifyListeners();
  }

  Future<void> search(String query, {int? userId}) async {
    _lastQuery = query;
    _loading = true;
    _error = null;
    _displayCount = _pageSize;
    notifyListeners();

    try {
      _allResults = await _local.search(query, topK: _topK);

      // Apply local filters
      if (_costFilter != null) {
        _allResults = _allResults.where((t) =>
          t.cost.toLowerCase().contains(_costFilter!.toLowerCase())
        ).toList();
      }
      if (_categoryFilter != null) {
        _allResults = _allResults.where((t) =>
          t.category.toLowerCase().contains(_categoryFilter!.toLowerCase())
        ).toList();
      }

      _sortResults();
      _applyPage();
    } catch (e) {
      _error = e.toString();
      _allResults = [];
      _results = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Load the next page of results.
  Future<void> loadMore() async {
    if (!hasMore || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();

    // Simulate a brief delay so the UI feels intentional
    await Future.delayed(const Duration(milliseconds: 300));

    _displayCount = (_displayCount + _pageSize).clamp(0, _allResults.length);
    _applyPage();

    _loadingMore = false;
    notifyListeners();
  }

  void _sortResults() {
    switch (_sortBy) {
      case 'Rating':
        _allResults.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Popularity':
        _allResults.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      default:
        _allResults.sort((a, b) => b.score.compareTo(a.score));
    }
  }

  void _applyPage() {
    _results = _allResults.take(_displayCount).toList();
  }

  void clearResults() {
    _results = [];
    _allResults = [];
    _error = null;
    _lastQuery = '';
    _displayCount = _pageSize;
    notifyListeners();
  }
}
