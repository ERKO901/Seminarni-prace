const express = require('express');
const teacherRoutes = require('./routes/teacherRoutes');
const classRoutes = require('./routes/classRoutes');
const subjectRoutes = require('./routes/subjectRoutes');
const studentRoutes = require('./routes/studentRoutes');
const parentRoutes = require('./routes/parentRoutes');
const db = require('./db'); // Import the database connection
const path = require('path');

const app = express();
const PORT = process.env.PORT || 25591;

// Use express.json() to parse incoming JSON requests
app.use(express.json()); // This middleware will automatically parse JSON bodies

// Define the routes
app.use('/api/teachers', teacherRoutes);
app.use('/api/classes', classRoutes);
app.use('/api/subjects', subjectRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/parents', parentRoutes);

// Download endpoint
app.get('/download', (req, res) => {
    const filePath = path.join(__dirname, 'download', 'Magistri.exe'); // Define the path to the APK file

    res.download(filePath, 'Magistri.exe', (err) => {
        if (err) {
            if (res.headersSent) {
                // If headers are already sent, just log the error and do nothing else
                console.log('Error in sending file download:', err);
            } else {
                // Only send an error response if headers aren't already sent
                console.log('Error with file download:', err);
                res.status(500).send('Error with file download');
            }
        }
    });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
