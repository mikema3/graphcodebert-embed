import os
import torch
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from transformers import AutoTokenizer, AutoModel

MODEL_ID = os.environ.get("MODEL_ID", "microsoft/graphcodebert-base")
# If you want CLS pooling instead, set POOLING=cls
POOLING = os.environ.get("POOLING", "mean").lower()

app = FastAPI(title="GraphCodeBERT Embeddings")

# Pick device & dtype
if torch.cuda.is_available():
    device = torch.device("cuda")
    dtype = torch.float16  # good default for inference on GPU
else:
    device = torch.device("cpu")
    dtype = torch.float32

# Load model/tokenizer once at startup (first cold start will download)
tokenizer = AutoTokenizer.from_pretrained(MODEL_ID, use_fast=True)
model = AutoModel.from_pretrained(MODEL_ID).to(device)
model.eval()

class EmbedRequest(BaseModel):
    texts: List[str]

def mean_pooling(last_hidden_state, attention_mask):
    # last_hidden_state: [B, T, H], attention_mask: [B, T]
    mask = attention_mask.unsqueeze(-1).expand(last_hidden_state.size()).float()
    summed = (last_hidden_state * mask).sum(dim=1)
    counts = torch.clamp(mask.sum(dim=1), min=1e-9)
    return summed / counts

@app.get("/health")
def health():
    return {"ok": True, "model": MODEL_ID, "device": str(device)}

@app.post("/embed")
@torch.inference_mode()
def embed(req: EmbedRequest):
    if not req.texts:
        return {"vectors": []}
    enc = tokenizer(
        req.texts,
        padding=True,
        truncation=True,
        return_tensors="pt"
    )
    enc = {k: v.to(device) for k, v in enc.items()}
    outputs = model(**enc)

    if POOLING == "cls":
        # RoBERTa-style CLS is token 0
        pooled = outputs.last_hidden_state[:, 0]
    else:
        pooled = mean_pooling(outputs.last_hidden_state, enc["attention_mask"])

    # Normalize (optional but common for cosine similarity)
    pooled = torch.nn.functional.normalize(pooled, p=2, dim=-1)

    return {"vectors": pooled.detach().to("cpu").float().tolist()}
