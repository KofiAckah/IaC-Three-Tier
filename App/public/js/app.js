// Todo App Frontend JavaScript
// Handles all client-side interactions and API calls

// ==================== Global State ====================
let todos = [];
let currentFilter = 'all';

// ==================== DOM Elements ====================
const addTodoForm = document.getElementById('addTodoForm');
const todoTitle = document.getElementById('todoTitle');
const todoDescription = document.getElementById('todoDescription');
const todoList = document.getElementById('todoList');
const emptyState = document.getElementById('emptyState');
const totalTodosEl = document.getElementById('totalTodos');
const completedTodosEl = document.getElementById('completedTodos');
const pendingTodosEl = document.getElementById('pendingTodos');
const filterButtons = document.querySelectorAll('.btn-filter');
const clearCompletedBtn = document.getElementById('clearCompleted');
const toast = document.getElementById('toast');

// ==================== API Functions ====================

// Fetch all todos from server
async function fetchTodos() {
    try {
        const response = await fetch('/api/todos');
        const data = await response.json();
        
        if (data.success) {
            todos = data.data;
            renderTodos();
            updateStats();
        } else {
            showToast('Failed to fetch todos', 'error');
        }
    } catch (error) {
        console.error('Error fetching todos:', error);
        showToast('Error connecting to server', 'error');
    }
}

// Create new todo
async function createTodo(title, description) {
    try {
        const response = await fetch('/api/todos', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ title, description })
        });
        
        const data = await response.json();
        
        if (data.success) {
            todos.unshift(data.data);
            renderTodos();
            updateStats();
            showToast('Todo created successfully!', 'success');
            return true;
        } else {
            showToast(data.error || 'Failed to create todo', 'error');
            return false;
        }
    } catch (error) {
        console.error('Error creating todo:', error);
        showToast('Error creating todo', 'error');
        return false;
    }
}

// Update todo
async function updateTodo(id, updates) {
    try {
        const response = await fetch(`/api/todos/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(updates)
        });
        
        const data = await response.json();
        
        if (data.success) {
            const index = todos.findIndex(todo => todo.id === id);
            if (index !== -1) {
                todos[index] = data.data;
                renderTodos();
                updateStats();
            }
            return true;
        } else {
            showToast(data.error || 'Failed to update todo', 'error');
            return false;
        }
    } catch (error) {
        console.error('Error updating todo:', error);
        showToast('Error updating todo', 'error');
        return false;
    }
}

// Delete todo
async function deleteTodo(id) {
    try {
        const response = await fetch(`/api/todos/${id}`, {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (data.success) {
            todos = todos.filter(todo => todo.id !== id);
            renderTodos();
            updateStats();
            showToast('Todo deleted successfully!', 'success');
            return true;
        } else {
            showToast(data.error || 'Failed to delete todo', 'error');
            return false;
        }
    } catch (error) {
        console.error('Error deleting todo:', error);
        showToast('Error deleting todo', 'error');
        return false;
    }
}

// Clear all completed todos
async function clearCompleted() {
    try {
        const response = await fetch('/api/todos/completed/all', {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (data.success) {
            await fetchTodos(); // Refresh the list
            showToast(data.message, 'success');
        } else {
            showToast(data.error || 'Failed to clear completed todos', 'error');
        }
    } catch (error) {
        console.error('Error clearing completed todos:', error);
        showToast('Error clearing completed todos', 'error');
    }
}

// ==================== Render Functions ====================

// Render todos based on current filter
function renderTodos() {
    // Filter todos
    let filteredTodos = todos;
    
    if (currentFilter === 'active') {
        filteredTodos = todos.filter(todo => !todo.completed);
    } else if (currentFilter === 'completed') {
        filteredTodos = todos.filter(todo => todo.completed);
    }
    
    // Clear list
    todoList.innerHTML = '';
    
    // Show empty state if no todos
    if (filteredTodos.length === 0) {
        emptyState.style.display = 'block';
        todoList.style.display = 'none';
        return;
    }
    
    emptyState.style.display = 'none';
    todoList.style.display = 'flex';
    
    // Render each todo
    filteredTodos.forEach(todo => {
        const todoEl = createTodoElement(todo);
        todoList.appendChild(todoEl);
    });
}

// Create todo DOM element
function createTodoElement(todo) {
    const div = document.createElement('div');
    div.className = `todo-item ${todo.completed ? 'completed' : ''}`;
    div.dataset.id = todo.id;
    
    const createdDate = new Date(todo.created_at).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
    
    div.innerHTML = `
        <input 
            type="checkbox" 
            class="todo-checkbox" 
            ${todo.completed ? 'checked' : ''}
            onchange="toggleTodo(${todo.id}, this.checked)"
        >
        <div class="todo-content">
            <div class="todo-title">${escapeHtml(todo.title)}</div>
            ${todo.description ? `<div class="todo-description">${escapeHtml(todo.description)}</div>` : ''}
            <div class="todo-meta">Created: ${createdDate}</div>
        </div>
        <div class="todo-actions">
            <button class="btn btn-danger" onclick="confirmDelete(${todo.id})">
                Delete
            </button>
        </div>
    `;
    
    return div;
}

// Update statistics
function updateStats() {
    const total = todos.length;
    const completed = todos.filter(todo => todo.completed).length;
    const pending = total - completed;
    
    totalTodosEl.textContent = total;
    completedTodosEl.textContent = completed;
    pendingTodosEl.textContent = pending;
}

// ==================== Event Handlers ====================

// Handle add todo form submission
addTodoForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const title = todoTitle.value.trim();
    const description = todoDescription.value.trim();
    
    if (!title) {
        showToast('Please enter a title', 'error');
        return;
    }
    
    const success = await createTodo(title, description);
    
    if (success) {
        todoTitle.value = '';
        todoDescription.value = '';
        todoTitle.focus();
    }
});

// Handle filter button clicks
filterButtons.forEach(button => {
    button.addEventListener('click', () => {
        filterButtons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        currentFilter = button.dataset.filter;
        renderTodos();
    });
});

// Handle clear completed button
clearCompletedBtn.addEventListener('click', () => {
    const completedCount = todos.filter(todo => todo.completed).length;
    
    if (completedCount === 0) {
        showToast('No completed todos to clear', 'error');
        return;
    }
    
    if (confirm(`Are you sure you want to delete ${completedCount} completed todo(s)?`)) {
        clearCompleted();
    }
});

// Toggle todo completion status
async function toggleTodo(id, completed) {
    await updateTodo(id, { completed });
}

// Confirm and delete todo
function confirmDelete(id) {
    if (confirm('Are you sure you want to delete this todo?')) {
        deleteTodo(id);
    }
}

// ==================== Utility Functions ====================

// Show toast notification
function showToast(message, type = 'success') {
    toast.textContent = message;
    toast.className = `toast show ${type}`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ==================== Initialize App ====================

// Load todos when page loads
document.addEventListener('DOMContentLoaded', () => {
    fetchTodos();
    
    // Auto-refresh every 30 seconds (optional)
    // setInterval(fetchTodos, 30000);
});

// Handle online/offline events
window.addEventListener('online', () => {
    showToast('Connection restored', 'success');
    fetchTodos();
});

window.addEventListener('offline', () => {
    showToast('You are offline', 'error');
});
