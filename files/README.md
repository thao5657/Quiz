# 🏍️ Ứng dụng Ôn thi GPLX A1

Ứng dụng Flutter giúp ôn luyện thi giấy phép lái xe hạng A1 theo chuẩn đề thi Việt Nam.

## Tính năng

- **Thi thử**: 25 câu, 19 phút, hệ thống điểm liệt
- **Luyện tập**: Xem đáp án và giải thích ngay sau mỗi câu  
- **Theo chủ đề**: Ôn theo từng chủ đề (biển báo, quy tắc, kỹ thuật...)
- **Lịch sử thi**: Theo dõi tiến độ học tập

## Cài đặt và chạy

### Yêu cầu
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio hoặc VS Code

### Chạy ứng dụng

```bash
# Clone hoặc copy project này
cd gplx_a1

# Cài dependencies
flutter pub get

# Chạy trên thiết bị/giả lập
flutter run

# Build APK
flutter build apk --release
```

## Cấu trúc project

```
lib/
├── main.dart                 # Entry point
├── data/
│   ├── questions.dart        # Ngân hàng 600 câu hỏi
│   └── app_theme.dart        # Theme và constants
├── models/
│   ├── question.dart         # Model câu hỏi
│   └── exam_result.dart      # Model kết quả thi
└── screens/
    ├── home_screen.dart      # Màn hình chính
    ├── exam_screen.dart      # Thi thử
    ├── result_screen.dart    # Kết quả thi
    ├── practice_screen.dart  # Luyện tập
    ├── topic_screen.dart     # Chọn chủ đề
    └── history_screen.dart   # Lịch sử
```

## Quy tắc thi GPLX A1

| Tiêu chí | Giá trị |
|----------|---------|
| Số câu | 25 câu |
| Thời gian | 19 phút |
| Điểm đạt | ≥ 21/25 câu (84%) |
| Câu điểm liệt | Sai 1 câu = Trượt ngay |

## Thêm câu hỏi

Chỉnh sửa file `lib/data/questions.dart` để thêm câu hỏi mới:

```dart
Question(
  id: 999,
  content: 'Nội dung câu hỏi?',
  options: ['Đáp án A', 'Đáp án B', 'Đáp án C', 'Đáp án D'],
  correctIndex: 0,  // index của đáp án đúng (0=A, 1=B, 2=C, 3=D)
  explanation: 'Giải thích đáp án đúng.',
  category: 'Biển báo',  // hoặc chủ đề khác
  isCritical: false,     // true nếu là câu điểm liệt
),
```
