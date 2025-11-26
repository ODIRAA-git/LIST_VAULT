import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- add this

import 'models/item.dart';
import 'models/weekly_list.dart';
import 'models/event_list.dart';
import 'models/custom_list.dart';
import 'models/user.dart' as models;
import 'models/family_group.dart';

import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'screens/list_type_selector.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -----------------------------
  // Initialize Supabase
  // -----------------------------
  await Supabase.initialize(
    url: 'https://bcalmvdvdwxvfjmwylie.supabase.co', // <-- replace with your URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjYWxtdmR2ZHd4dmZqbXd5bGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwNzA4NzgsImV4cCI6MjA3OTY0Njg3OH0.uKbZK7X-ndRQjnX6CikcPQOChfkgNSGpA2QOMGflmBM',            // <-- replace with your anon key
  );

  // -----------------------------
  // Initialize Hive
  // -----------------------------
  await Hive.initFlutter();

  // Register Hive adapters (only for models still using Hive)
  Hive.registerAdapter(EventListAdapter());
  Hive.registerAdapter(CustomListAdapter());
  Hive.registerAdapter(models.UserAdapter());
  Hive.registerAdapter(FamilyGroupAdapter());

  // Open Hive boxes (only for models still using Hive)
  await Hive.openBox<EventList>('eventLists');
  await Hive.openBox<CustomList>('customLists');
  await Hive.openBox<models.User>('users');
  await Hive.openBox<FamilyGroup>('familyGroups');

  // Initialize notifications
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'List Vault',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const ListTypeSelectorScreen(),
          );
        },
      ),
    );
  }
}
