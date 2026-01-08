import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:track_image/constants/constant.dart';
import 'package:track_image/models/display_model.dart';
import 'package:track_image/models/openai_model.dart';

class TrackerService {
  Future<DisplayModel?> askOpenAI(
    File imageFile, {
    String? customPrompt,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final base64Img = await imageToBase64(imageFile);
    final String promptToUse =
        customPrompt ??
        "Baca angka pada meteran air di gambar. Hanya baca digit yang tampil penuh di dalam kotak digit; abaikan garis pemisah, bayangan, atau bentuk non-digit. Hilangkan semua nol di depan. Gabungkan digit valid berupa 6 angka dan tampilkan angkanya saja tanpa penjelasan.";
    print("========== APIKEY -> $apiKey");

    final url = Uri.parse(Constant.baseUrl);

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final body = {
      "model": "gpt-5.1",
      "input": [
        {
          "role": "user",
          "content": [
            {"type": "input_text", "text": promptToUse},
            {
              "type": "input_image",
              "image_url": "data:image/jpeg;base64,$base64Img",
            },
          ],
        },
      ],
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    print("========== isi response = ${response.statusCode}");
    final data = jsonDecode(response.body);
    print("========== isi body = $data");

    final result = ResponseModel.fromJson(data);

    final usage = result.usage;

    final cost = calculateGpt5Cost(
      inputTokens: usage.inputTokens,
      outputTokens: usage.outputTokens,
      totalTokens: usage.totalTokens,
    );

    final display = DisplayModel.fromUsageAndResult(
      inputTokens: usage.inputTokens,
      outputTokens: usage.outputTokens,
      totalTokens: usage.totalTokens,
      resultText: result.output.first.content.first.text,
      costUsd: cost["usd"] ?? 0,
      costIdr: cost['idr'] ?? 0,
    );

    print("========== isi display = ${display.toJson()}");

    return display;
  }

  Future<String> imageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Map<String, double> calculateGpt5Cost({
    required int inputTokens,
    required int outputTokens,
    required int totalTokens,
  }) {
    // Harga GPT-5 (per 1 juta token)
    const double inputPricePer1M = 1.25;
    const double outputPricePer1M = 10.0;
    const double usdToIdr = 16000; // kurs bisa Anda ubah

    // Hitung harga per token
    final double inputPricePerToken = inputPricePer1M / 1000000;
    final double outputPricePerToken = outputPricePer1M / 1000000;

    // Hitung biaya
    final double costInputUsd = inputTokens * inputPricePerToken;
    final double costOutputUsd = outputTokens * outputPricePerToken;

    final double totalUsd = costInputUsd + costOutputUsd;
    final double totalIdr = totalUsd * usdToIdr;

    return {
      "usd": double.parse(totalUsd.toStringAsFixed(10)),
      "idr": double.parse(totalIdr.toStringAsFixed(2)),
    };
  }

  Future<String?> getImageOrientation(File? imageFile) async {
    if (imageFile == null) return null;

    final bytes = await imageFile.readAsBytes();

    // Decode ukuran gambar
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final width = image.width;
    final height = image.height;

    if (width > height) {
      return "landscape";
    } else if (height > width) {
      return "portrait";
    } else {
      return "square";
    }
  }
}
