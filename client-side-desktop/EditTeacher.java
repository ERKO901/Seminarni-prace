package erko.melonhost;

import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.layout.*;
import javafx.stage.Modality;
import javafx.stage.Stage;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class EditTeacher {
    private String loginToken; // Token for authorization
    private JSONObject teacher; // JSON object containing teacher data
    private Stage dialog; // The dialog for editing

    public EditTeacher(String loginToken, JSONObject teacher) {
        this.loginToken = loginToken;
        this.teacher = teacher;
        System.out.println("Teacher JSON: " + teacher.toString()); // Debugging line
        show(); // Show the edit dialog upon creation
    }

    public void show() {
        // Prevent opening multiple dialogs
        if (dialog != null && dialog.isShowing()) {
            return; // If dialog is already open, do not create a new one
        }

        dialog = new Stage();
        dialog.initModality(Modality.APPLICATION_MODAL); // Block events to other windows
        dialog.setTitle("Edit Teacher");

        // Create a VBox layout for the dialog
        VBox dialogLayout = new VBox(10);
        dialogLayout.setPadding(new Insets(20));
        dialogLayout.setStyle("-fx-background-color: #3C3C3C;"); // Dark background for dialog

        // Input fields for teacher details
        TextField fullnameField = new TextField(teacher.getString("fullname"));
        fullnameField.setPromptText("Full Name");
        fullnameField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;");

        TextField usernameField = new TextField(teacher.getString("username"));
        usernameField.setPromptText("Username");
        usernameField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;");

        TextField emailField = new TextField(teacher.getString("email"));
        emailField.setPromptText("Email");
        emailField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;");

        // Update isAdmin handling
        boolean isAdminValue = teacher.getInt("is_admin") == 1; // Convert integer to boolean

        CheckBox isAdminCheckBox = new CheckBox("Is Administrator");
        isAdminCheckBox.setSelected(isAdminValue); // Set the CheckBox state

        // ListView for subjects
        ListView<CheckBox> subjectsListView = new ListView<>();
        subjectsListView.setPrefHeight(200); // Set height for the ListView

        // Fetch subjects and populate ListView
        fetchSubjects(subjectsListView);

        // Populate assigned subjects from the teacher JSON
        List<String> assignedSubjects = getAssignedSubjects(); // Fetch assigned subjects

        // Check the relevant CheckBoxes in the ListView based on assigned subjects
        for (String subjectName : assignedSubjects) {
            for (CheckBox checkBox : subjectsListView.getItems()) {
                if (checkBox.getText().equals(subjectName)) {
                    checkBox.setSelected(true); // Mark the subject as selected if assigned
                }
            }
        }

        // Create a button to save changes
        Button saveButton = new Button("Save Changes");
        saveButton.setOnAction(e -> saveChanges(
                fullnameField.getText(),
                usernameField.getText(),
                emailField.getText(),
                isAdminCheckBox.isSelected(), // Get the admin status from checkbox
                subjectsListView // Pass the subjects ListView
        ));

        // Add components to the dialog layout
        dialogLayout.getChildren().addAll(fullnameField, usernameField, emailField, isAdminCheckBox, subjectsListView, saveButton);

        // Set the Scene for the dialog and show it
        Scene dialogScene = new Scene(dialogLayout, 400, 400);
        dialog.setScene(dialogScene);
        dialog.show();
    }

    private void fetchSubjects(ListView<CheckBox> subjectsListView) {
        try {
            // Create URL to fetch the subjects
            URL url = new URL("http://carrot.melonhost.cz:25591/api/subjects");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken); // Set the token in the header

            // Read response
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder response = new StringBuilder();
            String inputLine;

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            // Parse JSON response
            JSONArray subjects = new JSONArray(response.toString());

            for (int i = 0; i < subjects.length(); i++) {
                JSONObject subject = subjects.getJSONObject(i);
                String subjectName = subject.getString("subject_name");

                // Create a CheckBox for each subject
                CheckBox checkBox = new CheckBox(subjectName);
                subjectsListView.getItems().add(checkBox); // Add CheckBox to ListView
            }
        } catch (Exception e) {
            e.printStackTrace();
            displayError("Error fetching subjects.");
        }
    }

    private List<String> getAssignedSubjects() {
        List<String> assignedSubjects = new ArrayList<>();
        if (teacher.has("subjects")) {
            Object subjectsObject = teacher.get("subjects"); // Get the subjects object

            // Check if it's a JSONArray
            if (subjectsObject instanceof JSONArray) {
                JSONArray subjectsArray = (JSONArray) subjectsObject;
                for (int i = 0; i < subjectsArray.length(); i++) {
                    assignedSubjects.add(subjectsArray.getString(i)); // Add each subject from the array
                }
            } else if (subjectsObject instanceof String) {
                // If it's a single string, split it by commas
                String subjectsString = (String) subjectsObject;
                String[] subjectsArray = subjectsString.split(",\\s*"); // Split by comma and optional space
                for (String subject : subjectsArray) {
                    assignedSubjects.add(subject); // Add to the list
                }
            }
        }
        return assignedSubjects; // Return the list of assigned subjects
    }

    private void saveChanges(String fullname, String username, String email, boolean isAdmin, ListView<CheckBox> subjectsListView) {
        try {
            // Create URL to update teacher information
            URL url = new URL("http://carrot.melonhost.cz:25591/api/teachers/edit/" + teacher.getInt("id"));
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("PUT");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // Create JSON object for the updated teacher
            JSONObject updatedTeacher = new JSONObject();
            updatedTeacher.put("fullname", fullname);
            updatedTeacher.put("username", username);
            updatedTeacher.put("email", email);
            updatedTeacher.put("is_admin", isAdmin); // Include the isAdmin status

            // Log the updatedTeacher JSON for debugging
            System.out.println("Updated Teacher JSON: " + updatedTeacher.toString());

            // Create a JSONArray for subjects as an array of strings
            JSONArray subjectsArray = new JSONArray(getSelectedSubjects(subjectsListView));
            updatedTeacher.put("subjects", subjectsArray); // Add subjects as a JSON array

            // Send JSON data
            OutputStream os = conn.getOutputStream();
            os.write(updatedTeacher.toString().getBytes());
            os.flush();
            os.close();

            // Check response code
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                dialog.close(); // Close the dialog
            } else {
                // Read the error message from the server
                StringBuilder errorResponse = new StringBuilder();
                BufferedReader errorReader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
                String errorLine;
                while ((errorLine = errorReader.readLine()) != null) {
                    errorResponse.append(errorLine);
                }
                errorReader.close();

                // Show error message from the server
                Alert alert = new Alert(AlertType.ERROR);
                alert.setTitle("Error");
                alert.setHeaderText(null);
                alert.setContentText("Failed to update teacher. Response: " + errorResponse.toString());
                alert.showAndWait();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Show error message
            Alert alert = new Alert(AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("Error updating teacher: " + e.getMessage());
            alert.showAndWait();
        }
    }

    private List<String> getSelectedSubjects(ListView<CheckBox> subjectsListView) {
        List<String> selectedSubjects = new ArrayList<>();
        for (CheckBox checkBox : subjectsListView.getItems()) {
            if (checkBox.isSelected()) {
                selectedSubjects.add(checkBox.getText()); // Ensure this is just the subject name
            }
        }
        return selectedSubjects;
    }

    private void displayError(String message) {
        Alert alert = new Alert(AlertType.ERROR);
        alert.setTitle("Error");
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
