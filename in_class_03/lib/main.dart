import 'package:flutter/material.dart';

// ============================================================================
// 1. MAIN ENTRY POINT
// ============================================================================
// Summary: Every Flutter app starts here. runApp() takes your root widget and
// attaches it to the screen, kicking off the framework's build-and-render pipeline.
// Reference: https://api.flutter.dev/flutter/widgets/runApp.html
void main() {
  runApp(const TactileDeckApp());
}

// ============================================================================
// 2. ROOT APPLICATION WIDGET (Manages Global Theme State)
// ============================================================================
// Summary: A StatefulWidget that owns the single source of truth for light/dark
// mode. MaterialApp reads isDarkMode to pick a theme, and onToggleTheme lets the
// child screen flip it via a callback — no need to pass data back up manually.
// Reference: https://docs.flutter.dev/cookbook/design/themes
class TactileDeckApp extends StatefulWidget {
  const TactileDeckApp({super.key});

  @override
  State<TactileDeckApp> createState() => _TactileDeckAppState();
}

class _TactileDeckAppState extends State<TactileDeckApp> {
  // Global theme toggle variable (carried over from Activity 02!)
  bool isDarkMode = true;

  // MILESTONE 1 — Custom theme: a "Midnight Grimoire" (dark) and an
  // "Aged Parchment" (light) palette, both seeded from arcane purple.
  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7B3FE4),
        brightness: brightness,
      ),
      // Serif type gives the whole app an old-book feel (falls back safely).
      fontFamily: 'Georgia',
      fontFamilyFallback: const ['Times New Roman', 'serif'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Spellbook',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(isDarkMode ? Brightness.dark : Brightness.light),
      home: ControlDeckScreen(
        isDark: isDarkMode,
        // Callback function to toggle theme mode from child widget
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

// ============================================================================
// 3. MAIN DASHBOARD SCREEN (Stateful Controller)
// ============================================================================
// Summary: The screen users actually see. Its State object holds totalTaps,
// powerLevel, and systemStatus, and rebuilds the metrics card, status banner,
// buttons, and slider every time setState() runs.
// Reference: https://api.flutter.dev/flutter/material/Scaffold-class.html
class ControlDeckScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const ControlDeckScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ControlDeckScreen> createState() => _ControlDeckScreenState();
}

class _ControlDeckScreenState extends State<ControlDeckScreen> {
  // MILESTONE 2 — At or above this mana level the spellbook "surges".
  static const double surgeThreshold = 80.0;

  // --- Mutable State Variables (Day 3 Core Concept!) ---
  int totalTaps = 0;              // Increments on every spell cast
  double powerLevel = 65.0;       // Mana, controlled by the interactive slider
  String systemStatus = "READY";  // Displays the latest spell cast

  // Helper method to update dashboard state upon button press
  void _triggerAction(String spellName) {
    setState(() {
      totalTaps++;
      systemStatus = "$spellName CAST";
    });
  }

  @override
  Widget build(BuildContext context) {
    // MILESTONE 2 — Interactive feedback: true once mana reaches 80% or more.
    final bool isSurging = powerLevel >= surgeThreshold;

    // Dynamic background color adapting to current theme AND the 80% surge.
    final screenBg = isSurging
        ? (widget.isDark ? const Color(0xFF4A1230) : const Color(0xFFF7D7A8))
        : (widget.isDark ? const Color(0xFF1A1030) : const Color(0xFFF3E6C8));
    final cardBg = widget.isDark ? const Color(0xFF2A1B4A) : const Color(0xFFFFF8E7);
    // Accent used for mana readouts; flips to a warning ember when surging.
    final manaColor = isSurging
        ? Colors.deepOrangeAccent
        : (widget.isDark ? Colors.purpleAccent : Colors.deepPurple);

    // AnimatedContainer fades the background between normal and surge colors;
    // the Scaffold is transparent so that color shows through.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: screenBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "FANTASY SPELLBOOK",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 18),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Theme Toggle Button in the AppBar
            IconButton(
              icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- TOP STATUS METRICS CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Total Spells Counter
                    Column(
                      children: [
                        const Text("SPELLS CAST", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("$totalTaps", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // Vertical Divider Line
                    Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
                    // Mana Level Indicator
                    Column(
                      children: [
                        const Text("MANA LEVEL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("${powerLevel.toInt()}%", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: manaColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Live System Status Banner
              Text(
                "STATUS: $systemStatus",
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.amberAccent : Colors.brown.shade700,
                ),
              ),
              // MILESTONE 2 — Extra warning line that only appears at 80%+ mana.
              if (isSurging) ...[
                const SizedBox(height: 8),
                Text(
                  "⚠ MANA SURGE, the spellbook glows with unstable power!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: manaColor),
                ),
              ],
              const SizedBox(height: 28),

              // --- GRID OF TACTILE 3D BUTTONS (built from the spells list) ---
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  for (final spell in spells)
                    TactileButton(
                      icon: spell.icon,
                      label: spell.label,
                      accentColor: spell.accentColor,
                      isDark: widget.isDark,
                      onPressed: () => _triggerAction(spell.actionName),
                    ),
                ],
              ),
              const SizedBox(height: 36),

              // --- INTERACTIVE MANA SLIDER ---
              Text(
                "Mana Channeling: ${powerLevel.toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Slider(
                value: powerLevel,
                min: 0,
                max: 100,
                activeColor: manaColor,
                inactiveColor: Colors.grey.withValues(alpha: 0.3),
                // setState updates powerLevel immediately during slider drag
                onChanged: (newVal) => setState(() => powerLevel = newVal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3b. SPELL BUTTON CONFIGS (data that drives the button grid)
// ============================================================================
// Summary: One small immutable class holds everything a button needs, and the
// const list below is looped over in the Wrap. Adding a button = adding one
// SpellConfig line; TactileButton itself is never duplicated.
class SpellConfig {
  final IconData icon;
  final String label;
  final Color accentColor;
  final String actionName; // Shown in the status text, e.g. "FIREBALL CAST"

  const SpellConfig({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.actionName,
  });
}

const spells = [
  SpellConfig(icon: Icons.local_fire_department, label: "FIREBALL",   accentColor: Colors.deepOrangeAccent, actionName: "FIREBALL"),
  SpellConfig(icon: Icons.ac_unit,               label: "FROST WARD", accentColor: Colors.lightBlueAccent,  actionName: "FROST WARD"),
  SpellConfig(icon: Icons.remove_red_eye,        label: "SCRYING",    accentColor: Colors.purpleAccent,     actionName: "SCRYING ORB"),
  SpellConfig(icon: Icons.auto_fix_high,         label: "SUMMON",     accentColor: Colors.amberAccent,      actionName: "FAMILIAR SUMMON"),
];

// ============================================================================
// 4. REUSABLE TACTILE 3D BUTTON WIDGET
// ============================================================================
// Summary: A self-contained StatefulWidget that tracks its own isPressed flag
// and uses GestureDetector + two opposing BoxShadows to fake a physical
// push-button depress-and-release effect — no external packages required.
// Reference: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
class TactileButton extends StatefulWidget {
  final IconData icon;          // Icon to display in center
  final String label;           // Button title text
  final Color accentColor;      // Active glow color
  final bool isDark;            // Light or Dark theme mode
  final VoidCallback onPressed; // Action callback triggered on tap

  const TactileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  // Local boolean state tracking whether button is currently being held down
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine dynamic background and shadow colors (purple stone / parchment)
    final baseColor = widget.isDark ? const Color(0xFF241640) : const Color(0xFFEBDDBB);
    final darkShadow = widget.isDark ? Colors.black87 : const Color(0xFFB89F6E);
    final lightShadow = widget.isDark ? const Color(0xFF3A2A5E) : const Color(0xFFFFF6DE);

    return GestureDetector(
      // 1. User touches button -> depress button
      onTapDown: (_) {
        print('onTapDown'); // TEMP: Question 2 evidence
        setState(() => isPressed = true);
      },
      // 2. User releases button -> restore position and fire callback
      onTapUp: (_) {
        print('onTapUp'); // TEMP: Question 2 evidence
        setState(() => isPressed = false);
        print('calling widget.onPressed()'); // TEMP: Question 2 evidence
        widget.onPressed();
      },
      // 3. User cancels touch -> restore position safely
      onTapCancel: () {
        print('onTapCancel'); // TEMP: Question 2 evidence
        setState(() => isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // Smooth 100ms spring transition
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          // Dual opposing BoxShadows create the 3D Neomorphic depth effect
          boxShadow: isPressed
              ? [
                  // Pressed (Sunken) Shadow Offsets
                  BoxShadow(color: darkShadow.withValues(alpha: 0.5), offset: const Offset(2, 2), blurRadius: 4),
                  BoxShadow(color: lightShadow.withValues(alpha: 0.5), offset: const Offset(-2, -2), blurRadius: 4),
                ]
              : [
                  // Unpressed (Elevated) Shadow Offsets
                  BoxShadow(color: darkShadow.withValues(alpha: 0.7), offset: const Offset(8, 8), blurRadius: 16),
                  BoxShadow(color: lightShadow.withValues(alpha: 0.9), offset: const Offset(-8, -8), blurRadius: 16),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dynamic Icon that changes size and glows on press
            Icon(
              widget.icon,
              size: isPressed ? 40 : 46,
              color: isPressed ? widget.accentColor : (widget.isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 8),
            // Button Label
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
                color: isPressed ? widget.accentColor : (widget.isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
