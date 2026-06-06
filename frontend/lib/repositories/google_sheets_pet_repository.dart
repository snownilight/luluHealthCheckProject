import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;
import '../models/pet_status.dart';
import 'pet_repository.dart';

/// HTTP Client that appends Google Sign-In authentication headers to all requests.
class AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleSheetsPetRepository implements PetRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/spreadsheets',
      'https://www.googleapis.com/auth/drive.metadata.readonly',
    ],
  );

  GoogleSignInAccount? _currentUser;
  String? _spreadsheetId;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get spreadsheetId => _spreadsheetId;

  /// Trigger Google OAuth Login
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error during Google Sign-in: $e');
      return null;
    }
  }

  /// Trigger Google Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _spreadsheetId = null;
  }

  /// Set the active Spreadsheet ID
  void setSpreadsheetId(String? id) {
    _spreadsheetId = id;
  }

  /// Get the authenticated AuthClient
  Future<AuthClient?> _getAuthClient() async {
    var user = _currentUser;
    if (user == null) {
      user = await signIn();
    }
    if (user == null) {
      return null;
    }
    final headers = await user.authHeaders;
    return AuthClient(headers);
  }

  /// Verify if the user has Editor/Owner (write) permissions for the spreadsheet
  Future<bool> checkWritePermission(String sheetId) async {
    try {
      final client = await _getAuthClient();
      if (client == null) return false;

      final driveApi = drive.DriveApi(client);
      final file = await driveApi.files.get(
        sheetId,
        $fields: 'capabilities/canEdit',
      ) as drive.File;

      return file.capabilities?.canEdit ?? false;
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error checking write permission: $e');
      return false;
    }
  }

  /// Create a new Google Spreadsheet with headers
  Future<String?> createNewSpreadsheet(String title) async {
    try {
      final client = await _getAuthClient();
      if (client == null) return null;

      final sheetsApi = sheets.SheetsApi(client);

      // Define spreadsheet properties and default tabs
      final newSheet = sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(title: title),
        sheets: [
          sheets.Sheet(properties: sheets.SheetProperties(title: 'CareLogs')),
          sheets.Sheet(properties: sheets.SheetProperties(title: 'WeightLogs')),
          sheets.Sheet(properties: sheets.SheetProperties(title: 'DailySummaries')),
        ],
      );

      final created = await sheetsApi.spreadsheets.create(newSheet);
      final newSheetId = created.spreadsheetId;
      if (newSheetId == null) return null;

      _spreadsheetId = newSheetId;

      // Initialize Headers for each sheet
      await sheetsApi.spreadsheets.values.update(
        sheets.ValueRange.fromJson({
          'values': [
            ['Event ID', 'Event Type', 'Operator', 'Value', 'Unit', 'Note', 'Event Timestamp', 'Created At']
          ]
        }),
        newSheetId,
        'CareLogs!A1:H1',
        valueInputOption: 'USER_ENTERED',
      );

      await sheetsApi.spreadsheets.values.update(
        sheets.ValueRange.fromJson({
          'values': [
            ['Recorded At', 'Weight (kg)']
          ]
        }),
        newSheetId,
        'WeightLogs!A1:B1',
        valueInputOption: 'USER_ENTERED',
      );

      await sheetsApi.spreadsheets.values.update(
        sheets.ValueRange.fromJson({
          'values': [
            ['Date', 'Total Water (ml)', 'Total Food (g)', 'Average Weight (kg)']
          ]
        }),
        newSheetId,
        'DailySummaries!A1:D1',
        valueInputOption: 'USER_ENTERED',
      );

      return newSheetId;
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error creating spreadsheet: $e');
      return null;
    }
  }

  @override
  Future<bool> saveCareLog(Map<String, dynamic> careLogData) async {
    final sheetId = _spreadsheetId;
    if (sheetId == null) return false;

    try {
      final client = await _getAuthClient();
      if (client == null) return false;

      final sheetsApi = sheets.SheetsApi(client);

      final eventId = careLogData['eventId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final eventTypeStr = careLogData['eventType'];
      final operatorVal = careLogData['operator'] ?? 'Guest';
      final val = (careLogData['value'] as num?)?.toDouble();
      final unitVal = careLogData['unit'];
      final noteVal = careLogData['note'];
      final eventTimestamp = careLogData['eventTimestamp'] != null
          ? DateTime.parse(careLogData['eventTimestamp'] as String)
          : DateTime.now();
      final createdAt = DateTime.now();

      // 1. Append to CareLogs
      final careLogRange = 'CareLogs!A:H';
      final careLogValues = sheets.ValueRange.fromJson({
        'values': [
          [
            eventId,
            eventTypeStr,
            operatorVal,
            val?.toString() ?? '',
            unitVal ?? '',
            noteVal ?? '',
            eventTimestamp.toIso8601String(),
            createdAt.toIso8601String(),
          ]
        ]
      });

      await sheetsApi.spreadsheets.values.append(
        careLogValues,
        sheetId,
        careLogRange,
        valueInputOption: 'USER_ENTERED',
      );

      // 2. If weight update, append to WeightLogs
      if (eventTypeStr == 'WEIGHT_UPDATE' && val != null) {
        final weightRange = 'WeightLogs!A:B';
        final weightValues = sheets.ValueRange.fromJson({
          'values': [
            [
              eventTimestamp.toIso8601String(),
              val.toString(),
            ]
          ]
        });

        await sheetsApi.spreadsheets.values.append(
          weightValues,
          sheetId,
          weightRange,
          valueInputOption: 'USER_ENTERED',
        );
      }

      // 3. Update daily summary for that date
      await _updateDailySummaryForDate(sheetsApi, sheetId, eventTimestamp);

      return true;
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error saving care log: $e');
      return false;
    }
  }

  Future<void> _updateDailySummaryForDate(sheets.SheetsApi sheetsApi, String sheetId, DateTime timestamp) async {
    final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final dateStr = dateOnly.toIso8601String().substring(0, 10); // YYYY-MM-DD

    // Fetch all care logs from sheet to compute totals
    final careLogsResponse = await sheetsApi.spreadsheets.values.get(sheetId, 'CareLogs!A2:H');
    final careLogsRows = careLogsResponse.values ?? [];

    double waterSum = 0;
    double foodSum = 0;
    for (final row in careLogsRows) {
      if (row.length >= 8) {
        final rowType = row[1].toString();
        final rowVal = double.tryParse(row[3].toString()) ?? 0.0;
        final rowTimeStr = row[6].toString();
        if (rowTimeStr.startsWith(dateStr)) {
          if (rowType == 'DRINKING') {
            waterSum += rowVal;
          } else if (rowType == 'FEEDING') {
            foodSum += rowVal;
          }
        }
      }
    }

    // Fetch all weight logs to compute average weight
    final weightLogsResponse = await sheetsApi.spreadsheets.values.get(sheetId, 'WeightLogs!A2:B');
    final weightLogsRows = weightLogsResponse.values ?? [];

    double weightSum = 0;
    int weightCount = 0;
    for (final row in weightLogsRows) {
      if (row.length >= 2) {
        final rowTimeStr = row[0].toString();
        final rowVal = double.tryParse(row[1].toString()) ?? 0.0;
        if (rowTimeStr.startsWith(dateStr)) {
          weightSum += rowVal;
          weightCount++;
        }
      }
    }
    double avgWeight = weightCount > 0 ? (weightSum / weightCount) : 0.0;

    // Check if summary for this date already exists in DailySummaries
    final summaryResponse = await sheetsApi.spreadsheets.values.get(sheetId, 'DailySummaries!A2:D');
    final summaryRows = summaryResponse.values ?? [];

    int existingRowIndex = -1;
    for (int i = 0; i < summaryRows.length; i++) {
      if (summaryRows[i].isNotEmpty && summaryRows[i][0].toString().startsWith(dateStr)) {
        existingRowIndex = i + 2; // Offset for header (1-indexed)
        break;
      }
    }

    final newSummaryValues = [
      dateStr,
      waterSum.toString(),
      foodSum.toString(),
      avgWeight.toString(),
    ];

    if (existingRowIndex == -1) {
      // Append new row
      final range = 'DailySummaries!A:D';
      final body = sheets.ValueRange.fromJson({
        'values': [newSummaryValues]
      });
      await sheetsApi.spreadsheets.values.append(
        body,
        sheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } else {
      // Update existing row
      final range = 'DailySummaries!A$existingRowIndex:D$existingRowIndex';
      final body = sheets.ValueRange.fromJson({
        'values': [newSummaryValues]
      });
      await sheetsApi.spreadsheets.values.update(
        body,
        sheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCareLogs() async {
    final sheetId = _spreadsheetId;
    if (sheetId == null) return [];

    try {
      final client = await _getAuthClient();
      if (client == null) return [];

      final sheetsApi = sheets.SheetsApi(client);
      final response = await sheetsApi.spreadsheets.values.get(sheetId, 'CareLogs!A2:H');
      final rows = response.values ?? [];

      return rows.map((row) {
        return {
          'eventId': row.isNotEmpty ? row[0].toString() : '',
          'eventType': row.length > 1 ? row[1].toString() : '',
          'operator': row.length > 2 ? row[2].toString() : '',
          'value': row.length > 3 ? double.tryParse(row[3].toString()) : null,
          'unit': row.length > 4 ? row[4].toString() : null,
          'note': row.length > 5 ? row[5].toString() : null,
          'eventTimestamp': row.length > 6 ? row[6].toString() : DateTime.now().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error getting care logs: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyWeightTrend() async {
    final sheetId = _spreadsheetId;
    if (sheetId == null) return [];

    try {
      final client = await _getAuthClient();
      if (client == null) return [];

      final sheetsApi = sheets.SheetsApi(client);
      final response = await sheetsApi.spreadsheets.values.get(sheetId, 'WeightLogs!A2:B');
      final rows = response.values ?? [];

      return rows.map((row) {
        return {
          'recordedAt': row.isNotEmpty ? row[0].toString() : '',
          'weightKg': row.length > 1 ? double.tryParse(row[1].toString()) ?? 0.0 : 0.0,
        };
      }).toList();
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error getting weekly weight trend: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyDailySummary() async {
    final sheetId = _spreadsheetId;
    if (sheetId == null) return [];

    try {
      final client = await _getAuthClient();
      if (client == null) return [];

      final sheetsApi = sheets.SheetsApi(client);
      final response = await sheetsApi.spreadsheets.values.get(sheetId, 'DailySummaries!A2:D');
      final rows = response.values ?? [];

      return rows.map((row) {
        return {
          'date': row.isNotEmpty ? row[0].toString() : '',
          'totalWaterIntakeMl': row.length > 1 ? double.tryParse(row[1].toString()) ?? 0.0 : 0.0,
          'totalFoodIntakeG': row.length > 2 ? double.tryParse(row[2].toString()) ?? 0.0 : 0.0,
          'averageWeightKg': row.length > 3 ? double.tryParse(row[3].toString()) ?? 0.0 : 0.0,
        };
      }).toList();
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error getting monthly daily summary: $e');
      return [];
    }
  }

  @override
  Future<PetStatus> getPetStatus() async {
    final sheetId = _spreadsheetId;
    if (sheetId == null) {
      return PetStatus(
        lastWeightKg: 4.8,
        todayWaterIntakeMl: 0.0,
        todayFoodIntakeG: 0.0,
        lastActiveTime: DateTime.now().subtract(const Duration(minutes: 15)),
      );
    }

    try {
      final client = await _getAuthClient();
      if (client == null) throw Exception('Auth Client is null');

      final sheetsApi = sheets.SheetsApi(client);

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. Fetch today's summary from DailySummaries
      final summaryResponse = await sheetsApi.spreadsheets.values.get(sheetId, 'DailySummaries!A2:D');
      final summaryRows = summaryResponse.values ?? [];

      double water = 0.0;
      double food = 0.0;
      for (final row in summaryRows) {
        if (row.isNotEmpty && row[0].toString().startsWith(todayStr)) {
          water = double.tryParse(row[1].toString()) ?? 0.0;
          food = double.tryParse(row[2].toString()) ?? 0.0;
          break;
        }
      }

      // 2. Fetch latest weight from WeightLogs (last row)
      final weightResponse = await sheetsApi.spreadsheets.values.get(sheetId, 'WeightLogs!A2:B');
      final weightRows = weightResponse.values ?? [];
      double weight = 4.8;
      if (weightRows.isNotEmpty) {
        weight = double.tryParse(weightRows.last[1].toString()) ?? 4.8;
      }

      // 3. Fetch latest active time from CareLogs (last row)
      final careLogsResponse = await sheetsApi.spreadsheets.values.get(sheetId, 'CareLogs!A2:H');
      final careLogsRows = careLogsResponse.values ?? [];
      DateTime active = DateTime.now().subtract(const Duration(minutes: 15));
      if (careLogsRows.isNotEmpty) {
        final lastTimeStr = careLogsRows.last[6].toString();
        active = DateTime.tryParse(lastTimeStr) ?? active;
      }

      return PetStatus(
        lastWeightKg: weight,
        todayWaterIntakeMl: water,
        todayFoodIntakeG: food,
        lastActiveTime: active,
      );
    } catch (e) {
      print('[GoogleSheetsPetRepository] Error getting pet status: $e');
      return PetStatus(
        lastWeightKg: 4.8,
        todayWaterIntakeMl: 0.0,
        todayFoodIntakeG: 0.0,
        lastActiveTime: DateTime.now().subtract(const Duration(minutes: 15)),
      );
    }
  }
}
