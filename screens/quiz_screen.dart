import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../services/llm_service.dart';
import '../prompts/russian_law_prompts.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final String sessionId;
  final String username;
  final String specialty;
  final String difficulty;
  final String scenario;
  final bool isOwner;
  
  QuizScreen({
    required this.sessionId,
    required this.username,
    required this.specialty,
    required this.difficulty,
    required this.scenario,
    this.isOwner = false,
  });
  
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  
  bool _isLoading = false;
  String? _currentQuestion;
  String? _referenceAnswer;
  int _roundNumber = 1;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Session'),
        backgroundColor: widget.scenario == 'A' ? Colors.blue : Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Session: ${widget.sessionId}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text(
                            widget.difficulty.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getDifficultyColor(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Scenario: ${widget.scenario}'),
                        Text('Round: $_roundNumber'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            if (widget.scenario == 'A') ...[
              // Scenario A: User asks question
              _buildScenarioA(),
            ] else ...[
              // Scenario B: AI asks question
              _buildScenarioB(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildScenarioA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scenario A: You Ask',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your question about Russian Law. Other participants will answer, and AI will evaluate who is closest to the correct answer.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 20),
        
        // Question input
        TextFormField(
          controller: _questionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Your Question (max 50 words)',
            hintText: 'e.g., What is the minimum age for a passport in Russia?',
            border: OutlineInputBorder(),
            counterText: '',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a question';
            }
            final words = value.trim().split(RegExp(r'\s+'));
            if (words.length > 50) {
              return 'Question must be max 50 words';
            }
            return null;
          },
        ),
        
        SizedBox(height: 20),
        
        // Submit question button
        ElevatedButton(
          onPressed: _isLoading ? null : _submitQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('SUBMIT QUESTION', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
  
  Widget _buildScenarioB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_currentQuestion == null) ...[
          // Generate question button
          Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Icon(Icons.smart_toy, size: 60, color: Colors.purple.shade700),
                  SizedBox(height: 15),
                  Text(
                    'Scenario B: AI Asks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AI will generate a question about Russian Law. You and other participants will answer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _generateQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white),
                      SizedBox(width: 10),
                      Text('GENERATE QUESTION', style: TextStyle(fontSize: 16)),
                    ],
                  ),
          ),
        ] else ...[
          // Display question
          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.question_answer, color: Colors.purple.shade700),
                      SizedBox(width: 10),
                      Text(
                        'Question #$_roundNumber',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    _currentQuestion!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Answer input
          TextFormField(
            controller: _answerController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Your Answer (max 20 words)',
              hintText: 'Type your answer here...',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an answer';
              }
              final words = value.trim().split(RegExp(r'\s+'));
              if (words.length > 20) {
                return 'Answer must be max 20 words';
              }
              return null;
            },
          ),
          
          SizedBox(height: 20),
          
          // Submit answer button
          ElevatedButton(
            onPressed: _isLoading ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('SUBMIT ANSWER', style: TextStyle(fontSize: 16)),
          ),
        ],
      ],
    );
  }
  
  Future<void> _generateQuestion() async {
    setState(() => _isLoading = true);
    
    try {
      final question = await LLMService.generateQuestion(
        specialty: widget.specialty,
        difficulty: widget.difficulty,
      );
      
      // Parse JSON response to extract question and answer
      // For MVP, assume format: {"question": "...", "reference_answer": "..."}
      
      setState(() {
        _currentQuestion = question;
        // _referenceAnswer = extractedAnswer;
      });
      
    } catch (e) {
      _showErrorDialog('Failed to generate question: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _submitQuestion() async {
    if (!_validateQuestion()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final questionText = _questionController.text.trim();
      
      // Generate reference answer from LLM
      final referenceAnswer = await LLMService.generateReferenceAnswer(
        question: questionText,
        specialty: widget.specialty,
        difficulty: widget.difficulty,
      );
      
      // Save question to database
      await DatabaseService.saveQuestion({
        'id': Uuid().v4(),
        'session_id': widget.sessionId,
        'round_number': _roundNumber,
        'question_text': questionText,
        'reference_answer': referenceAnswer,
        'question_author': 'user',
        'word_count': questionText.split(RegExp(r'\s+')).length,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Show success and navigate to results
      _showSuccessAndNavigate(referenceAnswer);
      
    } catch (e) {
      _showErrorDialog('Failed to submit: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _submitAnswer() async {
    if (!_validateAnswer()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final answerText = _answerController.text.trim();
      
      // Calculate similarity to reference answer
      final similarity = await LLMService.calculateSimilarity(
        answer1: answerText,
        answer2: _referenceAnswer ?? '',
      );
      
      // Save answer
      await DatabaseService.saveAnswer({
        'id': Uuid().v4(),
        'question_id': 'current_question_id', // Get from DB
        'participant_id': 'current_participant_id',
        'username': widget.username,
        'answer_text': answerText,
        'word_count': answerText.split(RegExp(r'\s+')).length,
        'similarity_score': similarity,
        'submitted_at': DateTime.now().toIso8601String(),
      });
      
      // Check if winner (for single player)
      if (similarity > 50) {
        _showWinDialog(similarity);
      } else {
        _showNotWinDialog(similarity);
      }
      
    } catch (e) {
      _showErrorDialog('Failed to submit: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  bool _validateQuestion() {
    final text = _questionController.text.trim();
    if (text.isEmpty) {
      _showErrorDialog('Please enter a question');
      return false;
    }
    final words = text.split(RegExp(r'\s+'));
    if (words.length > 50) {
      _showErrorDialog('Question must be max 50 words');
      return false;
    }
    return true;
  }
  
  bool _validateAnswer() {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      _showErrorDialog('Please enter an answer');
      return false;
    }
    final words = text.split(RegExp(r'\s+'));
    if (words.length > 20) {
      _showErrorDialog('Answer must be max 20 words');
      return false;
    }
    return true;
  }
  
  void _showSuccessAndNavigate(String referenceAnswer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('✅ Question Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reference Answer:'),
            SizedBox(height: 10),
            SelectableText(
              referenceAnswer,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text('Participants can now answer!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultsScreen(
                    sessionId: widget.sessionId,
                    questionId: 'current',
                  ),
                ),
              );
            },
            child: Text('View Results'),
          ),
        ],
      ),
    );
  }
  
  void _showWinDialog(double score) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('🎉 You Won!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            SizedBox(height: 15),
            Text('Similarity Score: ${score.toStringAsFixed(1)}%'),
            SizedBox(height: 10),
            Text('You guessed correctly (>50%)!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestion = null;
                _answerController.clear();
                _roundNumber++;
              });
            },
            child: Text('Next Round'),
          ),
        ],
      ),
    );
  }
  
  void _showNotWinDialog(double score) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('❌ Not Quite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.orange),
            SizedBox(height: 15),
            Text('Similarity Score: ${score.toStringAsFixed(1)}%'),
            SizedBox(height: 10),
            Text('You need >50% to win. Try again!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestion = null;
                _answerController.clear();
                _roundNumber++;
              });
            },
            child: Text('Next Round'),
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
  
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('How to Play'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scenario A (You Ask):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('1. Enter your question about Russian Law\n'
                  '2. AI generates the correct answer\n'
                  '3. Other participants answer\n'
                  '4. AI compares answers and declares winner\n'),
              SizedBox(height: 15),
              Text(
                'Scenario B (AI Asks):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('1. AI generates a question\n'
                  '2. You and others answer\n'
                  '3. AI compares to correct answer\n'
                  '4. Winner has highest similarity (>50% for single player)\n'),
              SizedBox(height: 15),
              Text(
                'Rules:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('• Questions: max 50 words\n'
                  '• Answers: max 20 words\n'
                  '• Reference: max 10 words\n'
                  '• Max 5 participants per session'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }
}
