import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/ORController.dart';
import '../../../Domain/ORModel.dart';
import 'EditOR.dart';

class SubjectOffering extends StatefulWidget {
  const SubjectOffering({super.key});

  @override
  State<SubjectOffering> createState() => _SubjectOfferingState();
}

class _SubjectOfferingState extends State<SubjectOffering> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ORController>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Bottom Sheet: Add / Edit ───────────────────────────────────────────────
  void _showOfferingForm(BuildContext context, ORController controller,
      {dynamic offering, String? docId}) {
    final isEdit = offering != null;

    final subCodeCtrl =
        TextEditingController(text: isEdit ? offering.subCode : '');
    final subNameCtrl =
        TextEditingController(text: isEdit ? offering.subName : '');
    final sectNoCtrl =
        TextEditingController(text: isEdit ? offering.sectNo : '');
    final classTypeCtrl =
        TextEditingController(text: isEdit ? offering.classType : '');
    final daysCtrl = TextEditingController(text: isEdit ? offering.days : '');
    final startTimeCtrl =
        TextEditingController(text: isEdit ? offering.startTime : '');
    final endTimeCtrl =
        TextEditingController(text: isEdit ? offering.endTime : '');
    final lectNameCtrl =
        TextEditingController(text: isEdit ? offering.lectName : '');

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text(
                    isEdit ? 'Edit Subject Offering' : 'Add Subject Offering',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A5F7A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row: Subject Code + Subject Name
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildField(
                          controller: subCodeCtrl,
                          label: 'Subject Code',
                          hint: 'e.g. BCS2344',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildField(
                          controller: subNameCtrl,
                          label: 'Subject Name',
                          hint: 'e.g. Web Engineering',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row: Section No + Class Type
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: sectNoCtrl,
                          label: 'Section No',
                          hint: 'e.g. 01',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: classTypeCtrl,
                          label: 'Class Type',
                          hint: 'e.g. L60 / B30',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Days
                  _buildField(
                    controller: daysCtrl,
                    label: 'Day(s)',
                    hint: 'e.g. Mon / Mon - Wed',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Row: Start Time + End Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: startTimeCtrl,
                          label: 'Start Time',
                          hint: 'e.g. 8-10 a.m',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: endTimeCtrl,
                          label: 'End Time',
                          hint: 'e.g. 10-12 a.m',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Lecturer Name
                  _buildField(
                    controller: lectNameCtrl,
                    label: 'Lecturer Name',
                    hint: 'e.g. Dr. Noorlin',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF1A5F7A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF1A5F7A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            // ── TAMBAH: Semak activeSession ──
                            final session = controller.activeSession;
                            if (session == null) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Tiada OR session aktif. Sila aktifkan session dahulu.'),
                                ),
                              );
                              return;
                            }
                            // ────────────────────────────────

                            final newOffering = OfferingRegistration(
                              sectID: isEdit ? offering!.sectID : '',
                              subCode: subCodeCtrl.text.trim(),
                              subName: subNameCtrl.text.trim(),
                              sectNo: sectNoCtrl.text.trim(),
                              classType: classTypeCtrl.text.trim(),
                              days: daysCtrl.text.trim(),
                              startTime: startTimeCtrl.text.trim(),
                              endTime: endTimeCtrl.text.trim(),
                              lectName: lectNameCtrl.text.trim(),
                              quota: isEdit ? offering!.quota : 0,
                              enrolled: isEdit ? offering!.enrolled : 0,
                              venue: isEdit ? offering!.venue : '',
                              semester: session.semester, // ← ganti 'Sem 2'
                              session: session.sessionID, // ← ganti '2025/2026'
                            );

                            if (isEdit && docId != null) {
                              await controller.updateOffering(
                                  docId, newOffering);
                            } else {
                              await controller.addOffering(newOffering);
                            }

                            if (ctx.mounted) Navigator.pop(ctx);
                            controller.loadData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A5F7A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Add Offering',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Delete confirmation ────────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, ORController controller, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Offering'),
        content: const Text(
            'Are you sure you want to delete this subject offering?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF1A5F7A))),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteOffering(docId);
              if (ctx.mounted) Navigator.pop(ctx);
              controller.loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Reusable text field ────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF1A5F7A), fontSize: 13),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A5F7A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  // ─── Main build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Consumer<ORController>(
        builder: (context, controller, child) {
          final filtered = controller.offerings.where((o) {
            final q = _searchQuery.toLowerCase();
            return q.isEmpty ||
                o.subCode.toLowerCase().contains(q) ||
                o.subName.toLowerCase().contains(q) ||
                o.lectName.toLowerCase().contains(q);
          }).toList();

          final filteredDocIds = <String>[];
          for (int i = 0; i < controller.offerings.length; i++) {
            final o = controller.offerings[i];
            final q = _searchQuery.toLowerCase();
            if (q.isEmpty ||
                o.subCode.toLowerCase().contains(q) ||
                o.subName.toLowerCase().contains(q) ||
                o.lectName.toLowerCase().contains(q)) {
              filteredDocIds.add(controller.offeringsDocIds[i]);
            }
          }

          return Column(
            children: [
              // ── Gradient Header ──────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A5F7A), Color(0xFF2980B9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                'Subject Offering',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.school,
                                  color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // ── Papar semester dari activeSession ──
                        Consumer<ORController>(
                          builder: (context, ctrl, _) => Center(
                            child: Text(
                              ctrl.activeSession != null
                                  ? '${ctrl.activeSession!.semester} ${ctrl.activeSession!.sessionID}'
                                  : 'Tiada session aktif',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Search Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF1A5F7A)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.grey, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ── Section label ────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Offered subjects',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5F7A),
                      ),
                    ),
                    // ── Badge semester dari activeSession ──
                    Consumer<ORController>(
                      builder: (context, ctrl, _) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A5F7A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ctrl.activeSession?.semester ?? 'Tiada session',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1A5F7A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── List ─────────────────────────────────────────────────────
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              controller.errorMessage != null
                                  ? controller.errorMessage!
                                  : (_searchQuery.isEmpty
                                      ? 'No offerings available'
                                      : 'No results for "$_searchQuery"'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final offering = filtered[index];
                              final docId = filteredDocIds[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
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
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${offering.subCode} - ${offering.subName}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF1A2D3D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Sec ${offering.sectNo} - ${offering.classType} - ${offering.days} ${offering.startTime}-${offering.endTime}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF7F8C8D),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            offering.lectName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF1A5F7A),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action buttons
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditOR(
                                                  offeringDocId: docId,
                                                  offering: offering,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              controller.loadData();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1A5F7A)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Color(0xFF1A5F7A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: () => _confirmDelete(
                                              context, controller, docId),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),

      // ── Floating Add Button ───────────────────────────────────────────────
      floatingActionButton: Consumer<ORController>(
        builder: (context, controller, _) => SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FloatingActionButton.extended(
              onPressed: () => _showOfferingForm(context, controller),
              backgroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              label: const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF1A5F7A), size: 20),
                  SizedBox(width: 6),
                  Text(
                    '+ Add subject offering',
                    style: TextStyle(
                      color: Color(0xFF1A5F7A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
