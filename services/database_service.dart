import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  
  static Future<void> initialize() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'quizllm.db'),
      onCreate: (db, version) async {
        // Sessions table
        await db.execute('''
          CREATE TABLE sessions(
            id TEXT PRIMARY KEY,
            session_code TEXT NOT NULL,
            specialty TEXT NOT NULL,
            difficulty TEXT NOT NULL,
            scenario TEXT NOT NULL,
            owner_username TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT DEFAULT 'active'
          )
        ''');
        
        // Participants table
        await db.execute('''
          CREATE TABLE participants(
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            username TEXT NOT NULL,
            joined_at TEXT NOT NULL,
            FOREIGN KEY(session_id) REFERENCES sessions(id)
          )
        ''');
        
        // Questions table
        await db.execute('''
          CREATE TABLE questions(
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            round_number INTEGER NOT NULL,
            question_text TEXT NOT NULL,
            reference_answer TEXT NOT NULL,
            question_author TEXT NOT NULL,
            word_count INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY(session_id) REFERENCES sessions(id)
          )
        ''');
        
        // Answers table
        await db.execute('''
          CREATE TABLE answers(
            id TEXT PRIMARY KEY,
            question_id TEXT NOT NULL,
            participant_id TEXT NOT NULL,
            username TEXT NOT NULL,
            answer_text TEXT NOT NULL,
            word_count INTEGER NOT NULL,
            similarity_score REAL,
            submitted_at TEXT NOT NULL,
            FOREIGN KEY(question_id) REFERENCES questions(id),
            FOREIGN KEY(participant_id) REFERENCES participants(id)
          )
        ''');
        
        // Results table
        await db.execute('''
          CREATE TABLE results(
            id TEXT PRIMARY KEY,
            question_id TEXT NOT NULL,
            winner_participant_id TEXT,
            winner_type TEXT,
            winning_score REAL,
            created_at TEXT NOT NULL,
            FOREIGN KEY(question_id) REFERENCES questions(id)
          )
        ''');
      },
      version: 1,
    );
  }
  
  static Database get database {
    if (_database == null) {
      throw Exception('Database not initialized');
    }
    return _database!;
  }
  
  // Session CRUD operations
  static Future<void> createSession(Map<String, dynamic> session) async {
    await database.insert('sessions', session);
  }
  
  static Future<Map<String, dynamic>?> getSession(String sessionId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return maps.isNotEmpty ? maps.first : null;
  }
  
  // Participant operations
  static Future<void> addParticipant(Map<String, dynamic> participant) async {
    await database.insert('participants', participant);
  }
  
  static Future<List<Map<String, dynamic>>> getParticipants(String sessionId) async {
    return await database.query(
      'participants',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
  
  // Question operations
  static Future<void> saveQuestion(Map<String, dynamic> question) async {
    await database.insert('questions', question);
  }
  
  // Answer operations
  static Future<void> saveAnswer(Map<String, dynamic> answer) async {
    await database.insert('answers', answer);
  }
  
  static Future<List<Map<String, dynamic>>> getAnswers(String questionId) async {
    return await database.query(
      'answers',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'similarity_score DESC',
    );
  }
  
  // Result operations
  static Future<void> saveResult(Map<String, dynamic> result) async {
    await database.insert('results', result);
  }
}
