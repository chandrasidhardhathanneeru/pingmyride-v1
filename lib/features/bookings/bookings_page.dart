import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/booking.dart';
import '../../core/models/bus.dart';
import '../../core/models/bus_route.dart';
import '../../core/services/bus_service.dart';
import '../../core/theme/app_theme.dart';
import '../tracking/location_tracking_page.dart';

enum BookingFilter { all, confirmed, cancelled, completed }
enum BookingSort { upcoming, recent, oldest }

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  BookingFilter _currentFilter = BookingFilter.all;
  BookingSort _currentSort = BookingSort.upcoming;
  final Set<String> _expandedBookings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusService>(context, listen: false).fetchUserBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        actions: [
          PopupMenuButton<BookingSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (BookingSort sort) {
              setState(() {
                _currentSort = sort;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: BookingSort.upcoming,
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: _currentSort == BookingSort.upcoming ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming First',
                      style: TextStyle(
                        fontWeight: _currentSort == BookingSort.upcoming ? FontWeight.bold : null,
                        color: _currentSort == BookingSort.upcoming ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: BookingSort.recent,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _currentSort == BookingSort.recent ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Recent',
                      style: TextStyle(
                        fontWeight: _currentSort == BookingSort.recent ? FontWeight.bold : null,
                        color: _currentSort == BookingSort.recent ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: BookingSort.oldest,
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: _currentSort == BookingSort.oldest ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Oldest First',
                      style: TextStyle(
                        fontWeight: _currentSort == BookingSort.oldest ? FontWeight.bold : null,
                        color: _currentSort == BookingSort.oldest ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<BookingFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (BookingFilter filter) {
              setState(() {
                _currentFilter = filter;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: BookingFilter.all,
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      color: _currentFilter == BookingFilter.all ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'All',
                      style: TextStyle(
                        fontWeight: _currentFilter == BookingFilter.all ? FontWeight.bold : null,
                        color: _currentFilter == BookingFilter.all ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: BookingFilter.confirmed,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _currentFilter == BookingFilter.confirmed ? AppTheme.primaryColor : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confirmed',
                      style: TextStyle(
                        fontWeight: _currentFilter == BookingFilter.confirmed ? FontWeight.bold : null,
                        color: _currentFilter == BookingFilter.confirmed ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: BookingFilter.cancelled,
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: _currentFilter == BookingFilter.cancelled ? AppTheme.primaryColor : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cancelled',
                      style: TextStyle(
                        fontWeight: _currentFilter == BookingFilter.cancelled ? FontWeight.bold : null,
                        color: _currentFilter == BookingFilter.cancelled ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: BookingFilter.completed,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: _currentFilter == BookingFilter.completed ? AppTheme.primaryColor : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontWeight: _currentFilter == BookingFilter.completed ? FontWeight.bold : null,
                        color: _currentFilter == BookingFilter.completed ? AppTheme.primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              await Provider.of<BusService>(context, listen: false).fetchUserBookings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bookings refreshed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh bookings',
          ),
        ],
      ),
      body: Consumer<BusService>(
        builder: (context, busService, child) {
          if (busService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter bookings
          List<Booking> bookings = busService.userBookings;
          
          // Apply filter
          switch (_currentFilter) {
            case BookingFilter.confirmed:
              bookings = bookings.where((b) => b.status == BookingStatus.confirmed).toList();
              break;
            case BookingFilter.cancelled:
              bookings = bookings.where((b) => b.status == BookingStatus.cancelled).toList();
              break;
            case BookingFilter.completed:
              bookings = bookings.where((b) => b.status == BookingStatus.completed).toList();
              break;
            case BookingFilter.all:
              // No filtering
              break;
          }
          
          // Apply sort
          switch (_currentSort) {
            case BookingSort.upcoming:
              bookings.sort((a, b) {
                final aTime = _getBookingDateTime(a);
                final bTime = _getBookingDateTime(b);
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                
                final now = DateTime.now();
                final aDiff = aTime.difference(now);
                final bDiff = bTime.difference(now);
                
                // Upcoming bookings (future) come first, sorted by closest first
                if (aDiff.isNegative && bDiff.isNegative) {
                  // Both in past, sort by most recent
                  return bTime.compareTo(aTime);
                } else if (aDiff.isNegative) {
                  // a is past, b is future - b comes first
                  return 1;
                } else if (bDiff.isNegative) {
                  // a is future, b is past - a comes first
                  return -1;
                } else {
                  // Both in future, sort by closest first
                  return aTime.compareTo(bTime);
                }
              });
              break;
            case BookingSort.recent:
              bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case BookingSort.oldest:
              bookings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              break;
          }

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentFilter == BookingFilter.all 
                        ? 'No bookings yet'
                        : 'No ${_currentFilter.name} bookings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentFilter == BookingFilter.all
                        ? 'Your bus bookings will appear here'
                        : 'Try changing the filter',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter/Sort info bar
              if (_currentFilter != BookingFilter.all || _currentSort != BookingSort.upcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing ${_currentFilter.name} bookings sorted by ${_getSortLabel()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (_currentFilter != BookingFilter.all || _currentSort != BookingSort.upcoming)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentFilter = BookingFilter.all;
                              _currentSort = BookingSort.upcoming;
                            });
                          },
                          child: const Text('Clear', style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await busService.fetchUserBookings();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final bus = busService.getBusById(booking.busId);
                      final route = busService.getRouteById(booking.routeId);
                      
                      return _buildBookingCard(context, booking, bus, route, busService);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking,
    Bus? bus,
    BusRoute? route,
    BusService busService,
  ) {
    final canTrack = _canTrackBus(booking);
    final isUpcoming = _isUpcomingBooking(booking);
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isExpanded = _expandedBookings.contains(booking.id) || !isCancelled;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isUpcoming ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUpcoming
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_expandedBookings.contains(booking.id)) {
              _expandedBookings.remove(booking.id);
            } else {
              _expandedBookings.add(booking.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming badge
              if (isUpcoming)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'UPCOMING',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              // Header with bus number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking.busNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getStatusIcon(booking.status),
                        size: 20,
                        color: _getStatusColor(booking.status),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(booking.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          booking.status.label,
                          style: TextStyle(
                            color: _getStatusColor(booking.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            
            // Collapsed preview - show route and time
            if (!isExpanded) ...[
              const SizedBox(height: 12),
              if (route != null)
                Text(
                  route.routeName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (booking.selectedBookingDate != null && booking.selectedTimeSlot != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(booking.selectedBookingDate!)} at ${booking.selectedTimeSlot}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
        
            // Expanded details
            if (isExpanded) ...[
              const SizedBox(height: 16),
              
              // Route info
              if (route != null) ...[
                _buildInfoRow(
                  Icons.route,
                  'Route',
                  route.routeName,
                ),
                const SizedBox(height: 8),
              ],
              
              _buildInfoRow(
                Icons.location_on,
                'From',
                booking.pickupLocation,
              ),
              const SizedBox(height: 8),
              
              _buildInfoRow(
                Icons.location_on_outlined,
                'To',
                booking.dropLocation,
              ),
              const SizedBox(height: 8),
              
              // Booking date
              if (booking.selectedBookingDate != null) ...[
                _buildInfoRow(
                  Icons.calendar_today,
                  'Travel Date',
                  _formatDate(booking.selectedBookingDate!),
                ),
                const SizedBox(height: 8),
              ],
              
              // Time slot
              if (booking.selectedTimeSlot != null) ...[
                _buildInfoRow(
                  Icons.access_time,
                  'Pickup Time',
                  booking.selectedTimeSlot!,
                ),
                const SizedBox(height: 8),
              ],
              
              _buildInfoRow(
                Icons.person,
                'Driver',
                booking.driverName,
              ),
              const SizedBox(height: 8),
              
              _buildInfoRow(
                Icons.phone,
                'Contact',
                booking.driverPhone,
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  // Track Bus button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canTrack
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationTrackingPage(
                                    busId: booking.busId,
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: Icon(
                        Icons.location_on,
                        size: 18,
                      ),
                      label: Text(
                        canTrack ? 'Track Bus' : _getTrackingStatusText(booking),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canTrack ? AppTheme.primaryColor : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Cancel button (only for confirmed bookings)
                  if (booking.status == BookingStatus.confirmed) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(context, booking, busService),
                        icon: const Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Tracking info message
              if (!canTrack && booking.status == BookingStatus.confirmed) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getTrackingInfoMessage(booking),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  bool _canTrackBus(Booking booking) {
    // Only confirmed bookings can be tracked
    if (booking.status != BookingStatus.confirmed) {
      return false;
    }
    
    // Check if booking has a time slot
    if (booking.selectedTimeSlot == null || booking.selectedBookingDate == null) {
      return false;
    }
    
    // Parse the time slot (e.g., "08:30 AM")
    final timeSlot = booking.selectedTimeSlot!;
    final timeParts = timeSlot.split(' ');
    if (timeParts.length != 2) return false;
    
    final hourMinute = timeParts[0].split(':');
    if (hourMinute.length != 2) return false;
    
    int hour = int.tryParse(hourMinute[0]) ?? 0;
    final minute = int.tryParse(hourMinute[1]) ?? 0;
    final isPM = timeParts[1].toUpperCase() == 'PM';
    
    // Convert to 24-hour format
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    
    // Create DateTime for the booking
    final bookingDateTime = DateTime(
      booking.selectedBookingDate!.year,
      booking.selectedBookingDate!.month,
      booking.selectedBookingDate!.day,
      hour,
      minute,
    );
    
    final now = DateTime.now();
    final difference = bookingDateTime.difference(now);
    
    // Enable tracking if within 15 minutes before or after the scheduled time
    return difference.inMinutes <= 15 && difference.inMinutes >= -60;
  }

  String _getTrackingStatusText(Booking booking) {
    if (booking.status != BookingStatus.confirmed) {
      return 'Not Available';
    }
    
    if (booking.selectedTimeSlot == null || booking.selectedBookingDate == null) {
      return 'Not Available';
    }
    
    final timeSlot = booking.selectedTimeSlot!;
    final timeParts = timeSlot.split(' ');
    if (timeParts.length != 2) return 'Not Available';
    
    final hourMinute = timeParts[0].split(':');
    if (hourMinute.length != 2) return 'Not Available';
    
    int hour = int.tryParse(hourMinute[0]) ?? 0;
    final minute = int.tryParse(hourMinute[1]) ?? 0;
    final isPM = timeParts[1].toUpperCase() == 'PM';
    
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    
    final bookingDateTime = DateTime(
      booking.selectedBookingDate!.year,
      booking.selectedBookingDate!.month,
      booking.selectedBookingDate!.day,
      hour,
      minute,
    );
    
    final now = DateTime.now();
    final difference = bookingDateTime.difference(now);
    
    if (difference.inMinutes < -60) {
      return 'Trip Completed';
    } else if (difference.inMinutes > 15) {
      return 'Not Yet Available';
    }
    
    return 'Track Bus';
  }

  String _getTrackingInfoMessage(Booking booking) {
    if (booking.selectedTimeSlot == null || booking.selectedBookingDate == null) {
      return 'Tracking not available for this booking';
    }
    
    final timeSlot = booking.selectedTimeSlot!;
    final timeParts = timeSlot.split(' ');
    if (timeParts.length != 2) return 'Tracking not available';
    
    final hourMinute = timeParts[0].split(':');
    if (hourMinute.length != 2) return 'Tracking not available';
    
    int hour = int.tryParse(hourMinute[0]) ?? 0;
    final minute = int.tryParse(hourMinute[1]) ?? 0;
    final isPM = timeParts[1].toUpperCase() == 'PM';
    
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    
    final bookingDateTime = DateTime(
      booking.selectedBookingDate!.year,
      booking.selectedBookingDate!.month,
      booking.selectedBookingDate!.day,
      hour,
      minute,
    );
    
    final now = DateTime.now();
    final difference = bookingDateTime.difference(now);
    
    if (difference.inMinutes > 15) {
      // Calculate time until tracking is available (15 min before departure)
      final trackingAvailableAt = bookingDateTime.subtract(const Duration(minutes: 15));
      final timeUntilTracking = trackingAvailableAt.difference(now);
      
      if (timeUntilTracking.inHours >= 24) {
        final days = timeUntilTracking.inDays;
        final hours = timeUntilTracking.inHours % 24;
        return 'Tracking will be available in ${days}d ${hours}h';
      } else if (timeUntilTracking.inHours > 0) {
        final hours = timeUntilTracking.inHours;
        final minutes = timeUntilTracking.inMinutes % 60;
        return 'Tracking will be available in ${hours}h ${minutes}m';
      } else {
        final minutes = timeUntilTracking.inMinutes;
        return 'Tracking will be available in ${minutes}m';
      }
    }
    
    return 'Bus tracking is now available';
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showCancelDialog(BuildContext context, Booking booking, BusService busService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel your booking for bus ${booking.busNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await busService.cancelBooking(booking);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Booking cancelled successfully'
                          : 'Failed to cancel booking',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  DateTime? _getBookingDateTime(Booking booking) {
    if (booking.selectedTimeSlot == null || booking.selectedBookingDate == null) {
      return null;
    }
    
    final timeSlot = booking.selectedTimeSlot!;
    final timeParts = timeSlot.split(' ');
    if (timeParts.length != 2) return null;
    
    final hourMinute = timeParts[0].split(':');
    if (hourMinute.length != 2) return null;
    
    int hour = int.tryParse(hourMinute[0]) ?? 0;
    final minute = int.tryParse(hourMinute[1]) ?? 0;
    final isPM = timeParts[1].toUpperCase() == 'PM';
    
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    
    return DateTime(
      booking.selectedBookingDate!.year,
      booking.selectedBookingDate!.month,
      booking.selectedBookingDate!.day,
      hour,
      minute,
    );
  }

  bool _isUpcomingBooking(Booking booking) {
    if (booking.status != BookingStatus.confirmed) {
      return false;
    }
    
    final bookingDateTime = _getBookingDateTime(booking);
    if (bookingDateTime == null) return false;
    
    final now = DateTime.now();
    final difference = bookingDateTime.difference(now);
    
    // Consider booking as upcoming if it's in the future and within next 24 hours
    return difference.inMinutes > 0 && difference.inHours <= 24;
  }

  String _getSortLabel() {
    switch (_currentSort) {
      case BookingSort.upcoming:
        return 'upcoming first';
      case BookingSort.recent:
        return 'most recent';
      case BookingSort.oldest:
        return 'oldest first';
    }
  }
}
