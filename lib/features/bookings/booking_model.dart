/// Represents a single booking made by a user.
///
/// This is a plain data model (sometimes called a "plain old Dart object").
/// It holds no logic — its only job is to carry booking data cleanly
/// through the app after it has been fetched from the database.
class Booking {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final int tableNumber;
  final String date;    // Format: 'YYYY-MM-DD'
  final String time;    // Format: 'HH:MM' (24-hour)
  final int guests;
  final String status;  // e.g. 'confirmed', 'pending', 'cancelled'

  /// Creates a [Booking] instance with all required fields.
  ///
  /// All fields are required and immutable — once a [Booking]
  /// is created, its values cannot change.
  Booking({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.tableNumber,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
  });

  /// Creates a [Booking] from a raw Supabase JSON response.
  ///
  /// Expects a nested JSON structure where restaurant and table
  /// data are joined from their respective tables:
  ///
  /// ```json
  /// {
  ///   "id": "abc123",
  ///   "restaurants": { "name": "...", "address": "..." },
  ///   "tables":      { "table_number": 4 },
  ///   "date": "2025-08-01",
  ///   "time": "19:00",
  ///   "guests": 2,
  ///   "status": "confirmed"
  /// }
  /// ```
  ///
  /// Throws a [TypeError] if any expected key is missing or
  /// has the wrong type in the JSON.
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      // Nested access: Supabase returns related tables as sub-objects.
      restaurantName: json['restaurants']['name'],
      restaurantAddress: json['restaurants']['address'],
      tableNumber: json['tables']['table_number'],
      date: json['date'],
      time: json['time'],
      guests: json['guests'],
      status: json['status'],
    );
  }
}