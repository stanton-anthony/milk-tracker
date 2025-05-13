import 'package:flutter/material.dart';

void main() {
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _logs = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

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

  void _saveLog() {
    final logDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final log =
        'Saved at ${DateTime.now().toLocal().toString().split('.')[0]} - Feed: ${logDateTime.toLocal().toString().split('.')[0]}';
    setState(() {
      _logs.insert(0, log);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Feed time saved: ${logDateTime.toLocal().toString().split('.')[0]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Date: ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
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
              Text(
                'Select Time:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TimePickerSpinner(
                time: TimeOfDay(
                    hour: _selectedTime.hour, minute: _selectedTime.minute),
                onTimeChange: _onTimeChanged,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveLog,
                child: const Text('Save'),
              ),
              const SizedBox(height: 24),
              if (_logs.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logs:',
                        style: Theme.of(context).textTheme.titleMedium),
                    ..._logs.map((log) => Text(log)).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TimePickerSpinner extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay?> onTimeChange;

  const TimePickerSpinner(
      {Key? key, required this.time, required this.onTimeChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: hour12,
          items: List.generate(
              12,
              (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text((index + 1).toString().padLeft(2, '0')),
                  )),
          onChanged: (hour) {
            if (hour != null) {
              int hour24 = period == 'AM'
                  ? (hour == 12 ? 0 : hour)
                  : (hour == 12 ? 12 : hour + 12);
              onTimeChange(TimeOfDay(hour: hour24, minute: time.minute));
            }
          },
        ),
        const Text(' : '),
        DropdownButton<int>(
          value: time.minute,
          items: List.generate(
              60,
              (index) => DropdownMenuItem(
                    value: index,
                    child: Text(index.toString().padLeft(2, '0')),
                  )),
          onChanged: (minute) {
            if (minute != null) {
              onTimeChange(TimeOfDay(hour: time.hour, minute: minute));
            }
          },
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: period,
          items: ['AM', 'PM']
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p),
                  ))
              .toList(),
          onChanged: (newPeriod) {
            if (newPeriod != null) {
              int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
              int hour24 = newPeriod == 'AM'
                  ? (hour12 == 12 ? 0 : hour12)
                  : (hour12 == 12 ? 12 : hour12 + 12);
              onTimeChange(TimeOfDay(hour: hour24, minute: time.minute));
            }
          },
        ),
      ],
    );
  }
}
