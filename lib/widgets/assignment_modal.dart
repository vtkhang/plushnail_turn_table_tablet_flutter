import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/employee.dart';
import '../models/skill.dart';

class AssignmentModal extends StatefulWidget {
  const AssignmentModal({super.key});

  @override
  State<AssignmentModal> createState() => _AssignmentModalState();
}

class _AssignmentModalState extends State<AssignmentModal> {
  Employee? _selectedEmployee;
  final List<Skill> _selectedSkills = [];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Dialog(
      backgroundColor: const Color(0xFF111111),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEW ASSIGNMENT',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 32),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. SELECT PROFESSIONAL', style: _labelStyle),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: _boxDecoration(),
                            child: ListView.builder(
                              itemCount: provider.employees.length,
                              itemBuilder: (context, index) {
                                final emp = provider.employees[index];
                                final isSelected = _selectedEmployee?.id == emp.id;
                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: const Color(0xFFD4AF37).withOpacity(0.1),
                                  title: Text(
                                    emp.name, 
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white70, 
                                      fontSize: 13, 
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                    )
                                  ),
                                  onTap: () => setState(() => _selectedEmployee = emp),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('2. SELECT SKILLS', style: _labelStyle),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: _boxDecoration(),
                            child: ListView.builder(
                              itemCount: provider.skillCategories.length,
                              itemBuilder: (context, index) {
                                final cat = provider.skillCategories[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                                      child: Text(cat.name.toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: cat.skills.map((skill) {
                                          final isSelected = _selectedSkills.any((s) => s.id == skill.id);
                                          return FilterChip(
                                            label: Text(skill.name, style: const TextStyle(fontSize: 11)),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  _selectedSkills.add(skill);
                                                } else {
                                                  _selectedSkills.removeWhere((s) => s.id == skill.id);
                                                }
                                              });
                                            },
                                            selectedColor: const Color(0xFFD4AF37),
                                            checkmarkColor: Colors.black,
                                            labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70),
                                            backgroundColor: Colors.white.withOpacity(0.05),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(color: Colors.white10),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: (_selectedEmployee == null || _selectedSkills.isEmpty) ? null : _handleAssign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.white10,
                    disabledForegroundColor: Colors.white24,
                  ),
                  child: const Text('ASSIGN TASK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.02),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    );
  }

  static const _labelStyle = TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5);

  Future<void> _handleAssign() async {
    try {
      await Provider.of<AppProvider>(context, listen: false).assignTask(
        _selectedEmployee!.id,
        _selectedSkills,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to assign task: $e')));
      }
    }
  }
}
