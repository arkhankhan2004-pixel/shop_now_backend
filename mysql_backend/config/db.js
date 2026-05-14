const mysql = require('mysql2');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

const promisePool = pool.promise();

// Robust migration: Ensure discount_percent column exists
(async () => {
    try {
        const [columns] = await promisePool.query("SHOW COLUMNS FROM products LIKE 'discount_percent'");
        if (columns.length === 0) {
            await promisePool.query("ALTER TABLE products ADD COLUMN discount_percent INT DEFAULT 0");
            console.log('Database: discount_percent column added successfully.');
        } else {
            console.log('Database schema verified: discount_percent column exists.');
        }
    } catch (err) {
        console.error('Migration error:', err.message);
    }
})();

module.exports = promisePool;
