import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// put the instructor url here. if it is empty the app uses the mock tip.
const String baseUrl = '';

// gets a signup tip from the AI service (or the mock if no url)
// only sends the task and topic, never anything from the form.
Future<String> getSignupTip(bool pretendOffline) async {
  if (baseUrl == '') {
    await Future.delayed(const Duration(seconds: 1));
    if (pretendOffline) {
      throw Exception('offline');
    }
    return 'Use a longer password with a mix of letters, numbers and symbols. Do not reuse passwords from other sites.';
  }

  final response = await http
      .post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task': 'signup_tip', 'topic': 'password_help'}),
      )
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('bad status');
  }
  final data = jsonDecode(response.body);
  String tip = data['tip'].toString().trim();
  if (tip == '' || tip == 'null') {
    throw Exception('empty tip');
  }
  return tip;
}

// 🧓 Great-Grandparent
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Club Signup',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 🔑 The Global Key - acts like a remote control for the form.
  final _formKey = GlobalKey<FormState>();

  // 📝 Controllers to track what the user types.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // AI tip stuff
  bool _loading = false;
  String _tip = '';
  String _error = '';
  bool _pretendOffline = false;

  void _getTip() async {
    setState(() {
      _loading = true;
      _tip = '';
      _error = '';
    });
    try {
      String tip = await getSignupTip(_pretendOffline);
      if (tip.length > 240) {
        tip = tip.substring(0, 240);
      }
      setState(() {
        _tip = tip;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not get a tip right now. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // 👨 Parent
      appBar: AppBar(
        title: const Text('Signup App!'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form( // 👶 Child
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 👤 Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 📧 Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔒 Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🚀 Sign Up Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo signup complete — your form passed validation!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),

              // 🤖 AI Tip
              OutlinedButton(
                onPressed: _loading ? null : _getTip,
                child: const Text('Get a signup tip'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _pretendOffline,
                    onChanged: (value) {
                      setState(() {
                        _pretendOffline = value!;
                      });
                    },
                  ),
                  const Text('Pretend offline (mock test)'),
                ],
              ),
              if (_loading) const CircularProgressIndicator(),
              if (_tip != '')
                Text(
                  (baseUrl == '' ? 'AI-generated advice (Not real AI was called):\n' : 'AI-generated advice:\n') + _tip,
                ),
              if (_error != '') ...[
                Text(_error, style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: _getTip, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
