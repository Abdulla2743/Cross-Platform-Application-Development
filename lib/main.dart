
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'back4app_config.dart';
import 'models/task.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse
  await Parse().initialize(
    Back4AppConfig.applicationId,
    Back4AppConfig.serverUrl,
    clientKey: Back4AppConfig.clientKey,
    debug: true, // Set to false in production
    liveQueryUrl: Back4AppConfig.liveQueryUrl,
  );
  //ParseCoreData().registerSubClass(Task());

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskyNote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}



