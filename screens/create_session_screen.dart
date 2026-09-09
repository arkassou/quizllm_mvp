import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';

class CreateSessionScreen extends StatefulWidget {
  @override
  _CreateSessionScreenState createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionCodeController = TextEditingController();
  final _usernameController = TextEditingController();
  
  String _selectedSpecialty = 'Законодательство РФ и юриспруденция';
  String _selectedDifficulty = 'easy';
  String _selectedScenario = 'A';
  
  String? _generatedSessionId;
  bool _isLoading = false;
  
  final List<String> _specialties = [
    'Законодательство РФ и юриспруденция',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Session'),
        backgroundColor: Colors.green.shade600,
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
                            'Instructions',
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
                        '1. Enter your username (session owner)\n'
                        '2. Choose specialty and difficulty\n'
                        '3. Select scenario (A or B)\n'
                        '4. Tap "Create Session"\n'
                        '5. Share QR code with participants',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Your Username (Owner)',
                  hintText: 'e.g., Alex_Lawyer',
                  prefixIcon: Icon(Icons.person),
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
              
              SizedBox(height: 20),
              
              // Specialty dropdown
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: InputDecoration(
                  labelText: 'Specialty',
                  border: OutlineInputBorder(),
                ),
                items: _specialties.map((specialty) {
                  return DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value!;
                  });
                },
              ),
              
              SizedBox(height: 20),
              
              // Difficulty dropdown
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: InputDecoration(
                  labelText: 'Difficulty Level',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'easy',
                    child: Row(
                      children: [
                        Icon(Icons.school, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Easy (School Level)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('Medium (Bachelor Level)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'hard',
                    child: Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Hard (Expert Level)'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              
              SizedBox(height: 20),
              
              // Scenario selection
              Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Scenario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      
                      // Scenario A
                      RadioListTile<String>(
                        title: Text('Scenario A'),
                        subtitle: Text('You ask questions, others answer'),
                        value: 'A',
                        groupValue: _selectedScenario,
                        onChanged: (value) {
                          setState(() {
                            _selectedScenario = value!;
                          });
                        },
                        secondary: Icon(Icons.question_answer, color: Colors.blue),
                      ),
                      
                      // Scenario B
                      RadioListTile<String>(
                        title: Text('Scenario B'),
                        subtitle: Text('AI asks questions, you answer'),
                        value: 'B',
                        groupValue: _selectedScenario,
                        onChanged: (value) {
                          setState(() {
                            _selectedScenario = value!;
                          });
                        },
                        secondary: Icon(Icons.smart_toy, color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Create button
              ElevatedButton(
                onPressed: _isLoading ? null : _createSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
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
                          Icon(Icons.add_circle_outline, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'CREATE SESSION',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              
              SizedBox(height: 20),
              
              // QR code display (after creation)
              if (_generatedSessionId != null) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Session Created!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        SizedBox(height: 20),
                        QrImageView(
                          data: _generatedSessionId!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Share this QR code with participants',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Session ID: $_generatedSessionId',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Generate unique session ID
      final sessionId = Uuid().v4();
      
      // Create session in database
      await DatabaseService.createSession({
        'id': sessionId,
        'session_code': sessionId.substring(0, 10).toUpperCase(),
        'specialty': _selectedSpecialty,
        'difficulty': _selectedDifficulty,
        'scenario': _selectedScenario,
        'owner_username': _usernameController.text,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'active',
      });
      
      // Add owner as first participant
      await DatabaseService.addParticipant({
        'id': Uuid().v4(),
        'session_id': sessionId,
        'username': _usernameController.text,
        'joined_at': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _generatedSessionId = sessionId;
      });
      
      // Show success dialog
      _showSuccessDialog(sessionId);
      
    } catch (e) {
      _showErrorDialog('Failed to create session: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSuccessDialog(String sessionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('✅ Session Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Session ID:'),
            SizedBox(height: 5),
            SelectableText(
              sessionId,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Participants can scan the QR code or enter this ID to join.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
