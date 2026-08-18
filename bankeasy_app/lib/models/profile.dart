/// The user's saved profile. Every field here is optional and lives only
/// on-device (see ProfileStore) — nothing is transmitted anywhere. This
/// keeps the app out of most Play Store "Financial Features" / Data Safety
/// complications, and matches the "local-only, no silent backup" decision
/// from the audit checklist.
class Profile {
  String? fullName;
  String? cnic;
  String? phone;
  String? designation;
  String? grade; // e.g. OG-II — needed for accurate TA/DA rate lookups
  String? homeBranch;
  String? preferredBank; // drives default letterhead selection
  bool autofillEnabled;

  /// Fields the user has explicitly chosen never to autofill from the
  /// profile, keyed as "formId.fieldId" so the choice is per-form-field,
  /// not global. Remembered so the app never re-asks (audit item).
  Set<String> unlinkedFieldKeys;

  Profile({
    this.fullName,
    this.cnic,
    this.phone,
    this.designation,
    this.grade,
    this.homeBranch,
    this.preferredBank,
    this.autofillEnabled = true,
    Set<String>? unlinkedFieldKeys,
  }) : unlinkedFieldKeys = unlinkedFieldKeys ?? {};

  Map<String, String?> get asMap => {
        'fullName': fullName,
        'cnic': cnic,
        'phone': phone,
        'designation': designation,
        'grade': grade,
        'homeBranch': homeBranch,
        'preferredBank': preferredBank,
      };

  int get filledFieldCount => asMap.values.where((v) => v != null && v.isNotEmpty).length;
  int get totalFieldCount => asMap.length;

  Map<String, dynamic> toJson() => {
        ...asMap,
        'autofillEnabled': autofillEnabled,
        'unlinkedFieldKeys': unlinkedFieldKeys.toList(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        fullName: json['fullName'],
        cnic: json['cnic'],
        phone: json['phone'],
        designation: json['designation'],
        grade: json['grade'],
        homeBranch: json['homeBranch'],
        preferredBank: json['preferredBank'],
        autofillEnabled: json['autofillEnabled'] ?? true,
        unlinkedFieldKeys:
            Set<String>.from(json['unlinkedFieldKeys'] ?? const []),
      );
}
