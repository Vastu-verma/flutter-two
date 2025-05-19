
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Generator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const PasswordGeneratorHomePage(),
    );
  }
}

class PasswordGeneratorHomePage extends StatefulWidget {
  const PasswordGeneratorHomePage({super.key});

  @override
  State<PasswordGeneratorHomePage> createState() => _PasswordGeneratorHomePageState();
}

class _PasswordGeneratorHomePageState extends State<PasswordGeneratorHomePage> {
  double _length = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSpecial = true;
  String _generatedPassword = '';

  final _random = Random();

  void _generatePassword() {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_includeUppercase) chars += upper;
    if (_includeLowercase) chars += lower;
    if (_includeNumbers) chars += numbers;
    if (_includeSpecial) chars += special;

    if (chars.isEmpty) {
      setState(() {
        _generatedPassword = 'Please select at least one character type.';
      });
      return;
    }

    String password = List.generate(_length.toInt(), (index) => chars[_random.nextInt(chars.length)]).join();
    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty && !_generatedPassword.startsWith('Please')) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Password Length:'),
            Slider(
              value: _length,
              min: 8,
              max: 32,
              divisions: 24,
              label: _length.toInt().toString(),
              onChanged: (value) => setState(() => _length = value),
            ),
            CheckboxListTile(
              title: const Text('Include Uppercase Letters'),
              value: _includeUppercase,
              onChanged: (value) => setState(() => _includeUppercase = value!),
            ),
            CheckboxListTile(
              title: const Text('Include Lowercase Letters'),
              value: _includeLowercase,
              onChanged: (value) => setState(() => _includeLowercase = value!),
            ),
            CheckboxListTile(
              title: const Text('Include Numbers'),
              value: _includeNumbers,
              onChanged: (value) => setState(() => _includeNumbers = value!),
            ),
            CheckboxListTile(
              title: const Text('Include Special Characters'),
              value: _includeSpecial,
              onChanged: (value) => setState(() => _includeSpecial = value!),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _generatePassword,
                child: const Text('Generate Password'),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              _generatedPassword,
              style: const TextStyle(fontSize: 16),
            ),
            if (_generatedPassword.isNotEmpty && !_generatedPassword.startsWith('Please'))
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy to Clipboard',
                onPressed: _copyToClipboard,
              ),
          ],
        ),
      ),
    );
  }
}
