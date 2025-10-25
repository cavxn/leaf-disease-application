#!/usr/bin/env python3
"""
Backend startup script for Leaf Disease Detector
This script starts the FastAPI backend server
"""

import subprocess
import sys
import os
from pathlib import Path

def main():
    # Get the directory where this script is located
    script_dir = Path(__file__).parent
    backend_dir = script_dir / "leaf-disease-detector"
    
    # Check if backend directory exists
    if not backend_dir.exists():
        print("❌ Backend directory not found!")
        print(f"Expected: {backend_dir}")
        return 1
    
    # Check if backend files exist
    if not (backend_dir / "leaf_api.py").exists():
        print("❌ Backend files not found!")
        print(f"Expected leaf_api.py in: {backend_dir}")
        return 1
    
    # Change to backend directory
    os.chdir(backend_dir)
    
    print("🌿 Starting Leaf Disease Detector Backend...")
    print(f"📁 Working directory: {os.getcwd()}")
    
    try:
        # Use the correct Python version (3.10 where packages are installed)
        python_cmd = "/Users/cavins/.pyenv/shims/python3"
        
        # Start the FastAPI server with uvicorn (using simple version for now)
        cmd = [
            python_cmd, "-m", "uvicorn", 
            "leaf_api_simple:app", 
            "--host", "0.0.0.0", 
            "--port", "8000", 
            "--reload"
        ]
        
        print(f"🚀 Running command: {' '.join(cmd)}")
        subprocess.run(cmd, check=True)
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error starting backend: {e}")
        return 1
    except KeyboardInterrupt:
        print("\n🛑 Backend stopped by user")
        return 0
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
