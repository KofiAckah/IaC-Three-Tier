// Database Configuration and Connection Handler
// Supports both MySQL and PostgreSQL

const dbType = process.env.DB_TYPE || 'mysql';

let db;

// MySQL Configuration
if (dbType === 'mysql') {
  const mysql = require('mysql2/promise');
  
  const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'tododb',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0
  });
  
  db = {
    async query(sql, params) {
      const [rows] = await pool.execute(sql, params);
      return rows;
    },
    
    async testConnection() {
      try {
        await pool.query('SELECT 1');
        console.log('✅ MySQL connection successful');
        return true;
      } catch (error) {
        console.error('❌ MySQL connection failed:', error.message);
        throw error;
      }
    },
    
    async initializeTables() {
      const createTableSQL = `
        CREATE TABLE IF NOT EXISTS todos (
          id INT AUTO_INCREMENT PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          description TEXT,
          completed BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          INDEX idx_completed (completed),
          INDEX idx_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `;
      
      await pool.query(createTableSQL);
      console.log('✅ MySQL tables initialized');
    },
    
    async close() {
      await pool.end();
      console.log('MySQL connection closed');
    }
  };
}

// PostgreSQL Configuration
else if (dbType === 'postgresql' || dbType === 'postgres') {
  const { Pool } = require('pg');
  
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'tododb',
    max: 10,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });
  
  db = {
    async query(sql, params) {
      // Convert MySQL ? placeholders to PostgreSQL $1, $2, etc.
      let paramIndex = 0;
      const pgSQL = sql.replace(/\?/g, () => `$${++paramIndex}`);
      
      const result = await pool.query(pgSQL, params);
      return result.rows;
    },
    
    async testConnection() {
      try {
        await pool.query('SELECT 1');
        console.log('✅ PostgreSQL connection successful');
        return true;
      } catch (error) {
        console.error('❌ PostgreSQL connection failed:', error.message);
        throw error;
      }
    },
    
    async initializeTables() {
      const createTableSQL = `
        CREATE TABLE IF NOT EXISTS todos (
          id SERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          description TEXT,
          completed BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE INDEX IF NOT EXISTS idx_completed ON todos(completed);
        CREATE INDEX IF NOT EXISTS idx_created ON todos(created_at);
        
        -- Trigger to update updated_at
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
          NEW.updated_at = CURRENT_TIMESTAMP;
          RETURN NEW;
        END;
        $$ language 'plpgsql';
        
        DROP TRIGGER IF EXISTS update_todos_updated_at ON todos;
        
        CREATE TRIGGER update_todos_updated_at
        BEFORE UPDATE ON todos
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();
      `;
      
      await pool.query(createTableSQL);
      console.log('✅ PostgreSQL tables initialized');
    },
    
    async close() {
      await pool.end();
      console.log('PostgreSQL connection closed');
    }
  };
}

else {
  throw new Error(`Unsupported database type: ${dbType}. Use 'mysql' or 'postgresql'`);
}

module.exports = db;
