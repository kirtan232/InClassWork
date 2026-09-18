import 'package:flutter/material.dart';

void main() {
  runApp(const RunMyApp());
}

class RunMyApp extends StatefulWidget {
  const RunMyApp({super.key});

  @override
  State<RunMyApp> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<RunMyApp> {
  // Variable to manage the current theme mode
  ThemeMode _themeMode = ThemeMode.system;

  // Method to toggle the theme
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Card Demo',
      
      theme: ThemeData(
        useMaterial3: true, // Feature 1
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Feature 1
        scaffoldBackgroundColor: Colors.grey[200], // Light mode background
      ),
      darkTheme: ThemeData.dark(),
      
      themeMode: _themeMode, // Connects the state to the app

      home: Scaffold(
        appBar: AppBar(
          title: const Text('Status Card Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PART 1 TASK: Avatar and Text
              CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.teal
                    : Colors.blueGrey,
                child: const Icon(Icons.person, size: 42, color: Colors.white),
              ),

              const SizedBox(height: 12),

              const Text(
                'Flutter Theme Lab',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // PART 1 TASK: Status Badge Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),    // PART 2, Task 3
                curve: Curves.easeInOut,
                width: 220,
                height: 64,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Use a ternary operator to check theme brightness
                  color: Theme.of(context).brightness == Brightness.dark      // PART 2, Task 1
                      ? Colors.teal
                      : Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(     // Part2, Task 4: Dynamic Icon
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Text('Status: Online', style: TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text('Choose the Theme:', style: TextStyle(fontSize: 16)),
              
              const SizedBox(height: 10),

              // PART 1 TASK: Controls
              Switch(     // PART 2, Task 2: Switch replaces the two buttons
                value: _themeMode == ThemeMode.dark,
                onChanged: (bool isDark) {
                  setState(() {
                    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
          
          