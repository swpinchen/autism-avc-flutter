import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/features/items/recurring_rule_picker.dart';
import 'package:autism_avc_flutter/features/items/unsplash_picker_screen.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  final int? editItemId;
  final DateTime? initialDate;

  const ItemFormScreen({super.key, this.editItemId, this.initialDate});

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _recurringRule;
  String? _imagePath;
  bool _isLoading = false;

  bool get isEditing => widget.editItemId != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _startDate = widget.initialDate!;
    }
    if (isEditing) {
      _loadItem();
    }
  }

  Future<void> _loadItem() async {
    final db = ref.read(databaseProvider);
    final item = await db.getItem(widget.editItemId!);
    _titleController.text = item.title;
    _detailsController.text = item.details;
    setState(() {
      _startDate = item.startDate;
      _endDate = item.endDate;
      _recurringRule = item.recurringRule;
      _imagePath = item.imagePath;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'New Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Details
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Details are required' : null,
            ),
            const SizedBox(height: 16),

            // Start date/time
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start'),
              subtitle: Text(
                  DateFormat.yMMMd().add_jm().format(_startDate)),
              onTap: _pickStartDate,
            ),

            // End date/time
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('End'),
              subtitle: Text(_endDate != null
                  ? DateFormat.yMMMd().add_jm().format(_endDate!)
                  : 'Not set'),
              onTap: _pickEndDate,
            ),
            // Recurring rule
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repeat'),
              subtitle: Text(_recurringRule ?? 'None'),
              onTap: () async {
                final rule = await showModalBottomSheet<String?>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => RecurringRulePicker(
                      initialRule: _recurringRule),
                );
                // rule is null if cancelled, or a String? (null = 'None')
                if (rule != null || rule == null) {
                  setState(() => _recurringRule = rule);
                }
              },
            ),
            const SizedBox(height: 16),

            // Photo
            Text('Photo', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_imagePath != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _imagePath = null),
                    ),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickUnsplash,
                    icon: const Icon(Icons.image_search),
                    label: const Text('Unsplash'),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (time == null) return;

    setState(() {
      _startDate = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _endDate != null
          ? TimeOfDay.fromDateTime(_endDate!)
          : TimeOfDay.fromDateTime(
              _startDate.add(const Duration(hours: 1))),
    );
    if (time == null) return;

    setState(() {
      _endDate = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked == null) return;

    final imageService = ref.read(imageStorageServiceProvider);
    final path = await imageService.saveImage(File(picked.path));
    setState(() => _imagePath = path);
  }

  Future<void> _pickUnsplash() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const UnsplashPickerScreen()),
    );
    if (path != null) {
      setState(() => _imagePath = path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Profanity check
    final profanityFilter = ref.read(profanityFilterProvider);
    final errors = profanityFilter.validate(
      title: _titleController.text,
      details: _detailsController.text,
    );
    if (errors.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.join(', '))),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final db = ref.read(databaseProvider);

    if (isEditing) {
      await db.updateItem(ItemsCompanion(
        id: Value(widget.editItemId!),
        title: Value(_titleController.text),
        details: Value(_detailsController.text),
        startDate: Value(_startDate),
        endDate: Value(_endDate),
        recurringRule: Value(_recurringRule),
        imagePath: Value(_imagePath),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await db.insertItem(ItemsCompanion.insert(
        title: _titleController.text,
        details: Value(_detailsController.text),
        startDate: _startDate,
        endDate: Value(_endDate),
        recurringRule: Value(_recurringRule),
        imagePath: Value(_imagePath),
      ));
    }

    setState(() => _isLoading = false);
    if (mounted) context.pop();
  }
}
