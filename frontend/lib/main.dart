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
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF2A5298),
        accentColor: Color(0xFF4CAF50),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Color(0xFF2A5298),
          elevation: 2,
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF2A5298),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        textTheme: TextTheme(
          headline4: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A5298),
          ),
          headline5: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2A5298),
          ),
          headline6: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2A5298),
          ),
          subtitle1: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodyText1: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          bodyText2: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF1E3C72),
        accentColor: Color(0xFF4CAF50),
        scaffoldBackgroundColor: Color(0xFF121212),
        cardTheme: CardTheme(
          color: Color(0xFF242424),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: TextTheme(
          headline4: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headline5: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          headline6: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          subtitle1: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
          bodyText1: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          bodyText2: TextStyle(
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
