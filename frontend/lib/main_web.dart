import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'main.dart';

void main() {
  // Configure the URL strategy for the web app
  // This removes the hash (#) from the URLs
  setUrlStrategy(PathUrlStrategy());
  
  // Run the main app
  runApp(FinancialAdvisorApp());
}
