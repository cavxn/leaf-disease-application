#!/usr/bin/env python3
"""
Simple local API server for Leaf Disease Detection
This replaces the Render deployment with a local server
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import random
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Class names for the model
CLASS_NAMES = [
    'Apple__Apple_scab', 'Apple_Black_rot', 'Apple_Cedar_apple_rust', 'Apple_healthy',
    'Blueberry_healthy', 'Cherry(including_sour)Powdery_mildew', 'Cherry(including_sour)healthy',
    'Corn(maize)Cercospora_leaf_spot Gray_leaf_spot', 'Corn(maize)Common_rust',
    'Corn_(maize)Northern_Leaf_Blight', 'Corn(maize)healthy', 'Grape_Black_rot',
    'Grape_Esca(Black_Measles)', 'Grape__Leaf_blight(Isariopsis_Leaf_Spot)', 'Grape__healthy',
    'Orange_Haunglongbing(Citrus_greening)', 'Peach__Bacterial_spot', 'Peach_healthy',
    'Pepper,_bell_Bacterial_spot', 'Pepper,_bell_healthy', 'Potato_Early_blight',
    'Potato_Late_blight', 'Potato_healthy', 'Raspberry_healthy', 'Soybean_healthy',
    'Squash_Powdery_mildew', 'Strawberry_Leaf_scorch', 'Strawberry_healthy',
    'Tomato_Bacterial_spot', 'Tomato_Early_blight', 'Tomato_Late_blight', 'Tomato_Leaf_Mold',
    'Tomato_Septoria_leaf_spot', 'Tomato_Spider_mites Two-spotted_spider_mite',
    'Tomato_Target_Spot', 'Tomato_Tomato_Yellow_Leaf_Curl_Virus', 'Tomato_Tomato_mosaic_virus',
    'Tomato__healthy'
]

def get_mock_prediction():
    """Generate a realistic mock prediction"""
    # Favor healthy plants and common diseases
    healthy_classes = [i for i, name in enumerate(CLASS_NAMES) if 'healthy' in name.lower()]
    disease_classes = [i for i, name in enumerate(CLASS_NAMES) if 'healthy' not in name.lower()]
    
    # 70% chance of healthy, 30% chance of disease
    if random.random() < 0.7 and healthy_classes:
        predicted_class_idx = random.choice(healthy_classes)
        confidence = random.uniform(0.75, 0.95)
    else:
        predicted_class_idx = random.choice(disease_classes)
        confidence = random.uniform(0.65, 0.90)
    
    predicted_class = CLASS_NAMES[predicted_class_idx]
    
    # Generate top 3 predictions
    other_indices = [i for i in range(len(CLASS_NAMES)) if i != predicted_class_idx]
    top_3_indices = [predicted_class_idx] + random.sample(other_indices, min(2, len(other_indices)))
    random.shuffle(top_3_indices)
    
    top_3_predictions = []
    for i, idx in enumerate(top_3_indices[:3]):
        conf = confidence if i == 0 else random.uniform(0.1, confidence - 0.1)
        top_3_predictions.append({
            "class": CLASS_NAMES[idx],
            "confidence": conf
        })
    
    # Sort by confidence
    top_3_predictions.sort(key=lambda x: x['confidence'], reverse=True)
    
    return {
        "prediction": predicted_class,
        "class": predicted_class,
        "confidence": confidence,
        "top_predictions": top_3_predictions,
        "model_type": "mock_local"
    }

@app.route('/')
def root():
    """Health check endpoint"""
    return jsonify({
        "message": "🌿 Leaf Disease Detection API is running locally!",
        "model_loaded": True,
        "version": "2.0.0",
        "mode": "local_mock"
    })

@app.route('/health')
def health_check():
    """Detailed health check"""
    return jsonify({
        "status": "healthy",
        "model_loaded": True,
        "class_count": len(CLASS_NAMES),
        "version": "2.0.0",
        "mode": "local_mock"
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Predict plant disease from uploaded image"""
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({"error": "No file provided"}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({"error": "No file selected"}), 400
        
        # Generate mock prediction
        result = get_mock_prediction()
        
        logger.info(f"Prediction: {result['prediction']} (confidence: {result['confidence']:.3f}) [local_mock]")
        
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return jsonify({"error": "Internal server error"}), 500

@app.route('/classes')
def get_classes():
    """Get list of all possible disease classes"""
    return jsonify({
        "classes": CLASS_NAMES,
        "count": len(CLASS_NAMES)
    })

@app.route('/quantum/advantages')
def get_quantum_advantages():
    """Get quantum AI advantages (fallback mode)"""
    return jsonify({
        "error": "Quantum AI detector not available",
        "status": "fallback_mode",
        "message": "Quantum features are disabled for local deployment",
        "note": "This is a local deployment without quantum dependencies"
    })

@app.route('/quantum/limitations')
def get_quantum_limitations():
    """Get quantum AI limitations (fallback mode)"""
    return jsonify({
        "error": "Quantum AI detector not available",
        "status": "fallback_mode",
        "message": "Quantum features are disabled for local deployment"
    })

@app.route('/quantum/solutions')
def get_quantum_solutions():
    """Get solutions for quantum limitations (fallback mode)"""
    return jsonify({
        "error": "Quantum AI detector not available",
        "status": "fallback_mode",
        "message": "Quantum features are disabled for local deployment"
    })

@app.route('/quantum/analysis')
def get_quantum_analysis():
    """Get complete quantum AI analysis (fallback mode)"""
    return jsonify({
        "error": "Quantum AI detector not available",
        "status": "fallback_mode",
        "message": "Quantum features are disabled for local deployment",
        "implementation_status": {
            "quantum_circuit": "Not Available",
            "variational_classifier": "Not Available", 
            "feature_mapping": "Not Available",
            "error_handling": "Not Available",
            "hybrid_approach": "Not Available"
        }
    })

if __name__ == '__main__':
    print("🌿 Starting Local Leaf Disease Detection API...")
    print("📡 Server will be available at: http://localhost:8000")
    print("🔗 Health check: http://localhost:8000/health")
    print("📊 Prediction endpoint: http://localhost:8000/predict")
    app.run(host='0.0.0.0', port=8000, debug=True)
