import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_menu.dart';
import 'supabase_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your Supabase URL and anon key
  await Supabase.initialize(
    url: 'https://gykqibexlzwxpliezelo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3FpYmV4bHp3eHBsaWV6ZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MDUzMDEsImV4cCI6MjA1NzQ4MTMwMX0.MRfnjfhl5A7ZbK_ien8G1OPUmlF-3eqzOmx_EFTQHZk',
  );

  // Initialize SupabaseManager
  final supabaseManager = SupabaseManager();

  runApp(
    MyApp(supabaseManager: supabaseManager),
  ); // Pass SupabaseManager to MyApp
}

class MyApp extends StatefulWidget {
  final SupabaseManager
  supabaseManager; // Accept SupabaseManager in the constructor

  const MyApp({super.key, required this.supabaseManager});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.white,
  );

  final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.black,
  );

  static const double PHONE_WIDTH = 800;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isPhone = screenWidth <= PHONE_WIDTH;

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: LoginPage(
        toggleTheme: _toggleTheme,
        isPhone: isPhone,
        supabaseManager:
            widget.supabaseManager, // Pass the SupabaseManager to LoginPage
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.toggleTheme,
    required this.isPhone,
    required this.supabaseManager, // Accept SupabaseManager as a parameter
  });

  final VoidCallback toggleTheme;
  final bool isPhone;
  final SupabaseManager supabaseManager; // Declare SupabaseManager as a field

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final user = await widget.supabaseManager.login(email, password);

    if (user != null) {
      print('Login successful: ${user.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainMenu()),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid email or password';
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final user = await widget.supabaseManager.register(email, password);

    if (user != null) {
      print('Registration successful: ${user.email}');
      // Optionally navigate to another screen or provide feedback.
    } else {
      setState(() {
        _errorMessage = 'Registration failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: const Icon(Icons.sunny),
            tooltip: 'Modo Claro / Oscuro',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: widget.isPhone ? _buildPhoneLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Modo: Movil', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Dirección de correo',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Iniciar Sesión'),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Modo: Escritorio',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Dirección de correo',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        // TODO
        // Añadir que cuando se pulse 'Enter' haga lo mismo que este boton de abajo
        //                                                         vvvvvvvvvvvvvv
        ElevatedButton(
          onPressed: _isLoading ? null : _register,
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Iniciar Sesión'),
        ),
      ],
    );
  }
}
