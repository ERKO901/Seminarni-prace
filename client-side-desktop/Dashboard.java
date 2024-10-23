package erko.melonhost;

import javafx.application.Platform;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class Dashboard {
    private String loginToken;
    private Stage primaryStage;
    private VBox contentArea;
    private Button subjectsButton;
    private Button teachersButton;
    private boolean isAdmin;

    public Dashboard(Stage primaryStage, String loginToken) {
        this.primaryStage = primaryStage;
        this.loginToken = loginToken;

        primaryStage.setTitle("Gymnázium Kladno | Dashboard");

        // Create a BorderPane for layout
        BorderPane dashboard = new BorderPane();
        dashboard.setPadding(new Insets(0));
        dashboard.setStyle("-fx-background-color: #f4f4f4;"); // Light mode background color

        // Create a VBox for the sidebar
        VBox sidebar = new VBox();
        sidebar.setStyle("-fx-background-color: #f9f9f9;"); // Light mode sidebar background color
        sidebar.setAlignment(Pos.TOP_CENTER); // Center align all elements in the sidebar horizontally
        sidebar.setSpacing(20); // Add spacing between elements

        // Logo
        Image logoImage = new Image(getClass().getResourceAsStream("/images/logo.png"));
        ImageView logoView = new ImageView(logoImage);
        logoView.setFitWidth(220);  // Set the width of the logo
        logoView.setPreserveRatio(true); // Preserve aspect ratio

        // Title label
        Label titleLabel = new Label("Magistři");
        titleLabel.setStyle("-fx-text-fill: #333; -fx-font-size: 24px; -fx-font-weight: bold;");

        // Create a VBox to stack the logo above the title
        VBox titleBox = new VBox();
        titleBox.setAlignment(Pos.CENTER); // Center the titleBox
        titleBox.setSpacing(5); // Space between logo and title
        titleBox.getChildren().addAll(logoView, titleLabel); // Add logo and title to VBox

        // Label to display the name
        Label nameLabel = new Label();
        nameLabel.setStyle("-fx-text-fill: #333; -fx-font-size: 16px;");

        // Logout button
        Button logoutButton = new Button("Odhlásit se");
        logoutButton.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white; -fx-pref-width: 150px;");
        logoutButton.setOnAction(e -> logout());

        // Add elements to the sidebar
        sidebar.getChildren().addAll(titleBox, nameLabel, logoutButton);

        // Create a content area (center of the dashboard)
        contentArea = new VBox();
        contentArea.setPadding(new Insets(20));
        contentArea.setStyle("-fx-background-color: #f4f4f4;"); // Light mode content area background color
        contentArea.setAlignment(Pos.CENTER);

        // Create a GridPane for the buttons at the top of the content area
        GridPane buttonGrid = new GridPane();
        buttonGrid.setAlignment(Pos.CENTER);
        buttonGrid.setHgap(20); // Horizontal gap between elements
        buttonGrid.setVgap(20); // Vertical gap between elements
        buttonGrid.setPadding(new Insets(0, 0, 400, 0));

        // Create ImageViews for each button
        ImageView studentImageView = new ImageView(new Image(getClass().getResourceAsStream("/images/students.png")));
        studentImageView.setFitWidth(100); // Set image size
        studentImageView.setFitHeight(100);
        studentImageView.setPreserveRatio(true);

        ImageView timetableImageView = new ImageView(new Image(getClass().getResourceAsStream("/images/timetable.png")));
        timetableImageView.setFitWidth(100);
        timetableImageView.setFitHeight(100);
        timetableImageView.setPreserveRatio(true);

        ImageView subjectsImageView = new ImageView(new Image(getClass().getResourceAsStream("/images/subjects.png")));
        subjectsImageView.setFitWidth(100);
        subjectsImageView.setFitHeight(100);
        subjectsImageView.setPreserveRatio(true);

        ImageView teachersImageView = new ImageView(new Image(getClass().getResourceAsStream("/images/teachers.png")));
        teachersImageView.setFitWidth(100);
        teachersImageView.setFitHeight(100);
        teachersImageView.setPreserveRatio(true);

        // Create buttons for each section with both image and label inside
        Button studentButton = new Button();
        Button timetableButton = new Button();
        subjectsButton = new Button();
        teachersButton = new Button();

        // Create labels for each button
        Label studentLabel = new Label("Studenti");
        studentLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #333;");
        Label timetableLabel = new Label("Rozvrhy");
        timetableLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #333;");
        Label subjectsLabel = new Label("Předměty");
        subjectsLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #333;");
        Label teachersLabel = new Label("Učitelé");
        teachersLabel.setStyle("-fx-font-size: 14px; -fx-text-fill: #333;");

        // Create VBoxes to stack the image and label inside the button
        VBox studentButtonContent = new VBox(5, studentImageView, studentLabel);
        studentButtonContent.setAlignment(Pos.CENTER);
        studentButton.setGraphic(studentButtonContent);

        VBox timetableButtonContent = new VBox(5, timetableImageView, timetableLabel);
        timetableButtonContent.setAlignment(Pos.CENTER);
        timetableButton.setGraphic(timetableButtonContent);

        VBox subjectsButtonContent = new VBox(5, subjectsImageView, subjectsLabel);
        subjectsButtonContent.setAlignment(Pos.CENTER);
        subjectsButton.setGraphic(subjectsButtonContent);

        VBox teachersButtonContent = new VBox(5, teachersImageView, teachersLabel);
        teachersButtonContent.setAlignment(Pos.CENTER);
        teachersButton.setGraphic(teachersButtonContent);

        // Add the buttons to the GridPane
        buttonGrid.add(studentButton, 0, 0);
        buttonGrid.add(timetableButton, 1, 0);
        buttonGrid.add(subjectsButton, 2, 0);
        buttonGrid.add(teachersButton, 3, 0);

        // Set the sidebar to the left of the border pane and the button grid to the center
        dashboard.setLeft(sidebar);
        dashboard.setCenter(contentArea);
        contentArea.getChildren().add(buttonGrid);

        // Set actions for each button
        studentButton.setOnAction(e -> showStudents(studentButton, timetableButton, subjectsButton, teachersButton));
        timetableButton.setOnAction(e -> showTimetable(studentButton, timetableButton, subjectsButton, teachersButton));
        subjectsButton.setOnAction(e -> showSubjects(studentButton, timetableButton, subjectsButton, teachersButton));
        teachersButton.setOnAction(e -> showTeachers(studentButton, timetableButton, subjectsButton, teachersButton));

        // Fetch name and admin status
        fetchName(nameLabel);

        // Create the scene and set it on the primary stage
        Scene dashboardScene = new Scene(dashboard, 800, 600);
        primaryStage.setScene(dashboardScene);
        primaryStage.show();
    }





    // Method to fetch the teacher's name and admin status
    private void fetchName(Label nameLabel) {
        try {
            // Create URL to fetch the name and admin status
            URL url = new URL("http://carrot.melonhost.cz:25591/api/teachers/get-name"); // Adjust the URL as necessary
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + loginToken); // Set the token in the header

            // Read response
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String inputLine;
            StringBuilder response = new StringBuilder();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            // Parse JSON response
            JSONObject jsonResponse = new JSONObject(response.toString());
            nameLabel.setText(jsonResponse.getString("name")); // Set the name on the label

            // Get admin status
            isAdmin = jsonResponse.getInt("is_admin") == 1; // Set isAdmin based on response

            // Show/Hide the subjects button based on isAdmin
            Platform.runLater(() -> {
                subjectsButton.setVisible(isAdmin); // Make the button visible if the user is an admin
                teachersButton.setVisible(isAdmin); // Show Teachers button only for admins
            });

        } catch (Exception e) {
            e.printStackTrace();
            // Handle error appropriately
            Platform.runLater(() -> nameLabel.setText("Error fetching name"));
        }
    }

    // Show students in the content area and hide the buttons
    private void showStudents(Button... buttons) {
        contentArea.getChildren().clear(); // Clear existing content
        contentArea.getChildren().add(new Label("Student List (placeholder)")); // Placeholder for student list
        hideButtons(buttons); // Hide buttons
    }

    // Show timetable in the content area and hide the buttons
    private void showTimetable(Button... buttons) {
        contentArea.getChildren().clear(); // Clear existing content
        contentArea.getChildren().add(new Label("Timetable (placeholder)")); // Placeholder for timetable
        hideButtons(buttons); // Hide buttons
    }

    // Show subjects in the content area and hide the buttons
    private void showSubjects(Button... buttons) {
        contentArea.getChildren().clear(); // Clear existing content
        new Subjects(loginToken, contentArea); // Create Subjects instance to display subjects
        hideButtons(buttons); // Hide buttons
    }

    // Show teachers in the content area and hide the buttons
    private void showTeachers(Button... buttons) {
        contentArea.getChildren().clear(); // Clear existing content
        new Teachers(loginToken, contentArea); // Create Teachers instance to display teachers
        hideButtons(buttons); // Hide buttons
    }

    // Hide the buttons
    private void hideButtons(Button... buttons) {
        for (Button button : buttons) {
            button.setVisible(false); // Hide each button
        }
    }

    // Show the buttons again
    private void showButtons(Button... buttons) {
        for (Button button : buttons) {
            button.setVisible(true); // Show each button
        }
    }

    // Logout method to handle user logout
    private void logout() {
        // Clear the token (if any)
        loginToken = null;

        // Redirect to login page
        Main.showLogin(primaryStage);
    }
}
