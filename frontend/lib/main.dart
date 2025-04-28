import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/client_details_screen.dart';
import 'screens/account_screen.dart';
import 'screens/import_excel_screen.dart';

void main() {
  // Set preferred orientations
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(FinancialAdvisorApp());
}

class FinancialAdvisorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Advisor Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2A5298),
          secondary: Color(0xFF4CAF50),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A5298),
          elevation: 2,
          brightness: Brightness.light, //Corrected Brightness for light theme
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        buttonTheme: ButtonThemeData(
          backgroundColor: Color(0xFF2A5298),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A5298),
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2A5298),
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2A5298),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1E3C72),
          secondary: Color(0xFF4CAF50),
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        cardTheme: CardTheme(
          color: Color(0xFF242424),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(),
        '/client': (context) => ClientDetailsScreen(),
        '/account': (context) => AccountScreen(),
        '/import': (context) => ImportExcelScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
