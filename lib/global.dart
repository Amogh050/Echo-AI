import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['apiKey'] ?? '';
final String geminiApi = dotenv.env['geminiApi'] ?? '';
final String cloudflareAccountId = dotenv.env['cloudflareAccountId'] ?? '';
final String cloudflareApiToken = dotenv.env['cloudflareApiToken'] ?? '';
final String cloudinaryUploadPreset = dotenv.env['cloudinaryUploadPreset'] ?? '';
final String cloudinaryCloudName = dotenv.env['cloudinaryCloudName'] ?? '';