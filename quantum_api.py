from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from PIL import Image
import numpy as np
import io
import os
import logging
from typing import Dict, Any
import warnings
from quantum_ai_detector import quantum_detector

# Suppress warnings
warnings.filterwarnings('ignore')

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Quantum AI Leaf Disease Detection API",
    description="Quantum AI-powered plant disease detection using Variational Quantum Classifier",
    version="2.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """Preprocess image for quantum model prediction"""
    try:
        # Open and convert image
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Resize to standard size
        image = image.resize((224, 224))
        
        # Convert to numpy array and normalize
        image_array = np.array(image, dtype=np.float32) / 255.0
        
        return image_array
        
    except Exception as e:
        logger.error(f"Error preprocessing image: {e}")
        raise HTTPException(status_code=400, detail=f"Error processing image: {str(e)}")

@app.on_event("startup")
async def startup_event():
    """Initialize quantum detector on startup"""
    logger.info("🌌 Starting Quantum AI Leaf Disease Detection API...")
    logger.info("🔮 Quantum detector initialized successfully!")

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "🌌 Quantum AI Leaf Disease Detection API is running!",
        "version": "2.0.0",
        "quantum_enabled": True,
        "qubits": quantum_detector.num_qubits,
        "model_type": "Variational Quantum Classifier (VQC)"
    }

@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "quantum_enabled": True,
        "qubits_available": quantum_detector.num_qubits,
        "class_count": len(quantum_detector.class_names),
        "version": "2.0.0",
        "model_type": "quantum"
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """Predict plant disease using Quantum AI"""
    
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
        
        # Preprocess image
        processed_image = preprocess_image(image_bytes)
        
        # Make quantum prediction
        result = quantum_detector.predict_quantum(processed_image)
        
        logger.info(f"🌌 Quantum prediction: {result['prediction']} (confidence: {result['confidence']:.3f})")
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/quantum/advantages")
async def get_quantum_advantages():
    """Get quantum AI advantages"""
    return quantum_detector.get_quantum_advantages()

@app.get("/quantum/limitations")
async def get_quantum_limitations():
    """Get quantum AI limitations"""
    return quantum_detector.get_quantum_limitations()

@app.get("/quantum/solutions")
async def get_quantum_solutions():
    """Get solutions for quantum limitations"""
    return quantum_detector.get_quantum_solutions()

@app.get("/quantum/analysis")
async def get_quantum_analysis():
    """Get complete quantum AI analysis"""
    return {
        "advantages": quantum_detector.get_quantum_advantages(),
        "limitations": quantum_detector.get_quantum_limitations(),
        "solutions": quantum_detector.get_quantum_solutions(),
        "implementation_status": {
            "quantum_circuit": "Implemented",
            "variational_classifier": "Implemented", 
            "feature_mapping": "Implemented",
            "error_handling": "Implemented",
            "hybrid_approach": "Ready for implementation"
        }
    }

@app.get("/classes")
async def get_classes():
    """Get list of all possible disease classes"""
    return {
        "classes": quantum_detector.class_names,
        "count": len(quantum_detector.class_names)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
