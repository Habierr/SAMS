import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/ORController.dart';
import 'SubjectManagement.dart';
import 'SubjectOffering.dart';
import 'SetSchedule.dart';
import 'ViewEnrollment.dart';
import '../../../login.dart';

class RegistrarDashboard extends StatefulWidget {
  const RegistrarDashboard({super.key});

  @override
  State<RegistrarDashboard> createState() => _RegistrarDashboardState();
}

class _RegistrarDashboardState extends State<RegistrarDashboard> {
  // Scaffold key to programmatically trigger the sidebar drawer from the app bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Track grid cell press events for feedback styling mutations
  int _pressedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Safe framing callback initializing core datasets immediately after the first frame render completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ORController>(context, listen: false);
      controller.initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:
          _scaffoldKey, // Bind state key to access scaffold actions across child view scopes
      backgroundColor: const Color(0xFFF0F4F8),

      // Sidebar navigational overlay menu pane configuration
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(
                    0xFF1A5F7A), // Master theme signature header backdrop color
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.badge_outlined,
                    color: Color(0xFF1A5F7A), size: 36),
              ),
              accountName: const Text(
                'Faculty Registrar',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              accountEmail: const Text(
                'registrar@university.edu.my',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined,
                  color: Color(0xFF1A5F7A)),
              title: const Text('Dashboard Home'),
              onTap: () =>
                  Navigator.pop(context), // Dismiss drawer overlay sheet view
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined,
                  color: Color(0xFF1A5F7A)),
              title: const Text('Subject Management'),
              onTap: () {
                Navigator.pop(
                    context); // Close drawer menu prior to routing transitions
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubjectManagement()));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.people_outline, color: Color(0xFF1A5F7A)),
              title: const Text('View Enrollment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ViewEnrollment()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined,
                  color: Color(0xFF1A5F7A)),
              title: const Text('Subject Offering'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SubjectOffering()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF1A5F7A)),
              title: const Text('OR Session Schedule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SetSchedule()));
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_outlined, color: Colors.red),
              title: const Text(
                'Logout',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Clear active navigation trees and reset routing stack straight back to Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'STUDENT ACADEMIC\nMANAGEMENT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF1A5F7A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 24, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Programmatic sidebar invocation call
          },
          splashRadius: 20,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/logo_umpsa.png',
              height: 36,
              width: 36,
              errorBuilder: (context, error, stackTrace) {
                // Circular vector backup icon falls into place if local image path throws anomalies
                return Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 22,
                    color: Color(0xFF1A5F7A),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<ORController>(
        builder: (context, controller, child) {
          // Present loading indicator if background data synchronization actions are running
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A5F7A)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildWelcomeSection(),
                const SizedBox(height: 20),
                _buildQuickActionSection(context),
                const SizedBox(height: 20),
                _buildSearchSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Welcome, Faculty Registrar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildQuickActionSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick action',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A5F7A),
            ),
          ),
          const SizedBox(height: 14),
          _buildQuickActionGrid(context),
        ],
      ),
    );
  }

  // Maps label entities directly to their target dashboard interface screens
  Widget _buildQuickActionGrid(BuildContext context) {
    final actions = [
      {'label': 'Subject\nManagement', 'page': const SubjectManagement()},
      {'label': 'View Enrollment', 'page': const ViewEnrollment()},
      {'label': 'Subject\nOffering', 'page': const SubjectOffering()},
      {'label': 'OR session', 'page': const SetSchedule()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disables independent list scrolling inside scrolling parents
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressedIndex =
              index), // Capture index to deploy active card tap color
          onTapUp: (_) {
            setState(() => _pressedIndex =
                -1); // Reset feedback parameters cleanly on touch lift
            final page = actions[index]['page'] as Widget?;
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          onTapCancel: () => setState(() => _pressedIndex = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: _pressedIndex == index
                  ? const Color(0xFFB2D8E8) // Highlight selection tint
                  : const Color(0xFFD6EEF6), // Base selection tint
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              actions[index]['label'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A5F7A),
                height: 1.3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
        suffixIcon: const Icon(
          Icons.search,
          color: Color(0xFF7F8C8D),
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A5F7A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }
}
