# Pacific Tracker 🌊

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)

**Aplikasi Flutter untuk tracking berbagai objek menggunakan Computer Vision dengan OpenAI GPT-5**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture) • [API Integration](#-api-integration)

</div>

---

## 📋 Deskripsi

Pacific Tracker adalah aplikasi mobile berbasis Flutter yang memanfaatkan teknologi Computer Vision dari OpenAI GPT-5 untuk melakukan tracking dan pembacaan otomatis dari berbagai jenis objek, seperti meteran air, timbangan, dan plat kendaraan. Aplikasi ini dirancang untuk mempermudah proses pencatatan data dengan akurasi tinggi dan antarmuka yang user-friendly.

## ✨ Features

### 1. **Track Meter Air** 💧
- Membaca angka pada meteran air secara otomatis
- Menghilangkan noise dan digit yang tidak valid
- Hasil pembacaan akurat hingga 6 digit

### 2. **Track Timbangan** ⚖️
- Membaca angka pada layar timbangan digital
- Mengabaikan satuan dan simbol non-digit
- Pembacaan akurat tanpa bagian desimal

### 3. **Track Plat Kendaraan** 🚗
- Membaca nomor plat kendaraan Indonesia
- Identifikasi karakter dengan akurasi tinggi
- Format huruf kapital sesuai standar plat Indonesia

### Fitur Umum:
- ✅ Upload gambar dari galeri atau kamera
- ✅ Deteksi orientasi gambar otomatis (landscape/portrait/square)
- ✅ Real-time processing dengan loading indicator
- ✅ Tampilan biaya token (USD & IDR)
- ✅ Durasi processing time
- ✅ UI/UX modern dengan gradient theme
- ✅ Multi-feature selection

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **AI Model**: OpenAI GPT-5
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Image Handling**: image_picker
- **Environment Variables**: flutter_dotenv

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  another_dashed_container: ^1.0.0
  image_picker: ^1.2.1
  http: ^1.6.0
  dart_openai: ^6.1.0
  flutter_dotenv: ^6.0.0
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.7
```

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.0 atau lebih tinggi)
- Dart SDK
- Android Studio / VS Code dengan Flutter extension
- OpenAI API Key

### Langkah-langkah:

1. **Clone repository**
```bash
git clone https://github.com/username/pacific-tracker.git
cd pacific-tracker
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Environment Variables**
   
   Buat file `.env` di root project:
```env
OPENAI_API_KEY=your_openai_api_key_here
```

4. **Run aplikasi**
```bash
flutter run
```

## 📱 Usage

### 1. Pilih Feature
- Buka aplikasi dan pilih salah satu tracking feature di homepage
- Tersedia 3 pilihan: Track Meter Air, Track Timbangan, atau Track Plat Kendaraan

### 2. Upload Image
- Tap pada area dashed container untuk memilih sumber gambar
- Pilih dari **Kamera** untuk mengambil foto langsung
- Atau pilih dari **Galeri** untuk menggunakan foto yang sudah ada

### 3. Process Image
- Setelah gambar dipilih, tap tombol **"Process"**
- Tunggu beberapa detik untuk processing
- Hasil akan ditampilkan beserta informasi token dan biaya

### 4. View Results
Hasil yang ditampilkan meliputi:
- 📊 **Meter Number/Result**: Hasil pembacaan
- 🎯 **Token Amount**: Total token yang digunakan
- 💰 **Price**: Biaya dalam USD dan IDR
- ⏱️ **Duration**: Waktu processing

## 🏗️ Architecture

### Project Structure

```
lib/
├── constants/
│   ├── constant.dart           # Base URL dan konstanta
│   └── features.dart            # Definisi fitur dan prompt
│
├── helper/
│   └── function_helper.dart     # Helper functions (image picker, gradients)
│
├── models/
│   ├── display_model.dart       # Model untuk display result
│   └── openai_model.dart        # Model untuk response OpenAI
│
├── pages/
│   ├── home_page.dart           # Halaman utama dengan grid features
│   └── track_meter_page.dart    # Halaman tracking dengan camera/gallery
│
├── services/
│   └── tracker_service.dart     # Service untuk API call ke OpenAI
│
└── widgets/
    ├── feature_card.dart        # Card component untuk setiap feature
    ├── image_widget.dart        # Widget untuk display gambar
    └── result_widget.dart       # Widget untuk display hasil
```

### Data Flow

```
User Input → Image Selection → Image Processing → API Call → Result Display
     ↓              ↓                  ↓              ↓            ↓
HomePage → TrackMeterPage → TrackerService → OpenAI API → DisplayModel
```

## 🔌 API Integration

### OpenAI GPT-5 Integration

Aplikasi ini menggunakan OpenAI Responses API dengan model `gpt-5.1`:

**Endpoint**: `https://api.openai.com/v1/responses`

**Request Structure**:
```json
{
  "model": "gpt-5.1",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "Custom prompt based on feature"
        },
        {
          "type": "input_image",
          "image_url": "data:image/jpeg;base64,{base64_string}"
        }
      ]
    }
  ]
}
```

**Response Structure**:
```json
{
  "id": "response_id",
  "model": "gpt-5.1",
  "output": [
    {
      "content": [
        {
          "type": "text",
          "text": "Result text"
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 1000,
    "output_tokens": 50,
    "total_tokens": 1050
  }
}
```

### Cost Calculation

Biaya dihitung berdasarkan pricing GPT-5:
- **Input**: $1.25 per 1M tokens
- **Output**: $10.00 per 1M tokens
- **Kurs**: IDR 16,000 per USD (dapat disesuaikan)

Formula:
```dart
costUSD = (inputTokens × 1.25 / 1,000,000) + (outputTokens × 10.0 / 1,000,000)
costIDR = costUSD × 16,000
```

## 🎨 UI Components

### Home Page
- **SliverAppBar** dengan gradient background
- **Grid Layout** untuk menampilkan feature cards
- **Dynamic Gradients** untuk setiap feature card

### Track Meter Page
- **AppBar** dengan gradient dan back button
- **Dashed Container** untuk upload area
- **Image Display** dengan orientasi detection
- **Process & Cancel** buttons
- **Result Card** dengan detail informasi

### Widgets
1. **FeatureCard**: Card dengan icon, title, dan gradient
2. **ImageWidget**: Display gambar dengan shadow dan rounded corners
3. **ResultWidget**: Card untuk menampilkan hasil processing

## 🎯 Custom Prompts

Setiap feature memiliki prompt yang dioptimasi untuk hasil terbaik:

### Track Meter Air
```
Baca angka pada meteran air di gambar. Hanya baca digit yang tampil penuh 
di dalam kotak digit; abaikan garis pemisah, bayangan, atau bentuk non-digit. 
Hilangkan semua nol di depan. Gabungkan digit valid berupa 6 angka dan 
tampilkan angkanya saja tanpa penjelasan.
```

### Track Timbangan
```
Baca angka pada layar timbangan di gambar. Hanya baca digit yang tampil jelas 
pada layar; abaikan satuan, simbol, indikator, desimal, atau bentuk non-digit. 
Hilangkan bagian desimal jika ada. Gabungkan digit valid dan tampilkan 
angkanya saja tanpa penjelasan.
```

### Track Plat Kendaraan
```
Baca nomor plat kendaraan pada gambar. Hanya baca karakter plat kendaraan 
Indonesia yang tampil jelas; abaikan baut plat, logo, stiker, atau bentuk 
non-karakter. Gunakan huruf kapital dan gabungkan karakter valid. Tampilkan 
nomor plat saja tanpa penjelasan.
```

## 🔐 Security

- API Key disimpan dalam `.env` file (tidak di-commit ke repository)
- File `.env` harus ditambahkan ke `.gitignore`
- Base64 encoding untuk image transmission
- HTTPS protocol untuk API communication

### .gitignore
```gitignore
.env
*.env
.env.local
```

## 📊 Performance

- **Average Processing Time**: 3-5 detik
- **Image Size**: Optimal < 5MB
- **Supported Formats**: JPEG, PNG
- **Token Usage**: Rata-rata 1000-2000 tokens per request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenAI](https://openai.com) untuk GPT-5 API
- [Flutter](https://flutter.dev) untuk framework
- [Image Picker Plugin](https://pub.dev/packages/image_picker) untuk image handling
- Komunitas Flutter Indonesia

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star project ini jika membantu!

</div>
