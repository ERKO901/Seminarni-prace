package erko.melonhost;

import javafx.animation.PauseTransition;
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
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.util.Duration;


public class Teachers {
    private String loginToken; // Token for authorization
    private VBox contentArea; // Area to display teachers

    public Teachers(String loginToken, VBox contentArea) {
        this.loginToken = loginToken;
        this.contentArea = contentArea;

        // Fetch and display teachers initially
        fetchTeachers();
    }

    private void fetchTeachers() {
        try {
            // Create URL to fetch the teachers
            URL url = new URL("http://carrot.melonhost.cz:25591/api/teachers/all");
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
            JSONArray jsonResponse = new JSONArray(response.toString());
            displayTeachers(jsonResponse); // Call method to display teachers
        } catch (Exception e) {
            e.printStackTrace();
            // Handle error appropriately
            displayError("Error fetching teachers.");
        }
    }

    private void displayTeachers(JSONArray teachers) {
        // Clear existing content before displaying teachers
        contentArea.getChildren().clear();

        // Create an HBox for the header that will contain the back button and any other header items
        HBox header = new HBox();
        header.setSpacing(10); // Spacing between items in the header
        header.setPadding(new Insets(10)); // Padding around the header

        // Create back button to redirect to the dashboard
        Button backButton = createStyledButton("Zpět");
        backButton.setOnAction(e -> redirectToDashboard((Stage) contentArea.getScene().getWindow())); // Pass the current stage

        // Add a spacer to push the back button to the right
        Region spacer = new Region();
        HBox.setHgrow(spacer, Priority.ALWAYS); // Allow spacer to take all available horizontal space

        // Add spacer and back button to the header
        header.getChildren().addAll(spacer, backButton);

        // Create a ListView to display teachers
        ListView<HBox> teachersListView = new ListView<>();
        teachersListView.setStyle("-fx-background-color: #e1e1e1;"); // Set dark background for ListView

        // Set cell factory for ListView to ensure items have dark theme
        teachersListView.setCellFactory(lv -> new ListCell<HBox>() {
            @Override
            protected void updateItem(HBox item, boolean empty) {
                super.updateItem(item, empty);
                if (empty || item == null) {
                    setText(null);
                    setStyle("-fx-background-color: #e1e1e1;"); // Dark background for each cell
                } else {
                    setGraphic(item);
                    setStyle("-fx-background-color: #e1e1e1;"); // Dark background for each cell
                }
            }
        });

        // Populate ListView with teacher names, edit, and delete buttons
        for (int i = 0; i < teachers.length(); i++) {
            JSONObject teacher = teachers.getJSONObject(i);
            String teacherName = teacher.getString("fullname");

            // Create HBox to hold teacher name, edit, and delete buttons
            HBox teacherBox = new HBox();
            teacherBox.setSpacing(10); // Spacing between elements

            Label teacherLabel = new Label(teacherName);
            teacherLabel.setStyle("-fx-text-fill: black; -fx-font-size: 16px; -fx-padding: 10px;"); // Larger text for teachers

            // Create Edit button
            Button editButton = new Button("Upravit");
            editButton.setStyle("-fx-background-color: transparent; -fx-text-fill: #FF8C00; -fx-padding: 5px; -fx-opacity: 0.7; -fx-font-size: 14px;"); // Edit button styling
            editButton.setMinHeight(49); // Set minimum height for consistency
            editButton.setOnAction(e -> openEditTeacherDialog(teacher)); // Open Edit dialog

            // Create Delete button
            Button deleteButton = new Button("Smazat");
            deleteButton.setStyle("-fx-background-color: transparent; -fx-text-fill: rgba(177, 30, 30); -fx-padding: 5px; -fx-opacity: 0.7; -fx-font-size: 14px;"); // Adjust padding and font size
            deleteButton.setMinHeight(49); // Set minimum height for consistency
            deleteButton.setOnAction(e -> confirmDeleteTeacher(teacher.getInt("id"))); // Pass teacher ID to delete

            // Add elements to HBox and align buttons to the right
            HBox.setHgrow(teacherLabel, Priority.ALWAYS); // Allow teacher label to take available space
            teacherBox.getChildren().addAll(teacherLabel, editButton, deleteButton); // Add label, edit, and delete buttons to HBox

            teachersListView.getItems().add(teacherBox); // Add HBox to ListView
        }

        // Create button for adding a new teacher at the bottom right
        Button createTeacherButton = createStyledButton("Přidat učitele");
        createTeacherButton.setOnAction(e -> openCreateTeacherDialog());

        // Add the header and ListView to the content area
        contentArea.getChildren().addAll(header, teachersListView, createTeacherButton);
    }

    // Method to open the EditTeacher dialog
    private void openEditTeacherDialog(JSONObject teacher) {
        fetchTeachers(); // Call fetchTeachers() immediately

        // Create a PauseTransition to delay the opening of the edit dialog
        PauseTransition pause = new PauseTransition(Duration.millis(0));
        pause.setOnFinished(event -> {
            EditTeacher editTeacher = new EditTeacher(loginToken, teacher);
            editTeacher.show(); // Show the edit dialog after the delay
        });
        pause.play(); // Start the pause transition
    }




    private void redirectToDashboard(Stage primaryStage) {
        // Clear current content
        contentArea.getChildren().clear();

        // Create a new instance of Dashboard
        Dashboard dashboard = new Dashboard(primaryStage, loginToken);
    }

    private void confirmDeleteTeacher(int teacherId) {
        // Create a confirmation dialog
        Alert alert = new Alert(AlertType.CONFIRMATION);
        alert.setTitle("Delete Teacher");
        alert.setHeaderText("Are you sure you want to delete this teacher?");
        alert.setContentText("This action cannot be undone.");

        alert.showAndWait().ifPresent(response -> {
            if (response == ButtonType.OK) {
                deleteTeacher(teacherId); // Call method to delete the teacher
            }
        });
    }

    private void deleteTeacher(int teacherId) {
        try {
            // Create URL to delete a teacher
            URL url = new URL("http://carrot.melonhost.cz:25591/api/teachers/delete/" + teacherId);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("DELETE");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken); // Set the token in the header

            // Check response code
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Teacher deleted successfully
                fetchTeachers(); // Refresh the teachers list
            } else {
                // Handle error
                Alert alert = new Alert(AlertType.ERROR);
                alert.setTitle("Error");
                alert.setHeaderText(null);
                alert.setContentText("Failed to delete teacher.");
                alert.showAndWait();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Show error message
            Alert alert = new Alert(AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("Error deleting teacher: " + e.getMessage());
            alert.showAndWait();
        }
    }

    private void openCreateTeacherDialog() {
        // Create a new Stage for the dialog
        Stage dialog = new Stage();
        dialog.initModality(Modality.APPLICATION_MODAL); // Block events to other windows
        dialog.setTitle("Create Teacher");

        // Create a VBox layout for the dialog
        VBox dialogLayout = new VBox(10);
        dialogLayout.setPadding(new Insets(20));
        dialogLayout.setStyle("-fx-background-color: #3C3C3C;"); // Dark background for dialog

        // Input fields for teacher details
        TextField fullnameField = new TextField();
        fullnameField.setPromptText("Full Name");
        fullnameField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;"); // Dark background for TextField

        TextField usernameField = new TextField();
        usernameField.setPromptText("Username");
        usernameField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;"); // Dark background for TextField

        TextField emailField = new TextField();
        emailField.setPromptText("Email");
        emailField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;"); // Dark background for TextField

        PasswordField passwordField = new PasswordField(); // Use PasswordField for password entry
        passwordField.setPromptText("Password");
        passwordField.setStyle("-fx-background-color: #2D2D2D; -fx-text-fill: white;"); // Dark background for TextField

        // Checkbox for admin status
        CheckBox isAdminCheckBox = new CheckBox("Is Administrator");
        isAdminCheckBox.setStyle("-fx-text-fill: white;"); // Style for checkbox text

        // ListView for subjects
        ListView<CheckBox> subjectsListView = new ListView<>();
        subjectsListView.setPrefHeight(200); // Set height for the ListView

        // Fetch subjects and populate ListView
        fetchSubjects(subjectsListView);

        // Button to create a new teacher
        Button createButton = new Button("Přidat učitele");
        createButton.setOnAction(e -> createTeacher(
                fullnameField.getText(),
                usernameField.getText(),
                emailField.getText(),
                passwordField.getText(),
                getSelectedSubjects(subjectsListView),
                isAdminCheckBox.isSelected(), // Get the admin status from checkbox
                dialog // Pass the dialog to close it later
        ));

        // Add components to the dialog layout
        dialogLayout.getChildren().addAll(fullnameField, usernameField, emailField, passwordField, isAdminCheckBox, subjectsListView, createButton);

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
            // Handle error appropriately
            displayError("Error fetching subjects.");
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


    private void createTeacher(String fullname, String username, String email, String password, List<String> subjects, boolean isAdmin, Stage dialog) {
        try {
            // Create URL to add a new teacher
            URL url = new URL("http://carrot.melonhost.cz:25591/api/teachers/create");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken); // Set the token in the header
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // Create JSON object for the new teacher
            JSONObject newTeacher = new JSONObject();
            newTeacher.put("fullname", fullname);
            newTeacher.put("username", username);
            newTeacher.put("email", email);
            newTeacher.put("password", password);

            // Create a JSONArray for subjects as an array of strings
            JSONArray subjectsArray = new JSONArray(subjects); // Create a JSONArray directly from the list of subject names
            newTeacher.put("subjects", subjectsArray); // Add subjects as a JSON array

            // Add isAdmin field to the JSON object
            newTeacher.put("is_admin", isAdmin); // Make sure this matches the API's expected field

            // Send JSON data
            OutputStream os = conn.getOutputStream();
            os.write(newTeacher.toString().getBytes());
            os.flush();
            os.close();

            // Check response code
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Teacher created successfully
                dialog.close(); // Close the dialog
                fetchTeachers(); // Refresh the teachers list
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
                alert.setContentText("Failed to create teacher. Response: " + errorResponse.toString());
                alert.showAndWait();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Show error message
            Alert alert = new Alert(AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("Error creating teacher: " + e.getMessage());
            alert.showAndWait();
        }
    }




    private Button createStyledButton(String text) {
        Button button = new Button(text);
        button.setStyle("-fx-background-color: #b4b4b4; -fx-text-fill: black; -fx-padding: 10px 20px; -fx-font-size: 14px; -fx-opacity: 0.8;");
        return button;
    }

    private void displayError(String message) {
        Alert alert = new Alert(AlertType.ERROR);
        alert.setTitle("Error");
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}