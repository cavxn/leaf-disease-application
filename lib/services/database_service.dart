import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/garden_plant.dart';
import '../models/plant_photo.dart';
import '../models/growth_measurement.dart';
import '../models/garden_journal_entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('garden.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const boolType = 'INTEGER';

    // Plants table
    await db.execute('''
      CREATE TABLE plants (
        id $idType,
        name $textType,
        scientificName $textType,
        notes $textType,
        dateAdded $textType,
        imagePath $textType,
        status $textType
      )
    ''');

    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id $idType,
        plantId $textType,
        imagePath $textType,
        timestamp $textType,
        description $textType,
        diseaseDetected $textType,
        isTreatmentBefore $boolType
      )
    ''');

    // Health history table
    await db.execute('''
      CREATE TABLE health_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantId $textType,
        entry $textType
      )
    ''');

    // Growth measurements table
    await db.execute('''
      CREATE TABLE growth_measurements (
        id $textType,
        plantId $textType,
        timestamp $textType,
        height REAL,
        width REAL,
        leafCount REAL,
        notes $textType,
        imagePath $textType,
        measurementType $textType
      )
    ''');

    // Garden journal entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id $textType,
        date $textType,
        title $textType,
        content $textType,
        photoPaths $textType,
        weatherData $textType,
        temperature $textType,
        humidity $textType,
        weatherCondition $textType,
        entryType $textType,
        tags $textType,
        plantId $textType,
        mood $textType
      )
    ''');
  }

  // Plant methods
  Future<int> insertPlant(GardenPlant plant) async {
    final db = await database;
    return await db.insert('plants', plant.toJson());
  }

  Future<List<GardenPlant>> getAllPlants() async {
    final db = await database;
    final results = await db.query('plants');
    
    return results.map((json) {
      // Get health history for this plant
      return GardenPlant.fromJson(json);
    }).toList();
  }

  Future<void> loadHealthHistory(GardenPlant plant) async {
    final db = await database;
    final results = await db.query(
      'health_history',
      where: 'plantId = ?',
      whereArgs: [plant.id],
    );
    
    plant.healthHistory.addAll(results.map((row) => row['entry'] as String));
  }

  Future<int> updatePlant(GardenPlant plant) async {
    final db = await database;
    return await db.update('plants', plant.toJson(), where: 'id = ?', whereArgs: [plant.id]);
  }

  Future<int> deletePlant(String plantId) async {
    final db = await database;
    // Also delete health history
    await db.delete('health_history', where: 'plantId = ?', whereArgs: [plantId]);
    await db.delete('photos', where: 'plantId = ?', whereArgs: [plantId]);
    return await db.delete('plants', where: 'id = ?', whereArgs: [plantId]);
  }

  Future<void> saveHealthHistory(String plantId, List<String> history) async {
    final db = await database;
    // Clear existing
    await db.delete('health_history', where: 'plantId = ?', whereArgs: [plantId]);
    // Insert new
    for (final entry in history) {
      await db.insert('health_history', {
        'plantId': plantId,
        'entry': entry,
      });
    }
  }

  // Photo methods
  Future<int> insertPhoto(PlantPhoto photo) async {
    final db = await database;
    return await db.insert('photos', photo.toJson());
  }

  Future<List<PlantPhoto>> getPhotosForPlant(String plantId) async {
    final db = await database;
    final results = await db.query(
      'photos',
      where: 'plantId = ?',
      whereArgs: [plantId],
      orderBy: 'timestamp DESC',
    );
    
    return results.map((json) => PlantPhoto.fromJson(json)).toList();
  }

  Future<List<PlantPhoto>> getAllPhotos() async {
    final db = await database;
    final results = await db.query('photos');
    
    return results.map((json) => PlantPhoto.fromJson(json)).toList();
  }

  Future<int> deletePhoto(String photoId) async {
    final db = await database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [photoId]);
  }

  // Growth measurement methods
  Future<int> insertGrowthMeasurement(GrowthMeasurement measurement) async {
    final db = await database;
    return await db.insert('growth_measurements', measurement.toJson());
  }

  Future<List<GrowthMeasurement>> getAllGrowthMeasurements() async {
    final db = await database;
    final results = await db.query('growth_measurements');
    
    return results.map((json) => GrowthMeasurement.fromJson(json)).toList();
  }

  Future<List<GrowthMeasurement>> getGrowthMeasurementsForPlant(String plantId) async {
    final db = await database;
    final results = await db.query(
      'growth_measurements',
      where: 'plantId = ?',
      whereArgs: [plantId],
      orderBy: 'timestamp ASC',
    );
    
    return results.map((json) => GrowthMeasurement.fromJson(json)).toList();
  }

  Future<int> updateGrowthMeasurement(GrowthMeasurement measurement) async {
    final db = await database;
    return await db.update(
      'growth_measurements', 
      measurement.toJson(), 
      where: 'id = ?', 
      whereArgs: [measurement.id]
    );
  }

  Future<int> deleteGrowthMeasurement(String measurementId) async {
    final db = await database;
    return await db.delete('growth_measurements', where: 'id = ?', whereArgs: [measurementId]);
  }

  // Journal entry methods
  Future<int> insertJournalEntry(GardenJournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toJson());
  }

  Future<List<GardenJournalEntry>> getAllJournalEntries() async {
    final db = await database;
    final results = await db.query('journal_entries', orderBy: 'date DESC');
    
    return results.map((json) => GardenJournalEntry.fromJson(json)).toList();
  }

  Future<List<GardenJournalEntry>> getJournalEntriesForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final results = await db.query(
      'journal_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'date DESC',
    );
    
    return results.map((json) => GardenJournalEntry.fromJson(json)).toList();
  }

  Future<int> updateJournalEntry(GardenJournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal_entries', 
      entry.toJson(), 
      where: 'id = ?', 
      whereArgs: [entry.id]
    );
  }

  Future<int> deleteJournalEntry(String entryId) async {
    final db = await database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [entryId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
