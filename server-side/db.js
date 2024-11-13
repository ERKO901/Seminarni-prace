const mysql = require('mysql2'); // Načtení knihovny mysql2 pro připojení k MySQL databázi

const connection = mysql.createConnection({
    host: 'example.com',     // Nastavení hostname databázového serveru
    user: 'user',             // Uživatelské jméno pro přístup k databázi
    password: 'password',     // Heslo pro přístup k databázi
    database: 'database'      // Název databáze, ke které se chceme připojit
});

connection.connect((err) => {
    if (err) throw err;       // Pokud dojde k chybě připojení, vyhoď chybu
    console.log('Connected to MySQL database'); // Potvrzení úspěšného připojení
});

module.exports = connection; // Export připojení pro použití v dalších částech aplikace
