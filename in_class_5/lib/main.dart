// BLOCK 1: Import Flutter's Material widgets and launch the app.
    import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

    // BLOCK 2: This app shell does not change, so it is a StatelessWidget.
class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterPage(),
    );
  }
}

// BLOCK 3: This screen changes after user interactions, so it is stateful.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // BLOCK 4: State fields determine what the user sees at any moment.
  int _counter = 40;
  int _increment = 7;
  final List<int> _history = [];
  final TextEditingController _incrementController = TextEditingController(text: '7');

  @override
  void dispose() {
    // Controllers use resources; dispose them when this screen is removed.
    _incrementController.dispose();
    super.dispose();
  }

  // Set while the slider is being dragged: the value before the drag began.
  int? _dragStartValue;
  // Inline feedback for the increment field; null when the input is valid.
  String? _incrementError;

  // BLOCK 5: Helper methods enforce rules before they change UI state.
  static const int _minValue = 10;
  static const int _maxValue = 150;

  bool _isValidValue(int value) => value >= _minValue && value <= _maxValue;

  // Activity 05 color-feedback rule, driven by the same counter state.
  Color _counterColor() {
    if (_counter == 10) return Colors.red;
    if (_counter > 90) return Colors.green;
    return Colors.black;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // Replace stale feedback instead of queueing it.
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _moveTo(int nextValue) {
    // Reject the action before changing state or creating a history record.
    if (!_isValidValue(nextValue)) {
      _showMessage(nextValue < _minValue
          ? 'Blocked: $_counter − $_increment = $nextValue is below the minimum of $_minValue.'
          : 'Blocked: $_counter + $_increment = $nextValue is above the maximum of $_maxValue.');
      return;
    }
    if (nextValue == _counter) return; // No change, so nothing to record.

    setState(() {
      _history.add(_counter); // Save only the state that can be restored.
      _counter = nextValue;
    });
  }

  // Returns why the input is rejected, or null if it is a positive whole number.
  String? _incrementProblem(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return 'Empty';
    if (RegExp(r'^[+-]?\d*\.\d*$').hasMatch(input) && input.contains(RegExp(r'\d'))) {
      return '"$input" is a decimal';
    }
    if (RegExp(r'^-\d+$').hasMatch(input)) return '"$input" is negative';
    // Digits only: rejects hex like 0x1F and signs that int.tryParse would accept.
    if (!RegExp(r'^\d+$').hasMatch(input)) return '"$input" is not a number';
    final value = int.tryParse(input);
    if (value == null) return '"$input" is too large';
    if (value == 0) return 'Zero is not positive';
    return null;
  }

  void _readIncrement(String input) {
    final problem = _incrementProblem(input);
    setState(() {
      if (problem != null) {
        // Keep the last valid increment unchanged and say so.
        _incrementError = '$problem. Use a positive whole number; still using $_increment.';
      } else {
        _incrementError = null;
        _increment = int.parse(input.trim());
      }
    });
  }

  void _undo() {
    if (_history.isEmpty) {
      _showMessage('Nothing to undo.');
      return;
    }
    setState(() => _counter = _history.removeLast());
  }

  void _reset() {
    if (_counter == _minValue) {
      _showMessage('Already at $_minValue.');
      return;
    }
    _moveTo(_minValue);
  }

  // A whole slider drag is one undoable step: record the value from before
  // the drag once it ends, rather than one entry per intermediate tick.
  void _onSlideStart(double value) => _dragStartValue = _counter;

  void _onSlide(double value) => setState(() => _counter = value.round());

  void _onSlideEnd(double value) {
    final start = _dragStartValue;
    _dragStartValue = null;
    if (start != null && start != _counter) {
      setState(() => _history.add(start));
    }
  }

  @override
  Widget build(BuildContext context) {
    // BLOCK 6: Build reads state and connects widgets to user actions.
    return Scaffold(
      appBar: AppBar(title: const Text('Activity 05 Counter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$_counter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: _counterColor(),
                  ),
            ),
            Slider(
              value: _counter.toDouble(),
              min: _minValue.toDouble(),
              max: _maxValue.toDouble(),
              divisions: _maxValue - _minValue,
              label: '$_counter',
              // Slider moves are real counter changes, so they are undoable,
              // but a drag is recorded as a single step (see _onSlideEnd).
              onChangeStart: _onSlideStart,
              onChanged: _onSlide,
              onChangeEnd: _onSlideEnd,
            ),
            Text(
              'Limits: $_minValue – $_maxValue',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextField(
              controller: _incrementController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Increment amount (positive whole number)',
                helperText: 'Current increment: $_increment',
                errorText: _incrementError,
              ),
              onChanged: _readIncrement,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(onPressed: () => _moveTo(_counter - _increment), child: const Text('Decrease')),
                ElevatedButton(onPressed: () => _moveTo(_counter + _increment), child: const Text('Increase')),
                OutlinedButton(onPressed: _reset, child: const Text('Reset to 10')),
                OutlinedButton(onPressed: _undo, child: Text('Undo (${_history.length})')),
              ],
            ),
            const SizedBox(height: 20),
            Text(_history.isEmpty ? 'History: none' : 'History: ${_history.join(', ')}'),
          ],
        ),
      ),
    );
  }
}