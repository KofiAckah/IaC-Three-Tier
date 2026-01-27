#!/bin/bash
# Local Testing Script for Todo App
# Tests the application locally before deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

APP_URL="http://localhost:3000"

echo "=========================================="
echo "Todo App Local Testing"
echo "=========================================="

# Check if app is running
log_info "Checking if application is running..."
if ! curl -f -s "${APP_URL}/api/health" > /dev/null; then
    log_error "Application is not running"
    log_info "Start the application with: npm run dev"
    exit 1
fi

log_info "✅ Application is running"

# Test health endpoint
log_info "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "${APP_URL}/api/health")
echo "$HEALTH_RESPONSE" | jq '.' || echo "$HEALTH_RESPONSE"

# Test app info endpoint
log_info "Testing app info endpoint..."
INFO_RESPONSE=$(curl -s "${APP_URL}/api/info")
echo "$INFO_RESPONSE" | jq '.' || echo "$INFO_RESPONSE"

# Test get all todos
log_info "Testing GET /api/todos..."
curl -s "${APP_URL}/api/todos" | jq '.'

# Test create todo
log_info "Testing POST /api/todos..."
NEW_TODO=$(curl -s -X POST "${APP_URL}/api/todos" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Todo from Script","description":"This is a test"}')
echo "$NEW_TODO" | jq '.'

TODO_ID=$(echo "$NEW_TODO" | jq -r '.data.id')
log_info "Created todo with ID: $TODO_ID"

# Test update todo
log_info "Testing PUT /api/todos/$TODO_ID..."
curl -s -X PUT "${APP_URL}/api/todos/${TODO_ID}" \
    -H "Content-Type: application/json" \
    -d '{"completed":true}' | jq '.'

# Test get single todo
log_info "Testing GET /api/todos/$TODO_ID..."
curl -s "${APP_URL}/api/todos/${TODO_ID}" | jq '.'

# Test delete todo
log_info "Testing DELETE /api/todos/$TODO_ID..."
curl -s -X DELETE "${APP_URL}/api/todos/${TODO_ID}" | jq '.'

echo ""
log_info "=========================================="
log_info "All tests completed successfully!"
log_info "=========================================="
log_info "Web UI: ${APP_URL}"
log_info "API Docs: ${APP_URL}/api/info"
log_info "=========================================="
