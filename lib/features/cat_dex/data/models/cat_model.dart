import '../../../../core/constants/app_assets.dart';

enum CatVariant {
  oren,
  putih,
  hitam,
}

class CatModel {
  final String id;
  final String name;
  final String qrHash;
  final CatVariant variant;
  final String zone;
  final String locationDetail;
  final String avatarAsset;
  final String photoAsset;
  final String healthStatus;
  final String personality;
  final int encounterCount;
  final DateTime? lastScannedDate;
  final bool isNameLocked;
  final bool isCollected;
  final bool isCurrentlyInCafe;
  final String cafePose; // 'pillow', 'box', 'tree', 'carpet', 'stool'
  final String quote;

  const CatModel({
    required this.id,
    required this.name,
    required this.qrHash,
    required this.variant,
    required this.zone,
    required this.locationDetail,
    required this.avatarAsset,
    required this.photoAsset,
    required this.healthStatus,
    required this.personality,
    this.encounterCount = 0,
    this.lastScannedDate,
    this.isNameLocked = false,
    this.isCollected = false,
    this.isCurrentlyInCafe = false,
    this.cafePose = 'pillow',
    this.quote = 'Meoong... senangnya dikunjungi!',
  });

  /// Mengambil path aset pose kepala siap diusap sesuai variasi kucing.
  String get headPoseAsset {
    switch (variant) {
      case CatVariant.oren:
        return AppAssets.catOrenHead;
      case CatVariant.putih:
        return AppAssets.catPutihHead;
      case CatVariant.hitam:
        return AppAssets.catHitamHead;
    }
  }

  /// Mengambil path aset pose tiduran telentang memperlihatkan perut sesuai variasi kucing.
  String get bellyPoseAsset {
    switch (variant) {
      case CatVariant.oren:
        return AppAssets.catOrenBelly;
      case CatVariant.putih:
        return AppAssets.catPutihBelly;
      case CatVariant.hitam:
        return AppAssets.catHitamBelly;
    }
  }

  /// Mengambil path aset pose bahagia melompat sesuai variasi kucing.
  String get happyPoseAsset {
    switch (variant) {
      case CatVariant.oren:
        return AppAssets.catOrenHappy;
      case CatVariant.putih:
        return AppAssets.catPutihHappy;
      case CatVariant.hitam:
        return AppAssets.catHitamHappy;
    }
  }

  /// Mengambil path aset pose sedih (untuk pop-up cooldown harian) sesuai variasi kucing.
  String get sadPoseAsset {
    switch (variant) {
      case CatVariant.oren:
        return AppAssets.catOrenSad;
      case CatVariant.putih:
        return AppAssets.catPutihSad;
      case CatVariant.hitam:
        return AppAssets.catHitamSad;
    }
  }

  /// Mengambil path aset frame 1 animasi berjalan di Kafe Kucing sesuai variasi kucing.
  String get walk1PoseAsset {
    switch (variant) {
      case CatVariant.oren:
        return AppAssets.catOrenWalk1;
      case CatVariant.putih:
        return AppAssets.catPutihWalk1;
      case CatVariant.hitam:
        return AppAssets.catHitamWalk1;
    }
  }

  /// Mengambil path aset frame 2 animasi berjalan di Kafe Kucing sesuai variasi kucing.
  String get walk2PoseAsset {
    switch (variant) {
      case CatVariant.oren:
        return AppAssets.catOrenWalk2;
      case CatVariant.putih:
        return AppAssets.catPutihWalk2;
      case CatVariant.hitam:
        return AppAssets.catHitamWalk2;
    }
  }

  /// Syarat hak memberi nama permanen: pertemuan >= 5 kali dan nama belum dikunci.
  bool get canBeNamed => encounterCount >= 5 && !isNameLocked;

  /// Mengecek apakah kucing sudah di-scan pada tanggal kalender hari ini.
  bool get isScannedToday {
    final scanned = lastScannedDate;
    if (scanned == null) return false;
    final now = DateTime.now();
    return scanned.year == now.year &&
        scanned.month == now.month &&
        scanned.day == now.day;
  }

  /// Format tampilan ringkas waktu pertemuan terakhir.
  String get formattedLastScannedDate {
    final scanned = lastScannedDate;
    if (scanned == null) return 'Belum disapa hari ini';
    final now = DateTime.now();
    final hh = scanned.hour.toString().padLeft(2, '0');
    final mm = scanned.minute.toString().padLeft(2, '0');
    if (scanned.year == now.year &&
        scanned.month == now.month &&
        scanned.day == now.day) {
      return 'Hari ini, $hh:$mm WIB';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (scanned.year == yesterday.year &&
        scanned.month == yesterday.month &&
        scanned.day == yesterday.day) {
      return 'Kemarin, $hh:$mm WIB';
    }
    final dd = scanned.day.toString().padLeft(2, '0');
    final mo = scanned.month.toString().padLeft(2, '0');
    return '$dd/$mo/${scanned.year}';
  }

  CatModel copyWith({
    String? id,
    String? name,
    String? qrHash,
    CatVariant? variant,
    String? zone,
    String? locationDetail,
    String? avatarAsset,
    String? photoAsset,
    String? healthStatus,
    String? personality,
    int? encounterCount,
    DateTime? lastScannedDate,
    bool clearLastScannedDate = false,
    bool? isNameLocked,
    bool? isCollected,
    bool? isCurrentlyInCafe,
    String? cafePose,
    String? quote,
  }) {
    return CatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      qrHash: qrHash ?? this.qrHash,
      variant: variant ?? this.variant,
      zone: zone ?? this.zone,
      locationDetail: locationDetail ?? this.locationDetail,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      photoAsset: photoAsset ?? this.photoAsset,
      healthStatus: healthStatus ?? this.healthStatus,
      personality: personality ?? this.personality,
      encounterCount: encounterCount ?? this.encounterCount,
      lastScannedDate:
          clearLastScannedDate ? null : (lastScannedDate ?? this.lastScannedDate),
      isNameLocked: isNameLocked ?? this.isNameLocked,
      isCollected: isCollected ?? this.isCollected,
      isCurrentlyInCafe: isCurrentlyInCafe ?? this.isCurrentlyInCafe,
      cafePose: cafePose ?? this.cafePose,
      quote: quote ?? this.quote,
    );
  }
}
