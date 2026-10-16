import 'dart:io';

class Paket {
  String namaPengirim;
  String tujuan;
  double beratKg;

  Paket(this.namaPengirim, this.tujuan, this.beratKg);

  // Method dasar: mengembalikan 0 (akan di-override oleh class turunan)
  double hitungOngkir() {
    return 0;
  }

  // Nama layanan (juga di-override oleh class turunan)
  String get jenisLayanan => 'Umum';
}

class PaketReguler extends Paket {
  PaketReguler(String namaPengirim, String tujuan, double beratKg)
    : super(namaPengirim, tujuan, beratKg);

  // Overriding: ongkir reguler = beratKg * 10000
  @override
  double hitungOngkir() {
    return beratKg * 10000;
  }

  @override
  String get jenisLayanan => 'Reguler';
}

class PaketKilat extends Paket {
  PaketKilat(String namaPengirim, String tujuan, double beratKg)
    : super(namaPengirim, tujuan, beratKg);

  // Overriding: ongkir kilat = (beratKg * 15000) + 5000
  // Rp5.000 adalah biaya asuransi wajib
  @override
  double hitungOngkir() {
    return (beratKg * 15000) + 5000;
  }

  @override
  String get jenisLayanan => 'Kilat';
}

class AgenEkspedisi {
  // Agregasi: agen menyimpan objek Paket yang dibuat di luar class ini
  List<Paket> daftarPaket = [];

  // Enkapsulasi: atribut private (diawali underscore)
  double _totalPendapatan = 0;

  // Getter agar total pendapatan bisa dibaca dari luar class
  double get totalPendapatan => _totalPendapatan;

  void terimaPaket(Paket p) {
    daftarPaket.add(p);
    _totalPendapatan += p.hitungOngkir();
    print('Paket tujuan ${p.tujuan} berhasil diterima agen!');
  }
}

// Mengubah angka menjadi format Rupiah, contoh: 1234567 -> Rp1.234.567
String formatRupiah(double nilai) {
  String angka = nilai.round().toString();
  String hasil = '';
  int hitung = 0;
  for (int i = angka.length - 1; i >= 0; i--) {
    hasil = angka[i] + hasil;
    hitung++;
    if (hitung % 3 == 0 && i != 0) {
      hasil = '.' + hasil;
    }
  }
  return 'Rp$hasil';
}

// Membaca satu baris input. Jika input berakhir (null), program berhenti.
String bacaTeks(String pertanyaan) {
  stdout.write(pertanyaan);
  String? input = stdin.readLineSync();
  if (input == null) {
    print('\nInput berakhir. Program ditutup.');
    exit(0);
  }
  return input.trim();
}

// Membaca teks yang tidak boleh kosong
String bacaTeksWajib(String pertanyaan) {
  while (true) {
    String teks = bacaTeks(pertanyaan);
    if (teks.isNotEmpty) {
      return teks;
    }
    print('Input tidak boleh kosong. Silakan coba lagi.');
  }
}

// Membaca berat: harus angka dan lebih dari 0
double bacaBerat(String pertanyaan) {
  while (true) {
    String teks = bacaTeks(pertanyaan);
    if (teks.isEmpty) {
      print('Berat tidak boleh kosong. Silakan coba lagi.');
      continue;
    }
    double? berat = double.tryParse(teks.replaceAll(',', '.'));
    if (berat == null || !berat.isFinite) {
      print('Berat harus berupa angka. Contoh: 2 atau 1.5');
      continue;
    }
    if (berat <= 0) {
      print('Berat harus lebih dari 0 kg.');
      continue;
    }
    return berat;
  }
}

void main() {
  AgenEkspedisi agen = AgenEkspedisi();
  bool berjalan = true;

  while (berjalan) {
    print('');
    print('=== AGEN EKSPEDISI CEPATKIRIM ===');
    print('1. Terima Paket Baru');
    print('2. Lihat Semua Paket');
    print('3. Cek Total Pendapatan Agen');
    print('4. Keluar');
    String pilihan = bacaTeks('Pilih menu (1-4): ');

    if (pilihan == '1') {
      // ---- Menu 1: Terima Paket Baru ----
      String nama = bacaTeksWajib('Nama Pengirim : ');
      String tujuan = bacaTeksWajib('Tujuan        : ');
      double berat = bacaBerat('Berat (kg)    : ');
      String layanan = bacaTeks('Jenis layanan (1 = Reguler, 2 = Kilat): ');

      if (layanan == '1') {
        // Objek dibuat terpisah dari agen, lalu diserahkan ke agen
        PaketReguler paket = PaketReguler(nama, tujuan, berat);
        agen.terimaPaket(paket);
      } else if (layanan == '2') {
        PaketKilat paket = PaketKilat(nama, tujuan, berat);
        agen.terimaPaket(paket);
      } else {
        print('Pilihan layanan tidak valid. Paket tidak disimpan.');
      }
    } else if (pilihan == '2') {
      // ---- Menu 2: Lihat Semua Paket ----
      if (agen.daftarPaket.isEmpty) {
        print('Belum ada paket yang diterima.');
      } else {
        print('--- Daftar Paket ---');
        int nomor = 1;
        for (Paket p in agen.daftarPaket) {
          print(
            '$nomor. Pengirim: ${p.namaPengirim} | Tujuan: ${p.tujuan} '
            '| Berat: ${p.beratKg} kg | Layanan: ${p.jenisLayanan} '
            '| Ongkir: ${formatRupiah(p.hitungOngkir())}',
          );
          nomor++;
        }
      }
    } else if (pilihan == '3') {
      // ---- Menu 3: Cek Total Pendapatan ----
      print('Total pendapatan agen: ${formatRupiah(agen.totalPendapatan)}');
    } else if (pilihan == '4') {
      // ---- Menu 4: Keluar ----
      print('Terima kasih telah menggunakan layanan CepatKirim. Sampai jumpa!');
      berjalan = false;
    } else {
      print('Pilihan menu tidak valid. Masukkan angka 1 sampai 4.');
    }
  }
}
