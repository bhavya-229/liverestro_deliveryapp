const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'liverestro',
  port: parseInt(process.env.DB_PORT || '3306'),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

// Test connection on boot
(async () => {
  try {
    const connection = await pool.getConnection();
    console.log(`[Database] Connected successfully to MySQL (${process.env.DB_NAME || 'liverestro'}) at ${process.env.DB_HOST || '127.0.0.1'}`);
    connection.release();
  } catch (err) {
    console.warn(`[Database Warning] Could not establish persistent connection to MySQL: ${err.message}`);
    console.warn(`[Database Warning] API will run in fallback hybrid mode (Memory + Live DB).`);
  }
})();

module.exports = pool;
