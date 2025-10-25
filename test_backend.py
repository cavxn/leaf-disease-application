#!/usr/bin/env python3
"""
Test script for Leaf Disease Detector Backend
This script tests the backend API endpoints
"""

import requests
import json
import sys
from pathlib import Path

def test_backend():
    base_url = "http://localhost:8000"
    
    print("🧪 Testing Leaf Disease Detector Backend...")
    print(f"🌐 Base URL: {base_url}")
    
    # Test 1: Health check
    print("\n1️⃣ Testing health check endpoint...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"📄 Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Health check failed: {e}")
        return False
    
    # Test 2: Check if we have a sample image
    print("\n2️⃣ Looking for sample images...")
    sample_images = [
        "leaf-disease-detector/closeup.jpeg",
        "assets/images/soil_background.jpg"
    ]
    
    sample_image = None
    for img_path in sample_images:
        if Path(img_path).exists():
            sample_image = img_path
            print(f"✅ Found sample image: {img_path}")
            break
    
    if not sample_image:
        print("⚠️ No sample images found. Backend API is working but can't test prediction.")
        print("✅ Backend is ready for Flutter app!")
        return True
    
    # Test 3: Test prediction endpoint
    print(f"\n3️⃣ Testing prediction endpoint with {sample_image}...")
    try:
        with open(sample_image, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{base_url}/predict", files=files, timeout=30)
            
        if response.status_code == 200:
            result = response.json()
            print("✅ Prediction test passed")
            print(f"📊 Prediction: {result.get('prediction', 'Unknown')}")
            print(f"🎯 Confidence: {result.get('confidence', 'N/A')}")
        else:
            print(f"❌ Prediction test failed: {response.status_code}")
            print(f"📄 Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Prediction test failed: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ Sample image not found: {sample_image}")
        return False
    
    print("\n🎉 All tests passed! Backend is ready for Flutter app!")
    return True

def main():
    if test_backend():
        print("\n✅ Backend is working correctly!")
        print("📱 You can now run the Flutter app:")
        print("   flutter run")
        sys.exit(0)
    else:
        print("\n❌ Backend tests failed!")
        print("🔧 Please check the backend setup and try again.")
        sys.exit(1)

if __name__ == "__main__":
    main()
