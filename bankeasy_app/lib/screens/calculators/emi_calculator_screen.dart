import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum PaymentFrequency { monthly, halfYearly, yearly }
enum FinancingMethod { reducingBalance, flatRate }

extension on PaymentFrequency {
  int get periodsPerYear => switch (this) {
        PaymentFrequency.monthly => 12,
        PaymentFrequency.halfYearly => 2,
        PaymentFrequency.yearly => 1,
      };
  String get label => switch (this) {
        PaymentFrequency.monthly => 'Monthly',
        PaymentFrequency.halfYearly => 'Every 6 months',
        PaymentFrequency.yearly => 'Yearly',
      };
}

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});
  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double _amount = 2500000;
  double _tenureYears = 5;
  double _ratePercent = 15.5;
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  FinancingMethod _method = FinancingMethod.reducingBalance;

  /// Core math. See audit checklist: total payback is NOT constant across
  /// frequencies for a reducing-balance loan — fewer, less frequent
  /// payments leave more principal outstanding longer, so more profit
  /// accrues. The standard amortization formula captures this correctly
  /// on its own; no special-casing needed as long as periodsPerYear and
  /// the periodic rate are both correctly frequency-adjusted.
  ({double installment, double totalPayback, double totalProfit, int periods})
      _calculate() {
    final n = (_tenureYears * _frequency.periodsPerYear).round();
    if (_method == FinancingMethod.flatRate) {
      final totalProfit = _amount * (_ratePercent / 100) * _tenureYears;
      final totalPayback = _amount + totalProfit;
      final installment = totalPayback / n;
      return (installment: installment, totalPayback: totalPayback, totalProfit: totalProfit, periods: n);
    }

    // Reducing balance (standard amortization formula).
    final r = (_ratePercent / 100) / _frequency.periodsPerYear;
    final installment = r == 0
        ? _amount / n
        : _amount * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
    final totalPayback = installment * n;
    final totalProfit = totalPayback - _amount;
    return (installment: installment, totalPayback: totalPayback, totalProfit: totalProfit, periods: n);
  }

  String _fmt(double v) => 'Rs ${v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      )}';

  @override
  Widget build(BuildContext context) {
    final result = _calculate();
    return Scaffold(
      appBar: AppBar(title: const Text('Loan / EMI calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sliderRow('Loan amount', _fmt(_amount), _amount, 100000, 10000000,
              (v) => setState(() => _amount = v)),
          _sliderRow('Tenure', '${_tenureYears.round()} years', _tenureYears, 1, 20,
              (v) => setState(() => _tenureYears = v)),
          _sliderRow('Markup / profit rate', '${_ratePercent.toStringAsFixed(1)}% p.a.',
              _ratePercent, 5, 30, (v) => setState(() => _ratePercent = v)),
          const SizedBox(height: 8),
          const Text('Instalment frequency',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
          const SizedBox(height: 6),
          _segmented(
            options: PaymentFrequency.values,
            selected: _frequency,
            labelOf: (f) => f.label,
            onSelect: (f) => setState(() => _frequency = f),
          ),
          const SizedBox(height: 12),
          const Text('Calculation method',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
          const SizedBox(height: 6),
          _segmented(
            options: FinancingMethod.values,
            selected: _method,
            labelOf: (m) => m == FinancingMethod.reducingBalance
                ? 'Reducing balance'
                : 'Flat rate',
            onSelect: (m) => setState(() => _method = m),
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
                Text('${_frequency.label} instalment · ${result.periods} payments',
                    style: const TextStyle(color: Color(0xFF9FB2C9), fontSize: 11)),
                const SizedBox(height: 2),
                Text(_fmt(result.installment),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                const Divider(color: Color(0xFF2B4A6E), height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _statBlock('Total payback', _fmt(result.totalPayback)),
                    ),
                    Expanded(
                      child: _statBlock('Total profit paid', _fmt(result.totalProfit)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Estimate only, based on the rate and frequency you chose. '
            'Total payback changes with frequency for reducing-balance loans — '
            'less frequent instalments cost more overall. Not a loan offer.',
            style: TextStyle(fontSize: 10, color: AppColors.mutedLight, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _statBlock(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9FB2C9), fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      );

  Widget _sliderRow(String label, String valueLabel, double value, double min,
      double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
              Text(valueLabel,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppColors.navy,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _segmented<T>({
    required List<T> options,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E0D2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: options.map((o) {
          final isSelected = o == selected;
          return Expanded(
            child: InkWell(
              onTap: () => onSelect(o),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  labelOf(o),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isSelected ? Colors.white : AppColors.muted,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
