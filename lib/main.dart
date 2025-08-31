import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home.dart';
import 'models/app_state.dart';
import 'models/channel.dart';
import 'models/program.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Starting Hive initialization...');

    // Initialize Hive with consistent path for web
    await Hive.initFlutter();
    print('Hive initialized successfully');

    // Wait a moment to ensure Hive is fully ready
    await Future.delayed(const Duration(milliseconds: 100));

    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChannelAdapter());
      print('ChannelAdapter registered');
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(VideoTypeAdapter());
      print('VideoTypeAdapter registered');
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ProgramAdapter());
      print('ProgramAdapter registered');
    }

    print('All Hive adapters registered successfully');

    // Test Hive connection and verify persistence
    try {
      final testBox = await Hive.openBox('test_connection');
      final existingTest = testBox.get('test');

      if (existingTest == null) {
        // First time - set test value
        await testBox.put('test', 'Hive is working - ${DateTime.now()}');
        print('Set new test value in Hive');
      } else {
        // Value exists - verify persistence
        print('Found existing test value: $existingTest');
      }

      // Verify we can read/write
      await testBox.put('current_session', 'Session ${DateTime.now()}');
      final sessionValue = testBox.get('current_session');
      print('Current session test: $sessionValue');

      await testBox.close();
      print('Hive connection test successful');
    } catch (e) {
      print('Hive connection test failed: $e');
    }
  } catch (e) {
    print('Error during Hive initialization: $e');
    // Continue anyway - the app should still work
  }

  runApp(const LiveTVApp());
}

class LiveTVApp extends StatelessWidget {
  const LiveTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Live TV',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1A2F38),
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
