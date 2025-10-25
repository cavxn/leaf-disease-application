import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/plant_care_event.dart';
import '../models/plant.dart';
import '../providers/plant_care_provider.dart';

class PlantCalendarScreen extends StatefulWidget {
  const PlantCalendarScreen({Key? key}) : super(key: key);

  @override
  State<PlantCalendarScreen> createState() => _PlantCalendarScreenState();
}

class _PlantCalendarScreenState extends State<PlantCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<PlantCareProvider>(
      builder: (context, plantCareProvider, child) {
        // Initialize sample data if events list is empty
        if (plantCareProvider.events.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            plantCareProvider.initializeSampleData();
          });
        }
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  _buildCalendar(isDark, plantCareProvider),
                  Expanded(
                    child: _buildEventsList(isDark, plantCareProvider),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEventDialog(plantCareProvider),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
              borderRadius: BorderRadius.circular(15),
              border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant Care Calendar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Schedule your plant care routine',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Consumer<PlantCareProvider>(
            builder: (context, plantCareProvider, child) {
              return IconButton(
                onPressed: () => _showAddEventDialog(plantCareProvider),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3);
  }

  Widget _buildCalendar(bool isDark, PlantCareProvider plantCareProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(isDark, plantCareProvider),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildCalendarGrid(bool isDark, PlantCareProvider plantCareProvider) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    
    final List<Widget> days = [];
    
    // Add day headers
    for (int i = 1; i <= 7; i++) {
      days.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            DateFormat('E').format(DateTime(2024, 1, i)),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstDayWeekday; i++) {
      days.add(const SizedBox(height: 40));
    }
    
    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final hasEvents = plantCareProvider.events.any((event) => 
        event.date.year == date.year && 
        event.date.month == date.month && 
        event.date.day == date.day);
      final isSelected = _selectedDate.year == date.year && 
        _selectedDate.month == date.month && 
        _selectedDate.day == date.day;
      final isToday = date.year == DateTime.now().year && 
        date.month == DateTime.now().month && 
        date.day == DateTime.now().day;
      
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: isSelected 
                ? Colors.green.withOpacity(0.3)
                : isToday 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                ? Border.all(color: Colors.green, width: 2)
                : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  Widget _buildEventsList(bool isDark, PlantCareProvider plantCareProvider) {
    final selectedDateEvents = plantCareProvider.getEventsForDate(_selectedDate);
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedDateEvents.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  itemCount: selectedDateEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedDateEvents[index];
                    return _buildEventCard(event, isDark, plantCareProvider);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 48,
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events scheduled',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a plant care event',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white.withOpacity(0.5) : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(PlantCareEvent event, bool isDark, PlantCareProvider plantCareProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getEventColor(event.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getEventIcon(event.type),
                      color: _getEventColor(event.type),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.plantName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black38,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => plantCareProvider.toggleEventCompletion(event.id),
            icon: Icon(
              event.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: event.isCompleted ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(PlantCareEventType type) {
    switch (type) {
      case PlantCareEventType.watering:
        return Colors.blue;
      case PlantCareEventType.fertilizing:
        return Colors.orange;
      case PlantCareEventType.repotting:
        return Colors.brown;
      case PlantCareEventType.inspection:
        return Colors.purple;
      case PlantCareEventType.pruning:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(PlantCareEventType type) {
    switch (type) {
      case PlantCareEventType.watering:
        return Icons.water_drop;
      case PlantCareEventType.fertilizing:
        return Icons.eco;
      case PlantCareEventType.repotting:
        return Icons.agriculture;
      case PlantCareEventType.inspection:
        return Icons.visibility;
      case PlantCareEventType.pruning:
        return Icons.content_cut;
      default:
        return Icons.event;
    }
  }

  void _showAddEventDialog(PlantCareProvider plantCareProvider) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onEventAdded: (event) {
          plantCareProvider.addEvent(event);
        },
        selectedDate: _selectedDate,
        plants: plantCareProvider.plants,
      ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  final Function(PlantCareEvent) onEventAdded;
  final DateTime selectedDate;
  final List<Plant> plants;

  const AddEventDialog({
    Key? key,
    required this.onEventAdded,
    required this.selectedDate,
    required this.plants,
  }) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _plantNameController = TextEditingController();
  PlantCareEventType _selectedType = PlantCareEventType.watering;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Plant? _selectedPlant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Add Plant Care Event',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Plant>(
              value: _selectedPlant,
              decoration: InputDecoration(
                labelText: 'Select Plant',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: widget.plants.map((plant) {
                return DropdownMenuItem(
                  value: plant,
                  child: Text(plant.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlant = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PlantCareEventType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Event Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: PlantCareEventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Time: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Add Event', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addEvent() {
    if (_titleController.text.isNotEmpty && _selectedPlant != null) {
      final event = PlantCareEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: widget.selectedDate,
        time: _selectedTime,
        type: _selectedType,
        plantName: _selectedPlant!.name,
        plantId: _selectedPlant!.id,
        isCompleted: false,
      );
      widget.onEventAdded(event);
      Navigator.pop(context);
    }
  }
}
