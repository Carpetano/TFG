import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlidablePage extends StatefulWidget {
  final String title;

  const SlidablePage({super.key, required this.title});

  @override
  _SlidablePageState createState() => _SlidablePageState();
}

class _SlidablePageState extends State<SlidablePage> {
  List<dynamic> tests = [];
  bool isLoading = true; // Flag to indicate loading state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data from Supabase
  Future<void> _fetchData() async {
    final response =
        await Supabase.instance.client.from('test').select('*').execute();

    if (response.error == null) {
      setState(() {
        tests = response.data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: ${response.error!.message}'),
        ),
      );
    }
  }

  // Delete data from Supabase
  Future<void> _deleteData(int id) async {
    final response =
        await Supabase.instance.client
            .from('test')
            .delete()
            .eq('id', id)
            .execute();

    if (response.error == null) {
      setState(() {
        tests.removeWhere((test) => test['id'] == id);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: ${response.error!.message}'),
        ),
      );
    }
  }

  // Placeholder for edit action
  void _editData(int id) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit button clicked for ID: $id')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : tests.isEmpty
              ? const Center(child: Text("No data found"))
              : ListView.builder(
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return Slidable(
                    key: ValueKey(test['id']),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _editData(test['id']),
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        SlidableAction(
                          onPressed: (context) => _deleteData(test['id']),
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(test['desc'] ?? 'No description'),
                      subtitle: Text('ID: ${test['id']}'),
                    ),
                  );
                },
              ),
    );
  }
}
