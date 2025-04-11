import 'dart:convert';

import 'package:echo_ai/global.dart' as global;
import 'package:http/http.dart' as http;

class OpenaiServices {
  Future<String> checkIfImageGeneration(String prompt) async {
    try {
      final openAiKey = global.apiKey;
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAiKey",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "developer", "content": "You are a helpful assistant."},
            {
              "role": "user",
              "content":
                  'Does the following prompt want to generate a picture, art, or image? $prompt. Only answer in a yes or no format.',
            },
          ],
        }),
      );
      print(res.body);
      if(res.statusCode == 200){
        print('Successfull res generation');
      }
      return '';
    } catch (e) {
      return e.toString();
    }
  }
}
