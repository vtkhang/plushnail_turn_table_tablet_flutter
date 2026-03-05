import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/salon.dart';
import '../models/skill.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  List<Salon> _salons = [];
  Salon? _currentSalon;
  List<SkillCategory> _skillCategories = [];
  List<Employee> _employees = [];
  bool _isLoading = true;
  bool _isLoggingIn = true;
  String? _loginError;

  // AI Search State
  List<String> _recommendedIds = [];
  String? _aiExplanation;
  bool _isAiSearching = false;

  Timer? _pollingTimer;

  User? get user => _user;
  List<Salon> get salons => _salons;
  Salon? get currentSalon => _currentSalon;
  List<SkillCategory> get skillCategories => _skillCategories;
  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  bool get isLoggingIn => _isLoggingIn;
  String? get loginError => _loginError;
  List<String> get recommendedIds => _recommendedIds;
  String? get aiExplanation => _aiExplanation;
  bool get isAiSearching => _isAiSearching;

  AppProvider() {
    initialize();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('staff_token');
      final savedSalonId = prefs.getString('preferred_salon_id');

      // 1. Fetch Salons
      _salons = await _apiService.fetchSalons();

      // 2. Fetch Skill Categories
      _skillCategories = await _apiService.fetchSkillCategories();

      // 3. Restore session
      if (token != null) {
        _apiService.setToken(token);
        _user = await _apiService.getMe();
        if (_user != null) {
          _isLoggingIn = false;
        } else {
          await prefs.remove('staff_token');
          _apiService.setToken(null);
        }
      }

      // 4. Set initial salon
      if (savedSalonId != null) {
        try {
          _currentSalon = _salons.firstWhere(
            (s) => s.id.toString() == savedSalonId,
          );
        } catch (_) {
          if (_salons.isNotEmpty) _currentSalon = _salons.first;
        }
      } else if (_salons.isNotEmpty) {
        _currentSalon = _salons.first;
      }

      if (_currentSalon != null) {
        await fetchEmployees();
        startPolling();
      }
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _loginError = null;
    notifyListeners();

    try {
      final data = await _apiService.login(username, password);
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staff_token', data['token']);
        _apiService.setToken(data['token']);
        
        _user = User.fromJson(data);
        _isLoggingIn = false;
        
        if (_currentSalon != null) {
          await fetchEmployees();
          startPolling();
        }
        
        notifyListeners();
      } else {
        _loginError = data['message'] ?? 'Login failed';
        notifyListeners();
      }
    } catch (e) {
      _loginError = 'Network error. Please try again.';
      notifyListeners();
    }
  }

  void loginAsGuest() {
    if (_currentSalon == null) return;
    _user = User(
      id: 'guest',
      name: 'View Only',
      role: UserRole.employee,
      salonId: _currentSalon!.id,
    );
    _isLoggingIn = false;
    
    startPolling();
    notifyListeners();
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('staff_token');
    _apiService.setToken(null);
    _user = null;
    _isLoggingIn = true;
    _pollingTimer?.cancel();
    notifyListeners();
  }

  void setCurrentSalon(Salon salon) async {
    _currentSalon = salon;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_salon_id', salon.id.toString());
    await fetchEmployees();
    startPolling();
    notifyListeners();
  }

  Future<void> fetchEmployees() async {
    if (_currentSalon == null) return;
    try {
      final newEmployees = await _apiService.fetchEmployees(_currentSalon!.id);
      _employees = newEmployees;
      notifyListeners();
    } catch (e) {
      print('Fetch employees error: $e');
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchEmployees();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> updateTurn(String empId, int turnNum, String val) async {
    if (_currentSalon == null || _user == null) return;
    final emp = _employees.firstWhere((e) => e.id == empId);
    final success = await _apiService.updateTurn(
      empId,
      _currentSalon!.id,
      turnNum,
      val,
      _user!.name,
      emp.name,
    );
    if (success) {
      await fetchEmployees();
    }
  }

  Future<void> searchSkills(String query) async {
    if (query.isEmpty || _currentSalon == null) {
      _recommendedIds = [];
      _aiExplanation = null;
      notifyListeners();
      return;
    }

    _isAiSearching = true;
    notifyListeners();

    try {
      final data = await _apiService.searchSkills(query, _currentSalon!.id, _employees);
      _recommendedIds = (data['recommended_employee_ids'] as List? ?? []).map((id) => id.toString()).toList();
      _aiExplanation = data['explanation'];
    } catch (e) {
      print('AI Search error: $e');
    } finally {
      _isAiSearching = false;
      notifyListeners();
    }
  }

  Future<void> assignTask(String empId, List<Skill> skills) async {
    if (_currentSalon == null) return;
    
    try {
      final identityCode = await _apiService.generateIdentityCode();
      final seats = await _apiService.fetchSeats(_currentSalon!.id);
      
      final availableSeat = seats.firstWhere(
        (s) => s['state'] == 'idle', 
        orElse: () => seats.isNotEmpty ? seats.first : null
      );
      
      if (availableSeat == null) {
        throw Exception('No seats available');
      }

      final success = await _apiService.storeTaskAssignment(
        empId,
        _currentSalon!.id,
        availableSeat['id'],
        identityCode,
        skills.map((s) => s.id).toList(),
      );

      if (success) {
        await fetchEmployees();
      }
    } catch (e) {
      print('Assign task error: $e');
      rethrow;
    }
  }
}
