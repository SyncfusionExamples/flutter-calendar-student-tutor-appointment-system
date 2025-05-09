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
  final List<AppointmentRequest> _pendingRequests = [];
  final List<Appointment> _appointments = [];
  final List<AppointmentRequest> _rejectedRequests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment System'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.purple,
              ],
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
      height: 450,
      child: SfCalendar(
        view: CalendarView.month,
        dataSource: _AppointmentDataSource(_appointments),
        todayHighlightColor: headerColor,
        headerStyle: CalendarHeaderStyle(
          backgroundColor: headerColor,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        selectionDecoration: BoxDecoration(
          border: Border.all(
            color: headerColor,
            width: 2,
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
              color: Colors.white,
            ),
          ),
          onPressed: () => _showRequestDialog(context),
          style: ElevatedButton.styleFrom(
            iconColor: Colors.white,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Tutor Calendar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCalendar(Colors.deepPurple),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Pending Appointment Requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _pendingRequests.length,
            itemBuilder: (context, index) {
              var request = _pendingRequests[index];
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
      var request = _pendingRequests[index];
      var acceptedAppointment = Appointment(
        startTime: request.startTime,
        endTime: request.startTime.add(const Duration(minutes: 30)),
        subject: '${request.studentName} - Accepted',
        color: Colors.green,
      );
      _appointments.add(acceptedAppointment);
      _pendingRequests.removeAt(index);
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
                Navigator.pop(context);
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _requestAppointment(String studentName, DateTime startTime) {
    setState(() {
      _pendingRequests.add(
        AppointmentRequest(
          studentName,
          startTime,
          false,
        ),
      );
    });
  }

  Widget _buildRejectedRequests() {
    return Expanded(
      child: ListView.builder(
        itemCount: _rejectedRequests.length,
        itemBuilder: (context, index) {
          var request = _rejectedRequests[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 12,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              title: Text(
                'Request from ${request.studentName} at: ${request.startTime}',
              ),
              subtitle: Text(
                'Reason: ${request.rejectionReason}',
                style: const TextStyle(color: Colors.red),
              ),
              trailing: const Text('Rejected'),
            ),
          );
        },
      ),
    );
  }

  void _rejectAppointment(int index) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please enter the reason for rejecting this appointment:'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'Enter reason here'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                setState(() {
                  var request = _pendingRequests[index];
                  request.rejectionReason = reasonController.text;
                  _rejectedRequests.add(request);
                  _pendingRequests.removeAt(index);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class AppointmentRequest {
  String studentName;
  DateTime startTime;
  bool isAccepted;
  String? rejectionReason;

  AppointmentRequest(
    this.studentName,
    this.startTime,
    this.isAccepted, {
    this.rejectionReason,
  });
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
