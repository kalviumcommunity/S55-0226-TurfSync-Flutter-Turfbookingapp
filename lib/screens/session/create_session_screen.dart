import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/practice_session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';

/// Screen for coaches to create or edit a practice session.
class CreateSessionScreen extends StatefulWidget {
  final PracticeSessionModel? existingSession;

  const CreateSessionScreen({super.key, this.existingSession});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _maxPlayersController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _selectedTurfId;
  String? _selectedTurfName;

  bool get _isEditing => widget.existingSession != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.existingSession!;
      _titleController.text = s.title;
      _maxPlayersController.text = s.maxPlayers.toString();
      _selectedDate = s.date;
      _selectedTurfId = s.turfId;
      _selectedTurfName = s.turfName;
      // Parse stored times
      final startParts = s.startTime.split(':');
      _startTime = TimeOfDay(
          hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      final endParts = s.endTime.split(':');
      _endTime = TimeOfDay(
          hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
    } else {
      _maxPlayersController.text = '10';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  String _formatTod(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTurfId == null) {
      ErrorDialog.showError(context, 'Please select a turf');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final sessionProvider = context.read<SessionProvider>();

    final session = PracticeSessionModel(
      id: _isEditing ? widget.existingSession!.id : '',
      title: _titleController.text.trim(),
      coachId: authProvider.userId,
      coachName: authProvider.userModel?.fullName ?? 'Coach',
      turfId: _selectedTurfId!,
      turfName: _selectedTurfName ?? '',
      date: _selectedDate,
      startTime: _formatTod(_startTime),
      endTime: _formatTod(_endTime),
      maxPlayers: int.parse(_maxPlayersController.text.trim()),
      joinedPlayerIds:
          _isEditing ? widget.existingSession!.joinedPlayerIds : [],
      createdAt:
          _isEditing ? widget.existingSession!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await sessionProvider.updateSession(session);
    } else {
      success = await sessionProvider.createSession(session);
    }

    if (!mounted) return;

    if (success) {
      ErrorDialog.showSuccess(
        context,
        _isEditing ? 'Session updated!' : 'Session created!',
      );
      Navigator.pop(context);
    } else if (sessionProvider.errorMessage != null) {
      ErrorDialog.showError(context, sessionProvider.errorMessage!);
      sessionProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final turfs = context.watch<TurfProvider>().turfs;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Session' : AppStrings.createSession),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Title ───
              CustomTextField(
                controller: _titleController,
                label: 'Session Title',
                prefixIcon: Icons.title,
                validator: (v) => Validators.required(v, 'Title'),
              ),
              const SizedBox(height: 16),

              // ─── Turf Selection ───
              DropdownButtonFormField<String>(
                value: _selectedTurfId,
                decoration: const InputDecoration(
                  labelText: 'Select Turf',
                  prefixIcon: Icon(Icons.sports_soccer),
                ),
                items: turfs
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                validator: (v) => v == null ? 'Please select a turf' : null,
                onChanged: (value) {
                  setState(() {
                    _selectedTurfId = value;
                    _selectedTurfName =
                        turfs.firstWhere((t) => t.id == value).name;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ─── Max Players ───
              CustomTextField(
                controller: _maxPlayersController,
                label: 'Max Players',
                prefixIcon: Icons.group,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.numeric(v, 'Max players'),
              ),
              const SizedBox(height: 24),

              // ─── Date Picker ───
              Text('Date & Time',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
              ),
              const SizedBox(height: 12),

              // ─── Time Pickers ───
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(isStart: true),
                      icon: const Icon(Icons.access_time),
                      label: Text('Start: ${_formatTod(_startTime)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(isStart: false),
                      icon: const Icon(Icons.access_time),
                      label: Text('End: ${_formatTod(_endTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Save Button ───
              Consumer<SessionProvider>(
                builder: (context, ssnProv, _) {
                  return CustomButton(
                    text: _isEditing ? 'Update Session' : 'Create Session',
                    onPressed: _handleSave,
                    isLoading: ssnProv.isLoading,
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
