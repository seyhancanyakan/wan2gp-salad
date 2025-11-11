# WanGP Salad Docker Build Talimatları

## Ön Koşullar

Lokal makinende şunlar kurulu olmalı:
- ✅ Docker
- ✅ NVIDIA driver
- ✅ nvidia-container-toolkit (GPU desteği için)
- ✅ Docker Hub hesabı

## Adım 1: Docker İmajını Build Et

```bash
cd wan2gp-salad

# Docker Hub kullanıcı adınızı değiştirin
docker build -t YOUR_DOCKERHUB_USER/wan2gp-salad:latest .
```

**Örnek:**
```bash
docker build -t seyha/wan2gp-salad:latest .
```

Build süresi: ~15-30 dakika (internet hızına bağlı)

## Adım 2: Lokal Test (ÇOK ÖNEMLİ!)

Salad'a göndermeden önce mutlaka test edin:

```bash
docker run --rm -it \
  --gpus all \
  -p 7860:7860 \
  YOUR_DOCKERHUB_USER/wan2gp-salad:latest
```

**Örnek:**
```bash
docker run --rm -it \
  --gpus all \
  -p 7860:7860 \
  seyha/wan2gp-salad:latest
```

### Beklenen Davranış:
- ✅ Container loglarında `Running on 0.0.0.0:7860` görünmeli
- ✅ http://localhost:7860 adresinde WanGP arayüzü açılmalı
- ❌ "ModuleNotFoundError: torch" OLMAMALI
- ❌ "flash-attn" derleme hataları OLMAMALI

Test başarılıysa Ctrl+C ile durdurun ve devam edin.

## Adım 3: Docker Hub'a Push

```bash
# Docker Hub'a giriş
docker login

# İmajı push et
docker push YOUR_DOCKERHUB_USER/wan2gp-salad:latest
```

**Örnek:**
```bash
docker push seyha/wan2gp-salad:latest
```

## Adım 4: Salad Portal Konfigürasyonu

Salad Portal'da yeni Container Group oluştur:

### Image Configuration:
- **Image Source:** `YOUR_DOCKERHUB_USER/wan2gp-salad:latest`
- **Replicas:** 1

### Hardware:
- **GPU:** RTX 3090 / 4090 / A5000 (önerilen)
- **CPU:** En az 8 vCPU
- **RAM:** 16-24 GB

### Container Gateway:
- **Enabled:** ✅ Evet
- **Port:** 7860
- **Auth:** Not required (isteğe bağlı)

### Command Override:
- **Command:** BOŞ BIRAK! (imajın kendi ENTRYPOINT'i var)

### Probes (isteğe bağlı):
İlk etapta kapalı bırakabilirsin. Stabil olunca:
- **Readiness Probe:** HTTP GET / port 7860

## Beklenen Sonuç

✅ **Başarılı Deployment:**
- Logs: Sadece WanGP uygulamasının logları
- Access URL: https://....salad.cloud → 503 YOK, direkt arayüz açılır
- GPU kullanımı görünür olmalı

❌ **Hala 503 alıyorsan:**
1. Container loglarını kontrol et
2. Port 7860'ın doğru expose edildiğinden emin ol
3. Container Gateway ayarlarını tekrar kontrol et

## Troubleshooting

### "no matching manifest" hatası:
- Docker Hub'a push ettiğinden emin ol
- İmaj adının doğru olduğunu kontrol et

### GPU bulunamıyor:
- Salad'da GPU seçtiğinden emin ol
- Lokal testte `--gpus all` kullandığından emin ol

### Port erişilemiyor:
- Container Gateway'de port 7860 olmalı
- ENTRYPOINT'te `--listen 0.0.0.0` var mı kontrol et

## Docker Hub Kullanıcı Adını Değiştirmeyi Unutma!

Bu dokümandaki tüm `YOUR_DOCKERHUB_USER` yerlerini kendi kullanıcı adınla değiştir.
