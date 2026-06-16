import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/ORController.dart';
import '../../../Domain/ORModel.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});

  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  // GlobalKey untuk handle form validation status sebelum subjek baru disimpan
  final _formKey = GlobalKey<FormState>();

  // Text controller untuk menangkap input data dari textfield
  final _subCodeCtrl = TextEditingController();
  final _subNameCtrl = TextEditingController();
  final _creditHourCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();

  // State flag untuk control loading spinner dekat butang Save
  bool _isSaving = false;

  @override
  void dispose() {
    // Dipose semua controller bila widget mati untuk jimat memori / elak leak
    _subCodeCtrl.dispose();
    _subNameCtrl.dispose();
    _creditHourCtrl.dispose();
    _facultyCtrl.dispose();
    super.dispose();
  }

  // Fungsi hantar data subjek baru ke state controller (ORController)
  Future<void> _saveSubject() async {
    // Trigger validation semua field. Kalau ada error, fungsi stop kat sini
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Ambil input, trim whitespace, dan paksa subCode jadi uppercase automatik
    final newSubject = Subject(
      subCode: _subCodeCtrl.text.trim().toUpperCase(),
      subName: _subNameCtrl.text.trim(),
      creditHour: int.tryParse(_creditHourCtrl.text.trim()) ??
          3, // Fallback ke 3 jam kredit kalau parse fail
      faculty: _facultyCtrl.text.trim(),
    );

    try {
      // Panggil function addSubject dari Provider tanpa re-trigger build context
      final controller = Provider.of<ORController>(context, listen: false);
      await controller.addSubject(newSubject);

      if (mounted) {
        // Papar status kejayaan guna snackbar melayang (floating)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newSubject.subCode} added successfully!'),
            backgroundColor: const Color(0xFF1A5F7A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Tutup page dan hantar feedback 'true' ke parent widget untuk senarai di-refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Helper widget builder untuk elakkan duplicate kod UI custom TextFormField
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A7A8A),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F7),
      body: Column(
        children: [
          // ── Gradient Header ────────────────────────────────────────────
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
                        'Add Subject',
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

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Subject info card ────────────────────────────
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
                          const Text(
                            'Subject Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A5F7A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input untuk Kod Subjek
                          _buildField(
                            controller: _subCodeCtrl,
                            label: 'Subject Code',
                            hint: 'e.g. BCS2344',
                            capitalization: TextCapitalization.characters,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.trim().length < 5) {
                                return 'Code too short';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Input untuk Nama Subjek
                          _buildField(
                            controller: _subNameCtrl,
                            label: 'Subject Name',
                            hint: 'e.g. Web Engineering',
                            capitalization: TextCapitalization.words,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),

                          // Susunan horizontal untuk jam kredit dan fakulti
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _creditHourCtrl,
                                  label: 'Credit Hour',
                                  hint: 'e.g. 3',
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Required';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1 || n > 6) {
                                      return '1 – 6'; // Validasi had minimum dan maksimum jam kredit
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _buildField(
                                  controller: _facultyCtrl,
                                  label: 'Faculty',
                                  hint: 'e.g. FSKM',
                                  capitalization: TextCapitalization.characters,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Buttons ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveSubject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A5F7A),
                              foregroundColor: Colors.white,
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
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Save Subject',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
