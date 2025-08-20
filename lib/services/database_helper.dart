import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/election.dart';
import '../models/party.dart';
import '../models/vote.dart';
import '../models/admin.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'evoting.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        vin TEXT UNIQUE NOT NULL,
        phoneNumber TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        biometricEnabled INTEGER DEFAULT 0,
        biometricData TEXT,
        createdAt INTEGER NOT NULL,
        lastLogin INTEGER
      )
    ''');

    // Admins table
    await db.execute('''
      CREATE TABLE admins(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        role TEXT DEFAULT 'admin',
        createdAt INTEGER NOT NULL,
        lastLogin INTEGER
      )
    ''');

    // Elections table
    await db.execute('''
      CREATE TABLE elections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        status INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL,
        resultsReleasedAt INTEGER
      )
    ''');

    // Parties table
    await db.execute('''
      CREATE TABLE parties(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        logoPath TEXT,
        candidateName TEXT NOT NULL,
        electionId INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY(electionId) REFERENCES elections(id) ON DELETE CASCADE
      )
    ''');

    // Votes table
    await db.execute('''
      CREATE TABLE votes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        electionId INTEGER NOT NULL,
        partyId INTEGER NOT NULL,
        castAt INTEGER NOT NULL,
        voteHash TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id),
        FOREIGN KEY(electionId) REFERENCES elections(id),
        FOREIGN KEY(partyId) REFERENCES parties(id),
        UNIQUE(userId, electionId)
      )
    ''');

    // Create default admin user (password: admin123)
    await db.execute('''
      INSERT INTO admins (username, email, passwordHash, createdAt)
      VALUES ('admin', 'admin@evoting.com', '\$2b\$10\$X.JrNqgPeqJ9OTNpGKOlE.tQrWFvJVrE7H7Qb1w2Gh8Kz9K3Q4S5T6', ${DateTime.now().millisecondsSinceEpoch})
    ''');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByLastName(String lastName) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'lastName = ?',
      whereArgs: [lastName],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByVin(String vin) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'vin = ?',
      whereArgs: [vin],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final Database db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Admin operations
  Future<Admin?> getAdminByUsername(String username) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admins',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return Admin.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateAdmin(Admin admin) async {
    final Database db = await database;
    await db.update(
      'admins',
      admin.toMap(),
      where: 'id = ?',
      whereArgs: [admin.id],
    );
  }

  // Election operations
  Future<int> insertElection(Election election) async {
    final Database db = await database;
    return await db.insert('elections', election.toMap());
  }

  Future<List<Election>> getElections() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('elections');
    return List.generate(maps.length, (i) => Election.fromMap(maps[i]));
  }

  Future<Election?> getElectionById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'elections',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Election.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateElection(Election election) async {
    final Database db = await database;
    await db.update(
      'elections',
      election.toMap(),
      where: 'id = ?',
      whereArgs: [election.id],
    );
  }

  Future<void> deleteElection(int id) async {
    final Database db = await database;
    await db.delete(
      'elections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Party operations
  Future<int> insertParty(Party party) async {
    final Database db = await database;
    return await db.insert('parties', party.toMap());
  }

  Future<List<Party>> getPartiesByElection(int electionId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parties',
      where: 'electionId = ?',
      whereArgs: [electionId],
    );
    return List.generate(maps.length, (i) => Party.fromMap(maps[i]));
  }

  Future<Party?> getPartyById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parties',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Party.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateParty(Party party) async {
    final Database db = await database;
    await db.update(
      'parties',
      party.toMap(),
      where: 'id = ?',
      whereArgs: [party.id],
    );
  }

  Future<void> deleteParty(int id) async {
    final Database db = await database;
    await db.delete(
      'parties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Vote operations
  Future<int> insertVote(Vote vote) async {
    final Database db = await database;
    return await db.insert('votes', vote.toMap());
  }

  Future<Vote?> getUserVoteForElection(int userId, int electionId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'votes',
      where: 'userId = ? AND electionId = ?',
      whereArgs: [userId, electionId],
    );
    if (maps.isNotEmpty) {
      return Vote.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Vote>> getVotesByElection(int electionId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'votes',
      where: 'electionId = ?',
      whereArgs: [electionId],
    );
    return List.generate(maps.length, (i) => Vote.fromMap(maps[i]));
  }

  Future<Map<int, int>> getElectionResults(int electionId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT partyId, COUNT(*) as voteCount
      FROM votes
      WHERE electionId = ?
      GROUP BY partyId
    ''', [electionId]);

    Map<int, int> voteResults = {};
    for (var result in results) {
      voteResults[result['partyId']] = result['voteCount'];
    }
    return voteResults;
  }

  Future<void> close() async {
    final Database db = await database;
    db.close();
  }
}
