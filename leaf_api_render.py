from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image
import numpy as np
import io
import os
import logging
import random
from typing import Dict, Any
import warnings

# Suppress warnings
warnings.filterwarnings('ignore')

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Leaf Disease Detection API",
    description="AI-powered plant disease detection",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

# Try to load TensorFlow model, fallback to mock if fails
model = None
model_loaded = False

def load_model():
    """Try to load TensorFlow model, with fallback"""
    global model, model_loaded
    
    try:
        import tensorflow as tf
        logger.info("TensorFlow imported successfully")
        
        model_path = "final_leaf_disease_model.keras"
        if os.path.exists(model_path):
            logger.info("Loading TensorFlow model...")
            
            # Try loading with custom objects to handle compatibility issues
            try:
                model = tf.keras.models.load_model(
                    model_path,
                    compile=False,  # Don't compile to avoid compatibility issues
                    custom_objects=None
                )
                # Recompile the model with standard settings
                model.compile(
                    optimizer='adam',
                    loss='categorical_crossentropy',
                    metrics=['accuracy']
                )
                model_loaded = True
                logger.info("✅ TensorFlow model loaded and compiled successfully!")
                return True
                
            except Exception as model_error:
                logger.warning(f"Model loading failed with error: {model_error}")
                
                # Try loading with different approach
                try:
                    logger.info("🔄 Trying alternative model loading approach...")
                    model = tf.keras.models.load_model(
                        model_path,
                        compile=False
                    )
                    model_loaded = True
                    logger.info("✅ TensorFlow model loaded (alternative method)!")
                    return True
                except Exception as alt_error:
                    logger.warning(f"Alternative loading also failed: {alt_error}")
                    raise model_error
        else:
            logger.warning(f"Model file not found: {model_path}")
            
    except Exception as e:
        logger.warning(f"TensorFlow model loading failed: {e}")
        logger.info("🔄 Falling back to mock predictions")
    
    model_loaded = False
    return False

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """Preprocess image for model prediction"""
    try:
        # Open and convert image
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Resize to standard size
        image = image.resize((224, 224))
        
        # Convert to numpy array and normalize
        image_array = np.array(image, dtype=np.float32) / 255.0
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
        
    except Exception as e:
        logger.error(f"Error preprocessing image: {e}")
        raise HTTPException(status_code=400, detail=f"Error processing image: {str(e)}")

def predict_with_model(image_bytes: bytes) -> Dict[str, Any]:
    """Predict using TensorFlow model"""
    global model
    
    try:
        # Preprocess image
        processed_image = preprocess_image(image_bytes)
        
        # Make prediction with error handling
        try:
            predictions = model.predict(processed_image, verbose=0, batch_size=1)
        except Exception as predict_error:
            logger.warning(f"Prediction failed, trying with different batch size: {predict_error}")
            # Try with different batch size
            predictions = model.predict(processed_image, verbose=0, batch_size=None)
        
        # Get prediction results
        predicted_class_idx = np.argmax(predictions[0])
        confidence = float(np.max(predictions[0]))
        predicted_class = CLASS_NAMES[predicted_class_idx]
        
        # Get top 3 predictions
        top_3_indices = np.argsort(predictions[0])[-3:][::-1]
        top_3_predictions = [
            {
                "class": CLASS_NAMES[idx],
                "confidence": float(predictions[0][idx])
            }
            for idx in top_3_indices
        ]
        
        logger.info(f"✅ TensorFlow prediction: {predicted_class} (confidence: {confidence:.3f})")
        
        return {
            "prediction": predicted_class,
            "class": predicted_class,
            "confidence": confidence,
            "top_predictions": top_3_predictions,
            "model_type": "tensorflow"
        }
        
    except Exception as e:
        logger.error(f"Error during model prediction: {e}")
        # Fallback to mock prediction if model fails
        logger.info("🔄 Model prediction failed, falling back to mock prediction")
        return predict_with_mock(image_bytes)

def predict_with_mock(image_bytes: bytes) -> Dict[str, Any]:
    """Mock prediction for testing/fallback"""
    try:
        # Preprocess image to validate it
        processed_image = preprocess_image(image_bytes)
        
        # Generate realistic mock predictions
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
            "model_type": "mock"
        }
        
    except Exception as e:
        logger.error(f"Error during mock prediction: {e}")
        raise HTTPException(status_code=500, detail=f"Mock prediction failed: {str(e)}")

@app.on_event("startup")
async def startup_event():
    """Load model on startup"""
    logger.info("🚀 Starting Leaf Disease Detection API...")
    load_model()

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "🌿 Leaf Disease Detection API is running!",
        "model_loaded": model_loaded,
        "version": "1.0.0",
        "mode": "tensorflow" if model_loaded else "mock"
    }

@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "model_loaded": model_loaded,
        "class_count": len(CLASS_NAMES),
        "version": "1.0.0",
        "mode": "tensorflow" if model_loaded else "mock"
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """Predict plant disease from uploaded image"""
    
    # Validate file
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        # Read image bytes
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="Empty file")
        
        # Check file size (max 10MB)
        if len(image_bytes) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File too large (max 10MB)")
        
        # Make prediction
        if model_loaded and model is not None:
            result = predict_with_model(image_bytes)
        else:
            result = predict_with_mock(image_bytes)
        
        logger.info(f"Prediction: {result['prediction']} (confidence: {result['confidence']:.3f}) [{result['model_type']}]")
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/classes")
async def get_classes():
    """Get list of all possible disease classes"""
    return {
        "classes": CLASS_NAMES,
        "count": len(CLASS_NAMES)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
