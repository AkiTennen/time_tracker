import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'models/time_entry.dart';
import 'screens/home_screen.dart';
import 'screens/about_me_screen.dart';
import 'services/user_settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TimeEntryAdapter());
  await Hive.openBox<TimeEntry>('time_entries');
  await UserSettingsService.checkForCarryOver();

  runApp(const TimeTrackerApp());
}

class TimeTrackerApp extends StatefulWidget {
  const TimeTrackerApp({super.key});

  @override
  State<TimeTrackerApp> createState() => _TimeTrackerAppState();
}

class _TimeTrackerAppState extends State<TimeTrackerApp> {
  Locale _locale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('de')
          : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker Gothic',
      locale: _locale,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1D1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C1C1A),
          foregroundColor: Color(0xFFCBA135),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFEFE6D6)),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFCBA135),
          secondary: Color(0xFFB84335),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de')],
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(onToggleLocale: _toggleLocale),
        '/about': (context) => const AboutMeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
