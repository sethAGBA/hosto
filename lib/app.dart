import 'package:flutter/material.dart';
import 'screen/main_screen.dart';

class ResHopitalApp extends StatelessWidget {
  const ResHopitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Res Hopital',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5A4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF111827),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
