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
    
    # Change to project root directory
    os.chdir(script_dir)
    
    print("🌿 Starting Leaf Disease Detector Backend...")
    print(f"📁 Working directory: {os.getcwd()}")
    
    try:
        # Use the correct Python version (3.10 where packages are installed)
        python_cmd = "/Users/cavins/.pyenv/shims/python3"
        
        # Start the local Flask API server
        cmd = [
            python_cmd, "local_api.py"
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
