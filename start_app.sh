#!/bin/bash

# Leaf Disease Detection App - Complete Startup Script
# This script starts both the backend API and the Flutter app

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Function to kill processes on port 8000
kill_backend() {
    if port_in_use 8000; then
        print_warning "Port 8000 is in use. Killing existing processes..."
        pkill -f "local_api.py" || true
        pkill -f "leaf_api_deploy.py" || true
        sleep 2
    fi
}

# Function to start backend
start_backend() {
    print_status "Starting backend API server..."
    
    # Kill any existing backend processes
    kill_backend
    
    # Check if we're in the right directory
    if [ ! -f "local_api.py" ]; then
        print_error "local_api.py not found. Please run this script from the project root directory."
        exit 1
    fi
    
    # Start the backend in background
    print_status "Starting Flask API server on port 8000..."
    python local_api.py &
    BACKEND_PID=$!
    
    # Wait for backend to start
    print_status "Waiting for backend to start..."
    sleep 5
    
    # Test if backend is running
    if curl -s http://localhost:8000/health >/dev/null 2>&1; then
        print_success "Backend API server started successfully!"
        print_status "Backend PID: $BACKEND_PID"
        print_status "API available at: http://localhost:8000"
    else
        print_error "Failed to start backend API server"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
}

# Function to start Flutter app
start_flutter() {
    print_status "Starting Flutter app..."
    
    # Check if Flutter is installed
    if ! command_exists flutter; then
        print_error "Flutter is not installed or not in PATH"
        print_status "Please install Flutter and add it to your PATH"
        exit 1
    fi
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Please run this script from the Flutter project root directory."
        exit 1
    fi
    
    # Start Flutter app on specific device in release mode
    print_status "Starting Flutter app on device 00008120-00062C202EB8201E in release mode..."
    flutter run -d "00008120-00062C202EB8201E" --release &
    
    FLUTTER_PID=$!
    print_success "Flutter app started!"
    print_status "Flutter PID: $FLUTTER_PID"
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
        print_status "Backend server stopped"
    fi
    if [ ! -z "$FLUTTER_PID" ]; then
        kill $FLUTTER_PID 2>/dev/null || true
        print_status "Flutter app stopped"
    fi
    # Kill any remaining processes
    pkill -f "local_api.py" || true
    pkill -f "flutter run" || true
    print_success "Cleanup completed"
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Main execution
main() {
    echo "🌿 Leaf Disease Detection App - Complete Startup"
    echo "================================================"
    echo ""
    
    # Check if Python is available
    if ! command_exists python; then
        print_error "Python is not installed or not in PATH"
        exit 1
    fi
    
    # Check if curl is available
    if ! command_exists curl; then
        print_error "curl is not installed or not in PATH"
        exit 1
    fi
    
    print_status "Starting Leaf Disease Detection App..."
    echo ""
    
    # Start backend
    start_backend
    echo ""
    
    # Start Flutter app
    start_flutter
    echo ""
    
    print_success "🎉 Everything started successfully!"
    echo ""
    print_status "Backend API: http://172.20.188.100:8000"
    print_status "Health Check: http://172.20.188.100:8000/health"
    print_status "Flutter App: Running on your iPhone device"
    echo ""
    print_status "Press Ctrl+C to stop everything"
    
    # Wait for user to stop
    wait
}

# Run main function
main "$@"
