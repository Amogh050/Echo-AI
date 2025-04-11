import 'package:echo_ai/home_page.dart';
import 'package:echo_ai/pallete.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo AI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.darkSurfaceColor,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Pallete.accentBlue),
          titleTextStyle: TextStyle(
            color: Pallete.mainFontColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cera Pro',
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Pallete.mainFontColor),
        ),
      ),
      home: const HomePage(),
    );
  }
}