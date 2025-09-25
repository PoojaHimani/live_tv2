import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
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
  // Shared horizontal controller so header and program rows stay aligned
  late ScrollController _horizontalController;
  // Number of 30-minute slots to render (48 -> 24 hours)
  static const int _slotCount = 48;
  // Track current horizontal scroll offset to render a fixed header synced with grid
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _horizontalController = ScrollController();
    _horizontalController.addListener(() {
      if (!mounted) return;
      setState(() {
        _scrollOffset = _horizontalController.offset;
      });
    });
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

  // Compute a base start time used for header slots and scroll positioning.
  DateTime _computeBaseStart(AppState appState) {
    // Start from the current half-hour block so we show only current and upcoming content
    final now = DateTime.now();
    final int snappedMinute = now.minute - (now.minute % 30);
    return DateTime(now.year, now.month, now.day, now.hour, snappedMinute);
  }

  // Scroll the shared horizontal controller to show current time for the computed base
  void _scrollToCurrentTime(AppState appState, {int attempt = 0}) {
    if (!mounted) return;
    if (!_horizontalController.hasClients) {
      if (attempt < 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentTime(appState, attempt: attempt + 1);
        });
      }
      return;
    }

    const double tileWidth = 180.0;
    const double tileRightMargin = 8.0;
    final double slotWidth = tileWidth + tileRightMargin;

    final baseStart = _computeBaseStart(appState);
    final left = _getCurrentTimeLeft(baseStart, slotWidth);

    // aim to center current time a bit into the view
    final viewportWidth = _horizontalController.position.viewportDimension;
    final maxExtent = _horizontalController.position.maxScrollExtent;
    if (viewportWidth == 0 || maxExtent == 0) {
      if (attempt < 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentTime(appState, attempt: attempt + 1);
        });
      }
      return;
    }
    final target = (left - viewportWidth / 3).clamp(0.0, maxExtent);

    // Update header immediately to the target position so labels reflect real time
    setState(() {
      _scrollOffset = target;
    });

    _horizontalController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _horizontalController.dispose();
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
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
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
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
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
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
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
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'kings_live',
        title: 'Kings Live',
        channelId: 'fox_sports',
        startTime: now.add(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 50)),
        durationSeconds: 1800, // 30 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
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
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'grocery_games',
        title: 'Guy\'s Grocery Games',
        channelId: 'food_network',
        startTime: now.add(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 40)),
        durationSeconds: 1800, // 30 minutes
        videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'cbs_news',
        title: 'CBS News at 6PM Sundays',
        channelId: 'cbs',
        startTime: now.subtract(const Duration(minutes: 40)),
        endTime: now.add(const Duration(minutes: 20)),
        durationSeconds: 3600, // 1 hour
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'sixty_minutes',
        title: '60 Minutes',
        channelId: 'cbs',
        startTime: now.add(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 80)),
        durationSeconds: 3600, // 1 hour
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'deal_no_deal',
        title: 'Deal or No Deal',
        channelId: 'cnbc',
        startTime: now.subtract(const Duration(minutes: 40)),
        endTime: now.add(const Duration(minutes: 20)),
        durationSeconds: 3600, // 1 hour
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'shark_tank',
        title: 'Shark Tank',
        channelId: 'cnbc',
        startTime: now.add(const Duration(minutes: 20)),
        endTime: now.add(const Duration(minutes: 80)),
        durationSeconds: 3600, // 1 hour
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        videoType: VideoType.mp4,
      ),
      // Movie programs
      Program(
        id: 'avengers',
        title: 'Avengers: Endgame',
        channelId: 'hbo',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 120)),
        durationSeconds: 9000, // 150 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'spider_man',
        title: 'Spider-Man: No Way Home',
        channelId: 'netflix',
        startTime: now.add(const Duration(minutes: 120)),
        endTime: now.add(const Duration(minutes: 270)),
        durationSeconds: 9000, // 150 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'frozen',
        title: 'Frozen 2',
        channelId: 'disney',
        startTime: now.subtract(const Duration(minutes: 15)),
        endTime: now.add(const Duration(minutes: 90)),
        durationSeconds: 6300, // 105 minutes
        videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
        videoType: VideoType.mp4,
      ),
      // Kids programs
      Program(
        id: 'tom_jerry',
        title: 'Tom and Jerry',
        channelId: 'cartoon_network',
        startTime: now.subtract(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 20)),
        durationSeconds: 1800, // 30 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'spongebob',
        title: 'SpongeBob SquarePants',
        channelId: 'nickelodeon',
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now.add(const Duration(minutes: 25)),
        durationSeconds: 1800, // 30 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        videoType: VideoType.mp4,
      ),
      Program(
        id: 'mickey_mouse',
        title: 'Mickey Mouse Clubhouse',
        channelId: 'disney_junior',
        startTime: now.subtract(const Duration(minutes: 8)),
        endTime: now.add(const Duration(minutes: 22)),
        durationSeconds: 1800, // 30 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        videoType: VideoType.mp4,
      ),
      // Additional movie programs
      Program(
        id: 'batman',
        title: 'The Batman',
        channelId: 'hbo',
        startTime: now.add(const Duration(minutes: 150)),
        endTime: now.add(const Duration(minutes: 330)),
        durationSeconds: 10800, // 180 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        videoType: VideoType.mp4,
        isNew: true,
      ),
      Program(
        id: 'moana',
        title: 'Moana',
        channelId: 'disney',
        startTime: now.add(const Duration(minutes: 105)),
        endTime: now.add(const Duration(minutes: 210)),
        durationSeconds: 6300, // 105 minutes
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
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
            final content = Row(
              children: [
                // Left Navigation Menu with vertical scrolling
                Container(
                  width: 200,
                  color: const Color(0xFF1A2F38),
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                  ), // Added constraint
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
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
                            ],
                          ),
                        ),
                      ),
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
                      _buildHeader(appState),
                      // Program grid
                      Expanded(child: _buildProgramGrid(appState)),
                    ],
                  ),
                ),
              ],
            );

            // After the widgets have been laid out, auto-scroll the timeline to the current time
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToCurrentTime(appState);
            });

            return content;
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

  Widget _buildHeader(AppState appState) {
    final timeFormat = DateFormat('h:mma');
    final dateFormat = DateFormat('EEE MMM d');

    // The program tiles use a fixed width + margin. Keep the header slots the same
    const double tileWidth = 180.0;
    const double tileRightMargin = 8.0;
    const double slotWidth = tileWidth + tileRightMargin;
    // use class-level _slotCount so header and rows match
    final int slotCount = _slotCount;
    // Use the same base start as the grid so header and programs align
    final DateTime baseStart = _computeBaseStart(appState);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: const BoxConstraints(maxHeight: 80),
      child: Row(
        children: [
          // Current time and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
          // Timeline - NOT scrollable; labels sync with program grid scroll
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double viewportWidth = constraints.maxWidth;
                final int visibleSlots = (viewportWidth / slotWidth).ceil() + 1;
                final int firstVisibleIndex = (_scrollOffset / slotWidth)
                    .floor()
                    .clamp(0, slotCount - 1);
                final DateTime firstVisibleTime = baseStart.add(
                  Duration(minutes: firstVisibleIndex * 30),
                );

                final double currentLeftGlobal = _getCurrentTimeLeft(
                  baseStart,
                  slotWidth,
                );
                final double currentLeftInHeader =
                    (currentLeftGlobal - _scrollOffset).clamp(
                      0.0,
                      viewportWidth - 4,
                    );

                // Align labels precisely above tile boundaries by shifting remainder
                final double remainder = _scrollOffset % slotWidth;

                return ClipRect(
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(-remainder, 0),
                        child: SizedBox(
                          width: viewportWidth + slotWidth,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(visibleSlots + 1, (i) {
                              final DateTime slotTime = firstVisibleTime.add(
                                Duration(minutes: i * 30),
                              );
                              return Container(
                                width: slotWidth,
                                alignment: Alignment.center,
                                child: Text(
                                  timeFormat.format(slotTime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      // Current time indicator relative to visible viewport (fits within 60px content height)
                      Positioned(
                        left: currentLeftInHeader,
                        top: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Color(0xFF4CAF50),
                              size: 16,
                            ),
                            Container(
                              width: 2,
                              height: 44,
                              color: const Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Returns the left offset in pixels for the current time relative to a given base start and slot width
  double _getCurrentTimeLeft(DateTime baseStart, double slotWidth) {
    final now = _currentTime;
    final diff = now.difference(baseStart);
    // If current time is before the baseStart, keep indicator at start
    if (diff.isNegative) return 0.0;
    final totalSeconds = diff.inSeconds;
    // Each slot represents 30 minutes = 1800 seconds
    final pxPerSecond = slotWidth / 1800.0;
    final left = totalSeconds * pxPerSecond;
    // Clamp so it doesn't go beyond the total slots width
    final maxLeft = slotWidth * _slotCount;
    return math.min(left, maxLeft - 4);
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

    return SingleChildScrollView(
      child: Column(
        children: channels.map((channel) {
          final programs = appState.getProgramsForChannel(channel.id);
          return _buildChannelRow(channel, programs, appState);
        }).toList(),
      ),
    );
  }

  Widget _buildChannelRow(
    Channel channel,
    List<Program> programs,
    AppState appState,
  ) {
    // channel row build - no scheduling here (scroll is scheduled centrally)
    final baseStart = _computeBaseStart(appState);

    return Container(
      height: 85, // Reduced height to match program slots
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          // Channel logo - show image (network or asset) with fallback
          Container(
            width: 90,
            height: 75,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Builder(
                builder: (context) {
                  final logo = channel.logo;
                  if (logo.isEmpty) {
                    return const Text(
                      'NO LOGO',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    );
                  }

                  // If it looks like a URL, try network image
                  if (logo.startsWith('http://') ||
                      logo.startsWith('https://')) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        logo,
                        width: 80,
                        height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stack) {
                          final display = (channel.name.isNotEmpty)
                              ? channel.name
                              : channel.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Center(
                              child: Text(
                                display,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  // Prefer loading a local asset named assets/logos/<logo>.png
                  final assetPath = 'assets/logos/$logo.png';
                  return Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback: show the channel name when asset missing
                      final display = (channel.name.isNotEmpty)
                          ? channel.name
                          : channel.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: Text(
                            display,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Program timeline with horizontal scrolling (shared controller to sync with header)
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_slotCount, (index) {
                  final slotStart = baseStart.add(
                    Duration(minutes: index * 30),
                  );
                  final programForSlot = _findProgramForSlot(
                    channel.id,
                    slotStart,
                    appState,
                  );
                  return _buildProgramSlot(programForSlot, channel.id);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Find a program for the channel that covers the given slot start time.
  // If none is found, return a default 30-minute program starting at slotStart.
  Program _findProgramForSlot(
    String channelId,
    DateTime slotStart,
    AppState appState,
  ) {
    final slotEnd = slotStart.add(const Duration(minutes: 30));
    final programs = appState.getProgramsForChannel(channelId);
    for (final p in programs) {
      if (!p.startTime.isAfter(slotStart) && p.endTime.isAfter(slotStart)) {
        return p;
      }
    }
    return Program(
      id: 'default_${channelId}_${slotStart.toIso8601String()}',
      title: _getDefaultProgramTitle(channelId),
      channelId: channelId,
      startTime: slotStart,
      endTime: slotEnd,
      durationSeconds: 1800,
      videoUrl: _getDefaultVideoUrl(channelId),
      videoType: VideoType.mp4,
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
      durationSeconds: 1800, // 30 minutes
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
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      case 'fox_sports':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4';
      case 'food_network':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
      case 'cbs':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4';
      case 'cnbc':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4';
      case 'hbo':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4';
      case 'netflix':
        return 'https://www.w3schools.com/html/mov_bbb.mp4';
      case 'disney':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      case 'cartoon_network':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4';
      case 'nickelodeon':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
      case 'disney_junior':
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4';
      default:
        return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    }
  }

  Widget _buildProgramSlot(Program? program, String channelId) {
    // Always ensure we have a program (either real or default)
    final actualProgram = program ?? _getDefaultProgram(channelId, 0);
    final isCurrentlyPlaying = actualProgram.isCurrentlyPlaying;

    return Container(
      width: 180, // Reduced width to fit better
      height: 75, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _playProgram(actualProgram),
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentlyPlaying
                ? const Color(0xFF2196F3)
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
            border: isCurrentlyPlaying
                ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title row with NEW badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      actualProgram.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actualProgram.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              // Time info
              Text(
                '${_formatTime(actualProgram.startTime)} - ${_formatTime(actualProgram.endTime)}',
                style: TextStyle(color: Colors.grey[300], fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Remaining time
              Text(
                actualProgram.remainingTimeString,
                style: TextStyle(color: Colors.grey[400], fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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

  // settings navigation handled in AppBar actions
}
