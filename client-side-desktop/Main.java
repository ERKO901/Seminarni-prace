package erko.melonhost;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.GridPane;
import javafx.stage.Stage;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class Main extends Application {
    private TextField usernameField; // Field for username input
    private PasswordField passwordField;
    private Label errorLabel;

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Gymnáziumk Kaldno | Přihlášení");

        // Create UI components
        usernameField = new TextField(); // Field for username input
        passwordField = new PasswordField();
        Button loginButton = new Button("Přihlásit se");
        errorLabel = new Label();

        // Styling for light mode
        errorLabel.setTextFill(Color.RED);
        usernameField.setPromptText("Uživatelské jméno");
        passwordField.setPromptText("Heslo");

        // Set font for modern look
        usernameField.setFont(Font.font(16));
        passwordField.setFont(Font.font(16));
        loginButton.setFont(Font.font(16));

        // Create layout with padding and centering
        GridPane gridPane = new GridPane();
        gridPane.setPadding(new Insets(40, 40, 40, 40));
        gridPane.setVgap(20);
        gridPane.setHgap(10);
        gridPane.setAlignment(Pos.CENTER);

        // Load the image
        Image logoImage = new Image(getClass().getResourceAsStream("/images/logo.png"));
        if (logoImage.isError()) {
            System.out.println("Error loading image!");
        } else {
            ImageView imageView = new ImageView(logoImage);
            imageView.setFitWidth(300); // Set desired width
            imageView.setPreserveRatio(true); // Preserve aspect ratio
            gridPane.add(imageView, 0, 0, 2, 1); // Span across two columns for centering
        }

        // Add UI components to layout with appropriate labels
        Label usernameLabel = new Label("Uživatelské jméno:");
        Label passwordLabel = new Label("Heslo:");

        // Set label colors to black
        usernameLabel.setTextFill(Color.BLACK);
        passwordLabel.setTextFill(Color.BLACK);

        // Add labels and input fields to the grid
        gridPane.add(usernameLabel, 0, 1);
        gridPane.add(usernameField, 0, 2);
        gridPane.add(passwordLabel, 0, 3);
        gridPane.add(passwordField, 0, 4);
        gridPane.add(loginButton, 0, 5);
        gridPane.add(errorLabel, 0, 6);

        // Light mode styling
        gridPane.setStyle("-fx-background-color: #ffffff; -fx-text-fill: black;");
        loginButton.setStyle("-fx-background-color: #4290f1; -fx-text-fill: white; -fx-pref-width: 350;");

        // Ensure usernameField and passwordField have the same width
        usernameField.setPrefWidth(350);
        passwordField.setPrefWidth(350);
        loginButton.setPrefWidth(350);

        // Set up the scene and stage
        Scene scene = new Scene(gridPane, 600, 400);
        primaryStage.setScene(scene);
        primaryStage.show();

        // Set action on login button
        loginButton.setOnAction(e -> login(primaryStage));
    }

    private void login(Stage primaryStage) {
        String username = usernameField.getText();
        String password = passwordField.getText();

        try {
            URL url = new URL("http://carrot.melonhost.cz:25591/api/teachers/login");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");

            // Create JSON payload
            String jsonInputString = String.format("{\"username\":\"%s\", \"password\":\"%s\"}", username, password);
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonInputString.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            // Check the response code
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }

                // Print the response for debugging
                System.out.println("Response: " + response.toString());

                // Parse response and get the token
                JSONObject jsonResponse = new JSONObject(response.toString());
                String loginToken = jsonResponse.getString("token"); // Assume the token is in the response

                // Open the dashboard with the login token
                new Dashboard(primaryStage, loginToken);
            } else {
                errorLabel.setText("Login failed. Please check your credentials.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            errorLabel.setText("An error occurred. Please try again.");
        }
    }

    // Method to switch back to the login scene
    public static void showLogin(Stage primaryStage) {
        // Create a new Main instance to set up the login UI again
        Main main = new Main();
        main.start(primaryStage);
    }
}