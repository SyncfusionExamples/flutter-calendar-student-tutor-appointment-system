import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const AppointmentSystem(),
    );
  }
}

class AppointmentSystem extends StatefulWidget {
  const AppointmentSystem({super.key});
  @override
  AppointmentSystemState createState() => AppointmentSystemState();
}

class AppointmentSystemState extends State<AppointmentSystem> {
  List<AppointmentRequest> pendingRequests = [];
  List<Appointment> appointments = [];
  final List<String> _rejectedRequests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment System'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(child: _buildStudentCalendar()),
          const VerticalDivider(thickness: 1),
          Expanded(child: _buildTutorCalendar()),
        ],
      ),
    );
  }

  Widget _buildCalendar(Color headerColor) {
    return SizedBox(
      height: 300,
      child: SfCalendar(
        view: CalendarView.month,
        dataSource: _AppointmentDataSource(appointments),
        headerStyle: CalendarHeaderStyle(
          backgroundColor: headerColor,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCalendar() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Student Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildCalendar(Colors.blueAccent),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text(
            'Request Appointment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          onPressed: () => _showRequestDialog(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            backgroundColor: Colors.blueAccent,
          ),
        ),
        if (_rejectedRequests.isNotEmpty) _buildRejectedRequests(),
      ],
    );
  }

  Widget _buildTutorCalendar() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Tutor Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildCalendar(Colors.deepPurple),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Pending Appointment Requests:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              var request = pendingRequests[index];
              return Card(
                child: ListTile(
                  title: Text('Request from ${request.studentName}'),
                  subtitle: Text('Time: ${request.startTime}'),
                  trailing: _buildRequestActions(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestActions(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => _acceptAppointment(index),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _rejectAppointment(index),
        ),
      ],
    );
  }

  void _acceptAppointment(int index) {
    setState(() {
      var request = pendingRequests[index];
      var acceptedAppointment = Appointment(
        startTime: request.startTime,
        endTime: request.startTime.add(const Duration(minutes: 30)),
        subject: '${request.studentName} - Accepted',
        color: Colors.green,
      );
      appointments.add(acceptedAppointment);
      pendingRequests.removeAt(index);
    });
  }

  void _rejectAppointment(int index) {
    setState(() {
      var request = pendingRequests[index];
      _rejectedRequests.add(request.studentName);
      pendingRequests.removeAt(index);
    });
  }

  void _showRequestDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime selectedTime = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Pick Date & Time'),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    selectedTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _requestAppointment(nameController.text, selectedTime);
              }
              Navigator.pop(context);
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _requestAppointment(String studentName, DateTime startTime) {
    setState(() {
      pendingRequests.add(AppointmentRequest(studentName, startTime, false));
    });
  }

  Widget _buildRejectedRequests() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent, width: 1.5),
          ),
          child: const Text(
            'Rejected Request:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        ..._rejectedRequests
            .map((name) => Text('Request from $name was rejected.'))
            .toList(),
      ],
    );
  }
}

class AppointmentRequest {
  String studentName;
  DateTime startTime;
  bool isAccepted;
  AppointmentRequest(
    this.studentName,
    this.startTime,
    this.isAccepted,
  );
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
