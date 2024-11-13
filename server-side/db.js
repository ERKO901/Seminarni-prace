const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: 'example.com',
    user: 'user',
    password: 'password',
    database: 'database'
});

connection.connect((err) => {
    if (err) throw err;
    console.log('Connected to MySQL database');
});

module.exports = connection;
