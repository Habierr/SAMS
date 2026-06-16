import 'package:flutter/material.dart';
import 'package:sams/login.dart';
import 'package:sams/Page/Curriculum/review_curriculum_claims.dart';
import 'package:table_calendar/table_calendar.dart';

// Dashboard page for Pusat Adab user
class PusatDashboard extends StatefulWidget {
  const PusatDashboard({super.key});

  @override
  State<PusatDashboard> createState() => _PusatDashboardState();
}

class _PusatDashboardState extends State<PusatDashboard> {
  // Store currently focused calendar date
  DateTime _focusedDay = DateTime.now();

  // Store selected calendar date
  DateTime? _selectedDay;

  // Controller for note input field
  final TextEditingController noteController = TextEditingController();

  // Store notes based on selected date
  final Map<String, List<String>> notes = {};

  // Convert selected date into string key
  String getDateKey(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Add note to selected calendar date
  void addNote() {
    // Validate date selection
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    // Validate note input
    if (noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter note')),
      );
      return;
    }

    final key = getDateKey(_selectedDay!);

    // Save note into local notes map
    setState(() {
      notes.putIfAbsent(key, () => []);
      notes[key]!.add(noteController.text.trim());
      noteController.clear();
    });
  }

  @override
  void dispose() {
    // Dispose controller to avoid memory leaks
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get key for selected date
    final selectedKey = _selectedDay == null ? null : getDateKey(_selectedDay!);

    // Get notes for selected date
    final selectedNotes =
        selectedKey == null ? <String>[] : notes[selectedKey] ?? <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // Side navigation drawer
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer header with logo and system name
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF003EA1),
                    Color(0xFF4A69D6),
                    Color(0xFF8FA3F0),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo_umpsa.png',
                      width: 55,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'STUDENT ACADEMIC\nMANAGEMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigate to dashboard page
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Navigate to review curriculum claims page
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('Review Curriculum Claims'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewCurriculumClaims(),
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(),

            // Logout and return to login page
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Top app bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,

          // Open drawer menu
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          // App bar title
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'STUDENT ACADEMIC\nMANAGEMENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),

          centerTitle: true,

          // UMPSA logo
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/logo_umpsa.png',
                width: 45,
                height: 45,
                fit: BoxFit.contain,
              ),
            ),
          ],

          // Blue gradient background
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF003EA1),
                  Color(0xFF4A69D6),
                  Color(0xFF8FA3F0),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ),
      ),

      // Main dashboard body
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Welcome text
                const Text(
                  'Welcome ,',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003EA1),
                  ),
                ),

                const SizedBox(height: 20),

                // Dashboard section title
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                // Calendar card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,

                    // Mark selected date on calendar
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },

                    // Update selected and focused date
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),

                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF003EA1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Display selected date
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDay == null
                        ? 'No date selected'
                        : 'Selected Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Note input section title
                const Text(
                  'Add Notes / Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Note input field
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Example: Meeting, activity, reminder...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF003EA1),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Button to add note
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: addNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003EA1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'ADD NOTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Notes section title
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Display note list based on selected date
                if (_selectedDay == null)
                  const Text(
                    'Please select a date to view notes.',
                    style: TextStyle(color: Colors.grey),
                  )
                else if (selectedNotes.isEmpty)
                  const Text(
                    'No notes for this date.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Column(
                    children: selectedNotes.map((note) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF003EA1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_note,
                              color: Color(0xFF003EA1),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                note,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
