import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'models/app_state.dart';

void main() {
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
