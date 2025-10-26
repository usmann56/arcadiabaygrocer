import 'package:flutter/material.dart';

/**
 * DueDateSelector - Widget for selecting when an item needs to be purchased
 * 
 * Displays a date picker in a black container with white text.
 * Allows users to set a due date for their shopping items.
 */
class DueDateSelector extends StatelessWidget {
  final DateTime? dueDate; // Currently selected due date
  final ValueChanged<DateTime?>
  onDueDateSelected; // Callback when user selects date

  const DueDateSelector({
    super.key,
    required this.dueDate,
    required this.onDueDateSelected,
  });

  /**
   * Shows the date picker dialog
   */
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Allow up to 1 year in future
    );

    if (picked != null && picked != dueDate) {
      onDueDateSelected(picked);
    }
  }

  /**
   * Clears the selected due date
   */
  void _clearDate() {
    onDueDateSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Due Again At (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Date selection button
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    label: Text(
                      dueDate != null
                          ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                          : 'Select Date',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  // Clear date button (only show if date is selected)
                  if (dueDate != null)
                    ElevatedButton.icon(
                      onPressed: _clearDate,
                      icon: const Icon(Icons.clear, color: Colors.white),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
