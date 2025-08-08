import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'channel.dart';
import 'program.dart';

class AppState extends ChangeNotifier {
  List<Channel> _channels = [];
  List<Program> _programs = [];
  String _selectedCategory = 'RECENT';
  bool _isAuthenticated = false;
  String _settingsPassword = '1234'; // Default password
  Program? _defaultProgram;

  // Getters
  List<Channel> get channels => _channels;
  List<Program> get programs => _programs;
  String get selectedCategory => _selectedCategory;
  bool get isAuthenticated => _isAuthenticated;
  Program? get defaultProgram => _defaultProgram;

  // Get channels by category
  List<Channel> getChannelsByCategory(String category) {
    if (category == 'ALL CHANNELS') {
      return _channels;
    } else if (category == 'MY CHANNELS') {
      return _channels.where((channel) => channel.isFavorite).toList();
    } else {
      return _channels
          .where((channel) => channel.category == category)
          .toList();
    }
  }

  // Get programs for a specific channel
  List<Program> getProgramsForChannel(String channelId) {
    return _programs
        .where((program) => program.channelId == channelId)
        .toList();
  }

  // Get current program for a channel
  Program? getCurrentProgram(String channelId) {
    final now = DateTime.now();
    return _programs.firstWhere(
      (program) =>
          program.channelId == channelId &&
          program.startTime.isBefore(now) &&
          program.endTime.isAfter(now),
      orElse: () =>
          _defaultProgram ??
          Program(
            id: 'default',
            title: 'Default Program',
            channelId: channelId,
            startTime: now,
            endTime: now.add(const Duration(hours: 1)),
            duration: const Duration(hours: 1),
            videoUrl: '',
            videoType: VideoType.youtube,
          ),
    );
  }

  // Authentication methods
  Future<bool> authenticate(String password) async {
    if (password == _settingsPassword) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  // Category selection
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // CRUD operations for channels
  void addChannel(Channel channel) {
    _channels.add(channel);
    notifyListeners();
    _saveChannels();
  }

  void updateChannel(Channel channel) {
    final index = _channels.indexWhere((c) => c.id == channel.id);
    if (index != -1) {
      _channels[index] = channel;
      notifyListeners();
      _saveChannels();
    }
  }

  void deleteChannel(String channelId) {
    _channels.removeWhere((channel) => channel.id == channelId);
    _programs.removeWhere((program) => program.channelId == channelId);
    notifyListeners();
    _saveChannels();
    _savePrograms();
  }

  // CRUD operations for programs
  void addProgram(Program program) {
    _programs.add(program);
    notifyListeners();
    _savePrograms();
  }

  void updateProgram(Program program) {
    final index = _programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      _programs[index] = program;
      notifyListeners();
      _savePrograms();
    }
  }

  void deleteProgram(String programId) {
    _programs.removeWhere((program) => program.id == programId);
    notifyListeners();
    _savePrograms();
  }

  // Default program
  void setDefaultProgram(Program program) {
    _defaultProgram = program;
    notifyListeners();
    _saveDefaultProgram();
  }

  // Settings password
  void setSettingsPassword(String password) {
    _settingsPassword = password;
    notifyListeners();
    _saveSettingsPassword();
  }

  // Clear data methods
  void clearAllData() {
    _channels.clear();
    _programs.clear();
    notifyListeners();
  }

  // Persistence methods
  Future<void> loadData() async {
    await _loadChannels();
    await _loadPrograms();
    await _loadDefaultProgram();
    await _loadSettingsPassword();
    notifyListeners();
  }

  Future<void> _saveChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final channelData = _channels.map((c) => c.toJson()).toList();
    await prefs.setString('channels', channelData.toString());
  }

  Future<void> _loadChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final channelData = prefs.getString('channels');
    if (channelData != null) {
      // Parse channel data and populate _channels
      // This is a simplified version - in a real app you'd use proper JSON parsing
    }
  }

  Future<void> _savePrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final programData = _programs.map((p) => p.toJson()).toList();
    await prefs.setString('programs', programData.toString());
  }

  Future<void> _loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final programData = prefs.getString('programs');
    if (programData != null) {
      // Parse program data and populate _programs
    }
  }

  Future<void> _saveDefaultProgram() async {
    final prefs = await SharedPreferences.getInstance();
    if (_defaultProgram != null) {
      await prefs.setString(
        'default_program',
        _defaultProgram!.toJson().toString(),
      );
    }
  }

  Future<void> _loadDefaultProgram() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultProgramData = prefs.getString('default_program');
    if (defaultProgramData != null) {
      // Parse default program data
    }
  }

  Future<void> _saveSettingsPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_password', _settingsPassword);
  }

  Future<void> _loadSettingsPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString('settings_password');
    if (password != null) {
      _settingsPassword = password;
    }
  }
}
