FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/workspace/.cache/huggingface \
    TORCH_ALLOW_TF32_CUBLAS=1 \
    TORCH_ALLOW_TF32_CUDNN=1 \
    SDL_AUDIODRIVER=dummy \
    PULSE_RUNTIME_PATH=/tmp/pulse-runtime

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    git python3.10 python3-pip wget curl ffmpeg libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workspace

# pip güncelle
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# PyTorch NIGHTLY - RTX 5090 (sm_120) desteği için
# cu121 nightly kullan (cu124 nightly repo yok)
RUN pip install --no-cache-dir \
    --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu121 && \
    rm -rf ~/.cache/pip /tmp/*

# WanGP kodu
RUN git clone --depth 1 https://github.com/deepbeepmeep/Wan2GP.git /workspace && \
    rm -rf /workspace/.git

# Requirements install
RUN pip install --no-cache-dir -r /workspace/requirements.txt && \
    rm -rf ~/.cache/pip /tmp/* && \
    find /usr/local/lib/python3.10 -name '*.pyc' -delete && \
    find /usr/local/lib/python3.10 -name '__pycache__' -delete

RUN mkdir -p /workspace/.cache/huggingface

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:7860/ || exit 1

# Doğru argüman formatı
CMD ["python3", "wgp.py", "--listen", "--server-name", "0.0.0.0", "--server-port", "7860", "--share"]
