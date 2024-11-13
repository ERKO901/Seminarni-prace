const express = require('express');
const router = express.Router();
const db = require('../db'); // Import your database connection
const jwt = require('jsonwebtoken'); // Assuming you're using JSON Web Tokens for authentication

// Middleware to handle errors
const errorHandler = (err, res) => {
    console.error(err);
    res.status(500).json({ message: 'Internal Server Error' });
};

// Middleware to verify token and admin status
const verifyAdminToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1]; // Get the token from the authorization header

    if (!token) {
        return res.status(401).json({ message: 'Authorization token is required' });
    }

    // Verify the token (assuming you have a secret to verify with)
    jwt.verify(token, 'mySuperSecretKey123!', (err, decoded) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }

        // Check if the user is an admin
        db.query('SELECT is_admin FROM teachers WHERE id = ?', [decoded.userId], (err, results) => {
            if (err) return errorHandler(err, res);
            if (results.length === 0 || results[0].is_admin !== 1) {
                return res.status(403).json({ message: 'Access denied: Admins only' });
            }
            next(); // User is admin, proceed to the route handler
        });
    });
};

// Get all subjects (requires admin token)
router.get('/', verifyAdminToken, (req, res) => {
    db.query('SELECT * FROM subjects', (err, results) => {
        if (err) return errorHandler(err, res);
        res.json(results);
    });
});

// Create a new subject (requires admin token)
router.post('/', verifyAdminToken, (req, res) => {
    const { subject_name } = req.body; // Updated to match the column name

    if (!subject_name) {
        return res.status(400).json({ message: 'Subject name is required' });
    }

    db.query('INSERT INTO subjects (subject_name) VALUES (?)', [subject_name], (err) => {
        if (err) return errorHandler(err, res);
        res.status(201).json({ message: 'Subject created' });
    });
});

// Update a subject (requires admin token)
router.put('/:id', verifyAdminToken, (req, res) => {
    const { id } = req.params;
    const { subject_name } = req.body; // Updated to match the column name

    if (!subject_name) {
        return res.status(400).json({ message: 'Subject name is required' });
    }

    db.query('UPDATE subjects SET subject_name = ? WHERE id = ?', [subject_name, id], (err, result) => {
        if (err) return errorHandler(err, res);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Subject not found' });
        }
        res.json({ message: 'Subject updated' });
    });
});

// Delete a subject (requires admin token)
router.delete('/:id', verifyAdminToken, (req, res) => {
    const { id } = req.params;

    db.query('DELETE FROM subjects WHERE id = ?', [id], (err, result) => {
        if (err) return errorHandler(err, res);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Subject not found' });
        }
        res.json({ message: 'Subject deleted' });
    });
});

module.exports = router;
