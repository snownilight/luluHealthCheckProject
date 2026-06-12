import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/pet_repository.dart';
import '../repositories/local_pet_repository.dart';
import '../repositories/google_sheets_pet_repository.dart';
import '../repositories/server_pet_repository.dart';
import 'local_database.dart';
import 'api_service.dart';

enum StorageMode {
  local,
  googleSheets,
  server,
}

class StorageSettings {
  final StorageMode mode;
  final String? spreadsheetId;
  final String? spreadsheetTitle;
  final bool isConfigured;

  StorageSettings({
    required this.mode,
    this.spreadsheetId,
    this.spreadsheetTitle,
    required this.isConfigured,
  });

  StorageSettings copyWith({
    StorageMode? mode,
    String? spreadsheetId,
    String? spreadsheetTitle,
    bool? isConfigured,
  }) {
    return StorageSettings(
      mode: mode ?? this.mode,
      spreadsheetId: spreadsheetId ?? this.spreadsheetId,
      spreadsheetTitle: spreadsheetTitle ?? this.spreadsheetTitle,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}

class StorageSettingsNotifier extends StateNotifier<StorageSettings> {
  final Ref _ref;
  static const String _modeKey = 'storage_mode';
  static const String _sheetIdKey = 'google_sheet_id';
  static const String _sheetTitleKey = 'google_sheet_title';
  static const String _configuredKey = 'storage_setup_completed';

  StorageSettingsNotifier(this._ref)
      : super(StorageSettings(
          mode: StorageMode.local,
          isConfigured: false,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_modeKey) ?? 'local';
    final sheetId = prefs.getString(_sheetIdKey);
    final sheetTitle = prefs.getString(_sheetTitleKey) ?? 'MyPetHealth';
    final isConfigured = prefs.getBool(_configuredKey) ?? false;

    StorageMode mode = StorageMode.local;
    if (modeStr == 'google_sheets') {
      mode = StorageMode.googleSheets;
    } else if (modeStr == 'server') {
      mode = StorageMode.server;
    }

    state = StorageSettings(
      mode: mode,
      spreadsheetId: sheetId,
      spreadsheetTitle: sheetTitle,
      isConfigured: isConfigured,
    );

    // Synchronize spreadsheetId to Google Sheets repository
    if (mode == StorageMode.googleSheets && sheetId != null) {
      _ref.read(googleSheetsPetRepositoryProvider).setSpreadsheetId(sheetId);
    }
  }

  Future<void> setStorageMode(StorageMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String modeStr = 'local';
    if (mode == StorageMode.googleSheets) {
      modeStr = 'google_sheets';
    } else if (mode == StorageMode.server) {
      modeStr = 'server';
    }
    await prefs.setString(_modeKey, modeStr);
    state = state.copyWith(mode: mode);
  }

  Future<void> setSpreadsheetId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_sheetIdKey);
    } else {
      await prefs.setString(_sheetIdKey, id);
    }
    state = state.copyWith(spreadsheetId: id);
    _ref.read(googleSheetsPetRepositoryProvider).setSpreadsheetId(id);
  }

  Future<void> setSpreadsheetTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sheetTitleKey, title);
    state = state.copyWith(spreadsheetTitle: title);
  }

  Future<void> setConfigured(bool configured) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_configuredKey, configured);
    state = state.copyWith(isConfigured: configured);
  }
}

final storageSettingsProvider =
    StateNotifierProvider<StorageSettingsNotifier, StorageSettings>((ref) {
  return StorageSettingsNotifier(ref);
});

// Concrete repository providers
final localPetRepositoryProvider = Provider((ref) {
  final db = ref.watch(localDatabaseProvider);
  return LocalPetRepository(db);
});

final googleSheetsPetRepositoryProvider = Provider((ref) {
  return GoogleSheetsPetRepository();
});

final serverPetRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ServerPetRepository(apiService);
});

// Dynamic PetRepository Provider
final petRepositoryProvider = Provider<PetRepository>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  switch (settings.mode) {
    case StorageMode.local:
      return ref.read(localPetRepositoryProvider);
    case StorageMode.googleSheets:
      return ref.read(googleSheetsPetRepositoryProvider);
    case StorageMode.server:
      return ref.read(serverPetRepositoryProvider);
  }
});

class GoogleUserNotifier extends StateNotifier<GoogleSignInAccount?> {
  final Ref _ref;
  GoogleUserNotifier(this._ref) : super(null) {
    state = _ref.read(googleSheetsPetRepositoryProvider).currentUser;
  }

  Future<GoogleSignInAccount?> checkSilentSignIn() async {
    final googleRepo = _ref.read(googleSheetsPetRepositoryProvider);
    final user = await googleRepo.signInSilently();
    state = user;
    if (user != null) {
      await _autoLinkExistingSheet();
    }
    return user;
  }

  Future<GoogleSignInAccount?> signIn() async {
    final googleRepo = _ref.read(googleSheetsPetRepositoryProvider);
    final user = await googleRepo.signIn();
    state = user;
    if (user != null) {
      await _autoLinkExistingSheet();
    }
    return user;
  }

  Future<void> signOut() async {
    final googleRepo = _ref.read(googleSheetsPetRepositoryProvider);
    await googleRepo.signOut();
    state = null;
  }

  Future<void> _autoLinkExistingSheet() async {
    try {
      final settings = _ref.read(storageSettingsProvider);
      if (settings.spreadsheetId == null) {
        final title = settings.spreadsheetTitle ?? 'MyPetHealth';
        final googleRepo = _ref.read(googleSheetsPetRepositoryProvider);
        final existingId = await googleRepo.findExistingSpreadsheet(title);
        if (existingId != null) {
          print('[GoogleUserNotifier] Auto-linking existing spreadsheet found on Google Drive: $existingId');
          await _ref.read(storageSettingsProvider.notifier).setSpreadsheetId(existingId);
          await _ref.read(storageSettingsProvider.notifier).setStorageMode(StorageMode.googleSheets);
          await _ref.read(storageSettingsProvider.notifier).setConfigured(true);
        }
      }
    } catch (e) {
      print('[GoogleUserNotifier] Error during auto-linking existing sheet: $e');
    }
  }
}

final googleUserProvider =
    StateNotifierProvider<GoogleUserNotifier, GoogleSignInAccount?>((ref) {
  return GoogleUserNotifier(ref);
});
