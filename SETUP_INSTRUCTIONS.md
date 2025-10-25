# Leaf Disease Detector - Setup Instructions

## 🌿 Overview
This is a Flutter mobile app that uses AI to detect plant diseases from leaf images. The app connects to a Python backend that runs a machine learning model for disease classification.

## 📋 Prerequisites

### For Flutter App:
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- iOS Simulator / Android Emulator or physical device

### For Backend:
- Python 3.8+
- pip (Python package manager)
- Virtual environment (recommended)

## 🚀 Quick Start

### 1. Backend Setup

```bash
# Navigate to the project directory
cd /Users/cavins/Desktop/project/app_leaf-main

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install backend dependencies
cd leaf-disease-detector
pip install fastapi uvicorn tensorflow pillow numpy python-multipart

# Start the backend server
python start_backend.py
# OR manually:
# uvicorn leaf_api:app --host 0.0.0.0 --port 8000 --reload
```

The backend will be available at: `http://localhost:8000`

### 2. Flutter App Setup

```bash
# Navigate to the main project directory
cd /Users/cavins/Desktop/project/app_leaf-main

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

## 🔧 Configuration

### Backend Configuration
The backend API endpoint is configured in:
- `lib/services/api_service.dart` - Line 6: `_baseUrl = "http://10.126.101.156:8000"`

**Important**: Update this IP address to match your machine's IP address where the backend is running.

### Environment Variables
Create a `.env` file in the project root (optional):
```env
BACKEND_URL=http://localhost:8000
API_ENDPOINT=/predict
OPENAI_API_KEY=your_openai_key_here
GEMINI_API_KEY=your_gemini_key_here
```

## 📱 Permissions

### Android Permissions
The app requires the following permissions (already configured):
- Camera access
- Storage access
- Internet access
- Network state access

### iOS Permissions
The app requires the following permissions (already configured):
- Camera usage description
- Photo library usage description

## 🧪 Testing the App

### 1. Test Backend
```bash
# Test if backend is running
curl http://localhost:8000/
# Should return: {"message": "🌿 Leaf Disease Detection API is running!"}
```

### 2. Test Flutter App
1. Launch the app on your device/simulator
2. Grant camera and photo library permissions when prompted
3. Take a photo or select an image from gallery
4. Tap "Detect Disease" to analyze the image
5. View the results with confidence score and treatment recommendations

## 🔍 Troubleshooting

### Common Issues:

1. **Backend Connection Failed**
   - Ensure backend is running on the correct IP/port
   - Check firewall settings
   - Update IP address in `api_service.dart`

2. **Permission Denied**
   - Grant camera and storage permissions in device settings
   - Restart the app after granting permissions

3. **Model Loading Error**
   - Ensure `final_leaf_disease_model.keras` exists in backend directory
   - Check file permissions

4. **Flutter Build Errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart versions
   - Ensure all dependencies are properly installed

### Debug Mode:
- Enable debug logging in the app to see detailed API communication
- Check console output for error messages
- Use `flutter logs` to view app logs

## 📊 Model Information

The app uses a pre-trained Keras model (`final_leaf_disease_model.keras`) that can detect:
- 38 different plant diseases
- Healthy plant conditions
- Various crop types (Apple, Tomato, Corn, Grape, etc.)

## 🔄 Development Workflow

1. **Backend Changes**: Modify files in `leaf-disease-detector/` directory
2. **Flutter Changes**: Modify files in `lib/` directory
3. **Test Changes**: Restart backend and hot-reload Flutter app
4. **Deploy**: Build release versions for production

## 📝 API Endpoints

- `GET /` - Health check
- `POST /predict` - Disease prediction
  - Input: Image file (multipart/form-data)
  - Output: JSON with prediction and confidence

## 🎯 Features

- **AI Disease Detection**: Uses machine learning to identify plant diseases
- **Confidence Scoring**: Shows prediction confidence levels
- **Treatment Recommendations**: Provides treatment and prevention tips
- **History Tracking**: Saves detection history
- **Modern UI**: Beautiful, responsive interface
- **Cross-Platform**: Works on iOS and Android

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify all dependencies are installed
3. Ensure backend is running and accessible
4. Check device permissions
5. Review console logs for error messages

---

**Happy Plant Disease Detection! 🌱**
