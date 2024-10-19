const express = require('express');
const router = express.Router();
const db = require('../db'); // Import database connection

// Get all parents
router.get('/', (req, res) => {
    db.query('SELECT * FROM parents', (err, results) => {
        if (err) return res.status(500).json({ message: 'Database error' });
        res.json(results);
    });
});

// Create a new parent
router.post('/', (req, res) => {
    const { name, email } = req.body;
    db.query('INSERT INTO parents (name, email) VALUES (?, ?)', [name, email], (err) => {
        if (err) return res.status(500).json({ message: 'Error creating parent' });
        res.status(201).json({ message: 'Parent created' });
    });
});

// Additional routes (update, delete) can be added here

module.exports = router;
