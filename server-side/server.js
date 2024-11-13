const express = require('express');
const teacherRoutes = require('./routes/teacherRoutes');
const classRoutes = require('./routes/classRoutes');
const subjectRoutes = require('./routes/subjectRoutes');
const studentRoutes = require('./routes/studentRoutes');
const parentRoutes = require('./routes/parentRoutes');
const db = require('./db'); // Import připojení k databázi
const path = require('path');

const app = express();
const PORT = process.env.PORT || 25591;

// Použij express.json() k parsování příchozích JSON požadavků
app.use(express.json()); // Tento middleware automaticky parsuje JSON těla

// Definuj jednotlivé trasy
app.use('/api/teachers', teacherRoutes);
app.use('/api/classes', classRoutes);
app.use('/api/subjects', subjectRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/parents', parentRoutes);

// Endpoint ke stažení souboru
app.get('/download', (req, res) => {
    const filePath = path.join(__dirname, 'download', 'Magistri.exe'); // Definuj cestu k APK souboru

    res.download(filePath, 'Magistri.exe', (err) => {
        if (err) {
            if (res.headersSent) {
                // Pokud už byly odeslány hlavičky, pouze loguj chybu a nedělej nic dalšího
                console.log('Error in sending file download:', err);
            } else {
                // Pošli odpověď s chybou pouze pokud hlavičky ještě nebyly odeslány
                console.log('Error with file download:', err);
                res.status(500).send('Error with file download');
            }
        }
    });
});

// Spusť server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
