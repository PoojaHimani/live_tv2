import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'channel.dart';
import 'program.dart';

class AppState extends ChangeNotifier {
  List<Channel> _channels = [];
  List<Program> _programs = [
    Program(
      id: '1',
      channelId: 'channel_1',
      title: 'Sample MP4 Video 1',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      videoType: VideoType.mp4,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      durationSeconds: 600, // 10 minutes
    ),
  ];
  String _selectedCategory = 'RECENT';
  bool _isAuthenticated = false;
  String _settingsPassword = '1234'; // Default password
  Program? _defaultProgram;
  Set<String> _selectedChannelIds = <String>{}; // Track selected channels
  bool _isSelectionMode = false; // Track if we're in selection mode

  // Hive box names
  static const String _channelsBoxName = 'channels';
  static const String _programsBoxName = 'programs';
  static const String _settingsBoxName = 'settings';

  // Hive boxes - keep them open
  Box<Channel>? _channelsBox;
  Box<Program>? _programsBox;
  Box? _settingsBox;

  // Getters
  List<Channel> get channels => _channels;
  List<Program> get programs => _programs;
  String get selectedCategory => _selectedCategory;
  bool get isAuthenticated => _isAuthenticated;
  Program? get defaultProgram => _defaultProgram;
  Set<String> get selectedChannelIds => _selectedChannelIds;
  bool get isSelectionMode => _isSelectionMode;
  List<Channel> get selectedChannels => _channels
      .where((channel) => _selectedChannelIds.contains(channel.id))
      .toList();

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
            durationSeconds: 3600, // 1 hour
            videoUrl: '',
            videoType: VideoType.mp4,
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
    print('Adding channel: ${channel.name}');
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
    print('Adding program: ${program.title}');
    _programs.add(program);
    notifyListeners();
    _savePrograms();
  }

  void updateProgram(Program program) {
    final index = _programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      _programs[index] = program;
      // If the updated program is currently set as the default, update
      // the default snapshot so the settings UI reflects the changes.
      if (_defaultProgram != null && _defaultProgram!.id == program.id) {
        _defaultProgram = program;
        // Persist updated default snapshot
        _saveDefaultProgram();
      }
      notifyListeners();
      _savePrograms();
    }
  }

  void deleteProgram(String programId) {
    _programs.removeWhere((program) => program.id == programId);
    // If the deleted program was the selected default, clear it
    if (_defaultProgram != null && _defaultProgram!.id == programId) {
      _defaultProgram = null;
      _clearDefaultProgram();
    }
    notifyListeners();
    _savePrograms();
  }

  // Remove persisted default program from Hive and SharedPreferences
  Future<void> _clearDefaultProgram() async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_settingsBoxName);
      }
      await _settingsBox!.delete('default_program_id');
      await _settingsBox!.delete('default_program');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('default_program_id');
      print('Cleared default program from storage');
    } catch (e) {
      print('Error clearing default program: $e');
    }
  }

  // Default program
  void setDefaultProgram(Program program) async {
    _defaultProgram = program;
    notifyListeners();
    // Persist to both Hive (authoritative) and SharedPreferences (legacy/fallback)
    await _saveDefaultProgram();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_program_id', program.id);
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
    print('Loading data from Hive...');

    try {
      // Initialize Hive boxes if not already done
      if (_channelsBox == null) {
        _channelsBox = await Hive.openBox<Channel>(_channelsBoxName);
        print('Opened channels box: ${_channelsBox?.name}');
      }
      if (_programsBox == null) {
        _programsBox = await Hive.openBox<Program>(_programsBoxName);
        print('Opened programs box: ${_programsBox?.name}');
      }
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_settingsBoxName);
        print('Opened settings box: ${_settingsBox?.name}');
      }

      await _loadChannels();
      await _loadPrograms();
      await _loadDefaultProgram();
      await _loadSettingsPassword();

      print(
        'Successfully loaded ${_channels.length} channels and ${_programs.length} programs from Hive',
      );
    } catch (e) {
      print('Error in loadData: $e');
    }

    notifyListeners();
  }

  Future<void> _saveChannels() async {
    try {
      if (_channelsBox == null) {
        _channelsBox = await Hive.openBox<Channel>(_channelsBoxName);
      }

      print('Saving ${_channels.length} channels to Hive...');
      await _channelsBox!.clear();

      for (final channel in _channels) {
        await _channelsBox!.put(channel.id, channel); // Using ID as key
        print('Saved channel: ${channel.name} (ID: ${channel.id})');
      }

      print('Successfully saved ${_channels.length} channels to Hive');
    } catch (e) {
      print('Error saving channels: $e');
    }
  }

  Future<void> _loadChannels() async {
    try {
      if (_channelsBox == null) {
        _channelsBox = await Hive.openBox<Channel>(_channelsBoxName);
      }

      final keys = _channelsBox!.keys.toList();
      print('Found ${keys.length} channel keys in Hive: $keys');

      _channels.clear();
      for (final key in keys) {
        final channel = _channelsBox!.get(key);
        if (channel != null) {
          _channels.add(channel);
          print('Loaded channel: ${channel.name} (ID: ${channel.id})');
        }
      }

      print('Successfully loaded ${_channels.length} channels from Hive');
    } catch (e) {
      print('Error loading channels: $e');
    }
  }

  Future<void> _savePrograms() async {
    try {
      if (_programsBox == null) {
        _programsBox = await Hive.openBox<Program>(_programsBoxName);
      }

      print('Saving ${_programs.length} programs to Hive...');
      await _programsBox!.clear();

      for (final program in _programs) {
        await _programsBox!.put(program.id, program); // Using ID as key
        print('Saved program: ${program.title} (ID: ${program.id})');
      }

      print('Successfully saved ${_programs.length} programs to Hive');
    } catch (e) {
      print('Error saving programs: $e');
    }
  }

  Future<void> _loadPrograms() async {
    try {
      if (_programsBox == null) {
        _programsBox = await Hive.openBox<Program>(_programsBoxName);
      }

      final keys = _programsBox!.keys.toList();
      print('Found ${keys.length} program keys in Hive: $keys');

      _programs.clear();
      for (final key in keys) {
        final program = _programsBox!.get(key);
        if (program != null) {
          _programs.add(program);
          print('Loaded program: ${program.title} (ID: ${program.id})');
        }
      }

      print('Successfully loaded ${_programs.length} programs from Hive');
    } catch (e) {
      print('Error loading programs: $e');
    }
  }

  Future<void> _saveDefaultProgram() async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_settingsBoxName);
      }
      if (_defaultProgram != null) {
        await _settingsBox!.put('default_program_id', _defaultProgram!.id);
        await _settingsBox!.put('default_program', _defaultProgram!.toJson());
        print('Saved default program (id and snapshot) to Hive');
      }
    } catch (e) {
      print('Error saving default program: $e');
    }
  }

  Future<void> _loadDefaultProgram() async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_settingsBoxName);
      }
      // 1) Resolve by id if present
      final savedId = _settingsBox!.get('default_program_id');
      if (savedId is String) {
        final match = _programs.firstWhere(
          (p) => p.id == savedId,
          orElse: () {
            final snap = _settingsBox!.get('default_program');
            if (snap is Map) {
              return Program.fromJson(Map<String, dynamic>.from(snap));
            }
            throw Exception('No default program snapshot found');
          },
        );
        _defaultProgram = match;
        print('Loaded default program by id from Hive');
        return;
      }

      // 2) Fallback to serialized snapshot in Hive
      final defaultProgramData = _settingsBox!.get('default_program');
      if (defaultProgramData != null && defaultProgramData is Map) {
        _defaultProgram = Program.fromJson(
          Map<String, dynamic>.from(defaultProgramData),
        );
        await _settingsBox!.put('default_program_id', _defaultProgram!.id);
        print('Loaded default program snapshot from Hive');
        return;
      }

      // Fallback: attempt to load from SharedPreferences by saved program id
      final prefs = await SharedPreferences.getInstance();
      final spId = prefs.getString('default_program_id');
      if (spId != null) {
        final match = _programs.firstWhere(
          (p) => p.id == spId,
          orElse: () => Program(
            id: spId,
            title: 'Default Program',
            channelId: 'unknown',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            durationSeconds: 3600,
            videoUrl: '',
            videoType: VideoType.mp4,
          ),
        );
        _defaultProgram = match;
        // Save into Hive for future reliable loads
        await _saveDefaultProgram();
        print(
          'Loaded default program from SharedPreferences and saved to Hive',
        );
      }
    } catch (e) {
      print('Error loading default program: $e');
    }
  }

  Future<void> _saveSettingsPassword() async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_settingsBoxName);
      }
      await _settingsBox!.put('settings_password', _settingsPassword);
      print('Saved settings password to Hive');
    } catch (e) {
      print('Error saving settings password: $e');
    }
  }

  Future<void> _loadSettingsPassword() async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_settingsBoxName);
      }
      final password = _settingsBox!.get('settings_password');
      if (password != null) {
        _settingsPassword = password;
        print('Loaded settings password from Hive');
      }
    } catch (e) {
      print('Error loading settings password: $e');
    }
  }

  // Force reload data from Hive (useful for debugging)
  Future<void> forceReloadData() async {
    print('=== Force Reloading Data ===');

    try {
      // Close existing boxes to force fresh connection
      await _channelsBox?.close();
      await _programsBox?.close();
      await _settingsBox?.close();

      _channelsBox = null;
      _programsBox = null;
      _settingsBox = null;

      // Reload data
      await loadData();

      print('Force reload completed');
    } catch (e) {
      print('Error in force reload: $e');
    }
  }

  @override
  void dispose() {
    print('Disposing AppState - closing Hive boxes');
    _channelsBox?.close();
    _programsBox?.close();
    _settingsBox?.close();
    super.dispose();
  }

  // Test method to verify Hive is working
  Future<void> testHiveConnection() async {
    try {
      print('Testing Hive connection...');
      final testBox = await Hive.openBox('test_box');
      await testBox.put('test_key', 'test_value');
      final testValue = testBox.get('test_key');
      await testBox.close();
      print('Hive test successful: $testValue');
      return;
    } catch (e) {
      print('Hive test failed: $e');
      rethrow;
    }
  }

  // Debug method to show current state
  void debugCurrentState() {
    print('=== Current AppState Debug ===');
    print('Channels: ${_channels.length}');
    for (final channel in _channels) {
      print('  - ${channel.name} (${channel.id})');
    }
    print('Programs: ${_programs.length}');
    for (final program in _programs) {
      print('  - ${program.title} (${program.id})');
    }
    print('ChannelsBox: ${_channelsBox?.name}');
    print('ProgramsBox: ${_programsBox?.name}');
    print('SettingsBox: ${_settingsBox?.name}');
    print('=============================');
  }
}
