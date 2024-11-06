import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart'; // Import DashboardPage for navigation

class SubjectsPage extends StatefulWidget {
  final String token; // Token for authorization

  SubjectsPage({required this.token});

  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  late List<dynamic> subjects = [];
  late String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(
        Uri.parse("http://carrot.melonhost.cz:25591/api/subjects"),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Use token here
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          subjects = jsonDecode(response.body);
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = "Error fetching subjects.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching subjects: ${e.toString()}";
      });
    }
  }

  void confirmDeleteSubject(int subjectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Odstranit předmět"),
          content: Text("Opravdu chcete odstranit tento předmět?"),
          actions: [
            TextButton(
              child: Text("Zrušit"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Odstranit"),
              onPressed: () {
                deleteSubject(subjectId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteSubject(int subjectId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://carrot.melonhost.cz:25591/api/subjects/$subjectId"),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Use token here
        },
      );

      if (response.statusCode == 200) {
        fetchSubjects(); // Refresh the subjects list
      } else {
        showError("Failed to delete subject.");
      }
    } catch (e) {
      showError("Error deleting subject: ${e.toString()}");
    }
  }

  void openCreateSubjectDialog() {
    TextEditingController subjectNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Vytvořit předmět"),
          content: TextField(
            controller: subjectNameController,
            decoration: InputDecoration(hintText: "Jméno předmětu"),
          ),
          actions: [
            TextButton(
              child: Text("Zrušit"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Vytvořit"),
              onPressed: () {
                createSubject(subjectNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createSubject(String subjectName) async {
    if (subjectName.isEmpty) {
      showError("Subject name cannot be empty.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://carrot.melonhost.cz:25591/api/subjects"),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Use token here
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"subject_name": subjectName}),
      );

      if (response.statusCode == 201) {
        fetchSubjects(); // Refresh subjects list
      } else {
        showError("Failed to create subject.");
      }
    } catch (e) {
      showError("Error creating subject: ${e.toString()}");
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Předměty"),
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
            onPressed: openCreateSubjectDialog,
          ),
        ],
      ),
      body: subjects.isNotEmpty
          ? ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return ListTile(
            title: Text(subject['subject_name']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => confirmDeleteSubject(subject['id']),
            ),
          );
        },
      )
          : Center(
        child: Text(errorMessage.isNotEmpty ? errorMessage : "No subjects found."),
      ),
    );
  }
}
