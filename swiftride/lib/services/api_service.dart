// lib/services/api_service.dart
// ─────────────────────────────────────────────────────────────
//  Central HTTP client for SwiftRide backend
//  Base URL: http://127.0.0.1:8000/api
//  All requests include JWT Bearer token automatically
// ─────────────────────────────────────────────────────────────
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int?   statusCode;
  final String message;
  const ApiException(this.message, {this.statusCode});
  @override String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // ── Base URL — change to your server IP when testing on device ──
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── Token storage keys ───────────────────────────────────────
  static const _kAccess  = 'access_token';
  static const _kRefresh = 'refresh_token';

  // ── In-memory token cache ────────────────────────────────────
  String? _accessToken;
  String? _refreshToken;

  // ── Load tokens from storage on startup ─────────────────────
  Future<void> loadTokens() async {
    final prefs    = await SharedPreferences.getInstance();
    _accessToken   = prefs.getString(_kAccess);
    _refreshToken  = prefs.getString(_kRefresh);
  }

  Future<void> saveTokens(String access, String refresh) async {
    _accessToken  = access;
    _refreshToken = refresh;
    final prefs   = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess,  access);
    await prefs.setString(_kRefresh, refresh);
  }

  Future<void> clearTokens() async {
    _accessToken  = null;
    _refreshToken = null;
    final prefs   = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }

  bool get hasToken => _accessToken != null;

  // ── Headers ──────────────────────────────────────────────────
  Map<String, String> get _headers => {
    'Content-Type':  'application/json',
    'Accept':        'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // ── Token refresh ────────────────────────────────────────────
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveTokens(data['access'], _refreshToken!);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Core request method ──────────────────────────────────────
  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>?  queryParams,
    bool retry = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v)),
    );

    http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          res = await http.post(uri, headers: _headers,
              body: body != null ? jsonEncode(body) : null).timeout(const Duration(seconds: 10));
          break;
        case 'PUT':
          res = await http.put(uri, headers: _headers,
              body: body != null ? jsonEncode(body) : null).timeout(const Duration(seconds: 10));
          break;
        case 'PATCH':
          res = await http.patch(uri, headers: _headers,
              body: body != null ? jsonEncode(body) : null).timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 10));
          break;
        default:
          throw ApiException('Unknown HTTP method: $method');
      }
    } on SocketException {
      throw ApiException('No internet connection. Is the server running?');
    } on HttpException {
      throw ApiException('Network error.');
    } on TimeoutException {
      throw ApiException('Request timed out. Is the server running?');
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        throw ApiException('Cannot reach server. Check CORS or server is running.');
      }
      rethrow;
    }

    // Auto-refresh on 401
    if (res.statusCode == 401 && retry) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return _request(method, path, body: body, queryParams: queryParams, retry: false);
      }
      await clearTokens();
      throw ApiException('Session expired. Please log in again.', statusCode: 401);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    // Parse error response
    String message = 'Request failed (${res.statusCode})';
    try {
      final err = jsonDecode(res.body);
      if (err is Map) {
        if (err.containsKey('detail'))    message = err['detail'].toString();
        else if (err.containsKey('non_field_errors')) message = (err['non_field_errors'] as List).first.toString();
        else message = err.values.first.toString();
      }
    } catch (_) {}
    throw ApiException(message, statusCode: res.statusCode);
  }

  // ── Convenience methods ──────────────────────────────────────
  Future<dynamic> get(String path, {Map<String, String>? params}) =>
      _request('GET', path, queryParams: params);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) =>
      _request('PUT', path, body: body);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) =>
      _request('DELETE', path);
}
