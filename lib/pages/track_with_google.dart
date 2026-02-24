import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum jenis tracker
// ─────────────────────────────────────────────────────────────────────────────

enum TrackerType {
  meterAir,
  timbangan,
  platKendaraan,
  unknown;

  static TrackerType fromPrompt(String prompt) {
    switch (prompt.toLowerCase()) {
      case 'meter_air':
        return TrackerType.meterAir;
      case 'timbangan':
        return TrackerType.timbangan;
      case 'plat_kendaraan':
        return TrackerType.platKendaraan;
      default:
        return TrackerType.unknown;
    }
  }

  String get label {
    switch (this) {
      case TrackerType.meterAir:
        return 'Meteran Air';
      case TrackerType.timbangan:
        return 'Timbangan';
      case TrackerType.platKendaraan:
        return 'Plat Kendaraan';
      case TrackerType.unknown:
        return 'Teks';
    }
  }

  String get hint {
    switch (this) {
      case TrackerType.meterAir:
        return 'Crop pada deretan kotak angka meteran';
      case TrackerType.timbangan:
        return 'Crop ketat pada layar display angka';
      case TrackerType.platKendaraan:
        return 'Crop pada seluruh area plat kendaraan';
      case TrackerType.unknown:
        return 'Crop pada area teks yang ingin dibaca';
    }
  }

  // Apakah hasil berupa teks (plat) atau angka
  bool get isText => this == TrackerType.platKendaraan;
}

// ─────────────────────────────────────────────────────────────────────────────
// Halaman Crop (terpisah, fullscreen)
// ─────────────────────────────────────────────────────────────────────────────

class _CropPage extends StatefulWidget {
  final Uint8List imageBytes;
  final String hint;

  const _CropPage({required this.imageBytes, required this.hint});

  @override
  State<_CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<_CropPage> {
  final CropController _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xff10bddc),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: const Text(
          'Crop Area',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isCropping
                ? null
                : () {
                    setState(() => _isCropping = true);
                    _cropController.crop();
                  },
            child: _isCropping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.black87,
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xff10bddc),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.hint,
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              onCropped: (result) {
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    Navigator.pop(context, croppedImage);
                  case CropFailure():
                    Navigator.pop(context, null);
                }
              },
              initialRectBuilder: InitialRectBuilder.withBuilder((
                viewportRect,
                imageRect,
              ) {
                return Rect.fromLTWH(
                  viewportRect.left + viewportRect.width * 0.05,
                  viewportRect.top + viewportRect.height * 0.15,
                  viewportRect.width * 0.9,
                  viewportRect.height * 0.7,
                );
              }),
              maskColor: Colors.black.withOpacity(0.55),
              cornerDotBuilder: (size, edgeAlignment) =>
                  const DotControl(color: Color(0xff10bddc)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OCR Extractor — logika berbeda per jenis tracker
// ─────────────────────────────────────────────────────────────────────────────

class _OcrExtractor {
  /// Meteran air:
  /// - Ambil semua digit dari semua baris yang dikenali
  /// - Untuk digit yang "transisi" (posisi antara 2 angka), ambil yang lebih besar
  /// - Hapus leading zero
  /// - Ambil 5–7 digit terpanjang yang berurutan
  static String? extractMeterAir(RecognizedText recognized) {
    // Kumpulkan semua blok teks dari ML Kit
    final allLines = <String>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        allLines.add(line.text);
      }
    }

    // Cari baris yang paling banyak mengandung digit (kemungkinan baris angka meter)
    String bestLine = '';
    int bestDigitCount = 0;
    for (final line in allLines) {
      final digits = line.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length > bestDigitCount) {
        bestDigitCount = digits.length;
        bestLine = digits;
      }
    }

    if (bestLine.isEmpty) return null;

    // Hilangkan leading zero
    final trimmed = bestLine.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.isEmpty) return bestLine; // semua nol

    // Ambil maksimal 7 digit
    return trimmed.length > 7 ? trimmed.substring(0, 7) : trimmed;
  }

  /// Timbangan:
  /// - Ambil sequence angka terpanjang (display LED biasanya 4–6 digit)
  /// - Abaikan angka kecil (kemungkinan tanggal/kode, bukan berat)
  static String? extractTimbangan(RecognizedText recognized) {
    final raw = recognized.text;
    if (raw.isEmpty) return null;

    final matches = RegExp(r'\d{2,}').allMatches(raw);
    if (matches.isEmpty) return null;

    // Urutkan berdasarkan panjang, ambil terpanjang
    final sorted = matches.toList()
      ..sort((a, b) => b.group(0)!.length.compareTo(a.group(0)!.length));

    return sorted.first.group(0);
  }

  /// Plat kendaraan Indonesia:
  /// Pola: [1-2 huruf] [1-4 angka] [1-3 huruf]
  /// Contoh: B 2647 TZQ, D 1234 ABC, BK 123 A
  /// Mendukung plat putih, hitam, merah, kuning
  static String? extractPlatKendaraan(RecognizedText recognized) {
    final raw = recognized.text.toUpperCase();

    // Normalisasi: hapus newline & karakter aneh, pertahankan huruf-angka-spasi
    final normalized = raw
        .replaceAll(RegExp(r'[^A-Z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Regex plat Indonesia
    // Kode wilayah: 1-2 huruf
    // Nomor: 1-4 digit
    // Seri: 1-3 huruf (opsional)
    final platRegex = RegExp(r'\b([A-Z]{1,2})\s*(\d{1,4})\s*([A-Z]{1,3})?\b');

    final matches = platRegex.allMatches(normalized).toList();
    if (matches.isEmpty) return null;

    // Prioritaskan match yang memiliki seri huruf di belakang (lebih lengkap)
    matches.sort((a, b) {
      final aHasSuffix = (a.group(3) ?? '').isNotEmpty ? 1 : 0;
      final bHasSuffix = (b.group(3) ?? '').isNotEmpty ? 1 : 0;
      if (aHasSuffix != bHasSuffix) return bHasSuffix - aHasSuffix;
      // Jika sama, prioritaskan nomor yang lebih panjang
      return (b.group(2) ?? '').length.compareTo((a.group(2) ?? '').length);
    });

    final best = matches.first;
    final kode = best.group(1) ?? '';
    final nomor = best.group(2) ?? '';
    final seri = best.group(3) ?? '';

    // Format: "B 2647 TZQ" atau "B 2647" jika tidak ada seri
    if (seri.isNotEmpty) {
      return '$kode $nomor $seri';
    } else {
      return '$kode $nomor';
    }
  }

  /// Fallback: ambil semua teks
  static String? extractRaw(RecognizedText recognized) {
    return recognized.text.trim().isEmpty ? null : recognized.text.trim();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Page
// ─────────────────────────────────────────────────────────────────────────────

class TrackWithGoogle extends StatefulWidget {
  final String featureTitle;
  final String featurePrompt;
  final IconData featureIcon;

  const TrackWithGoogle({
    super.key,
    required this.featureTitle,
    required this.featurePrompt,
    required this.featureIcon,
  });

  @override
  State<TrackWithGoogle> createState() => _TrackWithGoogleState();
}

class _TrackWithGoogleState extends State<TrackWithGoogle> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  late final TrackerType _trackerType;

  File? _originalFile;
  Uint8List? _croppedBytes;

  String? _result; // hasil bersih (angka / plat)
  String? _rawText; // teks mentah dari ML Kit (untuk debug)

  bool _isScanning = false;

  bool get _isLoading => _isScanning;
  bool get _hasResult => _croppedBytes != null && !_isLoading;

  @override
  void initState() {
    super.initState();
    _trackerType = TrackerType.fromPrompt(widget.featurePrompt);
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  // ── Ambil gambar ──────────────────────────────────────────────────────────

  void _pickFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (picked != null) await _openCrop(File(picked.path));
  }

  void _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked != null) await _openCrop(File(picked.path));
  }

  // ── Crop ──────────────────────────────────────────────────────────────────

  Future<void> _openCrop(File file) async {
    final bytes = await file.readAsBytes();

    final result = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (_) => _CropPage(imageBytes: bytes, hint: _trackerType.hint),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _originalFile = file;
        _croppedBytes = result;
        _result = null;
        _rawText = null;
      });
      await _runOcr(result);
    }
  }

  Future<void> _recrop() async {
    if (_originalFile == null) return;
    await _openCrop(_originalFile!);
  }

  // ── OCR ───────────────────────────────────────────────────────────────────

  Future<void> _runOcr(Uint8List bytes) async {
    setState(() {
      _isScanning = true;
      _result = null;
      _rawText = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final tmpFile = File(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_crop.jpg',
      );
      await tmpFile.writeAsBytes(bytes);

      final inputImage = InputImage.fromFile(tmpFile);
      final RecognizedText recognized = await _textRecognizer.processImage(
        inputImage,
      );

      final rawText = recognized.text;
      final extracted = _extract(recognized);

      setState(() {
        _rawText = rawText;
        _result = extracted;
        _isScanning = false;
      });

      if (extracted != null) {
        _showSnackBar('${_trackerType.label} berhasil terbaca: $extracted');
      } else {
        _showSnackBar(
          'Tidak terdeteksi. Coba crop lebih ketat.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      _showSnackBar('Gagal membaca: $e', isError: true);
    }
  }

  String? _extract(RecognizedText recognized) {
    switch (_trackerType) {
      case TrackerType.meterAir:
        return _OcrExtractor.extractMeterAir(recognized);
      case TrackerType.timbangan:
        return _OcrExtractor.extractTimbangan(recognized);
      case TrackerType.platKendaraan:
        return _OcrExtractor.extractPlatKendaraan(recognized);
      case TrackerType.unknown:
        return _OcrExtractor.extractRaw(recognized);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Berhasil disalin ke clipboard');
  }

  void _reset() {
    setState(() {
      _originalFile = null;
      _croppedBytes = null;
      _result = null;
      _rawText = null;
    });
  }

  // ── UI: Empty state ───────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xff10bddc).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.featureIcon,
              size: 72,
              color: const Color(0xff10bddc),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.featureTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _trackerType.hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildStepIndicator(),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickFromCamera,
              icon: const Icon(Icons.camera_alt_rounded, size: 22),
              label: const Text(
                'Ambil Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10bddc),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_rounded, size: 22),
              label: const Text(
                'Pilih dari Galeri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff10bddc),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: Color(0xff10bddc), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      (Icons.camera_alt_rounded, 'Foto'),
      (Icons.crop_rounded, 'Crop'),
      (Icons.document_scanner_rounded, 'Scan'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Container(
            width: 28,
            height: 2,
            color: const Color(0xff10bddc).withOpacity(0.3),
          );
        }
        final s = steps[i ~/ 2];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff10bddc).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(s.$1, size: 18, color: const Color(0xff10bddc)),
            ),
            const SizedBox(height: 4),
            Text(
              s.$2,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        );
      }),
    );
  }

  // ── UI: Loading state ─────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_croppedBytes != null) ...[
            _buildCroppedPreview(showOverlay: true),
            const SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff10bddc)),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Membaca ${_trackerType.label}...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ML Kit menganalisis area yang di-crop',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── UI: Result state ──────────────────────────────────────────────────────

  Widget _buildResultState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCroppedPreview(),
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: _recrop,
              icon: const Icon(Icons.crop_rounded, size: 16),
              label: const Text('Crop Ulang', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff10bddc),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildResultCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff10bddc), Color(0xff2fd5f2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.featureIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil: ${_trackerType.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Diproses dengan Google ML Kit',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _result != null
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _result != null ? 'Terbaca' : 'Gagal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: _result != null
                ? _buildResultDisplay(_result!)
                : _buildNotFound(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDisplay(String result) {
    // Plat kendaraan → tampilan berbeda (plat hitam)
    if (_trackerType == TrackerType.platKendaraan) {
      return _buildPlatDisplay(result);
    }
    // Angka (meteran/timbangan) → LED display
    return _buildNumberDisplay(result);
  }

  /// LED-style display untuk angka
  Widget _buildNumberDisplay(String number) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xff1a1a2e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800, width: 2),
          ),
          child: Text(
            number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Color(0xffff3c3c),
              letterSpacing: 8,
              shadows: [
                Shadow(
                  blurRadius: 16,
                  color: Color(0xffff3c3c),
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCopyButton(number),
      ],
    );
  }

  /// Plat kendaraan Indonesia
  Widget _buildPlatDisplay(String plat) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Strip atas hitam tipis (seperti plat asli)
              Container(
                width: double.infinity,
                height: 6,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // TEXT PLAT (auto shrink jadi 1 line)
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    plat,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 6,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                height: 6,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCopyButton(plat),
      ],
    );
  }

  Widget _buildCopyButton(String value) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _copyToClipboard(value),
        icon: const Icon(Icons.copy_rounded, size: 18),
        label: Text(
          _trackerType == TrackerType.platKendaraan
              ? 'Salin Nomor Plat'
              : 'Salin Angka',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff10bddc),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Column(
      children: [
        Icon(Icons.search_off_rounded, size: 48, color: Colors.orange.shade400),
        const SizedBox(height: 12),
        Text(
          '${_trackerType.label} Tidak Terdeteksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _trackerType.hint,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _recrop,
            icon: const Icon(Icons.crop_rounded, size: 18),
            label: const Text(
              'Crop Ulang',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff10bddc),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        // Debug: teks mentah
        if (_rawText != null && _rawText!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teks mentah (debug):',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _rawText!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCroppedPreview({bool showOverlay = false}) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_croppedBytes!, fit: BoxFit.contain),
            if (showOverlay)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFromCamera,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Foto Ulang'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff10bddc),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xff10bddc)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Galeri'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff10bddc),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xff10bddc)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset',
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade600,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff10bddc),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.featureTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff10bddc), Color(0xff2fd5f2)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _originalFile == null
              ? _buildEmptyState()
              : _isLoading
              ? _buildLoadingState()
              : _buildResultState(),
        ),
      ),
    );
  }
}
