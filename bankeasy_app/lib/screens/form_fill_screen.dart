import 'package:flutter/material.dart';
import '../data/forms_catalog.dart';
import '../data/profile_store.dart';
import '../models/form_models.dart';
import '../models/profile.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/paper_preview.dart';

class FormFillScreen extends StatefulWidget {
  final FormSchema schema;
  const FormFillScreen({super.key, required this.schema});

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {
  Profile _profile = Profile();
  final Map<String, String> _values = {};
  final Map<String, FieldState> _state = {};
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedBank;
  bool _showPreview = false;

  /// Simple, illustrative sample values so the preview never looks empty
  /// before the user types anything — see the "Azhar Jameel / John Doe"
  /// design decision.
  final Map<String, String> _sampleValues = const {
    'employeeName': 'Azhar Jameel',
    'customerName': 'Azhar Jameel',
    'accountHolder': 'Azhar Jameel',
    'fullName': 'Azhar Jameel',
    'designation': 'Branch operations manager',
    'grade': 'OG-II',
    'homeBranch': 'Model Town, Lahore',
    'destination': 'Lahore regional office',
    'duration': '3',
    'accountNumber': '0123-4567890-01',
    'phone': '0300-1234567',
    'cnic': '35202-1234567-1',
  };

  @override
  void initState() {
    super.initState();
    _loadProfileAndInit();
  }

  Future<void> _loadProfileAndInit() async {
    final p = await ProfileStore.load();
    setState(() {
      _profile = p;
      _selectedBank = p.preferredBank ?? kBanks.first;
      for (final f in widget.schema.fields) {
        final unlinkKey = '${widget.schema.id}.${f.id}';
        final isUnlinked = p.unlinkedFieldKeys.contains(unlinkKey);
        final profileValue =
            f.profileKey != null ? p.asMap[f.profileKey!] : null;

        if (p.autofillEnabled &&
            !isUnlinked &&
            profileValue != null &&
            profileValue.isNotEmpty) {
          _values[f.id] = profileValue;
          _state[f.id] = FieldState.autofilled;
        } else {
          _values[f.id] = '';
          _state[f.id] = FieldState.blank;
        }
        _controllers[f.id] = TextEditingController(text: _values[f.id]);
      }
    });
  }

  bool _isUnlinked(FormFieldSchema f) =>
      _profile.unlinkedFieldKeys.contains('${widget.schema.id}.${f.id}');

  Future<void> _toggleUnlink(FormFieldSchema f) async {
    final key = '${widget.schema.id}.${f.id}';
    setState(() {
      if (_profile.unlinkedFieldKeys.contains(key)) {
        _profile.unlinkedFieldKeys.remove(key);
      } else {
        _profile.unlinkedFieldKeys.add(key);
        _values[f.id] = '';
        _controllers[f.id]!.text = '';
        _state[f.id] = FieldState.blank;
      }
    });
    await ProfileStore.save(_profile);
  }

  void _onFieldChanged(FormFieldSchema f, String text) {
    setState(() {
      _values[f.id] = text;
      _state[f.id] = text.trim().isEmpty ? FieldState.blank : FieldState.manual;
    });
  }

  /// Returns the first required field that's blank *and* profile-linked —
  /// used to trigger the contextual "missing from your profile" prompt
  /// rather than the generic blank-field warning.
  FormFieldSchema? _firstMissingProfileField() {
    for (final f in widget.schema.fields) {
      if (f.required &&
          f.profileKey != null &&
          (_values[f.id] ?? '').trim().isEmpty) {
        return f;
      }
    }
    return null;
  }

  List<FormFieldSchema> _remainingBlankRequiredFields() => widget.schema.fields
      .where((f) => f.required && (_values[f.id] ?? '').trim().isEmpty)
      .toList();

  Future<void> _onGeneratePressed() async {
    final missingProfileField = _firstMissingProfileField();
    if (missingProfileField != null) {
      final filled = await _showMissingProfileFieldDialog(missingProfileField);
      if (!filled) return; // user backed out
    }

    final stillBlank = _remainingBlankRequiredFields();
    if (stillBlank.isNotEmpty) {
      final proceed = await _showBlankFieldDialog(stillBlank.first);
      if (!proceed) return;
    }

    if (!mounted) return;
    await PdfService.generateAndShare(
      schema: widget.schema,
      values: _values,
      selectedBank: _selectedBank,
    );
  }

  Future<bool> _showMissingProfileFieldDialog(FormFieldSchema f) async {
    final controller = TextEditingController();
    bool saveToProfile = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Missing from your profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This form needs your ${f.label.toLowerCase()}. '
                'Add it once and it\'ll auto-fill everywhere.',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: f.hint),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: saveToProfile,
                    onChanged: (v) =>
                        setDialogState(() => saveToProfile = v ?? true),
                  ),
                  const Expanded(
                    child: Text('Save to my profile for next time',
                        style: TextStyle(fontSize: 11.5)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Skip once')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _values[f.id] = controller.text;
        _controllers[f.id]!.text = controller.text;
        _state[f.id] = FieldState.manual;
      });
      if (saveToProfile && f.profileKey != null) {
        _setProfileValue(f.profileKey!, controller.text);
        await ProfileStore.save(_profile);
      }
      return true;
    }
    return false;
  }

  void _setProfileValue(String key, String value) {
    switch (key) {
      case 'fullName': _profile.fullName = value; break;
      case 'cnic': _profile.cnic = value; break;
      case 'phone': _profile.phone = value; break;
      case 'designation': _profile.designation = value; break;
      case 'grade': _profile.grade = value; break;
      case 'homeBranch': _profile.homeBranch = value; break;
    }
  }

  Future<bool> _showBlankFieldDialog(FormFieldSchema f) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('One required field is blank'),
        content: Text(
          '"${f.label}" is required by this form but you\'ve left it empty. '
          'We\'ll still generate your PDF — leave it blank on the printed '
          'copy and write it in by hand before submitting.',
          style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Go back and fill it')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generate anyway'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickBank() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Choose a bank letterhead',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            for (final b in kBanks)
              ListTile(
                title: Text(b, style: const TextStyle(fontSize: 13)),
                trailing:
                    b == _selectedBank ? const Icon(Icons.check, size: 18) : null,
                onTap: () => Navigator.pop(ctx, b),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _selectedBank = picked);
  }

  @override
  Widget build(BuildContext context) {
    final schema = widget.schema;
    return Scaffold(
      appBar: AppBar(title: Text(schema.title)),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Fill',
                  selected: !_showPreview,
                  onTap: () => setState(() => _showPreview = false),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Preview',
                  selected: _showPreview,
                  onTap: () => setState(() => _showPreview = true),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _showPreview
                  ? PaperPreview(
                      schema: schema,
                      values: _values,
                      sampleValues: _sampleValues,
                      selectedBank: _selectedBank,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final f in schema.fields) _buildField(f),
                        if (schema.bankLetterheadEnabled) ...[
                          const SizedBox(height: 8),
                          const Text('Bank / branch (optional)',
                              style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: _pickBank,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.cardBorder),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedBank ?? kBanks.first,
                                      style: const TextStyle(fontSize: 13)),
                                  const Icon(Icons.keyboard_arrow_down, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _onGeneratePressed,
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                            label: const Text('Generate PDF'),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FormFieldSchema f) {
    final state = _state[f.id] ?? FieldState.blank;
    final canUnlink = f.profileKey != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(f.label + (f.required ? ' *' : ''),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
              if (state == FieldState.autofilled)
                const Row(
                  children: [
                    Icon(Icons.bolt, size: 12, color: AppColors.navy),
                    SizedBox(width: 2),
                    Text('From profile',
                        style: TextStyle(fontSize: 10, color: AppColors.navy)),
                  ],
                )
              else if (canUnlink)
                InkWell(
                  onTap: () => _toggleUnlink(f),
                  child: Text(
                    _isUnlinked(f) ? 'Allow autofill' : "Don't autofill this",
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedLight,
                        decoration: TextDecoration.underline),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (f.type == FieldType.dropdown)
            DropdownButtonFormField<String>(
              initialValue: _values[f.id]?.isNotEmpty == true ? _values[f.id] : null,
              items: f.options!
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => _onFieldChanged(f, v ?? ''),
              decoration: InputDecoration(hintText: f.hint),
            )
          else
            TextField(
              controller: _controllers[f.id],
              maxLines: f.type == FieldType.multiline ? 3 : 1,
              onChanged: (t) => _onFieldChanged(f, t),
              decoration: InputDecoration(hintText: f.hint),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.gold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? AppColors.navy : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
