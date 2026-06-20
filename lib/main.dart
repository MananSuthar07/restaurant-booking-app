import 'package:flutter/material.dart';
import 'package:restaurant_booking_app/features/bookings/booking_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gjynhfupsiptwnbjtcyo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdqeW5oZnVwc2lwdHduYmp0Y3lvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2ODYwNzAsImV4cCI6MjA5NjI2MjA3MH0.mD9dj7iwciilWUPOZZXukkuoZ9tWMZPRBT25upvtGc8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BookingScreen()
    );
  }
}