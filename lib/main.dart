import 'package:flutter/material.dart';

import 'screens/buku_list_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const BookScannerApp());
}

class BookScannerApp extends StatelessWidget {
  const BookScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan Buku Sekolah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final GlobalKey<BukuListScreenState> _bukuListKey =
      GlobalKey<BukuListScreenState>();

  late final List<Widget> _pages = [
    const ScanScreen(),
    BukuListScreen(key: _bukuListKey),
  ];

  void _onDestinationSelected(int i) {
    setState(() => _index = i);
    if (i == 1) {
      // Tab "Data Buku" dibuka -> reload biar data yang baru
      // ditambahin dari tab Scan langsung kelihatan.
      _bukuListKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Data Buku',
          ),
        ],
      ),
    );
  }
}
