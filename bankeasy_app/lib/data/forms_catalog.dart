import '../models/form_models.dart';

/// Bank options for the optional letterhead picker. "No bank — generic
/// template" is always first and is the default (see audit: bank
/// selection must be optional, never mandatory).
const List<String> kBanks = [
  'No bank — generic template',
  'ZTBL — Zarai Taraqiati Bank Limited',
  'Habib Bank Limited',
  'United Bank Limited',
];

/// A deliberately small but representative set of forms, spanning both
/// the "customer" and "HR/staff" halves of the app, and including the
/// two ZTBL samples originally uploaded (Tour Program/TA-DA and MCO).
/// Adding a new form to BankEasy means adding one more FormSchema here —
/// FormFillScreen renders any of them without new UI code.
final List<FormSchema> kFormsCatalog = [
  const FormSchema(
    id: 'tour_program_tada',
    title: 'Tour Program / TA-DA Claim',
    category: 'HR & Staff',
    bankLetterheadEnabled: true,
    fields: [
      FormFieldSchema(
        id: 'employeeName',
        label: 'Employee name',
        profileKey: 'fullName',
        required: true,
      ),
      FormFieldSchema(
        id: 'designation',
        label: 'Designation',
        hint: 'e.g. Branch operations manager',
        profileKey: 'designation',
        required: true,
      ),
      FormFieldSchema(
        id: 'grade',
        label: 'Grade / scale',
        hint: 'e.g. OG-II',
        profileKey: 'grade',
        required: true, // needed to look up the correct TA/DA rate — audit item
      ),
      FormFieldSchema(
        id: 'homeBranch',
        label: 'Home branch',
        profileKey: 'homeBranch',
      ),
      FormFieldSchema(
        id: 'destination',
        label: 'Tour destination',
        hint: 'e.g. Lahore regional office',
        required: true,
      ),
      FormFieldSchema(
        id: 'duration',
        label: 'Duration (days)',
        required: true,
      ),
    ],
  ),
  const FormSchema(
    id: 'mco_medical_claim',
    title: 'Medical Reimbursement (MCO)',
    category: 'HR & Staff',
    bankLetterheadEnabled: true,
    fields: [
      FormFieldSchema(
        id: 'employeeName',
        label: 'Employee name',
        profileKey: 'fullName',
        required: true,
      ),
      FormFieldSchema(
        id: 'patientName',
        label: "Patient name (if not self)",
        // Deliberately no profileKey — a dependent's name should never
        // silently autofill from the employee's own profile (audit item).
      ),
      FormFieldSchema(
        id: 'patientCnic',
        label: 'CNIC of patient',
        required: true,
      ),
      FormFieldSchema(
        id: 'amountClaimed',
        label: 'Amount claimed (Rs)',
        required: true,
      ),
    ],
  ),
  const FormSchema(
    id: 'leave_application',
    title: 'Leave Application',
    category: 'HR & Staff',
    bankLetterheadEnabled: true,
    fields: [
      FormFieldSchema(
        id: 'employeeName',
        label: 'Employee name',
        profileKey: 'fullName',
        required: true,
      ),
      FormFieldSchema(
        id: 'leaveType',
        label: 'Leave type',
        type: FieldType.dropdown,
        options: ['Casual', 'Annual', 'Medical', 'Short leave / half-day'],
        required: true,
      ),
      FormFieldSchema(id: 'fromDate', label: 'From date', type: FieldType.date, required: true),
      FormFieldSchema(id: 'toDate', label: 'To date', type: FieldType.date, required: true),
      FormFieldSchema(
        id: 'reason',
        label: 'Reason',
        type: FieldType.multiline,
        required: true,
      ),
    ],
  ),
  const FormSchema(
    id: 'complaint_feedback',
    title: 'Complaint / Feedback Form',
    category: 'Complaints & Feedback',
    bankLetterheadEnabled: true,
    fields: [
      FormFieldSchema(
        id: 'customerName',
        label: 'Full name',
        profileKey: 'fullName',
        required: true,
      ),
      FormFieldSchema(id: 'accountNumber', label: 'Account / card number'),
      FormFieldSchema(id: 'phone', label: 'Phone number', profileKey: 'phone'),
      FormFieldSchema(
        id: 'details',
        label: 'Complaint details',
        type: FieldType.multiline,
        required: true,
      ),
    ],
  ),
  const FormSchema(
    id: 'chequebook_request',
    title: 'Chequebook Request',
    category: 'Cheque Services',
    bankLetterheadEnabled: true,
    fields: [
      FormFieldSchema(
        id: 'accountHolder',
        label: 'Account holder name',
        profileKey: 'fullName',
        required: true,
      ),
      FormFieldSchema(id: 'accountNumber', label: 'Account number', required: true),
      FormFieldSchema(
        id: 'leafCount',
        label: 'Number of leaves',
        type: FieldType.dropdown,
        options: ['25', '50', '100'],
        required: true,
      ),
    ],
  ),
  const FormSchema(
    id: 'account_opening_individual',
    title: 'Individual Account Opening',
    category: 'Account Opening & KYC',
    bankLetterheadEnabled: true,
    fields: [
      FormFieldSchema(
        id: 'fullName',
        label: 'Full name',
        profileKey: 'fullName',
        required: true,
      ),
      FormFieldSchema(id: 'cnic', label: 'CNIC', profileKey: 'cnic', required: true),
      FormFieldSchema(id: 'phone', label: 'Phone number', profileKey: 'phone', required: true),
      FormFieldSchema(
        id: 'accountType',
        label: 'Account type',
        type: FieldType.dropdown,
        options: ['Current', 'Savings', 'PLS Savings'],
        required: true,
      ),
    ],
  ),
];
