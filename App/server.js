// Todo App Server - 3-Tier Architecture
// Main Express application server

const express = require('express');
const path = require('path');
const os = require('os');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Database configuration
const db = require('./config/database');

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Set view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// ==================== Routes ====================

// Home Page - Render Todo UI
app.get('/', (req, res) => {
  res.render('index', {
    hostname: os.hostname(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// ==================== API Endpoints ====================

// Health Check Endpoint (for ALB Target Group)
app.get('/api/health', async (req, res) => {
  try {
    // Test database connection
    await db.query('SELECT 1');
    
    res.status(200).json({
      status: 'healthy',
      database: 'connected',
      dbType: process.env.DB_TYPE || 'mysql',
      timestamp: new Date().toISOString(),
      hostname: os.hostname(),
      uptime: process.uptime()
    });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(503).json({
      status: 'unhealthy',
      database: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString(),
      hostname: os.hostname()
    });
  }
});

// Get Application Info
app.get('/api/info', (req, res) => {
  res.json({
    application: 'Todo App - 3-Tier Architecture',
    version: '1.0.0',
    hostname: os.hostname(),
    platform: os.platform(),
    nodeVersion: process.version,
    environment: process.env.NODE_ENV || 'development',
    database: {
      type: process.env.DB_TYPE || 'mysql',
      host: process.env.DB_HOST || 'localhost'
    }
  });
});

// Get all todos
app.get('/api/todos', async (req, res) => {
  try {
    const query = `
      SELECT id, title, description, completed, created_at, updated_at 
      FROM todos 
      ORDER BY created_at DESC
    `;
    
    const todos = await db.query(query);
    
    res.json({
      success: true,
      count: todos.length,
      data: todos
    });
  } catch (error) {
    console.error('Error fetching todos:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch todos',
      message: error.message
    });
  }
});

// Get single todo by ID
app.get('/api/todos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'SELECT * FROM todos WHERE id = ?';
    const todos = await db.query(query, [id]);
    
    if (todos.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }
    
    res.json({
      success: true,
      data: todos[0]
    });
  } catch (error) {
    console.error('Error fetching todo:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch todo',
      message: error.message
    });
  }
});

// Create new todo
app.post('/api/todos', async (req, res) => {
  try {
    const { title, description } = req.body;
    
    // Validation
    if (!title || title.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Title is required'
      });
    }
    
    const query = `
      INSERT INTO todos (title, description, completed) 
      VALUES (?, ?, ?)
    `;
    
    const result = await db.query(query, [
      title.trim(),
      description?.trim() || '',
      false
    ]);
    
    // Fetch the created todo
    const newTodo = await db.query('SELECT * FROM todos WHERE id = ?', [result.insertId]);
    
    res.status(201).json({
      success: true,
      message: 'Todo created successfully',
      data: newTodo[0]
    });
  } catch (error) {
    console.error('Error creating todo:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create todo',
      message: error.message
    });
  }
});

// Update todo
app.put('/api/todos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, completed } = req.body;
    
    // Check if todo exists
    const existing = await db.query('SELECT * FROM todos WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }
    
    // Build update query dynamically
    const updates = [];
    const values = [];
    
    if (title !== undefined) {
      updates.push('title = ?');
      values.push(title.trim());
    }
    
    if (description !== undefined) {
      updates.push('description = ?');
      values.push(description.trim());
    }
    
    if (completed !== undefined) {
      updates.push('completed = ?');
      values.push(completed);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No fields to update'
      });
    }
    
    updates.push('updated_at = NOW()');
    values.push(id);
    
    const query = `UPDATE todos SET ${updates.join(', ')} WHERE id = ?`;
    await db.query(query, values);
    
    // Fetch updated todo
    const updatedTodo = await db.query('SELECT * FROM todos WHERE id = ?', [id]);
    
    res.json({
      success: true,
      message: 'Todo updated successfully',
      data: updatedTodo[0]
    });
  } catch (error) {
    console.error('Error updating todo:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update todo',
      message: error.message
    });
  }
});

// Delete todo
app.delete('/api/todos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if todo exists
    const existing = await db.query('SELECT * FROM todos WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Todo not found'
      });
    }
    
    await db.query('DELETE FROM todos WHERE id = ?', [id]);
    
    res.json({
      success: true,
      message: 'Todo deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting todo:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete todo',
      message: error.message
    });
  }
});

// Delete all completed todos
app.delete('/api/todos/completed/all', async (req, res) => {
  try {
    const result = await db.query('DELETE FROM todos WHERE completed = ?', [true]);
    
    res.json({
      success: true,
      message: `Deleted ${result.affectedRows} completed todo(s)`
    });
  } catch (error) {
    console.error('Error deleting completed todos:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete completed todos',
      message: error.message
    });
  }
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    path: req.path
  });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error('Server Error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message
  });
});

// ==================== Server Startup ====================

// Initialize database and start server
const startServer = async () => {
  try {
    // Test database connection
    console.log('Testing database connection...');
    await db.testConnection();
    console.log('✅ Database connection successful');
    
    // Initialize database tables
    console.log('Initializing database tables...');
    await db.initializeTables();
    console.log('✅ Database tables initialized');
    
    // Start server
    app.listen(PORT, () => {
      console.log('='.repeat(60));
      console.log(`🚀 Todo App Server Started`);
      console.log('='.repeat(60));
      console.log(`📍 Server URL: http://localhost:${PORT}`);
      console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
      console.log(`📊 API Info: http://localhost:${PORT}/api/info`);
      console.log(`🖥️  Hostname: ${os.hostname()}`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🗄️  Database: ${process.env.DB_TYPE || 'mysql'} @ ${process.env.DB_HOST || 'localhost'}`);
      console.log('='.repeat(60));
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, closing server gracefully...');
  await db.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('\nSIGINT received, closing server gracefully...');
  await db.close();
  process.exit(0);
});

// Start the server
startServer();
