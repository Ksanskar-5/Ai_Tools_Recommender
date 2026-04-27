import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // ── API ──
  // Android emulator  → 'http://10.0.2.2:8000'
  // iOS simulator     → 'http://127.0.0.1:8000'
  // Physical device   → 'http://<YOUR_LAN_IP>:8000'
  //
  // We auto-detect at runtime: Android emulator uses 10.0.2.2,
  // every other platform uses 127.0.0.1.
  static String get baseUrl {
    // defaultTargetPlatform is Android when running on emulator/device
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  // ── Search ──
  static const int defaultTopK = 10;

  // ── Categories ──
  static const List<Map<String, dynamic>> categories = [
    {'icon': Icons.text_fields_rounded, 'label': 'Text & NLP', 'query': 'Text'},
    {'icon': Icons.image_rounded, 'label': 'Image', 'query': 'Image'},
    {'icon': Icons.music_note_rounded, 'label': 'Audio', 'query': 'Audio'},
    {'icon': Icons.videocam_rounded, 'label': 'Video', 'query': 'Video'},
    {'icon': Icons.chat_bubble_rounded, 'label': 'Chatbot', 'query': 'Chatbot'},
    {'icon': Icons.code_rounded, 'label': 'Code', 'query': 'Code'},
    {'icon': Icons.auto_fix_high_rounded, 'label': 'Design', 'query': 'Design'},
    {'icon': Icons.analytics_rounded, 'label': 'Data', 'query': 'Data'},
    {'icon': Icons.search_rounded, 'label': 'Search', 'query': 'Search'},
    {'icon': Icons.settings_suggest_rounded, 'label': 'Automation', 'query': 'Automation'},
  ];

  // ── Suggestion prompts ──
  static const List<String> suggestions = [
    'Best image generators for social media',
    'AI tools for writing articles',
    'Free chatbot platforms',
    'Code assistant for Python',
    'Audio transcription tools',
    'Video editing with AI',
  ];
}
