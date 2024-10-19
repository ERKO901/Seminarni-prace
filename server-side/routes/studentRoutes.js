const express = require('express');
const router = express.Router();
const db = require('../db'); // Import database connection

// Get all students
router.get('/', (req, res) => {
    db.query('SELECT * FROM students', (err, results) => {
        if (err) return res.status(500).json({ message: 'Database error' });
        res.json(results);
    });
});

// Create a new student
router.post('/', (req, res) => {
    const { name, class_id } = req.body;
    db.query('INSERT INTO students (name, class_id) VALUES (?, ?)', [name, class_id], (err) => {
        if (err) return res.status(500).json({ message: 'Error creating student' });
        res.status(201).json({ message: 'Student created' });
    });
});

// Additional routes (update, delete) can be added here

module.exports = router;
