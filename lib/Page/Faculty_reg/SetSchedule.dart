import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/ORController.dart';
import '../../../Domain/ORModel.dart';

class SetSchedule extends StatefulWidget {
  const SetSchedule({super.key});

  @override
  State<SetSchedule> createState() => _SetScheduleState();
}

class _SetScheduleState extends State<SetSchedule> {
  // Store saved schedule per year group (local display only)
  final Map<String, Map<String, String>> _schedules = {
    'P1 & P2 students': {},
    'Year 4 students': {},
    'Year 3 students': {},
    'Year 2 students': {},
  };

  final List<String> _yearGroups = [
    'P1 & P2 students',
    'Year 4 students',
    'Year 3 students',
    'Year 2 students',
  ];

  // Map year group label → studentYear value yang disimpan dalam Firestore
  final Map<String, String> _yearGroupToStudentYear = {
    'P1 & P2 students': 'P1P2',
    'Year 4 students': 'Year 4',
    'Year 3 students': 'Year 3',
    'Year 2 students': 'Year 2',
  };

  String? _expandedGroup;
  String? _tempStartDate;
  String? _tempEndDate;
  String? _tempStartTime;
  String? _tempEndTime;

  bool _isSaving = false;

  // ── Load existing sessions dari Firestore bila page dibuka ─────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingSessions();
    });
  }

  void _loadExistingSessions() {
    final ctrl = context.read<ORController>();
    for (final session in ctrl.orSessions) {
      // Cari group label yang padanan dengan studentYear
      final groupLabel = _yearGroupToStudentYear.entries
          .firstWhere(
            (e) => e.value == session.studentYear,
            orElse: () => const MapEntry('', ''),
          )
          .key;

      if (groupLabel.isNotEmpty && _schedules.containsKey(groupLabel)) {
        setState(() {
          _schedules[groupLabel] = {
            'startDate': _formatDateForDisplay(session.startDate),
            'endDate': _formatDateForDisplay(session.endDate),
            'startTime': session.startTime,
            'endTime': session.endTime,
            'isActive': session.isActive.toString(),
            'sessionID': session.sessionID,
          };
        });
      }
    }
  }

  // "2026-04-14 00:00:00.000" → "14-4-2026"
  String _formatDateForDisplay(DateTime dt) {
    return '${dt.day}-${dt.month}-${dt.year}';
  }

  // "14-4-2026" → DateTime
  DateTime _parseDisplayDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.tryParse(parts[2]) ?? DateTime.now().year,
        int.tryParse(parts[1]) ?? DateTime.now().month,
        int.tryParse(parts[0]) ?? DateTime.now().day,
      );
    }
    return DateTime.now();
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<String?> _pickDate(BuildContext context, {String? initial}) async {
    DateTime now = DateTime.now();
    DateTime? init;
    if (initial != null) {
      final parts = initial.split('-');
      if (parts.length == 3) {
        init = DateTime(
          int.tryParse(parts[2]) ?? now.year,
          int.tryParse(parts[1]) ?? now.month,
          int.tryParse(parts[0]) ?? now.day,
        );
      }
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: init ?? now,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A5F7A),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return '${picked.day}-${picked.month}-${picked.year}';
  }

  // ── Time picker ────────────────────────────────────────────────────────────
  Future<String?> _pickTime(BuildContext context, {String? initial}) async {
    TimeOfDay init = TimeOfDay.now();
    if (initial != null) {
      final parts = initial.split(':');
      if (parts.length == 2) {
        init = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: init,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A5F7A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  // ── Open form ──────────────────────────────────────────────────────────────
  void _openForm(String group) {
    final existing = _schedules[group]!;
    setState(() {
      _expandedGroup = group;
      _tempStartDate = existing['startDate'];
      _tempEndDate = existing['endDate'];
      _tempStartTime = existing['startTime'];
      _tempEndTime = existing['endTime'];
    });
  }

  // ── Save form → Firestore ──────────────────────────────────────────────────
  Future<void> _saveForm(String group) async {
    if (_tempStartDate == null || _tempEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Start Date and End Date'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final ctrl = context.read<ORController>();
    final studentYear = _yearGroupToStudentYear[group] ?? group;
    final existing = _schedules[group]!;

    // Generate sessionID baru atau guna yang lama
    final sessionID = existing['sessionID'] ??
        'SES-$studentYear-${DateTime.now().millisecondsSinceEpoch}';

    // Ambil semester dari session yang ada atau guna default
    final activeSess = ctrl.orSessions.firstWhere(
      (s) => s.studentYear == studentYear,
      orElse: () => ORSession(
        sessionID: sessionID,
        semester: 'Sem 2',
        isActive: false,
        studentYear: studentYear,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        startTime: '08:00',
        endTime: '23:59',
      ),
    );

    final session = ORSession(
      sessionID: sessionID,
      semester: activeSess.semester,
      isActive: activeSess.isActive,
      studentYear: studentYear,
      startDate: _parseDisplayDate(_tempStartDate!),
      endDate: _parseDisplayDate(_tempEndDate!),
      startTime: _tempStartTime ?? '08:00',
      endTime: _tempEndTime ?? '23:59',
    );

    try {
      // ← Simpan ke Firestore melalui ORController
      await ctrl.saveORSession(session);

      setState(() {
        _schedules[group] = {
          'startDate': _tempStartDate!,
          'endDate': _tempEndDate!,
          if (_tempStartTime != null) 'startTime': _tempStartTime!,
          if (_tempEndTime != null) 'endTime': _tempEndTime!,
          'isActive': activeSess.isActive.toString(),
          'sessionID': sessionID,
        };
        _expandedGroup = null;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule for $group saved!'),
            backgroundColor: const Color(0xFF1A5F7A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Activate OR Session → Firestore ───────────────────────────────────────
  Future<void> _activateSession(String group) async {
    final studentYear = _yearGroupToStudentYear[group] ?? group;
    final existing = _schedules[group]!;

    if (!existing.containsKey('startDate')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please set schedule for $group first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ctrl = context.read<ORController>();

    try {
      // ← Activate di Firestore melalui ORController
      await ctrl.activateORSession(studentYear, true);
      await ctrl.activateORSession(studentYear, true);

      setState(() {
        _schedules[group]!['isActive'] = 'true';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OR session for $group activated!'),
            backgroundColor: const Color(0xFF27AE60),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to activate: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Badge ──────────────────────────────────────────────────────────────────
  Widget _buildBadge(String group) {
    final data = _schedules[group]!;
    final hasDate = data.containsKey('startDate');
    final isActive = data['isActive'] == 'true';

    if (!hasDate) {
      return GestureDetector(
        onTap: () => _openForm(group),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            'Set',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5A7A8A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openForm(group),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF27AE60) : const Color(0xFF1A5F7A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(Icons.circle, color: Colors.white, size: 8),
              const SizedBox(width: 4),
            ],
            Text(
              isActive ? 'Active' : _shortDate(data['startDate']!),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(String date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final parts = date.split('-');
    if (parts.length == 3) {
      final d = parts[0];
      final m = int.tryParse(parts[1]) ?? 0;
      return '${months[m]} $d';
    }
    return date;
  }

  Widget _buildTapField({
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7A9AAA),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value ?? hint,
              style: TextStyle(
                fontSize: 14,
                color:
                    value != null ? const Color(0xFF1A2D3D) : Colors.grey[400],
                fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F7),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A5F7A), Color(0xFF3A9CC8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Set Schedule',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.school,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF1A5F7A)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Priority access card ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priority access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A5F7A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._yearGroups.map(
                          (group) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A2D3D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                _buildBadge(group),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── OR Period form ─────────────────────────────────────
                  if (_expandedGroup != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OR period for $_expandedGroup',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A5F7A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTapField(
                            label: 'Start Date',
                            value: _tempStartDate,
                            hint: 'Select date',
                            onTap: () async {
                              final d = await _pickDate(context,
                                  initial: _tempStartDate);
                              if (d != null) setState(() => _tempStartDate = d);
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTapField(
                            label: 'End Date',
                            value: _tempEndDate,
                            hint: 'Select date',
                            onTap: () async {
                              final d = await _pickDate(context,
                                  initial: _tempEndDate);
                              if (d != null) setState(() => _tempEndDate = d);
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Registration time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A9AAA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final t = await _pickTime(context,
                                        initial: _tempStartTime);
                                    if (t != null)
                                      setState(() => _tempStartTime = t);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _tempStartTime ?? '00:00',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1A2D3D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('-',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 18)),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final t = await _pickTime(context,
                                        initial: _tempEndTime);
                                    if (t != null)
                                      setState(() => _tempEndTime = t);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _tempEndTime ?? '00:00',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1A2D3D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _saveForm(_expandedGroup!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A9CC8),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Save',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _expandedGroup = null),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Activate OR Session button ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showActivateDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Activate OR session',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Activate dialog — pilih year group mana nak activate ──────────────────
  void _showActivateDialog() {
    // Cari groups yang dah ada schedule
    final groupsWithSchedule = _yearGroups
        .where((g) => _schedules[g]!.containsKey('startDate'))
        .toList();

    if (groupsWithSchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please set schedule for at least one year group first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Activate OR Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select year group to activate:'),
            const SizedBox(height: 12),
            ...groupsWithSchedule.map(
              (group) {
                final isActive = _schedules[group]!['isActive'] == 'true';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(group, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    isActive ? 'Already active' : 'Not active',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? const Color(0xFF27AE60) : Colors.grey,
                    ),
                  ),
                  trailing: isActive
                      ? const Icon(Icons.check_circle, color: Color(0xFF27AE60))
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _activateSession(group);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27AE60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Activate'),
                        ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFF1A5F7A))),
          ),
        ],
      ),
    );
  }
}
