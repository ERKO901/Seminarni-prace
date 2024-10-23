const express = require('express');
const router = express.Router();
const db = require('../db'); // Assuming db.js contains your database logic
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config(); // Import dotenv to load environment variables

// Middleware to authenticate token and retrieve user information
const authenticateToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1]; // Get token from Authorization header
    if (!token) return res.sendStatus(401); // No token provided

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.sendStatus(403); // Token is no longer valid
        req.user = user; // Save user information to request object
        next(); // Continue to the next middleware
    });
};

// Middleware to check if the user is an admin
const checkAdmin = (req, res, next) => {
    db.query('SELECT is_admin FROM teachers WHERE id = ?', [req.user.userId], (error, results) => {
        if (error) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0 || !results[0].is_admin) {
            return res.status(403).json({ error: 'Forbidden: Admin access required' });
        }
        next(); // User is an admin, proceed to the next middleware
    });
};

// Get all teachers (Admin only)
router.get('/all', authenticateToken, checkAdmin, (req, res) => {
    db.query('SELECT id, name AS fullname, username, email, subjects, is_admin FROM teachers', (error, results) => {
        if (error) {
            console.error('Database error:', error); // Log the specific database error
            return res.status(500).json({ error: 'Database error' });
        }
        res.json(results);
    });
});

// Create a new teacher (Admin only)
router.post('/create', authenticateToken, checkAdmin, async (req, res) => {
    const { fullname, username, password, email, subjects, is_admin } = req.body;

    // Validate required fields
    if (!fullname || !username || !password || !email || !subjects) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Ensure subjects is an array of strings
    const subjectsString = Array.isArray(subjects) ? subjects.join(', ') : '';

    // Check if the subjects string is empty and handle it
    if (!subjectsString) {
        return res.status(400).json({ error: 'At least one subject must be selected' });
    }

    // Default is_admin to 0 if not provided
    const isAdmin = is_admin ? 1 : 0; // Convert to integer for SQL

    // Insert new teacher into the database
    db.query(
        'INSERT INTO teachers (name, username, hashed_password, email, subjects, is_admin) VALUES (?, ?, ?, ?, ?, ?)',
        [fullname, username, hashedPassword, email, subjectsString, isAdmin],
        (error, result) => {
            if (error) {
                console.error('Failed to create teacher:', error);
                return res.status(500).json({ error: 'Failed to create teacher' });
            }

            res.json({ message: 'Teacher created successfully', teacherId: result.insertId });
        }
    );
});


router.put('/edit/:id', authenticateToken, checkAdmin, async (req, res) => {
    const teacherId = req.params.id; // Get teacher ID from the URL
    const { fullname, username, password, email, subjects, is_admin } = req.body;

    // Validate required fields
    if (!fullname || !username || !email || !subjects) {
        return res.status(400).json({ error: 'Full name, username, email, and subjects are required' });
    }

    // Prepare updated data
    const updates = {
        name: fullname,
        username: username,
        email: email,
        subjects: Array.isArray(subjects) ? subjects.join(', ') : '',
        is_admin: is_admin === undefined ? 0 : (is_admin ? 1 : 0) // Ensure proper handling of the checkbox
    };

    // Hash password if it has been updated
    if (password) {
        updates.hashed_password = await bcrypt.hash(password, 10);
    }

    // Create the SQL update query dynamically based on provided fields
    const fieldsToUpdate = [];
    const values = [];

    for (const [key, value] of Object.entries(updates)) {
        if (value !== undefined) { // Check for undefined
            fieldsToUpdate.push(`${key} = ?`);
            values.push(value);
        }
    }

    // Add the teacher ID to the values for the query
    values.push(teacherId);

    // Prepare the SQL query
    const sqlQuery = `UPDATE teachers SET ${fieldsToUpdate.join(', ')} WHERE id = ?`;

    db.query(sqlQuery, values, (error, result) => {
        if (error) {
            console.error('Failed to update teacher:', error);
            return res.status(500).json({ error: 'Failed to update teacher' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Teacher not found' });
        }

        res.json({ message: 'Teacher updated successfully' });
    });
});

// Delete a teacher by ID (Admin only)
router.delete('/delete/:id', authenticateToken, checkAdmin, (req, res) => {
    const teacherId = req.params.id;

    db.query('DELETE FROM teachers WHERE id = ?', [teacherId], (error, result) => {
        if (error) {
            console.error('Failed to delete teacher:', error); // Log the specific error
            return res.status(500).json({ error: 'Failed to delete teacher' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Teacher not found' });
        }

        res.json({ message: 'Teacher deleted successfully' });
    });
});




// Teacher login
router.post('/login', async (req, res) => {
    const { username, password } = req.body;

    db.query('SELECT * FROM teachers WHERE username = ?', [username], async (error, results) => {
        if (error) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(401).json({ error: 'Invalid username or password' });
        }

        const teacher = results[0];

        const validPassword = await bcrypt.compare(password, teacher.hashed_password);
        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid username or password' });
        }

        const token = jwt.sign({ userId: teacher.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

        db.query('UPDATE teachers SET token = ? WHERE id = ?', [token, teacher.id], (updateError) => {
            if (updateError) {
                return res.status(500).json({ error: 'Failed to save token to the database' });
            }

            return res.json({
                message: 'Login successful',
                is_admin: teacher.is_admin,
                token
            });
        });
    });
});

// Get name and admin status from token
router.get('/get-name', authenticateToken, (req, res) => {
    db.query('SELECT name, is_admin FROM teachers WHERE id = ?', [req.user.userId], (error, results) => {
        if (error) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const teacher = results[0];
        return res.json({
            name: teacher.name,
            is_admin: teacher.is_admin
        });
    });
});

module.exports = router;
