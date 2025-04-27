import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/client.dart';
import '../models/account.dart';
import '../models/activity.dart';

class ApiService {
  // Base URL for the API
  final String baseUrl = 'http://0.0.0.0:8000';
  
  // For web this would typically be the current domain, for testing we use the explicit server URL
  // final String baseUrl = 'http://localhost:8000';

  // HTTP client for making requests
  final http.Client _client = http.Client();

  // Get all clients
  Future<List<Client>> getClients() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/clients'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Client.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

  // Get accounts for a specific client
  Future<List<Account>> getClientAccounts(int clientId) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/clients/$clientId/accounts'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Account.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load accounts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load accounts: $e');
    }
  }

  // Get activities for a specific account
  Future<List<Activity>> getAccountActivities(int accountId) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/accounts/$accountId/activities'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load activities: $e');
    }
  }

  // Get performance metrics for a specific account
  Future<Map<String, dynamic>> getAccountPerformance(int accountId) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/accounts/$accountId/performance'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load performance data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load performance data: $e');
    }
  }

  // Get recent activities across all accounts (for dashboard)
  Future<List<Activity>> getRecentActivities() async {
    try {
      // This is a mock implementation since we don't have a dedicated endpoint for this
      // In a real app, you would have a specific endpoint for recent activities
      // For demo purposes, we'll fetch activities for the first account we can find
      
      // Get all clients
      final clientsResponse = await _client.get(Uri.parse('$baseUrl/api/clients'));
      
      if (clientsResponse.statusCode == 200) {
        final List<dynamic> clientsData = json.decode(clientsResponse.body);
        
        if (clientsData.isNotEmpty) {
          // Get the first client
          final clientId = clientsData[0]['client_id'];
          
          // Get accounts for this client
          final accountsResponse = await _client.get(Uri.parse('$baseUrl/api/clients/$clientId/accounts'));
          
          if (accountsResponse.statusCode == 200) {
            final List<dynamic> accountsData = json.decode(accountsResponse.body);
            
            if (accountsData.isNotEmpty) {
              // Get the first account
              final accountId = accountsData[0]['account_id'];
              
              // Get activities for this account
              return await getAccountActivities(accountId);
            }
          }
        }
        
        // If we couldn't get activities by this method, return an empty list
        return [];
      } else {
        throw Exception('Failed to load recent activities: ${clientsResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recent activities: $e');
    }
  }

  // Import Excel file
  Future<Map<String, dynamic>> importExcelFile(String filePath) async {
    try {
      final fileBytes = await File(filePath).readAsBytes();
      final filename = filePath.split('/').last;
      
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/import/excel'));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to import Excel file: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to import Excel file: $e');
    }
  }
}
