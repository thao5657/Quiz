import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../data/app_theme.dart';
import '../models/question.dart';

class PracticeScreen extends StatefulWidget {
  final String? category;
  const PracticeScreen({super.key, this.category});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _questions = questionBank.where((q) => q.category == widget.category).toList()..shuffle();
    } else {
      _questions = List.from(questionBank)..shuffle();
    }
  }

  Question get _current => _questions[_currentIndex];

  void _answer(int index) {
    if (_answered) return;
    final isCorrect = index == _current.correctIndex;
    if (isCorrect) _correctCount++;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Hoàn thành!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn đã trả lời đúng $_correctCount/${_questions.length} câu',
              style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tỉ lệ: ${(_correctCount / _questions.length * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Về trang chủ')),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
            setState(() {
              _questions.shuffle();
              _currentIndex = 0;
              _selectedAnswer = null;
              _answered = false;
              _correctCount = 0;
            });
          }, child: const Text('Luyện lại')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(widget.category ?? 'Luyện tập tất cả'),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '$_correctCount/${_currentIndex + (_answered ? 1 : 0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(AppTheme.success),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu ${_currentIndex + 1}/${_questions.length}',
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  if (_current.isCritical)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, color: AppTheme.error, size: 14),
                          const SizedBox(width: 4),
                          Text('Câu điểm liệt', style: TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                    ),
                    child: Text(
                      _current.content,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_current.options.length, (i) {
                    Color? bgColor;
                    Color? borderColor;
                    if (_answered) {
                      if (i == _current.correctIndex) {
                        bgColor = AppTheme.success.withOpacity(0.12);
                        borderColor = AppTheme.success;
                      } else if (i == _selectedAnswer) {
                        bgColor = AppTheme.error.withOpacity(0.1);
                        borderColor = AppTheme.error;
                      }
                    } else if (_selectedAnswer == i) {
                      bgColor = AppTheme.primary.withOpacity(0.1);
                      borderColor = AppTheme.primary;
                    }

                    return GestureDetector(
                      onTap: () => _answer(i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bgColor ?? Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor ?? Colors.grey.withOpacity(0.2),
                            width: borderColor != null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: borderColor != null ? borderColor!.withOpacity(0.15) : Colors.grey[100],
                              ),
                              child: Center(child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(fontWeight: FontWeight.bold, color: borderColor ?? Colors.grey[600]),
                              )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_current.options[i], style: const TextStyle(fontSize: 14))),
                            if (_answered && i == _current.correctIndex)
                              Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                            if (_answered && i == _selectedAnswer && i != _current.correctIndex)
                              Icon(Icons.cancel, color: AppTheme.error, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  if (_answered) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 16),
                              SizedBox(width: 6),
                              Text('Giải thích', style: TextStyle(
                                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14,
                              )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_current.explanation, style: const TextStyle(fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_answered)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_currentIndex < _questions.length - 1 ? 'Câu tiếp theo' : 'Xem kết quả'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
