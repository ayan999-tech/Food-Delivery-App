import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String apiKey = "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";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are a friendly food delivery assistant for QuickBite app. Keep responses concise and helpful."
            },
            {
              "role": "user",
              "content": message
            }
          ],
          "max_tokens": 150,
          "temperature": 0.7,
        }),
      );

      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"].trim();
      } else {
        final errorData = jsonDecode(response.body);
        print("Error: $errorData");
        return "Sorry, I'm having trouble connecting. Please try again.";
      }
    } catch (e) {
      print("Exception: $e");
      return "Connection error. Please check your internet.";
    }
  }
}


