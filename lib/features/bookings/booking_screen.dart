import 'package:flutter/material.dart';
import 'booking_model.dart';
import 'booking_services.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isLoading = true;
  bool locationSharing = false;
  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async{
    final data = await BookingServices().fetchBookings();
    setState(() {
      bookings = data;
      isLoading = false;
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
    backgroundColor: const Color(0xFF111318),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // greeting and card
            Text(getGreeting(), style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    ),
  );
  }
}