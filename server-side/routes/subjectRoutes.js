const express = require('express');
const router = express.Router();
const db = require('../db'); // Import připojení k databázi
const jwt = require('jsonwebtoken'); // Předpoklad použití JSON Web Tokenů pro autentizaci

// Middleware pro zpracování chyb
const errorHandler = (err, res) => {
    console.error(err);
    res.status(500).json({ message: 'Internal Server Error' });
};

// Middleware pro ověření tokenu a administrátorského přístupu
const verifyAdminToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1]; // Získání tokenu z hlavičky autorizace

    if (!token) {
        return res.status(401).json({ message: 'Authorization token is required' });
    }

    // Ověření tokenu (předpoklad použití tajného klíče pro ověření)
    jwt.verify(token, 'mySuperSecretKey123!', (err, decoded) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }

        // Ověření, zda je uživatel administrátorem
        db.query('SELECT is_admin FROM teachers WHERE id = ?', [decoded.userId], (err, results) => {
            if (err) return errorHandler(err, res);
            if (results.length === 0 || results[0].is_admin !== 1) {
                return res.status(403).json({ message: 'Access denied: Admins only' });
            }
            next(); // Uživatel je administrátor, pokračuje na další handler
        });
    });
};

// Získání všech předmětů (vyžaduje administrátorský token)
router.get('/', verifyAdminToken, (req, res) => {
    db.query('SELECT * FROM subjects', (err, results) => {
        if (err) return errorHandler(err, res);
        res.json(results);
    });
});

// Vytvoření nového předmětu (vyžaduje administrátorský token)
router.post('/', verifyAdminToken, (req, res) => {
    const { subject_name } = req.body; // Odpovídá názvu sloupce

    if (!subject_name) {
        return res.status(400).json({ message: 'Subject name is required' });
    }

    db.query('INSERT INTO subjects (subject_name) VALUES (?)', [subject_name], (err) => {
        if (err) return errorHandler(err, res);
        res.status(201).json({ message: 'Subject created' });
    });
});

// Aktualizace předmětu (vyžaduje administrátorský token)
router.put('/:id', verifyAdminToken, (req, res) => {
    const { id } = req.params;
    const { subject_name } = req.body; // Odpovídá názvu sloupce

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

// Smazání předmětu (vyžaduje administrátorský token)
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

module.exports = router; // Export routeru pro použití v hlavní aplikaci
