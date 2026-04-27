class AiTool {
  final int aiId;
  final String name;
  final String company;
  final String category;
  final String subcategory;
  final String inputType;
  final String outputType;
  final String description;
  final String cost;
  final String easeOfUse;
  final String integration;
  final String languages;
  final double rating;
  final double popularity;
  final double accuracy;
  final String speed;
  final String trainingDomain;
  final String link;
  final double score;
  final String reasoning;

  AiTool({
    required this.aiId,
    required this.name,
    required this.company,
    required this.category,
    this.subcategory = '',
    this.inputType = '',
    this.outputType = '',
    this.description = '',
    this.cost = 'Free',
    this.easeOfUse = '',
    this.integration = '',
    this.languages = '',
    this.rating = 0.0,
    this.popularity = 0.0,
    this.accuracy = 0.0,
    this.speed = '',
    this.trainingDomain = '',
    this.link = '',
    this.score = 0.0,
    this.reasoning = '',
  });

  factory AiTool.fromJson(Map<String, dynamic> json) {
    return AiTool(
      aiId: _parseInt(json['ai_id'] ?? json['ID'] ?? 0),
      name: _str(json['name'] ?? json['Name'] ?? 'Unnamed Tool'),
      company: _str(json['company'] ?? json['Company'] ?? ''),
      category: _str(json['category'] ?? json['Category'] ?? ''),
      subcategory: _str(json['subcategory'] ?? json['Subcategory'] ?? ''),
      inputType: _str(json['inputType'] ?? json['Input Type'] ?? ''),
      outputType: _str(json['outputType'] ?? json['Output Type'] ?? ''),
      description: _str(json['description'] ?? json['Task Description'] ?? ''),
      cost: _str(json['cost'] ?? json['Cost'] ?? 'Free'),
      easeOfUse: _str(json['easeOfUse'] ?? json['Ease of Use'] ?? ''),
      integration: _str(json['integration'] ?? json['Integration'] ?? ''),
      languages: _str(json['languages'] ?? json['Languages'] ?? ''),
      rating: _parseDouble(json['rating'] ?? json['Rating'] ?? 0),
      popularity: _parseDouble(json['popularity'] ?? json['Popularity'] ?? 0),
      accuracy: _parseDouble(json['accuracy'] ?? json['Accuracy'] ?? 0),
      speed: _str(json['speed'] ?? json['Speed'] ?? ''),
      trainingDomain: _str(json['trainingDomain'] ?? json['Training Domain'] ?? ''),
      link: _str(json['link'] ?? json['Link'] ?? ''),
      score: _parseDouble(json['score'] ?? 0),
      reasoning: _str(json['reasoning'] ?? json['Reasoning'] ?? ''),
    );
  }

  bool get isFree => cost.toLowerCase().contains('free');

  static String _str(dynamic v) => (v ?? '').toString().trim();

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
