/// The three states a field can be in at fill-time — see audit checklist
/// item "every field needs three states, not two".
enum FieldState { autofilled, manual, blank }

enum FieldType { text, date, dropdown, multiline }

/// One field within a form. If [profileKey] is set, the form engine will
/// try to autofill it from the user's local Profile — but the person can
/// always unlink it and type manually, or leave it blank if not required.
class FormFieldSchema {
  final String id;
  final String label;
  final String hint;
  final FieldType type;
  final bool required;
  final String? profileKey; // maps to ProfileStore key, e.g. "fullName"
  final List<String>? options; // for FieldType.dropdown

  const FormFieldSchema({
    required this.id,
    required this.label,
    this.hint = '',
    this.type = FieldType.text,
    this.required = false,
    this.profileKey,
    this.options,
  });
}

/// A complete form definition. Adding a new form to the app means adding
/// one of these to forms_catalog.dart — no new screen code required,
/// because FormFillScreen renders any FormSchema generically.
class FormSchema {
  final String id;
  final String title;
  final String category;
  final List<FormFieldSchema> fields;
  final bool bankLetterheadEnabled;

  const FormSchema({
    required this.id,
    required this.title,
    required this.category,
    required this.fields,
    this.bankLetterheadEnabled = true,
  });
}
