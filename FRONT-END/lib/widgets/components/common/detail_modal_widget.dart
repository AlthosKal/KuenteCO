import 'package:flutter/material.dart';

class DetailModalWidget extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;
  final List<DetailItem> details;
  final List<ActionButton> actions;

  const DetailModalWidget({
    Key? key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.details = const [],
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        amount,
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            if (details.isNotEmpty) ...[
              const SizedBox(height: 24),
              /// DETALLES
              ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDetailRow(context, detail.label, detail.value),
              )).toList(),
            ],
            
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              /// ACCIONES
              if (actions.length == 1)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: actions.first.onPressed,
                    icon: Icon(actions.first.icon),
                    label: Text(actions.first.label),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actions.first.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else
                Row(
                  children: actions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: action.onPressed,
                          icon: Icon(action.icon, size: 18),
                          label: Text(action.label),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: action.color,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (index < actions.length - 1) const SizedBox(width: 8),
                    ];
                  }).expand((element) => element).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class DetailItem {
  final String label;
  final String value;

  const DetailItem({
    required this.label,
    required this.value,
  });
}

class ActionButton {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}