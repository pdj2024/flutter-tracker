import 'dart:convert';

ResponseModel responseModelFromJson(String str) =>
    ResponseModel.fromJson(json.decode(str));

String responseModelToJson(ResponseModel data) => json.encode(data.toJson());

class ResponseModel {
  final String id;
  final String object;
  final int createdAt;
  final String status;
  final dynamic error;
  final dynamic incompleteDetails;
  final dynamic instructions;
  final dynamic maxOutputTokens;
  final String model;
  final List<Output> output;
  final bool parallelToolCalls;
  final dynamic previousResponseId;
  final Reasoning reasoning;
  final bool store;
  final double temperature;
  final TextFormat text;
  final String toolChoice;
  final List<dynamic> tools;
  final double topP;
  final String truncation;
  final Usage usage;
  final dynamic user;
  final Map<String, dynamic> metadata;

  ResponseModel({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.status,
    required this.error,
    required this.incompleteDetails,
    required this.instructions,
    required this.maxOutputTokens,
    required this.model,
    required this.output,
    required this.parallelToolCalls,
    required this.previousResponseId,
    required this.reasoning,
    required this.store,
    required this.temperature,
    required this.text,
    required this.toolChoice,
    required this.tools,
    required this.topP,
    required this.truncation,
    required this.usage,
    required this.user,
    required this.metadata,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
        id: json["id"],
        object: json["object"],
        createdAt: json["created_at"],
        status: json["status"],
        error: json["error"],
        incompleteDetails: json["incomplete_details"],
        instructions: json["instructions"],
        maxOutputTokens: json["max_output_tokens"],
        model: json["model"],
        output: List<Output>.from(json["output"].map((x) => Output.fromJson(x))),
        parallelToolCalls: json["parallel_tool_calls"],
        previousResponseId: json["previous_response_id"],
        reasoning: Reasoning.fromJson(json["reasoning"]),
        store: json["store"],
        temperature: (json["temperature"] as num).toDouble(),
        text: TextFormat.fromJson(json["text"]),
        toolChoice: json["tool_choice"],
        tools: List<dynamic>.from(json["tools"].map((x) => x)),
        topP: (json["top_p"] as num).toDouble(),
        truncation: json["truncation"],
        usage: Usage.fromJson(json["usage"]),
        user: json["user"],
        metadata: json["metadata"] ?? {},
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "created_at": createdAt,
        "status": status,
        "error": error,
        "incomplete_details": incompleteDetails,
        "instructions": instructions,
        "max_output_tokens": maxOutputTokens,
        "model": model,
        "output": List<dynamic>.from(output.map((x) => x.toJson())),
        "parallel_tool_calls": parallelToolCalls,
        "previous_response_id": previousResponseId,
        "reasoning": reasoning.toJson(),
        "store": store,
        "temperature": temperature,
        "text": text.toJson(),
        "tool_choice": toolChoice,
        "tools": List<dynamic>.from(tools.map((x) => x)),
        "top_p": topP,
        "truncation": truncation,
        "usage": usage.toJson(),
        "user": user,
        "metadata": metadata,
      };
}

// ========================= OUTPUT =========================

class Output {
  final String type;
  final String id;
  final String status;
  final String role;
  final List<OutputContent> content;

  Output({
    required this.type,
    required this.id,
    required this.status,
    required this.role,
    required this.content,
  });

  factory Output.fromJson(Map<String, dynamic> json) => Output(
        type: json["type"],
        id: json["id"],
        status: json["status"],
        role: json["role"],
        content: List<OutputContent>.from(
            json["content"].map((x) => OutputContent.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "status": status,
        "role": role,
        "content": List<dynamic>.from(content.map((x) => x.toJson())),
      };
}

class OutputContent {
  final String type;
  final String text;
  final List<dynamic> annotations;

  OutputContent({
    required this.type,
    required this.text,
    required this.annotations,
  });

  factory OutputContent.fromJson(Map<String, dynamic> json) => OutputContent(
        type: json["type"],
        text: json["text"],
        annotations: List<dynamic>.from(json["annotations"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "text": text,
        "annotations": List<dynamic>.from(annotations.map((x) => x)),
      };
}

// ========================= REASONING =========================

class Reasoning {
  final dynamic effort;
  final dynamic summary;

  Reasoning({required this.effort, required this.summary});

  factory Reasoning.fromJson(Map<String, dynamic> json) => Reasoning(
        effort: json["effort"],
        summary: json["summary"],
      );

  Map<String, dynamic> toJson() => {
        "effort": effort,
        "summary": summary,
      };
}

// ========================= TEXT =========================

class TextFormat {
  final TextFormatType format;

  TextFormat({required this.format});

  factory TextFormat.fromJson(Map<String, dynamic> json) => TextFormat(
        format: TextFormatType.fromJson(json["format"]),
      );

  Map<String, dynamic> toJson() => {
        "format": format.toJson(),
      };
}

class TextFormatType {
  final String type;

  TextFormatType({required this.type});

  factory TextFormatType.fromJson(Map<String, dynamic> json) =>
      TextFormatType(type: json["type"]);

  Map<String, dynamic> toJson() => {
        "type": type,
      };
}

// ========================= USAGE =========================

class Usage {
  final int inputTokens;
  final InputTokensDetails inputTokensDetails;
  final int outputTokens;
  final OutputTokensDetails outputTokensDetails;
  final int totalTokens;

  Usage({
    required this.inputTokens,
    required this.inputTokensDetails,
    required this.outputTokens,
    required this.outputTokensDetails,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
        inputTokens: json["input_tokens"],
        inputTokensDetails:
            InputTokensDetails.fromJson(json["input_tokens_details"]),
        outputTokens: json["output_tokens"],
        outputTokensDetails:
            OutputTokensDetails.fromJson(json["output_tokens_details"]),
        totalTokens: json["total_tokens"],
      );

  Map<String, dynamic> toJson() => {
        "input_tokens": inputTokens,
        "input_tokens_details": inputTokensDetails.toJson(),
        "output_tokens": outputTokens,
        "output_tokens_details": outputTokensDetails.toJson(),
        "total_tokens": totalTokens,
      };
}

class InputTokensDetails {
  final int cachedTokens;

  InputTokensDetails({required this.cachedTokens});

  factory InputTokensDetails.fromJson(Map<String, dynamic> json) =>
      InputTokensDetails(cachedTokens: json["cached_tokens"]);

  Map<String, dynamic> toJson() => {
        "cached_tokens": cachedTokens,
      };
}

class OutputTokensDetails {
  final int reasoningTokens;

  OutputTokensDetails({required this.reasoningTokens});

  factory OutputTokensDetails.fromJson(Map<String, dynamic> json) =>
      OutputTokensDetails(reasoningTokens: json["reasoning_tokens"]);

  Map<String, dynamic> toJson() => {
        "reasoning_tokens": reasoningTokens,
      };
}
