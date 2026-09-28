// Exception khusus untuk menangani validasi data penggajian
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

// Model data Karyawan
class Karyawan {
  final String nip;
  final String nama;
  final String divisi;
  final double gajiPokok;
  final double tunjangan;

  Karyawan({
    required this.nip,
    required this.nama,
    required this.divisi,
    required this.gajiPokok,
    this.tunjangan = 0.0,
  });

  // Hitung BPJS (3% dari Gaji Pokok)
  double get bpjs => gajiPokok * 0.03;

  // Hitung PPh berdasarkan bracket pajak (Penghasilan Bruto = Pokok + Tunjangan)
  double get pph {
    double bruto = gajiPokok + tunjangan;
    if (bruto <= 5000000) {
      return bruto * 0.05; // Bracket 1: 5%
    } else if (bruto <= 10000000) {
      return bruto * 0.10; // Bracket 2: 10%
    } else {
      return bruto * 0.15; // Bracket 3: 15%
    }
  }

  // Hitung Gaji Bersih = Pokok + Tunjangan - BPJS - PPh
  double get gajiBersih => (gajiPokok + tunjangan) - bpjs - pph;
}

// Sistem Penggajian
class SistemPenggajian {
  final List<Karyawan> _daftarKaryawan = [];

  List<Karyawan> get daftarKaryawan => List.unmodifiable(_daftarKaryawan);

  // Fungsi untuk menambah karyawan dengan exception handling & validasi
  void tambahKaryawan(Karyawan karyawan) {
    // Validasi Gaji Null / Negatif / Nol
    if (karyawan.gajiPokok <= 0) {
      throw ValidationException('Gaji pokok untuk ${karyawan.nama} tidak valid (harus lebih dari 0).');
    }

    // Validasi NIP Duplikat
    bool isDuplicate = _daftarKaryawan.any((k) => k.nip == karyawan.nip);
    if (isDuplicate) {
      throw ValidationException('NIP ${karyawan.nip} sudah terdaftar dalam sistem!');
    }

    _daftarKaryawan.add(karyawan);
  }

  // Fungsi cariKaryawan menggunakan Null Safety (mengembalikan null jika tidak ada)
  Karyawan? cariKaryawan(String nip) {
    try {
      return _daftarKaryawan.firstWhere((k) => k.nip == nip);
    } catch (_) {
      return null; // Return null jika tidak ditemukan
    }
  }

  // Menampilkan laporan gaji lengkap
  void tampilkanLaporan() {
    if (_daftarKaryawan.isEmpty) {
      print('Tidak ada data karyawan.');
      return;
    }

    print('=======================================================================================');
    print('                              LAPORAN PENGGAJIAN KARYAWAN                              ');
    print('=======================================================================================');
    print('${'NIP'.padRight(8)} | ${'Nama'.padRight(15)} | ${'Divisi'.padRight(12)} | ${'Gaji Pokok'.padLeft(12)} | ${'BPJS (3%)'.padLeft(10)} | ${'PPh'.padLeft(10)} | ${'Gaji Bersih'.padLeft(12)}');
    print('---------------------------------------------------------------------------------------');

    double totalPayroll = 0;
    double tertinggi = _daftarKaryawan.first.gajiBersih;
    double terendah = _daftarKaryawan.first.gajiBersih;
    String namaTertinggi = _daftarKaryawan.first.nama;
    String namaTerendah = _daftarKaryawan.first.nama;

    for (var k in _daftarKaryawan) {
      double bersih = k.gajiBersih;
      totalPayroll += bersih;

      if (bersih > tertinggi) {
        tertinggi = bersih;
        namaTertinggi = k.nama;
      }
      if (bersih < terendah) {
        terendah = bersih;
        namaTerendah = k.nama;
      }

      print(
        '${k.nip.padRight(8)} | '
        '${k.nama.padRight(15)} | '
        '${k.divisi.padRight(12)} | '
        '${_formatRupiah(k.gajiPokok).padLeft(12)} | '
        '${_formatRupiah(k.bpjs).padLeft(10)} | '
        '${_formatRupiah(k.pph).padLeft(10)} | '
        '${_formatRupiah(bersih).padLeft(12)}'
      );
    }

    double rataRata = totalPayroll / _daftarKaryawan.length;

    print('=======================================================================================');
    print('                                   RINGKASAN LAPORAN                                   ');
    print('=======================================================================================');
    print('Total Payroll  : ${_formatRupiah(totalPayroll)}');
    print('Rata-rata Gaji : ${_formatRupiah(rataRata)}');
    print('Gaji Tertinggi : ${_formatRupiah(tertinggi)} ($namaTertinggi)');
    print('Gaji Terendah  : ${_formatRupiah(terendah)} ($namaTerendah)');
    print('=======================================================================================\n');
  }

  // Format angka ke format rupiah sederhana
  String _formatRupiah(double val) {
    return 'Rp${val.toStringAsFixed(0)}';
  }
}

void main() {
  SistemPenggajian sistem = SistemPenggajian();

  // Input Minimal 10 Karyawan Valid
  List<Karyawan> listAwal = [
    Karyawan(nip: 'K001', nama: 'Budi Santoso', divisi: 'IT', gajiPokok: 8000000, tunjangan: 1000000),
    Karyawan(nip: 'K002', nama: 'Siti Aminah', divisi: 'HRD', gajiPokok: 6000000, tunjangan: 500000),
    Karyawan(nip: 'K003', nama: 'Andi Wijaya', divisi: 'Finance', gajiPokok: 12000000, tunjangan: 2000000),
    Karyawan(nip: 'K004', nama: 'Dewi Lestari', divisi: 'Marketing', gajiPokok: 4500000, tunjangan: 300000),
    Karyawan(nip: 'K005', nama: 'Eko Prasetyo', divisi: 'IT', gajiPokok: 9500000, tunjangan: 1200000),
    Karyawan(nip: 'K006', nama: 'Rina Permata', divisi: 'Operations', gajiPokok: 5500000, tunjangan: 400000),
    Karyawan(nip: 'K007', nama: 'Fajar Nugraha', divisi: 'IT', gajiPokok: 15000000, tunjangan: 2500000),
    Karyawan(nip: 'K008', nama: 'Gita Gutawa', divisi: 'HRD', gajiPokok: 4800000, tunjangan: 200000),
    Karyawan(nip: 'K009', nama: 'Hendra Setiawan', divisi: 'Sales', gajiPokok: 7000000, tunjangan: 1500000),
    Karyawan(nip: 'K010', nama: 'Indah Kusuma', divisi: 'Finance', gajiPokok: 11000000, tunjangan: 1800000),
  ];

  for (var k in listAwal) {
    try {
      sistem.tambahKaryawan(k);
    } catch (_) {
      // Mengabaikan exception jika terjadi
    }
  }

  // Langsung menampilkan tabel laporan & ringkasan
  sistem.tampilkanLaporan();
}