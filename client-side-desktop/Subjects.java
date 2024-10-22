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

public class Subjects {
    private String loginToken; // Token for authorization
    private VBox contentArea; // Area to display subjects

    public Subjects(String loginToken, VBox contentArea) {
        this.loginToken = loginToken;
        this.contentArea = contentArea;

        // Fetch and display subjects initially
        fetchSubjects();
    }

    private void fetchSubjects() {
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
            JSONArray jsonResponse = new JSONArray(response.toString());
            displaySubjects(jsonResponse); // Call method to display subjects
        } catch (Exception e) {
            e.printStackTrace();
            // Handle error appropriately
            displayError("Error fetching subjects.");
        }
    }

    private void displaySubjects(JSONArray subjects) {
        // Clear existing content before displaying subjects
        contentArea.getChildren().clear();

        // Create an HBox for the header that will contain the back button and any other header items
        HBox header = new HBox();
        header.setSpacing(10); // Spacing between items in the header
        header.setPadding(new Insets(10)); // Padding around the header

        // Create back button to redirect to the dashboard
        Button backButton = createStyledButton("Back to Dashboard");
        backButton.setOnAction(e -> redirectToDashboard((Stage) contentArea.getScene().getWindow())); // Pass the current stage

        // Add a spacer to push the back button to the right
        Region spacer = new Region();
        HBox.setHgrow(spacer, Priority.ALWAYS); // Allow spacer to take all available horizontal space

        // Add spacer and back button to the header
        header.getChildren().addAll(spacer, backButton);

        // Create a ListView to display subjects
        ListView<HBox> subjectsListView = new ListView<>();
        subjectsListView.setStyle("-fx-background-color: #F9F9F9; -fx-border-color: #E0E0E0;"); // Light background for ListView with soft border

        // Set cell factory for ListView to ensure items have light theme
        subjectsListView.setCellFactory(lv -> new ListCell<HBox>() {
            @Override
            protected void updateItem(HBox item, boolean empty) {
                super.updateItem(item, empty);
                if (empty || item == null) {
                    setText(null);
                    setStyle("-fx-background-color: #F9F9F9;"); // Light background for each cell
                } else {
                    setGraphic(item);
                    setStyle("-fx-background-color: #FFFFFF; -fx-border-color: #E0E0E0;"); // Light background with subtle border
                }
            }
        });

        // Populate ListView with subject names and delete buttons
        for (int i = 0; i < subjects.length(); i++) {
            JSONObject subject = subjects.getJSONObject(i);
            String subjectName = subject.getString("subject_name");

            // Create HBox to hold subject name and delete button
            HBox subjectBox = new HBox();
            subjectBox.setSpacing(10); // Spacing between elements

            Label subjectLabel = new Label(subjectName);
            subjectLabel.setStyle("-fx-text-fill: #333333; -fx-font-size: 16px; -fx-padding: 10px;"); // Darker text for subject names

            Button deleteButton = new Button("Delete");
            deleteButton.setStyle("-fx-background-color: transparent; -fx-text-fill: #FF5E57; -fx-padding: 5px; -fx-font-size: 14px; -fx-opacity: 0.9;"); // Light button with soft red text
            deleteButton.setMinHeight(49); // Set minimum height for consistency
            deleteButton.setOnAction(e -> confirmDeleteSubject(subject.getInt("id"))); // Pass subject ID to delete

            // Add elements to HBox and align delete button to the right
            HBox.setHgrow(subjectLabel, Priority.ALWAYS); // Allow subject label to take available space
            subjectBox.getChildren().addAll(subjectLabel, deleteButton); // Add label and button to HBox

            subjectsListView.getItems().add(subjectBox); // Add HBox to ListView
        }

        // Create button for adding a new subject at the bottom right
        Button createSubjectButton = createStyledButton("Create Subject");
        createSubjectButton.setOnAction(e -> openCreateSubjectDialog());

        // Add the header and ListView to the content area
        contentArea.getChildren().addAll(header, subjectsListView, createSubjectButton);
    }

    private void redirectToDashboard(Stage primaryStage) {
        // Clear current content
        contentArea.getChildren().clear();

        // Create a new instance of Dashboard
        Dashboard dashboard = new Dashboard(primaryStage, loginToken);
    }

    private void confirmDeleteSubject(int subjectId) {
        // Create a confirmation dialog
        Alert alert = new Alert(AlertType.CONFIRMATION);
        alert.setTitle("Delete Subject");
        alert.setHeaderText("Are you sure you want to delete this subject?");
        alert.setContentText("This action cannot be undone.");

        alert.showAndWait().ifPresent(response -> {
            if (response == ButtonType.OK) {
                deleteSubject(subjectId); // Call method to delete the subject
            }
        });
    }

    private void deleteSubject(int subjectId) {
        try {
            // Create URL to delete a subject
            URL url = new URL("http://carrot.melonhost.cz:25591/api/subjects/" + subjectId);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("DELETE");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken); // Set the token in the header

            // Check response code
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Subject deleted successfully
                fetchSubjects(); // Refresh the subjects list
            } else {
                // Handle error
                Alert alert = new Alert(AlertType.ERROR);
                alert.setTitle("Error");
                alert.setHeaderText(null);
                alert.setContentText("Failed to delete subject.");
                alert.showAndWait();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Show error message
            Alert alert = new Alert(AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("Error deleting subject: " + e.getMessage());
            alert.showAndWait();
        }
    }

    private void openCreateSubjectDialog() {
        // Create a new Stage for the dialog
        Stage dialog = new Stage();
        dialog.initModality(Modality.APPLICATION_MODAL); // Block events to other windows
        dialog.setTitle("Create Subject");

        // Create a VBox layout for the dialog
        VBox dialogLayout = new VBox(10);
        dialogLayout.setPadding(new Insets(20));
        dialogLayout.setStyle("-fx-background-color: #FFFFFF; -fx-border-color: #E0E0E0;"); // Light background for dialog

        // Input field for subject name
        TextField subjectNameField = new TextField();
        subjectNameField.setPromptText("Subject Name");
        subjectNameField.setStyle("-fx-background-color: #F5F5F5; -fx-text-fill: #333333; -fx-border-color: #CCCCCC;"); // Light background with subtle border

        // Button to create a new subject
        Button createButton = createStyledButton("Create Subject");
        createButton.setOnAction(e -> createSubject(subjectNameField.getText(), dialog));

        // Add elements to the dialog layout
        Label enterSubjectLabel = new Label("Enter Subject Name:");
        enterSubjectLabel.setStyle("-fx-text-fill: #333333;"); // Set text color for the label
        dialogLayout.getChildren().addAll(enterSubjectLabel, subjectNameField, createButton);

        // Set the scene for the dialog
        Scene dialogScene = new Scene(dialogLayout, 300, 200);
        dialog.setScene(dialogScene);
        dialog.show();
    }

    private void createSubject(String subjectName, Stage dialog) {
        if (subjectName.isEmpty()) {
            // Show error if the subject name is empty
            Alert alert = new Alert(AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("Subject name cannot be empty.");
            alert.showAndWait();
            return;
        }

        try {
            // Create URL to create a new subject
            URL url = new URL("http://carrot.melonhost.cz:25591/api/subjects");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken); // Set the token in the header
            conn.setRequestProperty("Content-Type", "application/json"); // Set content type
            conn.setDoOutput(true); // Enable output stream

            // Create JSON body
            String jsonInputString = "{\"subject_name\": \"" + subjectName + "\"}"; // Updated to match column name

            // Send request
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonInputString.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            // Check response code
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_CREATED) {
                // Subject created successfully
                dialog.close(); // Close dialog
                fetchSubjects(); // Refresh subjects list
            } else {
                // Show error message
                Alert alert = new Alert(AlertType.ERROR);
                alert.setTitle("Error");
                alert.setHeaderText(null);
                alert.setContentText("Failed to create subject.");
                alert.showAndWait();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Show error message
            Alert alert = new Alert(AlertType.ERROR);
            alert.setTitle("Error");
            alert.setHeaderText(null);
            alert.setContentText("Error creating subject: " + e.getMessage());
            alert.showAndWait();
        }
    }

    private Button createStyledButton(String text) {
        Button button = new Button(text);
        button.setStyle("-fx-background-color: #E0E0E0; -fx-text-fill: #333333; -fx-font-size: 12px; -fx-padding: 8px 16px; -fx-border-radius: 5px; -fx-background-radius: 5px;"); // Light modern style
        button.setOnMouseEntered(e -> button.setStyle("-fx-background-color: #CCCCCC; -fx-text-fill: #333333; -fx-font-size: 12px; -fx-padding: 8px 16px; -fx-border-radius: 5px; -fx-background-radius: 5px;")); // Hover effect
        button.setOnMouseExited(e -> button.setStyle("-fx-background-color: #E0E0E0; -fx-text-fill: #333333; -fx-font-size: 12px; -fx-padding: 8px 16px; -fx-border-radius: 5px; -fx-background-radius: 5px;")); // Revert effect
        return button;
    }

    private void displayError(String message) {
        // Clear the content area and display an error message
        contentArea.getChildren().clear();
        Label errorLabel = new Label(message);
        errorLabel.setStyle("-fx-text-fill: #333333;"); // Set dark text for error message
        contentArea.getChildren().add(errorLabel); // Add error message to the content area
    }
}
