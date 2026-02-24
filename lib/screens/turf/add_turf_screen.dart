import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/turf_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';

/// Screen for adding or editing a turf (Admin only).
class AddTurfScreen extends StatefulWidget {
  final TurfModel? existingTurf;

  const AddTurfScreen({super.key, this.existingTurf});

  @override
  State<AddTurfScreen> createState() => _AddTurfScreenState();
}

class _AddTurfScreenState extends State<AddTurfScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotDurationController = TextEditingController();

  int _startHour = 6;
  int _endHour = 22;

  bool get _isEditing => widget.existingTurf != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final turf = widget.existingTurf!;
      _nameController.text = turf.name;
      _locationController.text = turf.location;
      _descriptionController.text = turf.description;
      _priceController.text = turf.pricePerSlot.toStringAsFixed(0);
      _slotDurationController.text = turf.slotDuration.toString();
      _startHour = turf.startHour;
      _endHour = turf.endHour;
    } else {
      _slotDurationController.text = '60';
      _priceController.text = '500';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _slotDurationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final turfProvider = context.read<TurfProvider>();
    final now = DateTime.now();

    final turf = TurfModel(
      id: _isEditing ? widget.existingTurf!.id : '',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      startHour: _startHour,
      endHour: _endHour,
      slotDuration: int.parse(_slotDurationController.text.trim()),
      pricePerSlot: double.parse(_priceController.text.trim()),
      createdBy: authProvider.userId,
      createdAt: _isEditing ? widget.existingTurf!.createdAt : now,
      updatedAt: now,
    );

    bool success;
    if (_isEditing) {
      success = await turfProvider.updateTurf(turf);
    } else {
      success = await turfProvider.createTurf(turf);
    }

    if (!mounted) return;

    if (success) {
      ErrorDialog.showSuccess(
        context,
        _isEditing
            ? 'Turf updated successfully!'
            : 'Turf created successfully!',
      );
      Navigator.pop(context);
    } else if (turfProvider.errorMessage != null) {
      ErrorDialog.showError(context, turfProvider.errorMessage!);
      turfProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editTurf : AppStrings.addTurf),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Turf Name ───
              CustomTextField(
                controller: _nameController,
                label: AppStrings.turfName,
                prefixIcon: Icons.sports_soccer,
                validator: (v) => Validators.required(v, 'Turf name'),
              ),
              const SizedBox(height: 16),

              // ─── Location ───
              CustomTextField(
                controller: _locationController,
                label: AppStrings.turfLocation,
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => Validators.required(v, 'Location'),
              ),
              const SizedBox(height: 16),

              // ─── Description ───
              CustomTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ─── Price per Slot ───
              CustomTextField(
                controller: _priceController,
                label: 'Price per Slot (₹)',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.numeric(v, 'Price'),
              ),
              const SizedBox(height: 16),

              // ─── Slot Duration ───
              CustomTextField(
                controller: _slotDurationController,
                label: AppStrings.slotDuration,
                prefixIcon: Icons.timer,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.numeric(v, 'Slot duration'),
              ),
              const SizedBox(height: 24),

              // ─── Available Hours ───
              Text(
                'Available Hours',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Hour'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _startHour,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          items: List.generate(24, (i) => i)
                              .map((hour) => DropdownMenuItem(
                                    value: hour,
                                    child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _startHour = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Hour'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _endHour,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          items: List.generate(24, (i) => i + 1)
                              .where((h) => h > _startHour)
                              .map((hour) => DropdownMenuItem(
                                    value: hour,
                                    child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _endHour = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Save Button ───
              Consumer<TurfProvider>(
                builder: (context, turfProv, _) {
                  return CustomButton(
                    text: _isEditing ? 'Update Turf' : 'Create Turf',
                    onPressed: _handleSave,
                    isLoading: turfProv.isLoading,
                    icon: Icons.save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
