import 'package:flutter/material.dart';

class TurnCell extends StatelessWidget {
  final String value;
  final Function(String)? onChanged;
  final bool isBonus;

  const TurnCell({super.key, required this.value, this.onChanged, this.isBonus = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged != null ? () => _showPicker(context) : null,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            color: isBonus ? const Color(0xFFD4AF37) : Colors.blueGrey.shade700,
            fontSize: isBonus ? 14 : 20,
            fontWeight: isBonus ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final options = ['😊', '❤️', '💎', 'X', ''];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isBonus ? 'Select Bonus' : 'Select Turn Value', 
            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)
          ),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((opt) {
              return InkWell(
                onTap: () {
                  onChanged?.call(opt);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    opt.isEmpty ? 'CLEAR' : opt, 
                    style: TextStyle(
                      color: opt.isEmpty ? Colors.white38 : Colors.white, 
                      fontSize: opt.isEmpty ? 10 : 22,
                      fontWeight: opt.isEmpty ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
