import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import 'quiz_screen.dart';

class JoinSessionScreen extends StatefulWidget {
  @override
  _JoinSessionScreenState createState() => _JoinSessionScreenState();
}

class _JoinSessionScreenState extends State<JoinSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionCodeController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Session'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                          SizedBox(width: 10),
                          Text(
                            'How to Join',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '1. Get the Session ID from the host\n'
                        '2. Enter your username\n'
                        '3. Tap "Join Session"\n'
                        '4. Start answering questions!',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Session code field
              TextFormField(
                controller: _sessionCodeController,
                decoration: InputDecoration(
                  labelText: 'Session ID',
                  hintText: 'e.g., A1B2C3D4E5',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter session ID';
                  }
                  if (value.length != 10) {
                    return 'Session ID must be 10 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.characters,
              ),
              
              SizedBox(height: 20),
              
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Your Username',
                  hintText: 'e.g., Maria_Student',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  if (value.length < 3 || value.length > 30) {
                    return 'Username must be 3-30 characters';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 30),
              
              // Join button
              ElevatedButton(
                onPressed: _isLoading ? null : _joinSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'JOIN SESSION',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              
              SizedBox(height: 20),
              
              // Help card
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.blue.shade700),
                          SizedBox(width: 10),
                          Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '• Ask the host for the Session ID\n'
                        '• Make sure you\'re on the same network\n'
                        '• Check for typos in the ID\n'
                        '• Contact host if session is full',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _joinSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final sessionCode = _sessionCodeController.text.toUpperCase();
      final username = _usernameController.text;
      
      // Check if session exists
      final session = await DatabaseService.getSession(sessionCode);
      
      if (session == null) {
        throw Exception('Session not found. Please check the ID.');
      }
      
      // Check participant limit
      final participants = await DatabaseService.getParticipants(sessionCode);
      if (participants.length >= 5) {
        throw Exception('Session is full (max 5 participants)');
      }
      
      // Add participant
      await DatabaseService.addParticipant({
        'id': Uuid().v4(),
        'session_id': sessionCode,
        'username': username,
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      // Navigate to quiz screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            sessionId: sessionCode,
            username: username,
            specialty: session['specialty'],
            difficulty: session['difficulty'],
            scenario: session['scenario'],
            isOwner: false,
          ),
        ),
      );
      
    } catch (e) {
      _showErrorDialog('Failed to join: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('❌ Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _sessionCodeController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
