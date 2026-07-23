import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/buku.dart';

class AddBukuScreen extends StatefulWidget {
  const AddBukuScreen({super.key});

  @override
  State<AddBukuScreen> createState() => _AddBukuScreenState();
}

class _AddBukuScreenState extends State<AddBukuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeCtrl = TextEditingController();
  final _judulCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _judulCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanManual() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await DatabaseHelper.instance.upsertBuku(
      Buku(
        barcode: _barcodeCtrl.text.trim(),
        judul: _judulCtrl.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data tersimpan')),
    );
    _barcodeCtrl.clear();
    _judulCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Data Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(labelText: 'Barcode buku'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _judulCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul / keterangan buku',
                  hintText: 'misal: Buku MTK',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _simpanManual,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
