const express = require('express');
const router = express.Router();
const db = require('../db'); // Import database connection

// Get all classes
router.get('/', (req, res) => {
    db.query('SELECT * FROM classes', (err, results) => {
        if (err) return res.status(500).json({ message: 'Database error' });
        res.json(results);
    });
});

// Create a new class
router.post('/', (req, res) => {
    const { name, main_teacher_id } = req.body;
    db.query('INSERT INTO classes (name, main_teacher_id) VALUES (?, ?)', [name, main_teacher_id], (err) => {
        if (err) return res.status(500).json({ message: 'Error creating class' });
        res.status(201).json({ message: 'Class created' });
    });
});

// Additional routes (update, delete) can be added here

module.exports = router;
