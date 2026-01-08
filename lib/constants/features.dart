import 'package:flutter/material.dart';

class Features {
  static List<Map<String, dynamic>> feature = [
    {
      "title": "Track Meter Air",
      "icon": Icons.water_drop,
      "prompt":
          "Baca angka pada meteran air di gambar. Hanya baca digit yang tampil penuh di dalam kotak digit; abaikan garis pemisah, bayangan, atau bentuk non-digit. Hilangkan semua nol di depan. Gabungkan digit valid berupa 6 angka dan tampilkan angkanya saja tanpa penjelasan.",
    },
    {
      "title": "Track Timbangan",
      "icon": Icons.monitor_weight_outlined,
      "prompt":
          "Baca angka pada layar timbangan di gambar. Hanya baca digit yang tampil jelas pada layar; abaikan satuan, simbol, indikator, desimal, atau bentuk non-digit. Hilangkan bagian desimal jika ada. Gabungkan digit valid dan tampilkan angkanya saja tanpa penjelasan.",
    },
    {
      "title": "Track Plat Kendaraan",
      "icon": Icons.directions_car,
      "prompt":
          "Baca nomor plat kendaraan pada gambar. Hanya baca karakter plat kendaraan Indonesia yang tampil jelas; abaikan baut plat, logo, stiker, atau bentuk non-karakter. Gunakan huruf kapital dan gabungkan karakter valid. Tampilkan nomor plat saja tanpa penjelasan.",
    },
  ];
}
