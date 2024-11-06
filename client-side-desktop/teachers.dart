import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart'; // Import DashboardPage for navigation

class TeachersPage extends StatefulWidget {
  final String token;

  TeachersPage({required this.token});

  @override
  _TeachersPageState createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  late Future<List<Teacher>> teachers;
  late Future<List<String>> subjects;

  @override
  void initState() {
    super.initState();
    teachers = fetchTeachers();
    subjects = fetchSubjects();
  }

  Future<List<Teacher>> fetchTeachers() async {
    final response = await http.get(
      Uri.parse('https://magistri.melonhost.cz/api/teachers/all'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Teacher.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load teachers');
    }
  }

  Future<List<String>> fetchSubjects() async {
    final response = await http.get(
      Uri.parse('https://magistri.melonhost.cz/api/subjects'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<String>.from(data.map((json) => json['subject_name']));
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<void> deleteTeacher(int id) async {
    final response = await http.delete(
      Uri.parse('https://magistri.melonhost.cz/api/teachers/delete/$id'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        teachers = fetchTeachers(); // Refresh teacher list
      });
    } else {
      showErrorDialog('Failed to delete teacher');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Potvrdit odstranění'),
        content: Text('Opravdu chcete odstranit tohoto učitele?'),
        actions: [
          TextButton(
            onPressed: () {
              deleteTeacher(id);
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Odstranit'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel action
            child: Text('Zrušit'),
          ),
        ],
      ),
    );
  }

  void openCreateTeacherDialog() {
    TextEditingController _fullnameController = TextEditingController();
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    bool isAdmin = false;
    List<String> selectedSubjects = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Přidat učitele'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _fullnameController,
                      decoration: InputDecoration(labelText: 'Celé jméno'),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Uživatelské jméno'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Heslo'),
                      obscureText: true,
                    ),
                    CheckboxListTile(
                      title: Text('Is Administrator'),
                      value: isAdmin,
                      onChanged: (value) {
                        setDialogState(() {
                          isAdmin = value ?? false;
                        });
                      },
                    ),
                    FutureBuilder<List<String>>(
                      future: subjects,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Column(
                            children: snapshot.data!.map((subject) {
                              return CheckboxListTile(
                                title: Text(subject),
                                value: selectedSubjects.contains(subject),
                                onChanged: (checked) {
                                  setDialogState(() {
                                    if (checked == true) {
                                      selectedSubjects.add(subject);
                                    } else {
                                      selectedSubjects.remove(subject);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        } else {
                          return Center(child: Text('No subjects available'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Zrušit'),
                ),
                TextButton(
                  onPressed: () async {
                    await createTeacher(
                      fullname: _fullnameController.text,
                      username: _usernameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      isAdmin: isAdmin,
                      subjects: selectedSubjects,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Přidat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> createTeacher({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required bool isAdmin,
    required List<String> subjects,
  }) async {
    final response = await http.post(
      Uri.parse('https://magistri.melonhost.cz/api/teachers/create'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullname': fullname,
        'username': username,
        'email': email,
        'password': password,
        'is_admin': isAdmin,
        'subjects': subjects,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        teachers = fetchTeachers(); // Refresh teacher list
      });
    } else {
      showErrorDialog('Failed to create teacher');
    }
  }

  void openEditTeacherDialog(Teacher teacher) {
    // Prefill the controllers with the current teacher's details
    TextEditingController _fullnameController = TextEditingController(text: teacher.fullname);
    TextEditingController _usernameController = TextEditingController(text: teacher.username); // Prefill username
    TextEditingController _emailController = TextEditingController(text: teacher.email); // Prefill email
    bool isAdmin = teacher.isAdmin; // Prefill isAdmin status
    List<String> selectedSubjects = List<String>.from(teacher.subjects); // Prefill subjects if needed

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Upravit učitele'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _fullnameController,
                      decoration: InputDecoration(labelText: 'Celé jméno'),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Uživatelské jméno'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    CheckboxListTile(
                      title: Text('Is Administrator'),
                      value: isAdmin,
                      onChanged: (value) {
                        setDialogState(() {
                          isAdmin = value ?? false;
                        });
                      },
                    ),
                    // You can add a subject selection like in the creation dialog
                    FutureBuilder<List<String>>(
                      future: subjects,  // Fetch subjects if necessary
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Column(
                            children: snapshot.data!.map((subject) {
                              return CheckboxListTile(
                                title: Text(subject),
                                value: selectedSubjects.contains(subject),
                                onChanged: (checked) {
                                  setDialogState(() {
                                    if (checked == true) {
                                      selectedSubjects.add(subject);
                                    } else {
                                      selectedSubjects.remove(subject);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        } else {
                          return Center(child: Text('No subjects available'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Zrušit'),
                ),
                TextButton(
                  onPressed: () async {
                    // Call updateTeacher with the updated values
                    await updateTeacher(
                      teacher.id,
                      fullname: _fullnameController.text,
                      username: _usernameController.text,
                      email: _emailController.text,
                      isAdmin: isAdmin,
                      subjects: selectedSubjects,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Uložit'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Učitelé"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage(token: widget.token)),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: openCreateTeacherDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<Teacher>>(
        future: teachers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final teacher = snapshot.data![index];
                return ListTile(
                  title: Text(teacher.fullname),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openEditTeacherDialog(teacher),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDeleteConfirmationDialog(teacher.id),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No teachers available'));
          }
        },
      ),
    );
  }
  Future<void> updateTeacher(
      int id, {
        required String fullname,
        required String username,
        required String email,
        required bool isAdmin,  // Make sure it's a bool
        required List<String> subjects,
      }) async {
    final response = await http.put(
      Uri.parse('https://magistri.melonhost.cz/api/teachers/edit/$id'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullname': fullname,
        'username': username,
        'email': email,
        'is_admin': isAdmin,  // Ensure it's a boolean value (true/false)
        'subjects': subjects,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        teachers = fetchTeachers(); // Refresh the list of teachers
      });
    } else {
      showErrorDialog('Failed to update teacher');
    }
  }




}

class Teacher {
  final int id;
  final String fullname;
  final String username;
  final String email;
  final List<String> subjects;
  final bool isAdmin;

  Teacher({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.subjects,
    required this.isAdmin,
  });

  // Factory method to create a Teacher object from JSON
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      fullname: json['fullname'],
      username: json['username'],
      email: json['email'],
      subjects: json['subjects'] != null && json['subjects'].isNotEmpty
          ? List<String>.from(json['subjects'].split(', '))
          : [], // Default to empty list if subjects is null or empty
      isAdmin: json['is_admin'] == true, // Convert is_admin to a boolean
    );
  }

  // Method to convert Teacher object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username,
      'email': email,
      'subjects': subjects.join(', '), // Join the list of subjects into a string
      'is_admin': isAdmin, // Ensure this is passed as a boolean
    };
  }
}
