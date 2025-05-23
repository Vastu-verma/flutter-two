import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const MyPasswordApp());
}
// starts the app
class MyPasswordApp extends StatefulWidget {
  const MyPasswordApp({Key? key}) : super(key: key);

  @override
  State<MyPasswordApp> createState() => _MyPasswordAppState();
}
// main widget to manage dark mode
class _MyPasswordAppState extends State<MyPasswordApp> {

  bool darkModeOn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Password Generator',
      themeMode: darkModeOn ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      home: PasswordHomeScreen(
        isDark: darkModeOn,
        toggleDarkMode: (val) {
          setState(() {
            darkModeOn = val;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
    );
     }
}
// handles theme switch and sends data to home screen
class PasswordHomeScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool) toggleDarkMode;

  const PasswordHomeScreen({
    Key? key,
    required this.isDark,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  State<PasswordHomeScreen> createState() => _PasswordHomeScreenState();
}
// screen where password is generated
class _PasswordHomeScreenState extends State<PasswordHomeScreen>
    with SingleTickerProviderStateMixin {

  double passwordLength = 12;
  bool useUppercase = true;
  bool useLowercase = true;
  bool useNumbers = true;
  bool useSymbols = true;

  String password = '';

  final _randomGen = Random();

  late AnimationController _animationController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }
// setup animation for fade effect
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void generatePassword() {
    const uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const numberChars = '0123456789';
    const symbolChars = '!@#\$%^&*()-_=+[]{};:,.<>?';

    String allowedChars = '';
    if (useUppercase) allowedChars += uppercaseChars;
    if (useLowercase) allowedChars += lowercaseChars;
    if (useNumbers) allowedChars += numberChars;
    if (useSymbols) allowedChars += symbolChars;

    if (allowedChars.isEmpty) {
      setState(() {
        password = 'Please pick at least one character type!';
      });
      return;
    }

    String generated = List.generate(passwordLength.toInt(),
            (index) => allowedChars[_randomGen.nextInt(allowedChars.length)])
        .join();

    setState(() {
      password = generated;
    });

    _animationController.forward(from: 0);
  }
// makes a new password based on selected options
  void copyPassword() {
    if (password.isNotEmpty && !password.startsWith('Please')) {
      Clipboard.setData(ClipboardData(text: password));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    }
  }
// copies password to clipboard and shows message
  double getStrength() {
    if (password.isEmpty || password.startsWith('Please')) return 0;

    int typesCount = 0;
    if (useUppercase) typesCount++;
    if (useLowercase) typesCount++;
    if (useNumbers) typesCount++;
    if (useSymbols) typesCount++;

    double lengthScore = (passwordLength - 8) / (32 - 8);
    return (typesCount / 4) * 0.7 + lengthScore * 0.3;
  }
// calculates how strong the password is
  String strengthLabel(double val) {
    if (val < 0.3) return 'Weak';
    if (val < 0.7) return 'Moderate';
    return 'Strong';
  }
// gives text label for strength bar
  Color strengthColor(double val) {
    if (val < 0.3) return Colors.redAccent;
    if (val < 0.7) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final strengthVal = getStrength();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
        actions: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined),
              Switch(
                value: widget.isDark,
                onChanged: widget.toggleDarkMode,
                activeColor: Colors.yellow,
              ),
              const Icon(Icons.nights_stay_outlined),
              const SizedBox(width: 12),
            ],
          ),
     ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const Text('Choose password length'),
            Slider(
              value: passwordLength,
              min: 8,
              max: 32,
              divisions: 24,
              label: passwordLength.toInt().toString(),
              onChanged: (val) {
                setState(() {
                  passwordLength = val;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Use Uppercase Letters'),
              value: useUppercase,
              onChanged: (val) => setState(() => useUppercase = val!),
            ),
            CheckboxListTile(
              title: const Text('Use Lowercase Letters'),
              value: useLowercase,
              onChanged: (val) => setState(() => useLowercase = val!),
            ),
            CheckboxListTile(
              title: const Text('Include Numbers'),
              value: useNumbers,
              onChanged: (val) => setState(() => useNumbers = val!),
            ),
            CheckboxListTile(
              title: const Text('Include Symbols'),
              value: useSymbols,
              onChanged: (val) => setState(() => useSymbols = val!),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: generatePassword,
                child: const Text('Generate'),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeAnim,
              child: SelectableText(
                password,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            if (password.isNotEmpty && !password.startsWith('Please'))
              Center(
                child: IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 30,
                  tooltip: 'Copy password',
                  onPressed: copyPassword,
                ),
              ),
            const SizedBox(height: 20),
            if (password.isNotEmpty && !password.startsWith('Please'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Strength: ${strengthLabel(strengthVal)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: strengthColor(strengthVal),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: strengthVal,
                    backgroundColor: Colors.grey.shade300,
                    color: strengthColor(strengthVal),
                    minHeight: 8,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  // builds the full UI with sliders, checkboxes, password display, and strength bar

}
