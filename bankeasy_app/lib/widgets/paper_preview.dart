import 'package:flutter/material.dart';
import '../models/form_models.dart';
import '../theme/app_theme.dart';

/// Renders the current field values as a "paper" document — same visual
/// language whether the fields are still placeholders (Azhar Jameel /
/// John Doe sample) or the user's real, in-progress input.
class PaperPreview extends StatelessWidget {
  final FormSchema schema;
  final Map<String, String> values;
  final Map<String, String> sampleValues;
  final String? selectedBank;

  const PaperPreview({
    super.key,
    required this.schema,
    required this.values,
    required this.sampleValues,
    this.selectedBank,
  });

  @override
  Widget build(BuildContext context) {
    final hasLetterhead =
        selectedBank != null && !selectedBank!.startsWith('No bank');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder, width: 0.6),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLetterhead) ...[
            Text(selectedBank!,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const Divider(color: AppColors.navy, thickness: 1.2),
            const SizedBox(height: 6),
          ],
          Center(
            child: Text(
              schema.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final f in schema.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.paperTextStyle,
                  children: [
                    TextSpan(text: '${f.label}: '),
                    TextSpan(
                      text: (values[f.id]?.isNotEmpty ?? false)
                          ? values[f.id]
                          : (sampleValues[f.id] ?? ''),
                      style: TextStyle(
                        color: (values[f.id]?.isNotEmpty ?? false)
                            ? AppColors.ink
                            : AppColors.navy, // sample text tinted differently
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.ink,
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
}
