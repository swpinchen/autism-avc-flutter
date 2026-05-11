import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UnsplashPhoto {
  final String id;
  final String thumbUrl;
  final String regularUrl;
  final String photographerName;
  final String photographerUrl;

  const UnsplashPhoto({
    required this.id,
    required this.thumbUrl,
    required this.regularUrl,
    required this.photographerName,
    required this.photographerUrl,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final urls = json['urls'] as Map<String, dynamic>;
    final links = user['links'] as Map<String, dynamic>;
    return UnsplashPhoto(
      id: json['id'] as String,
      thumbUrl: urls['thumb'] as String,
      regularUrl: urls['regular'] as String,
      photographerName:
          '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
      photographerUrl: links['html'] as String,
    );
  }
}

class UnsplashService {
  static const _baseUrl = 'https://api.unsplash.com';
  final http.Client _client;

  UnsplashService({http.Client? client}) : _client = client ?? http.Client();

  String get _accessKey => dotenv.env['UNSPLASH_ACCESS_KEY'] ?? '';

  /// Search Unsplash for photos matching [query].
  Future<List<UnsplashPhoto>> search(String query, {int perPage = 20}) async {
    if (_accessKey.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search/photos').replace(
      queryParameters: {
        'query': query,
        'per_page': perPage.toString(),
      },
    );

    final response = await _client.get(uri, headers: {
      'Authorization': 'Client-ID $_accessKey',
    });

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((r) => UnsplashPhoto.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Download an image from [url] and return its bytes.
  Future<Uint8List?> downloadImage(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  /// Trigger a download event for attribution (Unsplash API guideline).
  Future<void> trackDownload(String photoId) async {
    if (_accessKey.isEmpty) return;
    final uri = Uri.parse('$_baseUrl/photos/$photoId/download');
    await _client.get(uri, headers: {
      'Authorization': 'Client-ID $_accessKey',
    });
  }

  void dispose() => _client.close();
}
