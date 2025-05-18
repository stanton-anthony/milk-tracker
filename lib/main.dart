import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Eddie\'s Milk Tracker'),
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
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isFeeding = true; // true = feeding, false = diaper
  bool _isPoopy = false; // for diaper
  double _amount = 2.0; // for feeding

  void _onTimeChanged(TimeOfDay? newTime) {
    if (newTime != null) {
      setState(() {
        _selectedTime = newTime;
      });
    }
  }

  void _onDateChanged(DateTime? newDate) {
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _onDateChanged(picked);
    }
  }

  Future<void> _saveLog() async {
    if (!_isFeeding) {
      // Diaper log
      await _saveDiaperLog(isPoopy: _isPoopy);
      return;
    }
    // Feeding log
    final logDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    try {
      await FirebaseFirestore.instance.collection('feed_logs').add({
        'feed_time': logDateTime,
        'amount': _amount,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Feed time saved: \n${logDateTime.toLocal().toString().split('.')[0]}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save log: $e')),
      );
    }
  }

  Future<void> _saveDiaperLog({required bool isPoopy}) async {
    final logDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    try {
      await FirebaseFirestore.instance.collection('diaper_logs').add({
        'diaper_time': logDateTime,
        'poopy': isPoopy,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Diaper change saved: ${logDateTime.toLocal().toString().split('.')[0]}${isPoopy ? " (poopy)" : ""}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save log: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_drink),
            tooltip: 'View Feed Logs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedLogsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.baby_changing_station),
            tooltip: 'View Diaper Logs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DiaperLogsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              // Remove extra bottom padding
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 32),
                  // Toggle for Feeding/Diaper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Feeding'),
                        selected: _isFeeding,
                        onSelected: (selected) {
                          setState(() {
                            _isFeeding = true;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Diaper'),
                        selected: !_isFeeding,
                        onSelected: (selected) {
                          setState(() {
                            _isFeeding = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text('Change Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TimePickerSpinner(
                    is24HourMode: false,
                    isForce2Digits: true,
                    normalTextStyle: Theme.of(context).textTheme.bodyLarge!,
                    highlightedTextStyle: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                    spacing: 30,
                    itemHeight: 50,
                    time: DateTime(
                        0, 0, 0, _selectedTime.hour, _selectedTime.minute),
                    onTimeChange: (dateTime) {
                      setState(() {
                        _selectedTime = TimeOfDay(
                            hour: dateTime.hour, minute: dateTime.minute);
                      });
                    },
                    minutesInterval: 1,
                  ),
                  const SizedBox(height: 16),
                  if (!_isFeeding)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: _isPoopy,
                          onChanged: (val) {
                            setState(() {
                              _isPoopy = val;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text('Poopy?'),
                      ],
                    ),
                  if (_isFeeding)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Amount (oz)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _amount = double.tryParse(val) ?? 0.0;
                              });
                            },
                            controller:
                                TextEditingController(text: _amount.toString()),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      // Move the Save button outside the scroll view and stack, and use bottomNavigationBar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ElevatedButton(
          onPressed: _saveLog,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Save'),
        ),
      ),
    );
  }
}

typedef DocumentSnapshot = QueryDocumentSnapshot<Map<String, dynamic>>;

class FeedLogsScreen extends StatelessWidget {
  const FeedLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Logs'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('feed_logs')
            .orderBy('feed_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No logs found.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final feedTime = (doc['feed_time'] as Timestamp).toDate();
              final amount = doc['amount'];
              return ListTile(
                leading: const Icon(Icons.local_drink),
                title: Text(
                  TimeOfDay.fromDateTime(feedTime).format(context),
                ),
                subtitle: Text(
                    '${feedTime.month.toString().padLeft(2, '0')}-${feedTime.day.toString().padLeft(2, '0')} \n$amount oz'),
              );
            },
          );
        },
      ),
    );
  }
}

class DiaperLogsScreen extends StatelessWidget {
  const DiaperLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diaper Logs'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('diaper_logs')
            .orderBy('diaper_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \n${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No diaper logs found.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final diaperTime = (doc['diaper_time'] as Timestamp).toDate();
              final poopy = doc['poopy'] == true;
              return ListTile(
                leading: Icon(poopy
                    ? Icons.airline_seat_recline_normal_rounded
                    : Icons.auto_fix_normal),
                title: Text(
                  TimeOfDay.fromDateTime(diaperTime).format(context),
                ),
                subtitle: Text(
                  '${diaperTime.month.toString().padLeft(2, '0')}-${diaperTime.day.toString().padLeft(2, '0')}${poopy ? '\nPoopy' : '\nPee'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
