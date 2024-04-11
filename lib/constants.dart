import 'package:pocketbase/pocketbase.dart';

const String backendUrl = "https://dietly-pb-v2.fly.dev";

String gemKey = const String.fromEnvironment('GEMINI_API_KEY');

var pb = PocketBase(backendUrl);
