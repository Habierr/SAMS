import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/ORController.dart';
import '../../../Domain/ORModel.dart';

class EditOR extends StatefulWidget {
  final String offeringDocId;
  final OfferingRegistration offering;

  const EditOR({
    super.key,
    required this.offeringDocId,
    required this.offering,
  });

  @override
  State<EditOR> createState() => _EditORState();
}

class _EditORState extends State<EditOR> {
  // Key used to trigger validation state flags across child fields prior to Firebase update writes
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _sectNoCtrl;
  late TextEditingController _quotaCtrl;
  late TextEditingController _lectNameCtrl;
  late TextEditingController _startTimeCtrl;
  late TextEditingController _endTimeCtrl;
  late TextEditingController _venueCtrl;

  late String _classType;
  late List<String> _selectedDays;
  bool _isSaving = false;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> _classTypes = ['Lecture', 'Tutorial', 'Lab'];

  @override
  void initState() {
    super.initState();
    // Initialize controller view buffers with current database document parameter records
    _sectNoCtrl = TextEditingController(text: widget.offering.sectNo);
    _quotaCtrl = TextEditingController(text: widget.offering.quota.toString());
    _lectNameCtrl = TextEditingController(text: widget.offering.lectName);
    _startTimeCtrl = TextEditingController(text: widget.offering.startTime);
    _endTimeCtrl = TextEditingController(text: widget.offering.endTime);
    _venueCtrl = TextEditingController(text: widget.offering.venue);

    // Case-insensitive normalization mapping incoming string variables against the strict dropdown arrays
    final normalized = widget.offering.classType.trim();
    _classType = _classTypes.firstWhere(
      (t) => t.toLowerCase() == normalized.toLowerCase(),
      orElse: () => _classTypes.first,
    );

    // Parses the comma-separated day strings stored in the database back into a clean selectable List array
    _selectedDays = widget.offering.days
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    // Terminate controller listeners manually to completely clear system memory on page exit
    _sectNoCtrl.dispose();
    _quotaCtrl.dispose();
    _lectNameCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  // Database update operation handler bundling modified fields into the state repository provider
  Future<void> _updateOffering() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Build the updated domain object model while preserving immutable identifiers like section IDs
    final updatedOffering = OfferingRegistration(
      sectID: widget.offering.sectID,
      subCode: widget.offering.subCode,
      subName: widget.offering.subName,
      classType: _classType,
      sectNo: _sectNoCtrl.text.trim(),
      quota: int.tryParse(_quotaCtrl.text.trim()) ?? widget.offering.quota,
      enrolled: widget.offering.enrolled,
      lectName:
          _lectNameCtrl.text.trim().isEmpty ? 'TBA' : _lectNameCtrl.text.trim(),
      days: _selectedDays.join(
          ', '), // Flattens tracking array back into a unified string block for Firestore
      startTime: _startTimeCtrl.text.trim(),
      endTime: _endTimeCtrl.text.trim(),
      venue: _venueCtrl.text.trim().isEmpty ? 'TBA' : _venueCtrl.text.trim(),
      semester: widget.offering.semester,
      session: widget.offering.session,
    );

    // Dispatch the payload down to the remote Firebase update service via the controller pattern
    final controller = Provider.of<ORController>(context, listen: false);
    await controller.updateOffering(widget.offeringDocId, updatedOffering);

    setState(() => _isSaving = false);

    // Safely exit scope if context remains alive, pushing a truthy indicator to notify list observers
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Section updated successfully!'),
          backgroundColor: Color(0xFF1A5F7A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // Reusable text layout field constructor to keep the form fields consistent
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A2D3D),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFE8F0F5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1A5F7A), width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Interface styling wrapper designed to package inputs within discrete white cards
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A5F7A),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F7),
      body: Column(
        children: [
          // ── Gradient Header UI Element ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A5F7A), Color(0xFF3A9CC8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 16, 16),
                child: Row(
                  children: [
                    // Back navigation button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Course details heading panel layout blocks
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Edit Section',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.offering.subCode}-${widget.offering.subName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // University decoration logo card element
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

          // ── Scrollable form entry layout canvas ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Card 1: Class Type Selector ──
                    _buildCard(
                      title: 'Class',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown selector handling class component categories
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _classType,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF1A5F7A),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF1A2D3D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                items: _classTypes
                                    .map((t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _classType = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Card 2: Section Attributes form rows ──
                    _buildCard(
                      title: 'Section details',
                      child: Column(
                        children: [
                          _buildField(
                            controller: _sectNoCtrl,
                            label: 'Section',
                            hint: 'e.g. 01',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _quotaCtrl,
                            label: 'Quota',
                            hint: 'e.g. 30',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (int.tryParse(v) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _lectNameCtrl,
                            label: 'Assign lecturer',
                            hint: 'e.g. Dr. Ahmad',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Card 3: Class Schedule configuration matrix ──
                    _buildCard(
                      title: 'Class schedule',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A9AAA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Multi-selection wrapping weekday toggle chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _days.map((day) {
                              final selected = _selectedDays.contains(day);
                              return GestureDetector(
                                onTap: () => setState(() {
                                  selected
                                      ? _selectedDays.remove(day)
                                      : _selectedDays.add(day);
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF5BAFD6)
                                        : const Color(0xFFE8F0F5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF7A9AAA),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A9AAA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Class time bounds input row setup
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _startTimeCtrl,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A2D3D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '08:00',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400], fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFFE8F0F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF1A5F7A), width: 1.6),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _endTimeCtrl,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A2D3D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '10:00',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400], fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFFE8F0F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF1A5F7A), width: 1.6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Venue location row item
                          _buildField(
                            controller: _venueCtrl,
                            label: 'Venue',
                            hint: 'e.g. BZ-01-102',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Bottom structural action confirm button row wrappers ──
                    Row(
                      children: [
                        // Save modification trigger action button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _updateOffering,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8F0F5),
                              foregroundColor: const Color(0xFF1A2D3D),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1A5F7A),
                                    ),
                                  )
                                : const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Screen exit cancel item
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isSaving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
