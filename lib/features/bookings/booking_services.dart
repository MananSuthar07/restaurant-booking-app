import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_model.dart';

/// Handles all database operations related to bookings
/// 
/// This service class acts as the data layer between the app
/// and the Supabse backend. It should be the single source
/// of truth for any booking-related queries.
class BookingServices {
  // A private instance of the Supabase client.
  // The underscore makes it inaccessible outside this class
  final _supabase = Supabase.instance.client;

  /// Fetch all bookings from the database. Including their
  /// associated restaurant and table details.
  /// 
  /// Returns a [List] of [Booking] objects parsed from the Supabase reponse
  /// 
  /// Throws a [PostgrestException] if the query fails.
  Future<List<Booking>> fetchBookings() async {
    final response = await _supabase
    .from('bookings')
    .select('''
      id,
      date,
      time,
      guests,
      status,
      restaurants (
        name,
        address
      ),
      tables (
        table_number
      )
      ''');
    /// Supabase returns a List<Map<String, dynamic>>.
    /// We map each raw JSON into a typed Booking model
    /// so the rest of the app never has to deal with raw maps.
    return response.map((json) => Booking.fromJson(json)).toList();
  }

  Future<String> fetchUserName() async {
    final response = await _supabase
    .from('users')
    .select('name')
    .eq('id', '6268eb5a-edff-4e76-a882-43b566a8865b')
    .single();

    return response['name'];
  }
}