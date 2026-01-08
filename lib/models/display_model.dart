class DisplayModel {
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final String resultText;
  final double costUsd;
  final double costIdr;

  DisplayModel({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.resultText,
    required this.costUsd,
    required this.costIdr,
  });

  factory DisplayModel.fromUsageAndResult({
    required int inputTokens,
    required int outputTokens,
    required int totalTokens,
    required String resultText,
    required double costUsd,
    required double costIdr,
  }) {

    return DisplayModel(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      totalTokens: totalTokens,
      resultText: resultText,
      costUsd: costUsd,
      costIdr: costIdr,
    );
  }

  Map<String, dynamic> toJson() => {
        "input_tokens": inputTokens,
        "output_tokens": outputTokens,
        "total_tokens": totalTokens,
        "result_text": resultText,
        "cost_usd": costUsd,
        "cost_idr": costIdr,
      };
}
