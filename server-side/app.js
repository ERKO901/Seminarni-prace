// Import necessary modules
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const bcrypt = require('bcrypt'); // For hashing passwords
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Create an Express app
const app = express();

// Middleware to parse JSON requests
app.use(bodyParser.json());

// Create a MySQL connection
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// Connect to MySQL
db.connect(err => {
  if (err) {
    console.error('MySQL connection error:', err);
    return;
  }
  console.log('MySQL connected!');
});

// User registration route
app.post('/api/users/register', async (req, res) => {
  console.log('Request body:', req.body); // Log the incoming request

  const { username, password, role } = req.body;

  // Basic validation
  if (!username || !password || !role) {
    return res.status(400).json({ error: 'Username, password, and role are required.' });
  }

  // Check if the user already exists
  db.query('SELECT * FROM users WHERE username = ?', [username], (err, results) => {
    if (err) {
      console.error('Database query error:', err); // Log database errors
      return res.status(500).json({ error: 'User registration failed.' });
    }
    
    if (results.length > 0) {
      return res.status(400).json({ error: 'User already exists.' });
    }

    // Hash the password
    bcrypt.hash(password, 10, (err, hash) => {
      if (err) {
        console.error('Password hashing error:', err);
        return res.status(500).json({ error: 'User registration failed.' });
      }

      // Insert new user into the database
      db.query('INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)', [username, hash, role], (err, results) => {
        if (err) {
          console.error('Database insert error:', err); // Log database insert errors
          return res.status(500).json({ error: 'User registration failed.' });
        }
        
        console.log('New user created:', results.insertId); // Log the newly created user ID
        res.status(201).json({ id: results.insertId, username, role });
      });
    });
  });
});

// Start the server
const PORT = process.env.PORT || 25591;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
