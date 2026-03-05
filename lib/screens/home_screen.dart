import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import '../models/employee.dart';
import '../widgets/turn_cell.dart';
import '../widgets/assignment_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;
    final isManagement = user?.role != UserRole.employee;

    return Scaffold(
      appBar: _buildHeader(context, provider),
      body: Column(
        children: [
          Expanded(
            child: _buildMainTable(context, provider),
          ),
          if (isManagement) _buildFooter(context, provider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context, AppProvider provider) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      toolbarHeight: 80,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo-booking.png',
                width: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text('P', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLUSH TURN TABLE',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              Text(
                provider.currentSalon?.name.toUpperCase() ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                onChanged: (val) => provider.searchSkills(val),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "AI Assistant: 'Who is best at nails and pedicures?'",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.2), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
          if (provider.user?.role == UserRole.director)
            DropdownButton<int>(
              value: provider.currentSalon?.id,
              dropdownColor: const Color(0xFF0A0A0A),
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4AF37)),
              items: provider.salons.map((s) {
                return DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) {
                  final salon = provider.salons.firstWhere((s) => s.id == id);
                  provider.setCurrentSalon(salon);
                }
              },
            ),
          const SizedBox(width: 24),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.user?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(provider.user?.role.toApiString().toUpperCase() ?? '', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => provider.logout(),
                icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
              ),
            ],
          ),
        ],
      ),
      bottom: provider.aiExplanation != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: const Color(0xFF1A1A1A),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.aiExplanation!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMainTable(BuildContext context, AppProvider provider) {
    if (provider.employees.isEmpty) {
      return const Center(child: Text('No employees found.', style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF111111)),
          dataRowMinHeight: 80,
          dataRowMaxHeight: 100,
          columnSpacing: 0,
          horizontalMargin: 0,
          border: TableBorder.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
          columns: [
            const DataColumn(label: _HeaderCell('PGR', width: 60)),
            const DataColumn(label: _HeaderCell('Professional', width: 180, textAlign: TextAlign.left)),
            ...List.generate(12, (i) => DataColumn(label: _HeaderCell('${i + 1}', width: 75))),
            const DataColumn(label: _HeaderCell('Bonus', width: 90, color: Color(0xFFD4AF37))),
          ],
          rows: provider.employees.map((emp) => _buildEmployeeRow(context, provider, emp)).toList(),
        ),
      ),
    );
  }

  DataRow _buildEmployeeRow(BuildContext context, AppProvider provider, Employee emp) {
    final isRecommended = provider.recommendedIds.contains(emp.id);
    final isManagement = provider.user?.role != UserRole.employee;

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (isRecommended) return const Color(0xFFD4AF37).withOpacity(0.1);
        return Colors.white;
      }),
      cells: [
        DataCell(SizedBox(width: 60, child: Center(child: Text(emp.pager, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))))),
        DataCell(
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (isRecommended)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
                        ),
                    ],
                  ),
                  Text(emp.phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _StatusBadge(
                        text: emp.status.toUpperCase(),
                        color: emp.status == 'idle' ? Colors.green : const Color(0xFFD4AF37),
                      ),
                      if (emp.status == 'working' && emp.currentTask != null)
                        _StatusBadge(text: emp.currentTask!, color: Colors.blueGrey, isOutline: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ...List.generate(12, (i) {
          final turnNum = i + 1;
          return DataCell(
            SizedBox(
              width: 75,
              child: TurnCell(
                value: emp.turns[turnNum] ?? '',
                onChanged: isManagement ? (val) => provider.updateTurn(emp.id, turnNum, val) : null,
              ),
            ),
          );
        }),
        DataCell(
          SizedBox(
            width: 90,
            child: TurnCell(
              value: emp.bonus ?? '',
              onChanged: isManagement ? (val) => provider.updateTurn(emp.id, 13, val) : null,
              isBonus: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, AppProvider provider) {
    final idleCount = provider.employees.where((e) => e.status == 'idle').length;
    final workingCount = provider.employees.where((e) => e.status == 'working').length;

    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF0A0A0A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _FooterStat(label: 'AVAILABLE', value: '$idleCount', color: Colors.green),
              const SizedBox(width: 32),
              _FooterStat(label: 'WORKING', value: '$workingCount', color: const Color(0xFFD4AF37)),
            ],
          ),
          Row(
            children: [
              _ActionButton(
                label: 'CHECK-IN',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  // TODO: Implement Check-in
                },
              ),
              const SizedBox(width: 16),
              _ActionButton(
                label: 'NEW ASSIGNMENT',
                icon: Icons.add,
                isPrimary: true,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AssignmentModal(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final TextAlign textAlign;
  final Color color;

  const _HeaderCell(this.label, {required this.width, this.textAlign = TextAlign.center, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label.toUpperCase(),
        textAlign: textAlign,
        style: TextStyle(color: color.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isOutline;

  const _StatusBadge({required this.text, required this.color, this.isOutline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FooterStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.icon, this.isPrimary = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.05),
          foregroundColor: isPrimary ? Colors.black : const Color(0xFFD4AF37),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: isPrimary ? BorderSide.none : BorderSide(color: Colors.white.withOpacity(0.1)),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}
