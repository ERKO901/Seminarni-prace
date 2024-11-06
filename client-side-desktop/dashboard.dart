import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'subjects.dart'; // Import the SubjectsPage
import 'teachers.dart'; // Import the TeachersPage
import 'main.dart'; // Import LoginPage for logout functionality

class DashboardPage extends StatefulWidget {
  final String token;

  DashboardPage({required this.token});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late String name = 'Loading...';
  bool isAdmin = false;
  bool showSubjects = false; // Controls visibility of Subjects page
  bool showTeachers = false; // Controls visibility of Teachers page

  @override
  void initState() {
    super.initState();
    fetchName(); // Fetch the name and admin status on init
  }

  Future<void> fetchName() async {
    try {
      final response = await http.get(
        Uri.parse('https://magistri.melonhost.cz/api/teachers/get-name'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          name = jsonResponse['name'];
          isAdmin = jsonResponse['is_admin'] == 1; // Check if the user is admin
        });
      } else {
        setState(() {
          name = 'Error fetching name';
        });
      }
    } catch (e) {
      setState(() {
        name = 'Error fetching name';
      });
    }
  }

  void logout() {
    // Navigate back to the login screen and clear credentials
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  void showSection(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Showing $section')),
    );
  }

  void toggleSubjects() {
    setState(() {
      showSubjects = true;
      showTeachers = false; // Ensure only one section is visible at a time
    });
  }

  void toggleTeachers() {
    setState(() {
      showTeachers = true;
      showSubjects = false; // Ensure only one section is visible at a time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gymnázium Kladno | Dashboard'),
        automaticallyImplyLeading: false, // Prevents back arrow from showing
      ),
      body: Row(
        children: [
          // Sidebar for navigation
          Container(
            width: 200,
            color: Color(0xFFF9F9F9),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('images/logo.png', width: 220),
                SizedBox(height: 10),
                Text(
                  'Magistři',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                SizedBox(height: 20),
                Text(
                  name,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE74C3C),
                    minimumSize: Size(150, 40),
                  ),
                  onPressed: logout, // Logout functionality
                  child: Text('Odhlásit se'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (!showSubjects && !showTeachers) ...[
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.start,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: () => showSection('Studenti'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('images/students.png', width: 80),
                              SizedBox(height: 10),
                              Text('Studenti'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: () => showSection('Rozvrhy'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('images/timetable.png', width: 80),
                              SizedBox(height: 10),
                              Text('Rozvrhy'),
                            ],
                          ),
                        ),
                        if (isAdmin) ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: toggleSubjects, // Toggle subjects view
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/subjects.png', width: 80),
                                SizedBox(height: 10),
                                Text('Předměty'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: toggleTeachers, // Toggle teachers view
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/teachers.png', width: 80),
                                SizedBox(height: 10),
                                Text('Učitelé'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else if (showSubjects) ...[
                    Expanded(
                      child: SubjectsPage(token: widget.token),
                    ),
                  ] else if (showTeachers) ...[
                    Expanded(
                      child: TeachersPage(token: widget.token),
                    ),
                  ],
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
