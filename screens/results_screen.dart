import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ResultsScreen extends StatelessWidget {
  final String sessionId;
  final String questionId;
  
  ResultsScreen({required this.sessionId, required this.questionId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.getAnswers(questionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final answers = snapshot.data ?? [];
          
          if (answers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No answers yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: answers.length,
            itemBuilder: (context, index) {
              final answer = answers[index];
              final isWinner = index == 0;
              
              return Card(
                color: isWinner ? Colors.amber.shade50 : null,
                elevation: isWinner ? 6 : 2,
                margin: EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isWinner)
                                Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                              SizedBox(width: 10),
                              Text(
                                '#${index + 1} ${answer['username']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isWinner ? Colors.amber.shade900 : null,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isWinner ? Colors.amber : Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${answer['similarity_score']?.toStringAsFixed(1) ?? 0}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Answer: ${answer['answer_text']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Words: ${answer['word_count']}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
