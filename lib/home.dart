import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/app_state.dart';
import 'models/channel.dart';
import 'models/program.dart';
import 'widgets/video_player_screen.dart';
import 'widgets/settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Load stored data first, then ensure base data exists without overwriting user additions
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppState>();

      // Load data from Hive first
      await appState.loadData();

      // Only load sample data if this is the first time (no existing data)
      if (appState.channels.isEmpty && appState.programs.length <= 1) {
        print('Loading sample data for first time...');
        _loadSampleData();
      } else {
        print('Skipping sample data load - existing data found');
        print(
          'Found ${appState.channels.length} channels and ${appState.programs.length} programs',
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadSampleData() {
    final appState = context.read<AppState>();

    // Base channels (added only if missing)
    final channels = [
      Channel(id: 'tbs', name: 'tbs', category: 'RECENT', logo: 'tbs'),
      Channel(
        id: 'fox_sports',
        name: 'FOX SPORTS WEST',
        category: 'SPORTS',
        logo: 'fox_sports',
      ),
      Channel(
        id: 'food_network',
        name: 'food network',
        category: 'RECENT',
        logo: 'food_network',
      ),
      Channel(id: 'cbs', name: 'CBS', category: 'NEWS', logo: 'cbs'),
      Channel(id: 'cnbc', name: 'CNBC', category: 'NEWS', logo: 'cnbc'),
      // Movies channels
      Channel(id: 'hbo', name: 'HBO', category: 'MOVIES', logo: 'hbo'),
      Channel(
        id: 'netflix',
        name: 'Netflix',
        category: 'MOVIES',
        logo: 'netflix',
      ),
      Channel(
        id: 'disney',
        name: 'Disney+',
        category: 'MOVIES',
        logo: 'disney',
      ),
      // Kids channels
      Channel(
        id: 'cartoon_network',
        name: 'Cartoon Network',
        category: 'KIDS',
        logo: 'cartoon_network',
      ),
      Channel(
        id: 'nickelodeon',
        name: 'Nickelodeon',
        category: 'KIDS',
        logo: 'nickelodeon',
      ),
      Channel(
        id: 'disney_junior',
        name: 'Disney Junior',
        category: 'KIDS',
        logo: 'disney_junior',
      ),
    ];

    for (final channel in channels) {
      final exists = appState.channels.any((c) => c.id == channel.id);
      if (!exists) {
        appState.addChannel(channel);
      }
    }

    // Base programs (added only if missing)
    final now = DateTime.now();
    final seedPrograms = [
      Program(
        id: 'seinfeld_1',
        title: 'Seinfeld',
        channelId: 'tbs',
        startTime: now.subtract(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 10)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'assets/videos/sample1.mp4',
        videoType: VideoType.mp4,
        episodeInfo: 'S6 E12 - The Label Maker',
      ),
      Program(
        id: 'seinfeld_2',
        title: 'Seinfeld',
        channelId: 'tbs',
        startTime: now.add(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 40)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'assets/videos/sample2.mp4',
        videoType: VideoType.mp4,
        episodeInfo: 'S4 E13 - The Pick',
      ),
      Program(
        id: 'big_bang',
        title: 'The Big Bang Theory',
        channelId: 'tbs',
        startTime: now.add(const Duration(minutes: 40)),
        endTime: now.add(const Duration(minutes: 70)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'assets/videos/sample3.mp4',
        videoType: VideoType.mp4,
        episodeInfo: 'S2 E11 - The Bath Item Gift Hypothesis',
      ),
      Program(
        id: 'hockey',
        title: 'Vegas Golden Knights at Los Angeles Kings',
        channelId: 'fox_sports',
        startTime: now.subtract(const Duration(minutes: 40)),
        endTime: now.add(const Duration(minutes: 20)),
        durationSeconds: 10800, // 3 hours
        videoUrl: 'assets/videos/sample4.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'kings_live',
        title: 'Kings Live',
        channelId: 'fox_sports',
        startTime: now.add(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 50)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'assets/videos/sample5.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'diners',
        title: 'Diners, Drive-Ins and Dives',
        channelId: 'food_network',
        startTime: now.subtract(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 10)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'assets/videos/sample6.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'grocery_games',
        title: 'Guy\'s Grocery Games',
        channelId: 'food_network',
        startTime: now.add(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 40)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'assets/videos/sample7.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'cbs_news',
        title: 'CBS News at 6PM Sundays',
        channelId: 'cbs',
        startTime: now.subtract(const Duration(minutes: 40)),
        endTime: now.add(const Duration(minutes: 20)),
        durationSeconds: 3600, // 1 hour
        videoUrl: 'assets/videos/sample8.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'sixty_minutes',
        title: '60 Minutes',
        channelId: 'cbs',
        startTime: now.add(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 80)),
        durationSeconds: 3600, // 1 hour
        videoUrl: 'assets/videos/sample9.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'deal_no_deal',
        title: 'Deal or No Deal',
        channelId: 'cnbc',
        startTime: now.subtract(const Duration(minutes: 40)),
        endTime: now.add(const Duration(minutes: 20)),
        duration: const Duration(hours: 1),
        videoUrl: 'assets/videos/sample10.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'shark_tank',
        title: 'Shark Tank',
        channelId: 'cnbc',
        startTime: now.add(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 80)),
        duration: const Duration(hours: 1),
        videoUrl: 'assets/videos/sample11.mp4',
        videoType: VideoType.mp4,
      ),
      // Movie programs
      Program(
        id: 'avengers',
        title: 'Avengers: Endgame',
        channelId: 'hbo',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 120)),
        duration: const Duration(minutes: 150),
        videoUrl: 'assets/videos/sample12.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'spider_man',
        title: 'Spider-Man: No Way Home',
        channelId: 'netflix',
        startTime: now.add(const Duration(minutes: 120)),
        endTime: now.add(const Duration(minutes: 270)),
        duration: const Duration(minutes: 150),
        videoUrl: 'assets/videos/sample13.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'frozen',
        title: 'Frozen 2',
        channelId: 'disney',
        startTime: now.subtract(const Duration(minutes: 15)),
        endTime: now.add(const Duration(minutes: 90)),
        duration: const Duration(minutes: 105),
        videoUrl: 'assets/videos/sample14.mp4',
        videoType: VideoType.mp4,
      ),
      // Kids programs
      Program(
        id: 'tom_jerry',
        title: 'Tom and Jerry',
        channelId: 'cartoon_network',
        startTime: now.subtract(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 20)),
        duration: const Duration(minutes: 30),
        videoUrl: 'assets/videos/sample15.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'spongebob',
        title: 'SpongeBob SquarePants',
        channelId: 'nickelodeon',
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now.add(const Duration(minutes: 25)),
        duration: const Duration(minutes: 30),
        videoUrl: 'assets/videos/sample16.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'mickey_mouse',
        title: 'Mickey Mouse Clubhouse',
        channelId: 'disney_junior',
        startTime: now.subtract(const Duration(minutes: 8)),
        endTime: now.add(const Duration(minutes: 22)),
        duration: const Duration(minutes: 30),
        videoUrl: 'assets/videos/sample17.mp4',
        videoType: VideoType.mp4,
      ),
      // Additional movie programs
      Program(
        id: 'batman',
        title: 'The Batman',
        channelId: 'hbo',
        startTime: now.add(const Duration(minutes: 150)),
        endTime: now.add(const Duration(minutes: 330)),
        duration: const Duration(minutes: 180),
        videoUrl: 'assets/videos/sample18.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'moana',
        title: 'Moana',
        channelId: 'disney',
        startTime: now.add(const Duration(minutes: 105)),
        endTime: now.add(const Duration(minutes: 210)),
        duration: const Duration(minutes: 105),
        videoUrl: 'assets/videos/sample19.mp4',
        videoType: VideoType.mp4,
      ),
    ];

    for (final program in seedPrograms) {
      final exists = appState.programs.any((p) => p.id == program.id);
      if (!exists) {
        appState.addProgram(program);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2F38),
      appBar: AppBar(
        title: const Text('Live TV'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Test button to verify Hive persistence
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () async {
              final appState = context.read<AppState>();
              print('=== Testing Hive Persistence ===');
              print('Current programs: ${appState.programs.length}');
              for (final program in appState.programs) {
                print('  - ${program.title} (ID: ${program.id})');
              }

              // Test adding a temporary program
              final testProgram = Program(
                id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                title:
                    'Test Program ${DateTime.now().hour}:${DateTime.now().minute}',
                channelId: 'test_channel',
                startTime: DateTime.now(),
                endTime: DateTime.now().add(const Duration(hours: 1)),
                durationSeconds: 3600, // 1 hour
                videoUrl: 'https://example.com/test.mp4',
                videoType: VideoType.mp4,
              );

              appState.addProgram(testProgram);
              print('Added test program: ${testProgram.title}');
              print('Programs after adding: ${appState.programs.length}');
            },
            tooltip: 'Test Hive Persistence',
          ),
          // Force reload button for debugging
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final appState = context.read<AppState>();
              print('=== Force Reloading Data ===');
              await appState.forceReloadData();
              print(
                'Force reload completed. Programs: ${appState.programs.length}',
              );
            },
            tooltip: 'Force Reload Data',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Row(
              children: [
                // Left Navigation Menu
                Container(
                  width: 200,
                  color: const Color(0xFF1A2F38),
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                  ), // Added constraint
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildNavigationItem(
                        'ALL CHANNELS',
                        appState.selectedCategory == 'ALL CHANNELS',
                      ),
                      _buildNavigationItem(
                        'MY CHANNELS',
                        appState.selectedCategory == 'MY CHANNELS',
                      ),
                      _buildNavigationItem(
                        'RECENT',
                        appState.selectedCategory == 'RECENT',
                      ),
                      _buildNavigationItem(
                        'SPORTS',
                        appState.selectedCategory == 'SPORTS',
                      ),
                      _buildNavigationItem(
                        'NEWS',
                        appState.selectedCategory == 'NEWS',
                      ),
                      _buildNavigationItem(
                        'MOVIES',
                        appState.selectedCategory == 'MOVIES',
                      ),
                      _buildNavigationItem(
                        'KIDS',
                        appState.selectedCategory == 'KIDS',
                      ),
                      const Spacer(),
                      // Debug info
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              'Channels: ${appState.channels.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Programs: ${appState.programs.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Header with time and timeline
                      _buildHeader(),
                      // Program grid
                      Expanded(child: _buildProgramGrid(appState)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationItem(String title, bool isSelected) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      constraints: const BoxConstraints(maxHeight: 50), // Added constraint
      child: TextButton(
        onPressed: () {
          context.read<AppState>().selectCategory(title);
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF4A90E2)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final timeFormat = DateFormat('h:mma');
    final dateFormat = DateFormat('EEE MMM d');

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: const BoxConstraints(maxHeight: 80), // Added constraint
      child: Row(
        children: [
          // Current time and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Text(
                timeFormat.format(_currentTime),
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateFormat.format(_currentTime).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(width: 40),
          // Timeline
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    _buildTimeSlot('7:00PM'),
                    _buildTimeSlot('7:30PM'),
                    _buildTimeSlot('8:00PM'),
                  ],
                ),
                // Current time indicator
                Positioned(
                  left: _getCurrentTimePosition(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                      Container(
                        width: 2,
                        height: 60,
                        color: const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    return Expanded(
      child: Text(
        time,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _getCurrentTimePosition() {
    final now = _currentTime;
    final startOfHour = DateTime(
      now.year,
      now.month,
      now.day,
      19,
      0,
    ); // 7:00 PM
    final endOfHour = DateTime(now.year, now.month, now.day, 20, 0); // 8:00 PM

    if (now.isBefore(startOfHour)) return 0;
    if (now.isAfter(endOfHour)) return 1;

    final totalDuration = endOfHour.difference(startOfHour);
    final currentDuration = now.difference(startOfHour);
    return currentDuration.inMilliseconds / totalDuration.inMilliseconds;
  }

  Widget _buildProgramGrid(AppState appState) {
    final channels = appState.getChannelsByCategory(appState.selectedCategory);

    if (channels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No channels available in this category',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: channels.length,
      shrinkWrap: true, // Added to prevent overflow
      itemBuilder: (context, index) {
        final channel = channels[index];
        final programs = appState.getProgramsForChannel(channel.id);

        return _buildChannelRow(channel, programs);
      },
    );
  }

  Widget _buildChannelRow(Channel channel, List<Program> programs) {
    return Container(
      height: 100, // Reduced from 120 to prevent overflow
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Channel logo
          Container(
            width: 120,
            height: 80,
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                channel.logo.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Program timeline
          Expanded(
            child: Row(
              children: [
                _buildProgramSlot(
                  programs.isNotEmpty
                      ? programs[0]
                      : _getDefaultProgram(channel.id, 0),
                  channel.id,
                ),
                _buildProgramSlot(
                  programs.length > 1
                      ? programs[1]
                      : _getDefaultProgram(channel.id, 1),
                  channel.id,
                ),
                _buildProgramSlot(
                  programs.length > 2
                      ? programs[2]
                      : _getDefaultProgram(channel.id, 2),
                  channel.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Program _getDefaultProgram(String channelId, int slotIndex) {
    final now = DateTime.now();
    final startTime = now.add(Duration(minutes: slotIndex * 30));
    final endTime = startTime.add(const Duration(minutes: 30));

    return Program(
      id: 'default_${channelId}_$slotIndex',
      title: _getDefaultProgramTitle(channelId),
      channelId: channelId,
      startTime: startTime,
      endTime: endTime,
      duration: const Duration(minutes: 30),
      videoUrl: _getDefaultVideoUrl(channelId),
      videoType: VideoType.mp4,
    );
  }

  String _getDefaultProgramTitle(String channelId) {
    switch (channelId) {
      case 'tbs':
        return 'Friends';
      case 'fox_sports':
        return 'Sports Center';
      case 'food_network':
        return 'Chopped';
      case 'cbs':
        return 'CBS News';
      case 'cnbc':
        return 'Mad Money';
      case 'hbo':
        return 'Game of Thrones';
      case 'netflix':
        return 'Stranger Things';
      case 'disney':
        return 'The Mandalorian';
      case 'cartoon_network':
        return 'Adventure Time';
      case 'nickelodeon':
        return 'SpongeBob';
      case 'disney_junior':
        return 'Mickey Mouse';
      default:
        return 'Default Show';
    }
  }

  String _getDefaultVideoUrl(String channelId) {
    switch (channelId) {
      case 'tbs':
        return 'assets/videos/sample1.mp4';
      case 'fox_sports':
        return 'assets/videos/sample2.mp4';
      case 'food_network':
        return 'assets/videos/sample3.mp4';
      case 'cbs':
        return 'assets/videos/sample4.mp4';
      case 'cnbc':
        return 'assets/videos/sample5.mp4';
      case 'hbo':
        return 'assets/videos/sample6.mp4';
      case 'netflix':
        return 'assets/videos/sample7.mp4';
      case 'disney':
        return 'assets/videos/sample8.mp4';
      case 'cartoon_network':
        return 'assets/videos/sample9.mp4';
      case 'nickelodeon':
        return 'assets/videos/sample10.mp4';
      case 'disney_junior':
        return 'assets/videos/sample11.mp4';
      default:
        return 'assets/videos/sample1.mp4';
    }
  }

  Widget _buildProgramSlot(Program? program, String channelId) {
    // Always ensure we have a program (either real or default)
    final actualProgram = program ?? _getDefaultProgram(channelId, 0);
    final isCurrentlyPlaying = actualProgram.isCurrentlyPlaying;

    return Expanded(
      child: GestureDetector(
        onTap: () => _playProgram(actualProgram),
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(right: 10),
          constraints: const BoxConstraints(maxHeight: 80), // Added constraint
          decoration: BoxDecoration(
            color: isCurrentlyPlaying
                ? const Color(0xFF2196F3)
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: isCurrentlyPlaying
                ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(
            8,
          ), // Reduced padding to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      actualProgram.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actualProgram.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4, // Reduced padding
                        vertical: 1, // Reduced padding
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8, // Reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                '${_formatTime(actualProgram.startTime)} - ${_formatTime(actualProgram.endTime)} • ${actualProgram.remainingTimeString}',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 11,
                ), // Reduced font size
              ),
              if (actualProgram.episodeInfo != null) ...[
                const SizedBox(height: 2), // Reduced spacing
                Text(
                  actualProgram.episodeInfo!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ), // Reduced font size
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$ampm';
  }

  void _playProgram(Program program) {
    print('Playing program: ${program.title}');
    print('Video URL: ${program.videoUrl}');

    // Navigate to video player immediately
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(program: program),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
