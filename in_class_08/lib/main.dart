import 'package:flutter/material.dart';

import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final helper = DatabaseHelper();
  try {
    await helper.init();
  } catch (error, stackTrace) {
    debugPrint('Database initialization failed: $error\n$stackTrace');
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Could not open local storage. Restart the app and check the logs.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
  }
  runApp(DirectoryApp(helper: helper));
}

class DirectoryApp extends StatelessWidget {
  const DirectoryApp({super.key, required this.helper});

  final DatabaseHelper helper;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Festival Roster',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange),
      home: RosterScreen(helper: helper),
    );
  }
}

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key, required this.helper});

  final DatabaseHelper helper;

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  static const minAge = 0;
  static const maxAge = 130;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  // In-memory screen state. The database is the source of truth; these
  // fields only mirror the most recent successful query.
  List<Map<String, dynamic>> _rows = [];
  int _count = 0;
  bool _loading = true;
  bool _busy = false;
  String? _readError;
  String? _feedback;
  int? _selectedId;

  DatabaseHelper get _helper => widget.helper;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Queries the database and replaces the visible list. Returns true on
  /// success so callers can distinguish write failures from refresh failures.
  Future<bool> _load() async {
    try {
      final rows = await _helper.queryAllRows();
      final count = await _helper.queryRowCount();
      if (!mounted) return false;
      setState(() {
        _rows = rows;
        _count = count;
        _readError = null;
      });
      return true;
    } catch (error, stackTrace) {
      debugPrint('Read failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _readError = 'Could not read the roster: $error');
      }
      return false;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _loading = true;
    });
    try {
      final ok = await _load();
      if (mounted && ok) setState(() => _feedback = 'Roster refreshed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a name (spaces alone are not a name).';
    }
    return null;
  }

  String? _validateAge(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter an age.';
    final age = int.tryParse(text);
    if (age == null) return 'Age must be a whole number (no decimals or letters).';
    if (age < minAge || age > maxAge) {
      return 'Age must be from $minAge through $maxAge.';
    }
    return null;
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _ageController.clear();
    _selectedId = null;
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _feedback = 'Not saved: fix the highlighted fields.');
      return;
    }
    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final editingId = _selectedId;

    setState(() => _busy = true);
    String message;
    try {
      if (editingId == null) {
        final id = await _helper.insert({
          DatabaseHelper.columnName: name,
          DatabaseHelper.columnAge: age,
        });
        message = 'Added $name with ID $id.';
      } else {
        final updated = await _helper.update({
          DatabaseHelper.columnId: editingId,
          DatabaseHelper.columnName: name,
          DatabaseHelper.columnAge: age,
        });
        if (updated != 1) {
          // Row no longer exists: report it, keep input, reload.
          if (mounted) {
            setState(() {
              _selectedId = null;
              _feedback =
                  'Guest ID $editingId was not found ($updated rows updated). '
                  'The roster has been reloaded.';
            });
          }
          await _load();
          return;
        }
        message = 'Updated ID $editingId: $updated row affected.';
      }
    } catch (error, stackTrace) {
      debugPrint('Write failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _feedback = 'Save failed: $error. Your input was kept.');
      }
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    // The write succeeded: clear the form, then refresh separately.
    if (!mounted) return;
    setState(() {
      _clearForm();
      _busy = true;
    });
    try {
      final ok = await _load();
      if (mounted) {
        setState(() => _feedback =
            ok ? message : '$message Saved, but refresh failed. Tap Refresh.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startEdit(Map<String, dynamic> row) {
    setState(() {
      _selectedId = row[DatabaseHelper.columnId] as int;
      _nameController.text = row[DatabaseHelper.columnName] as String;
      _ageController.text = '${row[DatabaseHelper.columnAge]}';
      _feedback = 'Editing guest ID $_selectedId.';
    });
  }

  void _cancelEdit() {
    setState(() {
      _clearForm();
      _feedback = 'Edit cancelled. Nothing was written.';
    });
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    if (_busy) return;
    final id = row[DatabaseHelper.columnId] as int;
    final name = row[DatabaseHelper.columnName];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete guest?'),
        content: Text('Delete ID $id ($name, age ${row[DatabaseHelper.columnAge]})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _feedback = 'Deletion of ID $id cancelled. Nothing was written.');
      return;
    }

    setState(() => _busy = true);
    String message;
    try {
      final deleted = await _helper.delete(id);
      message = deleted == 1
          ? 'Deleted ID $id: $deleted row affected.'
          : 'Guest ID $id was not found ($deleted rows deleted). Roster reloaded.';
      if (mounted && _selectedId == id) setState(_clearForm);
    } catch (error, stackTrace) {
      debugPrint('Delete failed: $error\n$stackTrace');
      if (mounted) setState(() => _feedback = 'Delete failed: $error');
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final ok = await _load();
      if (mounted) {
        setState(() => _feedback =
            ok ? message : '$message Refresh failed. Tap Refresh.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = _selectedId != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Festival Roster'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      editing ? 'Editing guest ID $_selectedId' : 'Add a guest',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                        labelText: 'Age ($minAge-$maxAge)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      validator: _validateAge,
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _busy ? null : _save,
                            child: Text(editing ? 'Save' : 'Add'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: (_busy || !editing) ? null : _cancelEdit,
                            child: const Text('Cancel edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : _refresh,
                            child: const Text('Refresh'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_feedback != null)
                Text(_feedback!, style: Theme.of(context).textTheme.bodyMedium),
              const Divider(height: 24),
              Text(
                'Guests stored: $_count',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_readError != null) {
      return Center(
        child: Text(
          '$_readError\nUse Refresh to retry.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_rows.isEmpty) {
      return const Center(
        child: Text('No festival guests yet. The pumpkin patch is quiet.'),
      );
    }
    return ListView.separated(
      itemCount: _rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = _rows[index];
        final id = row[DatabaseHelper.columnId];
        return ListTile(
          leading: CircleAvatar(child: Text('$id')),
          title: Text('${row[DatabaseHelper.columnName]}'),
          subtitle: Text('ID $id · Age ${row[DatabaseHelper.columnAge]}'),
          selected: id == _selectedId,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit ID $id',
                onPressed: _busy ? null : () => _startEdit(row),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete ID $id',
                onPressed: _busy ? null : () => _delete(row),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}
