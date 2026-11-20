class AirQuality {
  final String city;
  final int aqi;
  final String dominantPollutant;
  final double? temperature;
  final double? humidity;
  final double? windSpeed;
  final double? pm25;
  final double? pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;
  final String time;

  AirQuality({
    required this.city,
    required this.aqi,
    required this.dominantPollutant,
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.pm25,
    this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    required this.time,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json){
    final data = json['data'] ?? {};
    final iaqi = data['iaqi'] as Map<String, dynamic>? ?? {};

    return AirQuality(
      city: data['city']?['name'] ?? 'Makassar, Indonesia',
      aqi: data['aqi'] is int ? data['aqi'] : int.tryParse('${data['aqi']}') ?? 0,
      dominantPollutant: (data['dominentpol'] ?? 'pm25').toString().toUpperCase(),
      temperature: (iaqi['t']?['v'] as num?)?.toDouble() ?? 31.0,
      humidity: (iaqi['h']?['v'] as num?)?.toDouble() ?? 74.0,
      windSpeed: (iaqi['w']?['v'] as num?)?.toDouble() ?? 12.0,
      pm25: (iaqi['pm25']?['v'] as num?)?.toDouble() ?? 28.0,
      pm10: (iaqi['pm10']?['v'] as num?)?.toDouble() ?? 41.0,
      o3: (iaqi['o3']?['v'] as num?)?.toDouble() ?? 22.0,
      no2: (iaqi['no2']?['v'] as num?)?.toDouble() ?? 9.0,
      so2: (iaqi['so2']?['v'] as num?)?.toDouble() ?? 4.0,
      co: (iaqi['co']?['v'] as num?)?.toDouble() ?? 3.0,
      time: data['time']?['s'] ?? '02.00 WITA',
    );
  }

  String get status {
    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sedang';
    if (aqi <= 150) return 'Sensitif';
    if (aqi <= 200) return 'Tidak Sehat';
    if (aqi <= 300) return 'Sangat Tidak Sehat';
    return 'Berbahaya';
  }

  int get statusColorValue {
    if (aqi <= 50) return 0xFF10B981; // Hijau
    if (aqi <= 100) return 0xFFFBBF24; // Kuning
    if (aqi <= 150) return 0xFFF97316; // Oranye
    if (aqi <= 200) return 0xFFEF4444; // Merah
    if (aqi <= 300) return 0xFFA855F7; // Ungu
    return 0xFF7F1D1D; // Maroon
  }

  // Teks deskripsi dampak kualitas udara
  String get description {
    if (aqi <= 50) {
      return 'Kualitas udara sangat baik. Udara bersih dan tidak berisiko bagi kesehatan manusia maupun hewan.';
    }
    if (aqi <= 100) {
      return 'Kualitas udara dapat diterima. Kelompok sensitif sebaiknya mengurangi aktivitas berat di luar ruangan.';
    }
    if (aqi <= 150) {
      return 'Kelompok sensitif dapat mengalami gangguan kesehatan. Masyarakat umum umumnya tidak terpengaruh.';
    }
    if (aqi <= 200) {
      return 'Semua orang dapat mulai merasakan dampak kesehatan; kelompok sensitif dapat mengalami dampak lebih serius.';
    }
    return 'Peringatan kesehatan kondisi darurat. Seluruh populasi berisiko tinggi terkena dampak.';
  }

  // Saran kesehatan untuk tab Polutan
  String get healthAdvice {
    if (aqi <= 50) {
      return 'Sangat ideal untuk berolahraga dan beraktivitas di luar ruangan.';
    }
    if (aqi <= 100) {
      return 'Masyarakat umum masih aman beraktivitas di luar ruangan. Penderita asma atau gangguan pernapasan sebaiknya membatasi aktivitas berat dan membawa obat pribadi.';
    }
    if (aqi <= 150) {
      return 'Gunakan masker bila beraktivitas di luar ruangan dalam jangka waktu lama, terutama bagi lansia dan anak-anak.';
    }
    return 'Hindari aktivitas di luar ruangan. Tutup jendela dan nyalakan penjernih udara (air purifier).';
  }
}