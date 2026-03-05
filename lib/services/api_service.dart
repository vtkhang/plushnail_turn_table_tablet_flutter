import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/salon.dart';
import '../models/skill.dart';
import '../models/employee.dart';

class ApiService {
  static String get baseUrl => dotenv.get('VITE_API_BASE_URL', fallback: 'http://localhost:8000/api');
  static String get pythonUrl => dotenv.get('VITE_PYTHON_API_URL', fallback: 'http://localhost:8000');

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<List<Salon>> fetchSalons() async {
    final response = await http.get(Uri.parse('$baseUrl/public/salons'), headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = (data['data'] ?? data) as List;
      return list.map((s) => Salon.fromJson(s)).toList();
    }
    throw Exception('Failed to load salons');
  }

  Future<List<SkillCategory>> fetchSkillCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/employee-management/categories-with-skills'), headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['ret_code'] == 0) {
        final list = data['data'] as List;
        return list.map((c) => SkillCategory.fromJson(c)).toList();
      }
    }
    throw Exception('Failed to load skills');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/login'),
      headers: _headers,
      body: json.encode({'username': username, 'password': password}),
    );
    return json.decode(response.body);
  }

  Future<User?> getMe() async {
    if (_token == null) return null;
    try {
      final response = await http.get(Uri.parse('$baseUrl/staff/me'), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
    } catch (e) {
      print('Failed to restore session: $e');
    }
    return null;
  }

  Future<List<Employee>> fetchEmployees(int salonId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse('$baseUrl/turn-assignments/attendance?salon_id=$salonId&date=$today'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = (data['data'] ?? []) as List;
      return list.map((e) => Employee.fromJson(e)).toList();
    }
    throw Exception('Failed to load employees');
  }

  Future<bool> updateTurn(String empId, int salonId, int turnNum, String val, String updaterName, String empName) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await http.post(
      Uri.parse('$baseUrl/turn-assignments/update'),
      headers: _headers,
      body: json.encode({
        'user_id': int.parse(empId),
        'salon_id': salonId,
        'date': today,
        'turn_number': turnNum,
        'turn_value': val,
        'employee_name': updaterName,
        'employee_name_changed': empName,
      }),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> searchSkills(String query, int salonId, List<Employee> employees) async {
    final response = await http.post(
      Uri.parse('$pythonUrl/turn-table/search-skills'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': query,
        'salon_id': salonId,
        'employees': employees.map((e) => {
          'id': e.id,
          'name': e.name,
          'status': e.status,
          'skills': e.skills?.map((s) => s.name).toList(),
        }).toList(),
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('AI Search failed');
  }

  Future<String> generateIdentityCode() async {
    final response = await http.post(Uri.parse('$baseUrl/task-assignment/generate-identity-code'), headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to generate identity code');
  }

  Future<List<dynamic>> fetchSeats(int salonId) async {
    final response = await http.get(Uri.parse('$baseUrl/public/seats?salon_id=$salonId'), headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    return [];
  }

  Future<bool> storeTaskAssignment(String empId, int salonId, int seatId, String identityCode, List<int> serviceIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/task-assignment/store'),
      headers: _headers,
      body: json.encode({
        'user_id': int.parse(empId),
        'salon_id': salonId,
        'seat_id': seatId,
        'identity_code': identityCode,
        'service_ids': serviceIds,
        'is_appointment': false,
      }),
    );
    return response.statusCode == 200;
  }
}
