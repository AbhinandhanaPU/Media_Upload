import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://kyumgeqmwvfpscyyhcob.supabase.co';
const supabaseKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5dW1nZXFtd3ZmcHNjeXloY29iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwODUwNDcsImV4cCI6MjA0OTY2MTA0N30.MfOvZ-PKpDUqw8lgi33O8QOMpjs4Pw60Vv05bNWaz08');

Future<void> initializeSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
}