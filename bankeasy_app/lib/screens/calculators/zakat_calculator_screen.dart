import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});
  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _cashCtrl = TextEditingController(text: '800000');
  final _goldCtrl = TextEditingController(text: '450000');
  final _investCtrl = TextEditingController(text: '0');
  final _debtsCtrl = TextEditingController(text: '250000');
  // Editable placeholder — in production this must come from a live
  // gold/silver price feed, refreshed daily (audit item).
  final _nisabCtrl = TextEditingController(text: '172000');

  DateTime? _hawlStartDate;
  bool _deductDebts = true; // Hanafi/Maliki/Hanbali default — see audit note

  static const int _hawlDays = 354; // full Islamic lunar year

  double _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0;

  String _fmt(double v) => 'Rs ${v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      )}';

  Future<void> _pickHawlDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hawlStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _hawlStartDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final gross = _num(_cashCtrl) + _num(_goldCtrl) + _num(_investCtrl);
    final net = _deductDebts ? (gross - _num(_debtsCtrl)).clamp(0, double.infinity) : gross;
    final nisab = _num(_nisabCtrl);
    final aboveNisab = net >= nisab && nisab > 0;

    int? daysSinceHawlStart;
    bool hawlComplete = false;
    if (_hawlStartDate != null) {
      daysSinceHawlStart = DateTime.now().difference(_hawlStartDate!).inDays;
      hawlComplete = daysSinceHawlStart >= _hawlDays;
    }

    final zakatDue = (aboveNisab && hawlComplete) ? net * 0.025 : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Zakat calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Cash and bank balances', _cashCtrl),
          _field('Gold and silver (market value)', _goldCtrl),
          _field('Investments and business stock', _investCtrl),
          Row(
            children: [
              Checkbox(
                value: _deductDebts,
                onChanged: (v) => setState(() => _deductDebts = v ?? true),
              ),
              const Expanded(
                child: Text(
                  'Deduct debts owed (Hanafi/Maliki/Hanbali view — Shafi\'i school '
                  'generally does not; consult your scholar if unsure)',
                  style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
          if (_deductDebts) _field('Debts you owe', _debtsCtrl),
          const SizedBox(height: 4),
          _field('Nisab threshold (silver, editable placeholder)', _nisabCtrl),
          const Text(
            'Nisab must come from a live gold/silver rate feed in production — '
            'this is a manually editable placeholder.',
            style: TextStyle(fontSize: 10, color: AppColors.mutedLight),
          ),
          const SizedBox(height: 14),

          // --- Hawl tracking (the audit fix) ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.balance, size: 15, color: AppColors.goldTintText),
                    SizedBox(width: 6),
                    Text('Hawl — when did your wealth first reach Nisab?',
                        style: TextStyle(fontSize: 11, color: AppColors.goldTintText)),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickHawlDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _hawlStartDate == null
                          ? 'Select the date'
                          : '${_hawlStartDate!.year}-${_hawlStartDate!.month.toString().padLeft(2, '0')}-${_hawlStartDate!.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ),
                if (daysSinceHawlStart != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    hawlComplete
                        ? 'A full lunar year (354+ days) has passed since this date.'
                        : 'Day $daysSinceHawlStart of $_hawlDays — Zakat is not yet due '
                          'even if you are above Nisab. ${(_hawlDays - daysSinceHawlStart)} days remaining.',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.goldTintText),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Net zakatable wealth',
                    style: TextStyle(color: Color(0xFF9FB2C9), fontSize: 11)),
                Text(_fmt(net),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                const Divider(color: Color(0xFF2B4A6E), height: 22),
                const Text('Zakat due · 2.5%',
                    style: TextStyle(color: Color(0xFF9FB2C9), fontSize: 11)),
                Text(_fmt(zakatDue),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  _hawlStartDate == null
                      ? 'Set your Hawl start date above to see whether Zakat is due.'
                      : (aboveNisab && hawlComplete)
                          ? 'Above Nisab and Hawl complete — Zakat is due.'
                          : !aboveNisab
                              ? 'Below Nisab — no Zakat due right now.'
                              : 'Above Nisab, but Hawl is not yet complete.',
                  style: const TextStyle(color: Color(0xFFCFE0D4), fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This is a religious guidance tool, not a fatwa — consult your '
            'scholar for your specific situation.',
            style: TextStyle(fontSize: 10, color: AppColors.mutedLight, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
