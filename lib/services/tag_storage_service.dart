import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tag.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagStorageService {

  static String? token;

  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<void> _initToken() async {
    if(token != null) {
      return; // Token already initialized
    }
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    if (token == null || token!.isEmpty) {
      throw Exception('Token not found in shared preferences');
    }
  }

  static Future<List<Tag>> fetchTags() async {
    try {
      await _initToken();
      final response = await  http.get(
        Uri.parse('$_baseUrl/tags'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Tag.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      print('Error fetching tags: $e');
      throw Exception('Failed to fetch tags');
    }
  }

  static Future<Tag> addTag(Tag tag) async {
    try {
      await _initToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/tags'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tag.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add tag: ${response.body}');
      }

      // Optionally, you can handle the response if needed
      // For example, you can parse the response to get the created tag
      final jsonData = jsonDecode(response.body);
      final createdTag = Tag.fromJson(jsonData);
      print('Tag added successfully: ${createdTag.name}');
      return createdTag;
    } catch (e) {
      print('Error adding tag: $e');
      throw Exception('Failed to add tag');
    }
  }

  static Future<void> softDeleteTag(String tagId) async {
    try {
      await _initToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/tags/$tagId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete tag: ${response.body}');
      }
      print('Tag deleted successfully');
    } catch (e) {
      print('Error deleting tag: $e');
      throw Exception('Failed to delete tag');
    }
  }

  static Future<void> deleteTag(String tagId) async {
    try {
      await _initToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/tags/$tagId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to permanently delete tag: ${response.body}');
      }
      print('Tag permanently deleted successfully');
    } catch (e) {
      print('Error permanently deleting tag: $e');
      throw Exception('Failed to permanently delete tag');
    }
  }

  static Future<void> updateTag(Tag tag) async {
    try {
      await _initToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/tags/${tag.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tag.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update tag: ${response.body}');
      }
      print('Tag updated successfully');
    } catch (e) {
      print('Error updating tag: $e');
      throw Exception('Failed to update tag');
    }
  }

  static Future<void> restoreTag(String tagId) async {
    try {
      await _initToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/tags/$tagId/restore'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to restore tag: ${response.body}');
      }
      print('Tag restored successfully');
    } catch (e) {
      print('Error restoring tag: $e');
      throw Exception('Failed to restore tag');
    }
  }


  

}