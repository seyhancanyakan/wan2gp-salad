# WanGP Salad Docker İmajı

Bu Docker imajı, Salad platformunda WanGP (Wan2GP) TTS modelini sorunsuz çalıştırmak için hazırlanmıştır.

## Hızlı Başlangıç

```bash
# 1. Build
docker build -t YOUR_DOCKERHUB_USER/wan2gp-salad:latest .

# 2. Lokal Test
docker run --rm -it --gpus all -p 7860:7860 YOUR_DOCKERHUB_USER/wan2gp-salad:latest

# 3. Push
docker push YOUR_DOCKERHUB_USER/wan2gp-salad:latest
```

Detaylı talimatlar için [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) dosyasına bakın.

## Sorun Çözümü

### Orijinal Sorun
`olilanz/ai-wan21-gp` imajı:
- ❌ Container başlangıcında pip upgrade yapıyor
- ❌ flash-attn derlemeye çalışıyor
- ❌ torch bulamıyor ve çöküyor
- ❌ Salad 503 veriyor

### Bu İmajın Çözümü
- ✅ Önce torch, sonra requirements (doğru sıra)
- ✅ CUDA 12.4 uyumlu torch sürümü
- ✅ Ekstra script yok, sadece `wgp.py` çalışır
- ✅ Deterministik build süreci

## Özellikler

- **Base Image:** nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
- **Python:** 3.10
- **PyTorch:** 2.7.0 (CUDA 12.8 index)
- **Port:** 7860
- **ENTRYPOINT:** `python3 wgp.py --listen 0.0.0.0 --port 7860`

## Salad Konfigürasyonu

```yaml
Image: YOUR_DOCKERHUB_USER/wan2gp-salad:latest
GPU: RTX 3090/4090/A5000
CPU: 8 vCPU
RAM: 16-24 GB
Port: 7860
Command: (boş bırak)
```

## Kaynak

- WanGP GitHub: https://github.com/deepbeepmeep/Wan2GP
- Salad Docs: https://docs.salad.com/
