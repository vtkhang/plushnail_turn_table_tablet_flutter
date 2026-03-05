import 'skill.dart';

class Employee {
  final String id;
  final String pager;
  final String name;
  final String phone;
  final String status;
  final String? currentTask;
  final String? expectedFinish;
  final String? nextAppointment;
  final String? comments;
  final Map<int, String> turns;
  final String? bonus;
  final String checkInTime;
  final List<Skill>? skills;

  Employee({
    required this.id,
    required this.pager,
    required this.name,
    required this.phone,
    required this.status,
    this.currentTask,
    this.expectedFinish,
    this.nextAppointment,
    this.comments,
    required this.turns,
    this.bonus,
    required this.checkInTime,
    this.skills,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final turnsMap = <int, String>{};
    final turnsJson = json['turn_assignments'] as Map<String, dynamic>? ?? {};
    turnsJson.forEach((key, value) {
      final turnNum = int.tryParse(key);
      if (turnNum != null) {
        turnsMap[turnNum] = value['turn_value'] ?? '';
      }
    });

    return Employee(
      id: json['id'].toString(),
      pager: json['id'].toString(),
      name: json['user_name'] ?? json['employee_name'] ?? '',
      phone: json['phone'] ?? '',
      status: json['current_status']?.toString().toLowerCase() ?? 'idle',
      currentTask: json['active_task']?['menu']?['name'] ?? json['active_task']?['name'] ?? (json['current_status'] == 'Working' ? 'Task' : null),
      expectedFinish: json['expected_finished_time'] != null 
        ? (DateTime.tryParse(json['expected_finished_time'].toString())?.toLocal().toString().substring(11, 16)) 
        : null,
      nextAppointment: json['next_appointment']?['time']?.toString().substring(0, 5),
      turns: turnsMap,
      bonus: turnsMap[13] ?? '',
      checkInTime: json['checked_in_time'] ?? '',
      skills: (json['skills'] as List? ?? []).map((s) => Skill.fromJson(s)).toList(),
    );
  }
}
