import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const GplxApp());
}

class GplxApp extends StatelessWidget {
  const GplxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ôn thi GPLX A1',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
