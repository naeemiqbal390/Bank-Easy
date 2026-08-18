import 'package:flutter/material.dart';
import '../data/forms_catalog.dart';
import '../theme/app_theme.dart';
import 'calculators/emi_calculator_screen.dart';
import 'calculators/zakat_calculator_screen.dart';
import 'form_fill_screen.dart';
import 'forms_library_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const FormsLibraryScreen(),
      const _ToolsTab(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.description_outlined), label: 'Forms'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.navy,
          expandedHeight: 96,
          pinned: true,
          flexibleSpace: const FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 16, bottom: 14),
            title: Text('BankEasy',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text('BROWSE',
                  style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.6)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _CategoryTile(
                    icon: Icons.description_outlined,
                    title: 'Forms library',
                    subtitle: 'Customer and staff',
                    onTap: () => _pushTab(context, 1),
                  ),
                  _CategoryTile(
                    icon: Icons.calculate_outlined,
                    title: 'Calculators',
                    subtitle: 'EMI, Zakat, tax',
                    onTap: () => _pushTab(context, 2),
                  ),
                  _CategoryTile(
                    icon: Icons.badge_outlined,
                    title: 'HR and staff',
                    subtitle: 'Leave, TA/DA, MCO',
                    onTap: () => _pushTab(context, 1),
                  ),
                  _CategoryTile(
                    icon: Icons.account_balance_outlined,
                    title: 'By bank',
                    subtitle: 'Optional letterhead',
                    onTap: () => _pushTab(context, 1),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('POPULAR THIS WEEK',
                  style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.6)),
              const SizedBox(height: 8),
              _PopularRow(
                icon: Icons.nightlight_outlined,
                label: 'Zakat calculator',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen())),
              ),
              _PopularRow(
                icon: Icons.directions_car_outlined,
                label: 'Car loan EMI calculator',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const EmiCalculatorScreen())),
              ),
              _PopularRow(
                icon: Icons.flight_takeoff_outlined,
                label: 'Tour program / TA-DA claim',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FormFillScreen(
                            schema: kFormsCatalog.firstWhere((f) => f.id == 'tour_program_tada')))),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _pushTab(BuildContext context, int index) {
    // Simplest approach for this scaffold: jump straight to the relevant
    // screen rather than manipulating the shell's tab state from here.
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FormsLibraryScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const _ToolsTab()));
    }
  }
}

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculators & tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_car_outlined, color: AppColors.navy),
              title: const Text('Loan / EMI calculator', style: TextStyle(fontSize: 12.5)),
              subtitle: const Text('Reducing balance or flat rate, any frequency',
                  style: TextStyle(fontSize: 10.5)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const EmiCalculatorScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.nightlight_outlined, color: AppColors.navy),
              title: const Text('Zakat calculator', style: TextStyle(fontSize: 12.5)),
              subtitle: const Text('Includes Hawl (lunar year) tracking',
                  style: TextStyle(fontSize: 10.5)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder, width: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.navy, size: 20),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.mutedLight)),
          ],
        ),
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PopularRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 17, color: AppColors.gold),
        title: Text(label, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: onTap,
      ),
    );
  }
}
