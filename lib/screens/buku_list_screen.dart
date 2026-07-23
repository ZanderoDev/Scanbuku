import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/buku.dart';
import 'add_buku_screen.dart';

class BukuListScreen extends StatefulWidget {
  const BukuListScreen({super.key});

  @override
  State<BukuListScreen> createState() => BukuListScreenState();
}

class BukuListScreenState extends State<BukuListScreen> {
  late Future<List<Buku>> _future;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// Muat ulang data dari database. Public biar bisa dipanggil dari luar
  /// (misal HomeShell) pas tab ini dibuka, karena IndexedStack cuma
  /// manggil initState() sekali.
  void reload() {
    setState(() {
      _future = DatabaseHelper.instance.getAllBuku();
    });
  }

  Future<void> _confirmDelete(Buku buku) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Hapus data "${buku.judul}" (barcode: ${buku.barcode})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && buku.id != null) {
      await DatabaseHelper.instance.deleteBuku(buku.id!);
      reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Buku')),
      body: FutureBuilder<List<Buku>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Text('Belum ada data. Tambah dulu lewat tombol +'),
            );
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final buku = data[index];
              return ListTile(
                title: Text(buku.judul),
                subtitle: Text('Barcode: ${buku.barcode}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(buku),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddBukuScreen()),
          );
          reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
