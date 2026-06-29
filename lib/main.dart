import 'package:flashgamer/pages/AdminDashboard.dart';
import 'package:flashgamer/pages/Home.dart';
import 'package:flashgamer/pages/Initial.dart';
import 'package:flashgamer/pages/Login.dart';
import 'package:flashgamer/pages/New.dart';
import 'package:flashgamer/pages/Question.dart';
import 'package:flashgamer/pages/Ranking.dart';
import 'package:flashgamer/pages/Shop.dart';
import 'package:flashgamer/services/api_service.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: ApiService.navigatorKey,
    title: 'FlashGamer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    home: const LoginPage(title: 'Flutter Login'),
    routes: {
      '/login': (context) => const LoginPage(title: 'Flutter Login'),
      '/initial': (context) => const InitialPage(),
      '/new': (context) => const NewPage(),
      '/home': (context) => const HomePage(),
      '/ranking': (context) => const RankingPage(),
      '/shop': (context) => const ShopPage(),
      '/question': (context) => const QuestionPage(),
      '/admin': (context) => const AdminDashboardPage(),
    },
  );
}