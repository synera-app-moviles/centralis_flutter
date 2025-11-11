import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../data/models/priority.dart';

class PrioritySelector extends StatelessWidget {
  final Priority selectedPriority;
  final ValueChanged<Priority> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPriorityChip('Normal', Priority.normal),
            const SizedBox(width: 8),
            _buildPriorityChip('High', Priority.high),
            const SizedBox(width: 8),
            _buildPriorityChip('Urgent', Priority.urgent),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String label, Priority priority) {
    final isSelected = selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPriorityChanged(priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AnnouncementColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AnnouncementColors.primary : AnnouncementColors.textSecondary,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AnnouncementColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}