import 'package:flutter/material.dart';
import '../data/forms_catalog.dart';
import '../models/form_models.dart';
import '../theme/app_theme.dart';
import 'form_fill_screen.dart';

class FormsLibraryScreen extends StatefulWidget {
  const FormsLibraryScreen({super.key});
  @override
  State<FormsLibraryScreen> createState() => _FormsLibraryScreenState();
}

class _FormsLibraryScreenState extends State<FormsLibraryScreen> {
  String _query = '';

  Map<String, List<FormSchema>> get _byCategory {
    final map = <String, List<FormSchema>>{};
    for (final f in kFormsCatalog) {
      map.putIfAbsent(f.category, () => []).add(f);
    }
    return map;
  }

  List<FormSchema> get _searchResults => kFormsCatalog
      .where((f) => f.title.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms library'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search forms',
                hintStyle: const TextStyle(color: Color(0xFF9FB2C9)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9FB2C9), size: 18),
                filled: true,
                fillColor: AppColors.navyLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: searching ? _buildSearchResults() : _buildCategoryList(),
    );
  }

  Widget _buildCategoryList() {
    final categories = _byCategory;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: categories.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 9),
          child: ExpansionTile(
            title: Text(entry.key, style: const TextStyle(fontSize: 12.5)),
            trailing: Text('${entry.value.length} form${entry.value.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 10.5, color: AppColors.mutedLight)),
            children: entry.value
                .map((f) => ListTile(
                      dense: true,
                      title: Text(f.title, style: const TextStyle(fontSize: 12.5)),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FormFillScreen(schema: f))),
                    ))
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults;
    if (results.isEmpty) {
      return const Center(
        child: Text('No forms match that search', style: TextStyle(color: AppColors.mutedLight)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${results.length} results',
            style: const TextStyle(fontSize: 10.5, color: AppColors.mutedLight)),
        const SizedBox(height: 8),
        for (final f in results)
          Card(
            margin: const EdgeInsets.only(bottom: 9),
            child: ListTile(
              title: Text(f.title, style: const TextStyle(fontSize: 12.5)),
              subtitle: Text(f.category, style: const TextStyle(fontSize: 10)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => FormFillScreen(schema: f))),
            ),
          ),
      ],
    );
  }
}
