FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/workspace/.cache/huggingface \
    TORCH_ALLOW_TF32_CUBLAS=1 \
    TORCH_ALLOW_TF32_CUDNN=1 \
    SDL_AUDIODRIVER=dummy \
    PULSE_RUNTIME_PATH=/tmp/pulse-runtime

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3-pip \
    wget \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# pip güncelle
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# ÖNCE PyTorch kur (CUDA 12.4 uyumlu)
RUN pip install --no-cache-dir \
    torch==2.6.0+cu124 \
    torchvision==0.21.0+cu124 \
    torchaudio==2.6.0+cu124 \
    --extra-index-url https://download.pytorch.org/whl/cu124

# WanGP kodunu github'dan çek
RUN git clone https://github.com/deepbeepmeep/Wan2GP.git /workspace

# Kalan bağımlılıklar
RUN pip install --no-cache-dir -r /workspace/requirements.txt

# Cache directory
RUN mkdir -p /workspace/.cache/huggingface

# Port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:7860/ || exit 1

# Start
ENTRYPOINT ["python3", "wgp.py"]
CMD ["--listen", "0.0.0.0", "--port", "7860", "--share"]
