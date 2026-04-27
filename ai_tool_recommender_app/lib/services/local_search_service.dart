import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ai_tool.dart';

/// Offline vector search service.
///
/// Uses a pre-computed TF-IDF vector index (1251-dim sparse vectors for 993 docs)
/// and performs cosine similarity at query time for semantic-quality matching.
class LocalSearchService {
  static final LocalSearchService _instance = LocalSearchService._();
  factory LocalSearchService() => _instance;
  LocalSearchService._();

  // ── Raw tool data ──
  List<Map<String, dynamic>> _rawTools = [];

  // ── Vector index ──
  List<String> _vocab = [];
  Map<String, int> _word2idx = {};
  List<double> _idf = [];
  List<Map<int, double>> _docVectors = [];
  List<double> _docNorms = [];

  bool _loaded = false;

  /// Load bundled dataset + vector index
  Future<void> init() async {
    if (_loaded) return;

    // Load tools JSON
    final toolsJson = await rootBundle.loadString('assets/ai_tools.json');
    _rawTools = List<Map<String, dynamic>>.from(jsonDecode(toolsJson));

    // Load vector index
    final indexJson = await rootBundle.loadString('assets/vector_index.json');
    final index = jsonDecode(indexJson) as Map<String, dynamic>;

    _vocab = List<String>.from(index['vocab']);
    _word2idx = {for (int i = 0; i < _vocab.length; i++) _vocab[i]: i};
    _idf = List<double>.from((index['idf'] as List).map((e) => (e as num).toDouble()));

    final rawDocs = index['docs'] as List;
    _docVectors = rawDocs.map((d) {
      final m = d as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(int.parse(k), (v as num).toDouble()));
    }).toList();

    _docNorms = List<double>.from(
      (index['norms'] as List).map((e) => (e as num).toDouble()),
    );

    _loaded = true;
  }

  int get toolCount => _rawTools.length;

  /// Vector search: compute query TF-IDF vector → cosine similarity vs all docs
  Future<List<AiTool>> search(String query, {int topK = 15}) async {
    await init();
    if (query.trim().isEmpty) return [];

    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty) return [];

    // ── Build query TF-IDF vector (sparse) ──
    final tf = <int, int>{};
    int totalTokens = 0;
    for (final token in queryTokens) {
      final idx = _word2idx[token];
      if (idx != null) {
        tf[idx] = (tf[idx] ?? 0) + 1;
        totalTokens++;
      }
    }
    if (tf.isEmpty) {
      // No vocabulary overlap — fall back to substring matching
      return _substringFallback(query, topK);
    }

    // TF-IDF for query
    final queryVec = <int, double>{};
    double queryNorm = 0;
    for (final entry in tf.entries) {
      final tfidf = (entry.value / max(totalTokens, 1)) * _idf[entry.key];
      queryVec[entry.key] = tfidf;
      queryNorm += tfidf * tfidf;
    }
    queryNorm = sqrt(queryNorm);
    if (queryNorm == 0) return _substringFallback(query, topK);

    // ── Cosine similarity against all documents ──
    final scores = List<_DocScore>.generate(_docVectors.length, (i) {
      double dot = 0;
      final docVec = _docVectors[i];
      // Only iterate query terms (sparse dot product)
      for (final qEntry in queryVec.entries) {
        final docVal = docVec[qEntry.key];
        if (docVal != null) {
          dot += qEntry.value * docVal;
        }
      }
      final docNorm = _docNorms[i];
      final sim = (queryNorm > 0 && docNorm > 0) ? dot / (queryNorm * docNorm) : 0.0;
      return _DocScore(index: i, score: sim);
    });

    // Sort by similarity descending
    scores.sort((a, b) => b.score.compareTo(a.score));

    // Take top results with score > 0
    final topResults = scores.where((s) => s.score > 0.01).take(topK);

    if (topResults.isEmpty) return _substringFallback(query, topK);

    final maxScore = topResults.first.score;
    return topResults.map((s) {
      final toolMap = Map<String, dynamic>.from(_rawTools[s.index]);
      toolMap['score'] = maxScore > 0 ? s.score / maxScore : 0;
      return AiTool.fromJson(toolMap);
    }).toList();
  }

  /// Fallback: simple substring matching when query has no vocab overlap
  List<AiTool> _substringFallback(String query, int topK) {
    final q = query.toLowerCase();
    final results = <_DocScore>[];

    for (int i = 0; i < _rawTools.length; i++) {
      final tool = _rawTools[i];
      final text = _buildSearchText(tool);
      double score = 0;

      // Exact name match
      final name = (tool['Name'] ?? '').toString().toLowerCase();
      if (name == q) {
        score = 1.0;
      } else if (name.contains(q)) {
        score = 0.8;
      } else if (text.contains(q)) {
        score = 0.5;
      }

      // Check individual words
      if (score == 0) {
        final words = q.split(RegExp(r'\s+'));
        int hits = 0;
        for (final w in words) {
          if (w.length > 2 && text.contains(w)) hits++;
        }
        if (hits > 0) score = 0.3 * (hits / words.length);
      }

      if (score > 0) results.add(_DocScore(index: i, score: score));
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(topK).map((s) {
      final toolMap = Map<String, dynamic>.from(_rawTools[s.index]);
      toolMap['score'] = s.score;
      return AiTool.fromJson(toolMap);
    }).toList();
  }

  /// Get tools by category
  Future<List<AiTool>> getByCategory(String category, {int topK = 10}) async {
    await init();
    final cat = category.toLowerCase();
    final matches = _rawTools.where((t) {
      final toolCat = (t['Category'] ?? '').toString().toLowerCase();
      final toolSubcat = (t['Subcategory'] ?? '').toString().toLowerCase();
      return toolCat.contains(cat) || toolSubcat.contains(cat);
    }).take(topK);

    return matches.map((t) {
      final m = Map<String, dynamic>.from(t);
      m['score'] = 0.8;
      return AiTool.fromJson(m);
    }).toList();
  }

  /// Get popular tools (sorted by rating)
  Future<List<AiTool>> getPopular({int topK = 10}) async {
    await init();
    final sorted = List<Map<String, dynamic>>.from(_rawTools)
      ..sort((a, b) {
        final ra = double.tryParse('${a['Rating']}') ?? 0;
        final rb = double.tryParse('${b['Rating']}') ?? 0;
        return rb.compareTo(ra);
      });
    return sorted.take(topK).map((t) {
      final m = Map<String, dynamic>.from(t);
      m['score'] = 0.9;
      return AiTool.fromJson(m);
    }).toList();
  }

  // ── Helpers ──

  String _buildSearchText(Map<String, dynamic> tool) {
    return [
      tool['Name'], tool['Company'], tool['Category'],
      tool['Subcategory'], tool['Task Description'],
      tool['Integration'], tool['Languages'],
    ].map((v) => (v ?? '').toString().toLowerCase()).join(' ');
  }

  static const _stopWords = {'a','an','the','is','are','was','were','be','been',
    'being','have','has','had','do','does','did','will','would','could','should',
    'may','might','shall','can','to','of','in','for','on','with','at','by','from',
    'as','into','through','during','before','after','above','below','and','but',
    'or','nor','not','so','yet','both','either','neither','each','every','all',
    'any','few','more','most','other','some','such','no','only','own','same',
    'than','too','very','just','i','me','my','we','our','you','your','he','him',
    'his','she','her','it','its','they','them','their','what','which','who',
    'whom','this','that','these','those','want','need','looking','find','tool',
    'tools','best','good','like','using','used','use','based','also','new',
    'one','two','many','much'};

  List<String> _tokenize(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1 && !_stopWords.contains(w))
        .toList();
  }
}

class _DocScore {
  final int index;
  final double score;
  const _DocScore({required this.index, required this.score});
}
