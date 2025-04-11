import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:echo_ai/global.dart' as global;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GeminiServices {
  List<Map<String, String>> messages = [];

  Future<String> checkIfImageGeneration(String prompt) async {
    try {
      final geminiApiKey = global.geminiApi;

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text":
                      "Does the following prompt want to generate a picture, art, or image?\n\n$prompt\n\nOnly answer in a yes or no format.",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'].trim();

        // Store the prompt and response in messages
        messages.add({'role': 'user', 'content': prompt});
        messages.add({'role': 'assistant', 'content': text});

        switch (text.toLowerCase()) {
          case 'yes':
          case 'yes.':
            final res = await generateImage(prompt);
            return res ?? 'Error: Unable to generate image.';
          default:
            final res = await geminiAPI(prompt);
            return res;
        }
      } else {
        return 'Error: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> imagenAPI(String prompt) async {
    print("imagenapi called");
    try {
      final geminiApiKey = global.geminiApi;

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/imagen-3.0-generate-002:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text":
                      "Generate an image based on the following prompt:\n\n$prompt",
                },
              ],
            },
          ],
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl =
            data['candidates'][0]['content']['parts'][0]['inlineData']['data'];

        // Store the prompt and response in messages
        messages.add({'role': 'user', 'content': prompt});
        messages.add({'role': 'assistant', 'content': imageUrl});

        return imageUrl;
      } else {
        return 'Error: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> geminiAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final geminiApiKey = global.geminiApi;

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text":
                      "Generate a response in maximum 250 words based on the following prompt:\n\n$prompt",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Store the response in messages
        messages.add({'role': 'assistant', 'content': text});

        // Format the response to handle asterisks and markdown formatting
        return formatGeminiResponse(text);
      } else {
        return 'Error: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Formats Gemini responses to handle markdown formatting like asterisks
  String formatGeminiResponse(String response) {
    // Handle bold text (remove ** markers but keep the text)
    response = response.replaceAll(RegExp(r'\*\*([\s\S]*?)\*\*'), r'$1');

    // Handle italic text (remove * markers but keep the text)
    response = response.replaceAll(RegExp(r'\*([\s\S]*?)\*'), r'$1');

    // Handle bullet points (convert to proper bullet points with spacing)
    response = response.replaceAll(RegExp(r'^\* ', multiLine: true), '• ');

    // Remove any extra asterisks that might be left
    response = response.replaceAll('*', '');

    return response;
  }

  Future<String?> generateImage(String prompt) async {
    try {
      final cloudflareAccountId = global.cloudflareAccountId;
      final cloudflareApiToken = global.cloudflareApiToken;

      // 1. Generate image using Cloudflare
      final url = Uri.parse(
        'https://api.cloudflare.com/client/v4/accounts/$cloudflareAccountId/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $cloudflareApiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"prompt": prompt}),
      );

      if (response.statusCode != 200) {
        print('Cloudflare Error: ${response.statusCode} ${response.body}');
        return null;
      }

      // 2. Save image temporarily
      final tempDir = await getTemporaryDirectory();
      final imageFile = File('${tempDir.path}/generated.png');
      await imageFile.writeAsBytes(response.bodyBytes);

      // 3. Upload to Cloudinary
      final cloudinary = CloudinaryPublic(
        global.cloudinaryCloudName!,
        global.cloudinaryUploadPreset!,
        cache: false,
      );

      CloudinaryResponse cloudinaryRes = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path),
      );

      return cloudinaryRes.secureUrl;
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}
