# BankEasy — Flutter project (foundation build)

This is a real, working Flutter project — not a mockup. It implements the
core architecture from the design process, plus a representative set of
forms and calculators to prove it out. It is **not** a finished, submittable
Play Store app yet. This README says exactly what's here, what's missing,
and what to do next.

## What's actually implemented

- **Schema-driven form engine** (`lib/models/form_models.dart`,
  `lib/data/forms_catalog.dart`, `lib/screens/form_fill_screen.dart`) —
  add a new form by adding one `FormSchema` entry to the catalog. No new
  screen code needed. Six real forms are included: Tour Program/TA-DA,
  MCO medical claim, Leave application, Complaint/feedback, Chequebook
  request, Individual account opening.
- **Profile with local-only autofill** (`lib/models/profile.dart`,
  `lib/data/profile_store.dart`) — saved via `shared_preferences`
  (on-device only, nothing is ever transmitted). Supports the three field
  states (autofilled / manual / blank), per-field "don't autofill this"
  that's remembered, and a permanent "clear profile data" action.
- **Fill → Preview → PDF flow** with the Azhar Jameel sample-value
  pattern, an optional bank-letterhead picker (never mandatory), and the
  two audited dialogs: "missing from your profile" (contextual, one field)
  and "required field is blank" (offers "generate anyway, fill by hand").
- **PDF generation** (`lib/services/pdf_service.dart`) using the `pdf` +
  `printing` packages — produces a real, shareable/printable PDF.
- **EMI calculator** with the corrected math: reducing-balance vs
  flat-rate selector, and frequency (monthly/6-monthly/yearly) that
  correctly recomputes total payback rather than assuming it's constant
  — this was a real error caught during the design audit and is fixed here.
- **Zakat calculator** with actual Hawl (lunar-year) date tracking — not
  just a Nisab snapshot, which was the other real gap caught in the audit.
- **Home, Forms Library (browse + search), Profile screens**, matching
  the navy/off-white/gold design system from the mockups.

## What's deliberately NOT built yet (see the audit checklist)

- Most of the ~60-form catalog discussed — only 6 are implemented as
  proof of the schema pattern. Adding the rest is data entry, not
  architecture work.
- Live data feeds: gold/silver Nisab price, FX rates, SBP Debt Burden
  Ratio, withholding tax rates/thresholds, bank holidays, prize bond
  draws. All currently have placeholder/manual values with comments
  marking exactly where a live feed needs to go.
- The attendance/key/visitor "register" tool type (blank multi-row
  templates) — flagged in the audit as a different UI pattern from the
  fill-a-form flow, not yet built.
- "Suggest a form/tool" submission flow and public roadmap.
- Multi-signature forms (joint holder changes, internal approvals).
- App icon, splash screen, and Play Store listing assets.

## Running it

```
flutter pub get
flutter run
```

Requires the Flutter SDK installed locally — this was written without
network access to pub.dev, so run `flutter pub upgrade` after `pub get`
to confirm you're on current compatible package versions before your
first real build.

## Path to Play Store from here

1. Fill in the remaining forms in `forms_catalog.dart` (bulk of the
   remaining work, but mechanical).
2. Wire up live data sources for every 🟡-flagged value in the audit
   checklist — do this before launch, not after; stale tax/rate figures
   are a real liability, not a cosmetic issue.
3. Review Google Play's Financial Features declaration and Data Safety
   requirements directly before submission — this app almost certainly
   avoids "financial services" classification since it doesn't move
   money or lend, but the calculators (loan eligibility, EMI) sit close
   enough to that line that it's worth confirming against Play's current
   policy text, not assuming.
4. Add app icon, splash screen, and Play Store listing content.
5. Register a Google Play Developer (Organization) account and complete
   the standard submission flow.

See `BankEasy_Audit_Checklist.md` (shared earlier in this conversation)
for the full list of logic/customization items still open.
