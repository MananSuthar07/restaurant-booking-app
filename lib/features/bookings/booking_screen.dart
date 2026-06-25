import 'package:flutter/material.dart';
import 'booking_model.dart';
import 'booking_services.dart';

/// The main screen that displays a user's upcoming bookings.
///
/// This is a [StatefulWidget] because it manages async data that
/// arrives after the widget is first built — the booking list and
/// the user's name both load from Supabase on mount.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

/// Private state class for [BookingScreen].
///
/// Manages loading state, booking data, and user identity.
/// All data fetching is triggered once in [initState] and
/// reflected in the UI via [setState].
class _BookingScreenState extends State<BookingScreen> {
  /// True while either [fetchBookings] or [fetchUserName] is in flight.
  /// Controls whether the loading spinner or the main UI is shown.
  bool isLoading = true;

  // ignore: unused_field
  /// Reserved for a future location-sharing feature.
  /// Not yet wired to any UI or backend logic.
  bool locationSharing = false;

  /// The list of bookings fetched from Supabase.
  /// Starts empty and is populated by [fetchBookings].
  List<Booking> bookings = [];

  /// The display name of the currently authenticated user.
  /// Starts empty and is populated by [fetchUserName].
  String userName = '';

  /// Called once when this widget is inserted into the tree.
  ///
  /// Kicks off both data-fetching calls in parallel. We don't
  /// await them here — each one calls [setState] internally
  /// when it completes, triggering a rebuild at that point.
  @override
  void initState() {
    super.initState();
    fetchBookings();
    fetchUserName();
  }

  /// Fetches all bookings for the current user from Supabase
  /// and stores them in [bookings].
  ///
  /// Sets [isLoading] to false once data arrives, which causes
  /// the loading spinner to be replaced by the main UI.
  Future<void> fetchBookings() async {
    final data = await BookingServices().fetchBookings();
    setState(() {
      bookings = data;
      isLoading = false;
    });
  }

  /// Fetches the display name of the currently authenticated user.
  ///
  /// The result is stored in [userName] and used in the greeting
  /// header at the top of the screen.
  Future<void> fetchUserName() async {
    final data = await BookingServices().fetchUserName();
    // TODO: remove before release — avoid logging user identity in production.
    print('Username fetched: $data');
    setState(() {
      userName = data;
    });
  }

  /// Returns a time-appropriate greeting string based on the device clock.
  ///
  /// - Before 12:00 → 'Good Morning!'
  /// - 12:00–16:59  → 'Good Afternoon!'
  /// - 17:00+       → 'Good Evening!'
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

  String formatDate(String date){
    final parts = date.split('-');
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${parts[2]} ${months[int.parse(parts[1]) - 1]} ${parts[0]}';
  }

  String formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '$displayHour:$minute $period';
  }

  /// Builds the booking screen UI.
  ///
  /// Renders a full-screen [CircularProgressIndicator] while data
  /// is loading, then switches to the main layout once both
  /// [bookings] and [userName] are available.
  @override
  Widget build(BuildContext context) {
    // Show a full-screen spinner until all async data has loaded.
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

              // --- Greeting header ---
              // Shows a time-aware greeting above the user's name.
              Text(
                getGreeting(),
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),

              SizedBox(height: 4),

              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 24),

              // --- Booking card ---
              // Displays the first booking in the list.
              // TODO: replace bookings[0] with a proper "next upcoming"
              // query or guard against an empty list to avoid a RangeError.
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1d24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2a2d35)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // Restaurant name and label
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Booking',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            Text(
                              bookings[0].restaurantName,
                              style: TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          ],
                        ),

                        // Status badge — green pill showing booking state,
                        // e.g. 'confirmed', 'pending', 'cancelled'.
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0f3d2a),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bookings[0].status,
                            style: const TextStyle(
                              color: Color(0xFF4ade80),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Divider(color: Color(0xFF2a2d35)),

                    SizedBox(height: 16),

                    // Row 2: date and time shown side by side.
                    // formatDate and formatTime convert raw DB strings
                    // into human-readable display values.
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Text('Date', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text(formatDate(bookings[0].date), style: TextStyle(color: Colors.white, fontSize: 20)),
                              ],
                            ),
                          ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text(formatTime(bookings[0].time), style: TextStyle(color: Colors.white, fontSize: 20)),
                            ]
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16,),

                    // Row 3: table number and guest count side by side.
                    Row( 
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Table', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text(
                                'Table ${bookings[0].tableNumber}', 
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ],
                          )
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Guests', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text(
                                '${bookings[0].guests} people', style: TextStyle(color: Colors.white, fontSize: 20),
                              )
                            ],
                          )
                        )
                      ],
                    ),

                    SizedBox(height: 16,),

                    Divider(color: Color(0xFF2a2d35)),

                    SizedBox(height: 16,),

                    // Restaurant address show beneath the second devider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Restaurant Address', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        Text(bookings[0].restaurantAddress, style: TextStyle(color: Colors.white, fontSize: 20),)
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 24),
              
              // --- Location sharing card ---
              // A standalone card with a toggle that lets the user
              // share their real-time arrival with the restaurant.
              // The switch updates [locationSharing] via setState,
              // but the value is not yet sent to the backend.
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1d24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2a2d35)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Share Location', style: TextStyle(color: Colors.white, fontSize: 20)),
                        
                        // Purple Switch to match the app's accent colour.
                        // TODO: wire onChanged to a backend call or
                        // permissions request before enabling this in production.
                        Switch(
                          value: locationSharing, 
                          onChanged: (value) {
                            setState(() {
                              locationSharing = value;
                            });
                          },
                          activeColor: const Color(0xFFa78bfa),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Let the restaurant track your arrival in real time',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ]
                ),
              ),

              SizedBox(height: 24,),

              // --- Action buttons ---
              // 'Check In' and 'Cancel' sit side by side in equal-width columns.
              // TODO: replace print statements with real check-in and
              // cancellation logic before release.
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        print('Check in tapped');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFa78bfa),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ), 
                      ),
                      child: const Text(
                        'Check In',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Cancel pressed');
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a1d24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                  )
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}