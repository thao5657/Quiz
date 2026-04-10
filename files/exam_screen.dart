import 'dart:async';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../data/app_theme.dart';
import '../models/question.dart';
import '../models/exam_result.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<Question> _questions;
  late List<int?> _answers;
  int _currentIndex = 0;
  late DateTime _startTime;
  late Timer _timer;
  int _remainingSeconds = AppConstants.examTimeLimitMinutes * 60;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _questions = generateExam(count: AppConstants.examQuestionCount);
    _answers = List.filled(_questions.length, null);
    _startTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _submitExam();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _submitExam() {
    if (_submitted) return;
    _submitted = true;
    _timer.cancel();

    int correct = 0;
    bool hasCriticalError = false;

    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) {
        correct++;
      } else if (_questions[i].isCritical) {
        hasCriticalError = true;
      }
    }

    final result = ExamResult(
      date: _startTime,
      totalQuestions: _questions.length,
      correctAnswers: correct,
      durationSeconds: AppConstants.examTimeLimitMinutes * 60 - _remainingSeconds,
      passed: correct >= AppConstants.passingScore && !hasCriticalError,
      hasCriticalError: hasCriticalError,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(
        result: result,
        questions: _questions,
        answers: _answers,
      )),
    );
  }

  String get _timerDisplay {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return AppTheme.error;
    if (_remainingSeconds <= 180) return AppTheme.warning;
    return Colors.white;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final answeredCount = _answers.where((a) => a != null).length;

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Thoát bài thi?'),
            content: const Text('Kết quả sẽ không được lưu. Bạn chắc chắn muốn thoát?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          title: Text('Câu ${_currentIndex + 1}/${_questions.length}'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(_timerDisplay, style: TextStyle(
                    color: _timerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: answeredCount / _questions.length,
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
                    if (question.isCritical)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 10),
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
                            Text('Câu điểm liệt', style: TextStyle(
                              color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600,
                            )),
                          ],
                        ),
                      ),

                    // Question
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8, offset: const Offset(0, 2),
                        )],
                      ),
                      child: Text(
                        'Câu ${_currentIndex + 1}: ${question.content}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(question.options.length, (i) {
                      final isSelected = _answers[_currentIndex] == i;
                      return GestureDetector(
                        onTap: () => setState(() => _answers[_currentIndex] = i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppTheme.primary : Colors.grey[100],
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + i),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(question.options[i], style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? AppTheme.primary : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  // Question indicators
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _questions.length,
                      itemBuilder: (context, i) {
                        final isAnswered = _answers[i] != null;
                        final isCurrent = i == _currentIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _currentIndex = i),
                          child: Container(
                            width: 30, height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppTheme.primary
                                  : isAnswered
                                  ? AppTheme.success.withOpacity(0.8)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: (isCurrent || isAnswered) ? Colors.white : Colors.grey[600],
                              ),
                            )),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _currentIndex--),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Trước'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _currentIndex < _questions.length - 1
                            ? ElevatedButton.icon(
                          onPressed: () => setState(() => _currentIndex++),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Câu tiếp'),
                        )
                            : ElevatedButton.icon(
                          onPressed: () => _confirmSubmit(),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: Text('Nộp bài ($answeredCount/${_questions.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSubmit() {
    final unanswered = _answers.where((a) => a == null).length;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nộp bài?'),
        content: Text(unanswered > 0
            ? 'Còn $unanswered câu chưa trả lời. Bạn có chắc muốn nộp bài?'
            : 'Bạn đã trả lời đủ ${_questions.length} câu. Xác nhận nộp bài?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}
