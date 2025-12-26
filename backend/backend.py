"""
AudioPure Modal Backend
SAM-Audio integration with span prediction and quality re-ranking

Deploy: modal deploy backend.py
"""

import modal
import base64
import io
import torch

# Define the Modal app
app = modal.App("audiopure-sam-audio")

# Define the image with SAM-Audio dependencies
sam_audio_image = (
    modal.Image.debian_slim(python_version="3.11")
    .pip_install(
        "torch",
        "torchaudio", 
        "transformers",
        "huggingface_hub",
    )
    .run_commands(
        "pip install git+https://github.com/facebookresearch/sam-audio.git"
    )
)

@app.cls(
    image=sam_audio_image,
    gpu="A10G",  # or "T4" for cheaper
    timeout=300,
    secrets=[modal.Secret.from_name("huggingface-secret")],  # HF_TOKEN
)
class SAMAudioProcessor:
    
    @modal.enter()
    def load_model(self):
        """Load SAM-Audio model on container startup"""
        from sam_audio import SAMAudio, SAMAudioProcessor
        
        self.model = SAMAudio.from_pretrained("facebook/sam-audio-large")
        self.processor = SAMAudioProcessor.from_pretrained("facebook/sam-audio-large")
        self.model = self.model.eval().cuda()
        self.sample_rate = self.processor.audio_sampling_rate
    
    @modal.method()
    def process(
        self, 
        audio_base64: str,
        prompt: str,
        mode: str = "remove",
        predict_spans: bool = True,
        high_quality: bool = False
    ) -> dict:
        """
        Process audio with SAM-Audio
        
        Args:
            audio_base64: Base64 encoded audio data
            prompt: Description of sound to isolate/remove
            mode: "isolate" or "remove"
            predict_spans: Auto-detect time spans (better accuracy)
            high_quality: Use re-ranking (8 candidates, slower but better)
        
        Returns:
            dict with status and base64 output audio
        """
        import torchaudio
        
        try:
            # Decode audio
            audio_data = base64.b64decode(audio_base64)
            audio_buffer = io.BytesIO(audio_data)
            waveform, sr = torchaudio.load(audio_buffer)
            
            # Resample if needed
            if sr != self.sample_rate:
                resampler = torchaudio.transforms.Resample(sr, self.sample_rate)
                waveform = resampler(waveform)
            
            # Prepare batch
            batch = self.processor(
                audios=[waveform],
                descriptions=[prompt],
            ).to("cuda")
            
            # Configure re-ranking candidates
            reranking_candidates = 8 if high_quality else 1
            
            # Run separation
            with torch.inference_mode():
                result = self.model.separate(
                    batch,
                    predict_spans=predict_spans,
                    reranking_candidates=reranking_candidates
                )
            
            # Get output based on mode
            if mode == "isolate":
                output_audio = result.target.cpu()
            else:  # remove
                output_audio = result.residual.cpu()
            
            # Encode output to base64
            output_buffer = io.BytesIO()
            torchaudio.save(output_buffer, output_audio, self.sample_rate, format="wav")
            output_base64 = base64.b64encode(output_buffer.getvalue()).decode()
            
            return {
                "status": "succeeded",
                "output": f"data:audio/wav;base64,{output_base64}"
            }
            
        except Exception as e:
            return {
                "status": "failed",
                "error": str(e)
            }

# Web endpoint for iOS app
@app.function(image=sam_audio_image)
@modal.web_endpoint(method="POST")
def process_audio(request: dict) -> dict:
    """
    Web endpoint matching iOS ModalService request format
    
    Expected request body:
    {
        "input": {
            "audio": "data:audio/wav;base64,...",
            "prompt": "voice",
            "mode": "remove",
            "predict_spans": true,
            "high_quality": false
        }
    }
    """
    try:
        input_data = request.get("input", {})
        
        # Extract audio (remove data URL prefix)
        audio_data = input_data.get("audio", "")
        if "base64," in audio_data:
            audio_base64 = audio_data.split("base64,")[1]
        else:
            audio_base64 = audio_data
        
        prompt = input_data.get("prompt", "")
        mode = input_data.get("mode", "remove")
        predict_spans = input_data.get("predict_spans", True)
        high_quality = input_data.get("high_quality", False)
        
        # Process with SAM-Audio
        processor = SAMAudioProcessor()
        result = processor.process.remote(
            audio_base64=audio_base64,
            prompt=prompt,
            mode=mode,
            predict_spans=predict_spans,
            high_quality=high_quality
        )
        
        return result
        
    except Exception as e:
        return {
            "status": "failed",
            "error": str(e)
        }

# Local testing
if __name__ == "__main__":
    print("Deploy with: modal deploy backend.py")
    print("Test locally with: modal run backend.py")
