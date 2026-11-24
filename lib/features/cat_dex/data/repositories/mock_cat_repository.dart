import 'package:flutter/foundation.dart';
import '../models/cat_model.dart';
import '../../../map_territory/models/territory_model.dart';
import '../../../../core/constants/app_assets.dart';

class MockCatRepository extends ChangeNotifier {
  // Singleton pattern for simple state sharing across screens
  static final MockCatRepository _instance = MockCatRepository._internal();
  factory MockCatRepository() => _instance;
  MockCatRepository._internal();

  /// Daftar simulasi nama permanen yang sudah terkunci (case-insensitive)
  /// untuk validasi keunikan nama kucing di seluruh katalog kampus.
  final Set<String> _lockedNames = {
    'si oyen',
    'kuro',
    'luna',
  };

  Set<String> get lockedNames => Set.unmodifiable(_lockedNames);

  final List<CatModel> _cats = [
    const CatModel(
      id: 'cat_001',
      name: 'Si Oyen',
      qrHash: 'TELCAT-TULT-001',
      variant: CatVariant.oren,
      zone: 'TULT & Asrama',
      locationDetail: 'Lobby Utama Gedung TULT Lt. 1',
      avatarAsset: AppAssets.catOrenHead,
      photoAsset: AppAssets.catOrenHappy,
      healthStatus: 'Sehat & Steril (Data Pengelola)',
      personality: 'Pemberani & Suka Camilan',
      encounterCount: 5,
      lastScannedDate: null,
      isNameLocked: true,
      isCollected: true,
      isCurrentlyInCafe: true,
      cafePose: 'pillow',
      quote: 'Kalau bawa ikan tongkol, kita langsung bestie!',
    ),
    const CatModel(
      id: 'cat_002',
      name: 'Kucing Putih #02',
      qrHash: 'TELCAT-ASRAMA-002',
      variant: CatVariant.putih,
      zone: 'TULT & Asrama',
      locationDetail: 'Teras Gazebo Asrama Putri',
      avatarAsset: AppAssets.catPutihHead,
      photoAsset: AppAssets.catPutihHappy,
      healthStatus: 'Sehat & Terawat (Data Pengelola)',
      personality: 'Manja & Suka Mendengkur',
      encounterCount: 4,
      lastScannedDate: null,
      isNameLocked: false,
      isCollected: true,
      isCurrentlyInCafe: true,
      cafePose: 'box',
      quote: 'Kardus hangat ini adalah singgasana terbaikku!',
    ),
    CatModel(
      id: 'cat_003',
      name: 'Kuro',
      qrHash: 'TELCAT-DANAU-003',
      variant: CatVariant.hitam,
      zone: 'Cacuk',
      locationDetail: 'Tepian Jalur Jogging Dekat Gedung Cacuk',
      avatarAsset: AppAssets.catHitamHead,
      photoAsset: AppAssets.catHitamHappy,
      healthStatus: 'Sehat & Lincah (Data Pengelola)',
      personality: 'Misterius & Mandiri',
      encounterCount: 5,
      lastScannedDate: DateTime.now(),
      isNameLocked: true,
      isCollected: true,
      isCurrentlyInCafe: true,
      cafePose: 'carpet',
      quote: 'Jangan kaget kalau aku tiba-tiba muncul di pinggir danau ya!',
    ),
    const CatModel(
      id: 'cat_004',
      name: 'Kucing Oren #04',
      qrHash: 'TELCAT-GKU-004',
      variant: CatVariant.oren,
      zone: 'GKU',
      locationDetail: 'Koridor Depan Gedung Kuliah Bersama Lt. 2',
      avatarAsset: AppAssets.catOrenHead,
      photoAsset: AppAssets.catOrenHappy,
      healthStatus: 'Dalam Pantauan Pengelola',
      personality: 'Waspada tapi Penasaran',
      encounterCount: 0,
      lastScannedDate: null,
      isNameLocked: false,
      isCollected: false,
      isCurrentlyInCafe: false,
      cafePose: 'tree',
      quote: 'Ssst... aku sedang menyimak kuliah umum dari balik pilar koridor!',
    ),
    const CatModel(
      id: 'cat_005',
      name: 'Kucing Putih #05',
      qrHash: 'TELCAT-OPLIB-005',
      variant: CatVariant.putih,
      zone: 'GKU',
      locationDetail: 'Teras Teduh Sisi Timur Gedung GKU',
      avatarAsset: AppAssets.catPutihHead,
      photoAsset: AppAssets.catPutihHappy,
      healthStatus: 'Sehat & Gemuk (Data Pengelola)',
      personality: 'Santai & Hobi Tidur',
      encounterCount: 0,
      lastScannedDate: null,
      isNameLocked: false,
      isCollected: false,
      isCurrentlyInCafe: false,
      cafePose: 'stool',
      quote: 'Skripsi boleh menumpuk, tapi tidur siang tetap nomor satu.',
    ),
    const CatModel(
      id: 'cat_006',
      name: 'Luna',
      qrHash: 'TELCAT-TN-006',
      variant: CatVariant.putih,
      zone: 'Fakultas Depan',
      locationDetail: 'Bawah Pohon Rindang Kompleks Fakultas Depan',
      avatarAsset: AppAssets.catPutihHead,
      photoAsset: AppAssets.catPutihHappy,
      healthStatus: 'Sehat & Steril (Data Pengelola)',
      personality: 'Ramah & Suka Dibelai',
      encounterCount: 5,
      lastScannedDate: null,
      isNameLocked: true,
      isCollected: true,
      isCurrentlyInCafe: true,
      cafePose: 'tree',
      quote: 'Elus kepalaku sebentar sebelum masuk kelas ya, biar harimu cerah!',
    ),
    const CatModel(
      id: 'cat_007',
      name: 'Kucing Hitam #07',
      qrHash: 'TELCAT-CACUK-007',
      variant: CatVariant.hitam,
      zone: 'Cacuk',
      locationDetail: 'Pelataran Gedung Cacuk & Gedung Lengkung',
      avatarAsset: AppAssets.catHitamHead,
      photoAsset: AppAssets.catHitamHappy,
      healthStatus: 'Sehat (Data Pengelola)',
      personality: 'Cepat & Gesit',
      encounterCount: 0,
      lastScannedDate: null,
      isNameLocked: false,
      isCollected: false,
      isCurrentlyInCafe: false,
      cafePose: 'carpet',
      quote: 'Bayangan lewat di parkiran? Itu aku yang lagi patroli sore!',
    ),
    const CatModel(
      id: 'cat_008',
      name: 'Kucing Oren #08',
      qrHash: 'TELCAT-SC-008',
      variant: CatVariant.oren,
      zone: 'Fakultas Depan',
      locationDetail: 'Selasar Gerbang Utama Fakultas Depan',
      avatarAsset: AppAssets.catOrenHead,
      photoAsset: AppAssets.catOrenHappy,
      healthStatus: 'Sehat & Steril (Data Pengelola)',
      personality: 'Penyambut Tamu Handal',
      encounterCount: 2,
      lastScannedDate: null,
      isNameLocked: false,
      isCollected: true,
      isCurrentlyInCafe: true,
      cafePose: 'pillow',
      quote: 'Ada yang baru datang lewat gerbang depan? Sapa aku dulu ya!',
    ),
  ];

  final List<TerritoryModel> _territories = const [
    TerritoryModel(
      id: 'territory_tult',
      name: 'TULT & Asrama',
      shortLabel: '🏢 TULT & Asrama',
      description:
          'Area semenanjung kiri atas antara menara Telkom University Landmark Tower (TULT) dan deretan gedung asrama mahasiswa.',
      landmark: 'Menara TULT & Deretan Gedung Asrama',
      activeCatsCount: 2,
      imageAsset: AppAssets.zoneTult,
      residentCatIds: ['cat_001', 'cat_002'],
      latitude: -6.9730,
      longitude: 107.6300,
      mapDx: 0.31,
      mapDy: 0.18,
    ),
    TerritoryModel(
      id: 'territory_gku',
      name: 'GKU',
      shortLabel: '🏫 GKU',
      description:
          'Gedung Kuliah Umum persegi besar berhalaman tengah di sisi kiri-tengah kampus yang sejuk untuk tempat berteduh kucing.',
      landmark: 'Gedung Kuliah Umum & Halaman Tengah',
      activeCatsCount: 2,
      imageAsset: AppAssets.campusMap,
      residentCatIds: ['cat_004', 'cat_005'],
      latitude: -6.9745,
      longitude: 107.6315,
      mapDx: 0.37,
      mapDy: 0.43,
    ),
    TerritoryModel(
      id: 'territory_cacuk',
      name: 'Cacuk',
      shortLabel: '🏛️ Cacuk',
      description:
          'Area gedung akademik horizontal & gedung lengkung di pusat kampus berdekatan dengan Danau Situ Techno.',
      landmark: 'Gedung Cacuk & Gedung Lengkung Pusat',
      activeCatsCount: 2,
      imageAsset: AppAssets.campusMap,
      residentCatIds: ['cat_003', 'cat_007'],
      latitude: -6.9710,
      longitude: 107.6285,
      mapDx: 0.48,
      mapDy: 0.58,
    ),
    TerritoryModel(
      id: 'territory_fakultas',
      name: 'Fakultas Depan',
      shortLabel: '🎓 Fakultas Depan',
      description:
          'Kompleks gedung fakultas di sisi kanan dekat gerbang utama yang ramai disapa mahasiswa setiap pagi.',
      landmark: 'Kompleks Fakultas Depan & Gerbang Utama',
      activeCatsCount: 2,
      imageAsset: AppAssets.zoneTult,
      residentCatIds: ['cat_006', 'cat_008'],
      latitude: -6.9720,
      longitude: 107.6330,
      mapDx: 0.74,
      mapDy: 0.50,
    ),
  ];

  // Getters
  String? _selectedAvatarCatId;

  List<CatModel> get allCats => List.unmodifiable(_cats);

  List<CatModel> get collectedCats =>
      _cats.where((c) => c.isCollected).toList();

  List<CatModel> get encounteredCats =>
      _cats.where((c) => c.encounterCount > 0).toList();

  List<CatModel> get uncollectedCats =>
      _cats.where((c) => !c.isCollected).toList();

  List<CatModel> get cafeActiveCats =>
      _cats.where((c) => c.isCollected && c.isCurrentlyInCafe).toList();

  int get totalEncounters =>
      _cats.fold<int>(0, (sum, cat) => sum + cat.encounterCount);

  int get maxEncounterCount {
    var highest = 0;
    for (final cat in _cats) {
      if (cat.encounterCount > highest) {
        highest = cat.encounterCount;
      }
    }
    return highest;
  }

  int get lockedNamesCount => _cats.where((c) => c.isNameLocked).length;

  /// Kucing yang paling sering dijumpai (nilai encounterCount tertinggi).
  CatModel? get bestBuddyCat {
    final metCats = encounteredCats;
    if (metCats.isEmpty) return null;
    CatModel best = metCats.first;
    for (final cat in metCats.skip(1)) {
      if (cat.encounterCount > best.encounterCount) {
        best = cat;
      }
    }
    return best;
  }

  /// Kucing yang dipilih sebagai avatar profil (fallback ke kucing pertama yang ditemui).
  CatModel? get selectedAvatarCat {
    final metCats = encounteredCats;
    if (metCats.isEmpty) return null;
    if (_selectedAvatarCatId != null) {
      for (final cat in metCats) {
        if (cat.id == _selectedAvatarCatId) {
          return cat;
        }
      }
    }
    return metCats.first;
  }

  String get selectedProfileAvatarAsset =>
      selectedAvatarCat?.headPoseAsset ?? AppAssets.catOrenHead;

  void selectProfileAvatar(String catId) {
    final target = encounteredCats.where((c) => c.id == catId);
    if (target.isEmpty) return;
    _selectedAvatarCatId = catId;
    notifyListeners();
  }

  List<TerritoryModel> get territories => List.unmodifiable(_territories);

  CatModel getCatById(String id) {
    return _cats.firstWhere(
      (c) => c.id == id,
      orElse: () => _cats.first,
    );
  }

  CatModel getCatByQr(String qr) {
    return _cats.firstWhere(
      (c) => c.qrHash.toUpperCase() == qr.toUpperCase() || c.id == qr,
      orElse: () => _cats.first,
    );
  }

  TerritoryModel getTerritoryById(String id) {
    return _territories.firstWhere(
      (t) => t.id == id,
      orElse: () => _territories.first,
    );
  }

  // TODO: Ganti simulasi lokal ini dengan endpoint API Laravel terpusat (encounter log, daily cooldown 1x/hari, dan update nama permanen)
  bool isScannedToday(String catId) {
    return getCatById(catId).isScannedToday;
  }

  // TODO: Ganti simulasi lokal ini dengan endpoint API Laravel terpusat (encounter log, daily cooldown 1x/hari, dan update nama permanen)
  CatModel recordEncounter(String catId) {
    final index = _cats.indexWhere((c) => c.id == catId);
    if (index == -1) return _cats.first;

    final old = _cats[index];
    final updated = old.copyWith(
      isCollected: true,
      isCurrentlyInCafe: true,
      encounterCount: old.encounterCount + 1,
      lastScannedDate: DateTime.now(),
    );
    _cats[index] = updated;
    notifyListeners();
    return updated;
  }

  // TODO: Ganti simulasi lokal ini dengan endpoint API Laravel terpusat (encounter log, daily cooldown 1x/hari, dan update nama permanen)
  bool isNameTaken(String name) {
    final normalized = name.trim().toLowerCase();
    return _lockedNames.contains(normalized);
  }

  // TODO: Ganti simulasi lokal ini dengan endpoint API Laravel terpusat (encounter log, daily cooldown 1x/hari, dan update nama permanen)
  String? renameCat(String catId, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    if (trimmed.length < 2 || trimmed.length > 20) {
      return 'Panjang nama harus 2–20 karakter.';
    }
    if (isNameTaken(trimmed)) {
      return 'Nama ini sudah dipakai kucing lain, pilih nama lain ya!';
    }

    final index = _cats.indexWhere((c) => c.id == catId);
    if (index == -1) return 'Kucing tidak ditemukan.';

    final old = _cats[index];
    if (!old.canBeNamed) {
      return 'Kucing ini belum memenuhi syarat 5x pertemuan atau namanya sudah terkunci.';
    }

    _lockedNames.add(trimmed.toLowerCase());
    _cats[index] = old.copyWith(
      name: trimmed,
      isNameLocked: true,
    );
    notifyListeners();
    return null;
  }

  // TODO: Ganti simulasi lokal ini dengan endpoint API Laravel terpusat (encounter log, daily cooldown 1x/hari, dan update nama permanen)
  void resetAllDailyCooldowns() {
    for (var i = 0; i < _cats.length; i++) {
      _cats[i] = _cats[i].copyWith(clearLastScannedDate: true);
    }
    notifyListeners();
  }

  // TODO: Ganti simulasi lokal ini dengan endpoint API Laravel terpusat (encounter log, daily cooldown 1x/hari, dan update nama permanen)
  void simulateFourEncounters(String catId) {
    final index = _cats.indexWhere((c) => c.id == catId);
    if (index == -1) return;

    final old = _cats[index];
    if (old.isNameLocked) {
      _lockedNames.remove(old.name.trim().toLowerCase());
    }
    _cats[index] = old.copyWith(
      encounterCount: 4,
      isNameLocked: false,
      isCollected: true,
      isCurrentlyInCafe: true,
      clearLastScannedDate: true,
    );
    notifyListeners();
  }
}
