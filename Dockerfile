FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/workspace/.cache/huggingface \
    TORCH_ALLOW_TF32_CUBLAS=1 \
    TORCH_ALLOW_TF32_CUDNN=1 \
    SDL_AUDIODRIVER=dummy \
    PULSE_RUNTIME_PATH=/tmp/pulse-runtime

# Sistem bağımlılıkları (tek layer, cache temizlikli)
RUN apt-get update && apt-get install -y \
    git python3.10 python3-pip wget curl ffmpeg libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workspace

# pip güncelle ve PyTorch kur (tek layer)
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
        torch==2.6.0+cu124 \
        torchvision==0.21.0+cu124 \
        torchaudio==2.6.0+cu124 \
        --extra-index-url https://download.pytorch.org/whl/cu124 && \
    rm -rf ~/.cache/pip /tmp/*

# WanGP kodu (shallow clone)
RUN git clone --depth 1 https://github.com/deepbeepmeep/Wan2GP.git /workspace && \
    rm -rf /workspace/.git

# Requirements install ve temizlik
RUN pip install --no-cache-dir -r /workspace/requirements.txt && \
    rm -rf ~/.cache/pip /tmp/* && \
    find /usr/local/lib/python3.10 -name '*.pyc' -delete && \
    find /usr/local/lib/python3.10 -name '__pycache__' -delete

RUN mkdir -p /workspace/.cache/huggingface

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:7860/ || exit 1

# FIX: wgp.py --listen flag doğru formatı
CMD ["python3", "wgp.py", "--listen", "--server-name", "0.0.0.0", "--server-port", "7860", "--share"]
