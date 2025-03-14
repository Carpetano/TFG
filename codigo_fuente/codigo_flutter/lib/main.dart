import 'package:codigo_flutter/calendar_page.dart';
import 'package:codigo_flutter/slidable_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gykqibexlzwxpliezelo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3FpYmV4bHp3eHBsaWV6ZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MDUzMDEsImV4cCI6MjA1NzQ4MTMwMX0.MRfnjfhl5A7ZbK_ien8G1OPUmlF-3eqzOmx_EFTQHZk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'This is Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) {
      return; // Ensure widget is still mounted before showing Snackbar
    }

    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _insert(BuildContext context) async {
    final response =
        await Supabase.instance.client.from('test').insert([
          {'id': 1, 'desc': 'Test from flutter'},
        ]).execute();

    if (!context.mounted) {
      return; // Ensure widget is still mounted before showing Snackbar
    }

    if (response.error != null) {
      _showSnackbar(
        context,
        'Error inserting: ${response.error!.message}',
        isError: true,
      );
    } else {
      _showSnackbar(context, 'Data inserted successfully');
    }
  }

  Future<void> _select(BuildContext context) async {
    final response =
        await Supabase.instance.client.from('test').select('*').execute();

    if (!context.mounted) return;

    if (response.error != null) {
      _showSnackbar(
        context,
        'Error fetching: ${response.error!.message}',
        isError: true,
      );
    } else {
      _showSnackbar(context, 'Data fetched successfully');
      print('Data fetched: ${response.data}');
    }
  }

  Future<void> _update(BuildContext context) async {
    final response =
        await Supabase.instance.client
            .from('test')
            .update({'desc': 'Updated from flutter'})
            .eq('id', 1)
            .execute();

    if (!context.mounted) return;

    if (response.error != null) {
      _showSnackbar(
        context,
        'Error updating: ${response.error!.message}',
        isError: true,
      );
    } else {
      _showSnackbar(context, 'Data updated successfully');
    }
  }

  Future<void> _delete(BuildContext context) async {
    final response =
        await Supabase.instance.client
            .from('test')
            .delete()
            .eq('id', 1)
            .execute();

    if (!context.mounted) return;

    if (response.error != null) {
      _showSnackbar(
        context,
        'Error deleting: ${response.error!.message}',
        isError: true,
      );
    } else {
      _showSnackbar(context, 'Data deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              height:
                  MediaQuery.of(context).size.height *
                  0.07, // 7% of screen height
              child: ElevatedButton(
                onPressed: () => _insert(context),
                child: Text("Insert", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                onPressed: () => _select(context),
                child: Text("Select", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                onPressed: () => _update(context),
                child: Text("Update", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                onPressed: () => _delete(context),
                child: Text("Delete", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SlidablePage(title: "Slidable Page"),
                    ),
                  );
                },
                child: Text("Go to New Page"),
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarPage()),
                  );
                },
                child: Text("Go to New Page"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
