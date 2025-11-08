import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'fd_provider.dart';
import 'fd.dart';

class AddFDScreen extends StatefulWidget {
  final FD? fdToEdit;

  const AddFDScreen({super.key, this.fdToEdit});

  @override
  State<AddFDScreen> createState() => _AddFDScreenState();
}

class _AddFDScreenState extends State<AddFDScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _bankController;
  late TextEditingController _accountNoController;
  late TextEditingController _principalController;
  late TextEditingController _rateController;
  late TextEditingController _nomineeNameController;
  late TextEditingController _jointHolderController;
  late TextEditingController _remarksController;

  DateTime? _startDate;
  DateTime? _maturityDate;
  String _payoutFreq = 'On Maturity';

  bool get _isEditing => widget.fdToEdit != null;

  @override
  void initState() {
    super.initState();
    final fd = widget.fdToEdit;

    _titleController = TextEditingController(text: fd?.title ?? '');
    _bankController = TextEditingController(text: fd?.bankName ?? '');
    _accountNoController = TextEditingController(text: fd?.accountNo ?? '');
    _principalController =
        TextEditingController(text: fd?.principal.toString() ?? '');
    _rateController = TextEditingController(text: fd?.rate.toString() ?? '');
    _nomineeNameController = TextEditingController(text: fd?.nomineeName ?? '');
    _jointHolderController = TextEditingController(text: fd?.jointHolder ?? '');
    _remarksController = TextEditingController(text: fd?.remarks ?? '');

    if (_isEditing) {
      _startDate = fd!.startDate;
      _maturityDate = fd.maturityDate;
      _payoutFreq = fd.payoutFreq;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bankController.dispose();
    _accountNoController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _nomineeNameController.dispose();
    _jointHolderController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_maturityDate ?? _startDate ?? DateTime.now());

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _maturityDate = picked;
        }
      });
    }
  }

  void _saveFD() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_startDate == null || _maturityDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and maturity dates.')),
      );
      return;
    }
    if (_maturityDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maturity date must be after the start date.')),
      );
      return;
    }

    final fdProvider = Provider.of<FDProvider>(context, listen: false);

    final String computedStatus =
    _maturityDate!.isBefore(DateTime.now()) ? 'Matured' : 'Active';

    final fd = FD(
      id: widget.fdToEdit?.id,
      title: _titleController.text,
      bankName: _bankController.text,
      accountNo: _accountNoController.text,
      principal: double.tryParse(_principalController.text) ?? 0.0,
      rate: double.tryParse(_rateController.text) ?? 0.0,
      startDate: _startDate!,
      maturityDate: _maturityDate!,
      payoutFreq: _payoutFreq,
      nomineeName: _nomineeNameController.text,
      jointHolder: _jointHolderController.text,
      remarks: _remarksController.text,
      status: computedStatus,
    );

    if (_isEditing) {
      fdProvider.updateFD(fd).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FD updated successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $error')),
        );
      });
    } else {
      fdProvider.addFD(fd).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FD added successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add failed: $error')),
        );
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Add or Edit Fixed Deposit form',
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit FD' : 'Add FD'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete FD'),
                      content: Text('Delete "${_titleController.text}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<FDProvider>(context, listen: false)
                                .deleteFD(widget.fdToEdit!.id!);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Information
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Basic Information",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'FD Title *'),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bankController,
                          decoration: const InputDecoration(labelText: 'Bank Name *'),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter bank name' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _accountNoController,
                          decoration: const InputDecoration(labelText: 'Account Number'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _principalController,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Principal Amount *',
                            prefixText: '₹ ',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter principal';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Please enter a valid positive amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _rateController,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Interest Rate * (%)',
                            suffixText: '%',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter rate';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Please enter a valid positive rate';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Dates and Frequency
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Dates & Frequency",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_startDate == null
                              ? 'Select Start Date'
                              : 'Start Date: ${DateFormat('dd MMM yyyy').format(_startDate!)}'),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _pickDate(true),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_maturityDate == null
                              ? 'Select Maturity Date'
                              : 'Maturity Date: ${DateFormat('dd MMM yyyy').format(_maturityDate!)}'),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _pickDate(false),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _payoutFreq,
                          items: ['On Maturity', 'Monthly', 'Quarterly', 'Half-Yearly']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) => setState(() => _payoutFreq = val!),
                          decoration: const InputDecoration(labelText: 'Interest Payout Frequency'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Optional Info
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Optional Information",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomineeNameController,
                          decoration: const InputDecoration(labelText: 'Nominee Name'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _jointHolderController,
                          decoration: const InputDecoration(labelText: 'Joint Holder Name'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _remarksController,
                          decoration: const InputDecoration(labelText: 'Remarks / Notes'),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveFD,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_isEditing ? 'Update FD' : 'Save FD'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
