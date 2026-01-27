#!/bin/bash
# Database Initialization Script
# Initializes MySQL or PostgreSQL database for Todo App

set -e

# ==================== Configuration ====================
DB_TYPE=${DB_TYPE:-"mysql"}
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"3306"}
DB_NAME=${DB_NAME:-"tododb"}
DB_USER=${DB_USER:-"admin"}
DB_PASSWORD=${DB_PASSWORD:-"YourSecurePassword123!"}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Database Initialization Script"
echo "=========================================="
echo "Database Type: $DB_TYPE"
echo "Database Host: $DB_HOST"
echo "Database Name: $DB_NAME"
echo "=========================================="

# ==================== MySQL Initialization ====================
if [ "$DB_TYPE" == "mysql" ]; then
    echo -e "${GREEN}Initializing MySQL database...${NC}"
    
    # Check if mysql client is installed
    if ! command -v mysql &> /dev/null; then
        echo -e "${YELLOW}Installing MySQL client...${NC}"
        sudo yum install -y mysql || sudo apt-get install -y mysql-client
    fi
    
    # Test connection
    echo "Testing database connection..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" || {
        echo "Failed to connect to database"
        exit 1
    }
    
    # Create database if not exists
    echo "Creating database if not exists..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE $DB_NAME;

-- Create todos table
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

-- Show tables
SHOW TABLES;
DESCRIBE todos;
EOF
    
    echo -e "${GREEN}✅ MySQL database initialized successfully${NC}"

# ==================== PostgreSQL Initialization ====================
elif [ "$DB_TYPE" == "postgresql" ] || [ "$DB_TYPE" == "postgres" ]; then
    echo -e "${GREEN}Initializing PostgreSQL database...${NC}"
    
    # Adjust port for PostgreSQL
    [ "$DB_PORT" == "3306" ] && DB_PORT="5432"
    
    # Check if psql client is installed
    if ! command -v psql &> /dev/null; then
        echo -e "${YELLOW}Installing PostgreSQL client...${NC}"
        sudo yum install -y postgresql || sudo apt-get install -y postgresql-client
    fi
    
    # Test connection
    echo "Testing database connection..."
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1;" || {
        echo "Failed to connect to database"
        exit 1
    }
    
    # Create database and tables
    echo "Creating database if not exists..."
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres << EOF
-- Create database if not exists
SELECT 'CREATE DATABASE $DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

\c $DB_NAME

-- Create todos table
CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_completed ON todos(completed);
CREATE INDEX IF NOT EXISTS idx_created ON todos(created_at);

-- Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
\$\$ language 'plpgsql';

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS update_todos_updated_at ON todos;

-- Create trigger
CREATE TRIGGER update_todos_updated_at
BEFORE UPDATE ON todos
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Show tables
\dt
\d todos
EOF
    
    echo -e "${GREEN}✅ PostgreSQL database initialized successfully${NC}"

else
    echo "Unsupported database type: $DB_TYPE"
    echo "Supported types: mysql, postgresql"
    exit 1
fi

echo "=========================================="
echo "Database initialization complete!"
echo "=========================================="
