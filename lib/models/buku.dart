/// Merepresentasikan satu baris data: barcode buku -> judul/keterangan buku.
class Buku {
  final int? id;
  final String barcode;
  final String judul;

  const Buku({
    this.id,
    required this.barcode,
    required this.judul,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'judul': judul,
    };
  }

  factory Buku.fromMap(Map<String, Object?> map) {
    return Buku(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      judul: map['judul'] as String,
    );
  }
}
