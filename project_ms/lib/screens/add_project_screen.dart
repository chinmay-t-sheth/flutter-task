// lib/screens/add_project_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedType;
  List<String> _members = [];
  DateTime? _startDate;
  DateTime? _endDate;

  static const List<String> _types = ['Web', 'Mobile', 'Desktop'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.folder)),
                  validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                  validator: (value) => value?.isEmpty ?? true ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category)),
                  items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _selectedType = value),
                  validator: (value) => value == null ? 'Select type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Members (comma separated)',
                    prefixIcon: const Icon(Icons.group),
                  ),
                  onChanged: (value) => _members = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => _startDate = date);
                        },
                        child: Text(_startDate == null ? 'Start Date' : DateFormat('MMM dd, yyyy').format(_startDate!)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (date != null) setState(() => _endDate = date);
                        },
                        child: Text(_endDate == null ? 'End Date' : DateFormat('MMM dd, yyyy').format(_endDate!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false && _selectedType != null && _startDate != null && _endDate != null) {
                        // Add project logic; create Project object
                        final newProject = Project(
                          id: DateTime.now().toString(),
                          name: _nameController.text,
                          description: _descController.text,
                          type: _selectedType!,
                          members: _members,
                          startDate: _startDate!,
                          endDate: _endDate!,
                          progress: 0.0,
                          status: 'pending',
                        );
                        // Simulate save
                        Navigator.pop(context, newProject);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project added!')));
                      }
                    },
                    child: const Text('Add Project'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
