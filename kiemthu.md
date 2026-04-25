# 📋 BÁO CÁO KIỂM THỬ API / FUNCTION
## Kịch bản và Kết quả Kiểm thử

> **Dự án:** Ứng dụng Ôn thi GPLX A1 (Flutter) | **Giai đoạn:** Tuần 4 – Service Layer Testing

| Trường | Nội dung |
|---|---|
| **Tên dự án** | Ứng dụng Ôn thi Giấy phép lái xe Hạng A1 (GPLX A1) |
| **Framework** | Flutter / Dart + SQLite (sqflite_ffi) |
| **Phạm vi kiểm thử** | Unit Test – Service Layer (QuestionService, ExamResultService) |
| **Ngày thực hiện** | 20/04/2026 |
| **Tổng số Test Case** | 34 TC (QuestionService: 20 TC \| ExamResultService: 14 TC) |
| **Tổng kết** | ✅ PASS: 34/34 \| ❌ FAIL: 0/34 \| Tỷ lệ đạt: **100%** |
| **Môi trường chạy test** | `flutter test` – SQLite in-memory (sqflite_ffi) – Không cần thiết bị thật |

---

## 1. KIỂM THỬ `QuestionService`

`QuestionService` cung cấp toàn bộ business logic cho câu hỏi, bao gồm CRUD và các thao tác phân tích dữ liệu. Mọi truy vấn DB đều được định tuyến qua lớp này thay vì truy cập trực tiếp `DatabaseHelper` từ UI.

### 1.1 Bảng kịch bản kiểm thử & kết quả

| Mã TC | Nhóm hàm | Mô tả kịch bản | Dữ liệu đầu vào | Kết quả mong đợi | Kết quả | Ghi chú |
|---|---|---|---|---|:---:|---|
| **TC-Q01** | `addQuestion` | Thêm câu hỏi hợp lệ - trả về id > 0 | QuestionDB hợp lệ (text, 4 options, correctIndex=0, topic="Biển báo") | id trả về là số nguyên dương (> 0) | ✅ PASS | id = 1 |
| **TC-Q02** | `addQuestion` | Thêm câu hỏi - lấy lại đúng nội dung | text = "Tốc độ tối đa trong khu dân cư?" | `getAllQuestions().first.text` == "Tốc độ tối đa trong khu dân cư?" | ✅ PASS | Dữ liệu khớp |
| **TC-Q03** | `addQuestion` | Thêm câu hỏi rỗng nội dung - ném ArgumentError | text = "" (chuỗi rỗng) | Ném `ArgumentError` với message chứa "không được rỗng" | ✅ PASS | Exception đúng loại |
| **TC-Q04** | `addQuestion` | correctIndex ngoài phạm vi (=5) - ném ArgumentError | correctIndex = 5 (hợp lệ: 0-3) | Ném `ArgumentError` | ✅ PASS | Validation đúng |
| **TC-Q05** | `addQuestion` | Chủ đề rỗng - ném ArgumentError | topic = "" | Ném `ArgumentError` | ✅ PASS | Validation đúng |
| **TC-Q06** | `getAllQuestions` | DB rỗng - trả về danh sách trống | Chưa có câu nào trong DB | Danh sách trống (isEmpty = true) | ✅ PASS | list.length = 0 |
| **TC-Q07** | `getAllQuestions` | Thêm 3 câu - trả về đúng 3 câu | Thêm 3 câu hỏi khác nhau | list.length == 3 | ✅ PASS | Đếm chính xác |
| **TC-Q08** | `getQuestionsByTopic` | Lọc đúng chủ đề "Biển báo" | DB có 2 câu: topic="Biển báo" và topic="Quy tắc", lọc "Biển báo" | Trả về 1 câu, text = "Câu A" | ✅ PASS | Lọc chính xác |
| **TC-Q09** | `getQuestionsByTopic` | Chủ đề không tồn tại - trả về rỗng | Tìm topic = "ABCXYZ" không có trong DB | Danh sách trống | ✅ PASS | list.length = 0 |
| **TC-Q10** | `getQuestionsByTopic` | Topic rỗng - ném ArgumentError | topic = "" | Ném `ArgumentError` | ✅ PASS | Validation đúng |
| **TC-Q11** | `updateQuestion` | Cập nhật nội dung câu hỏi thành công | id hợp lệ, text mới = "Câu mới" | `getAllQuestions().first.text` == "Câu mới" | ✅ PASS | Update thành công |
| **TC-Q12** | `updateQuestion` | Update không có id - ném ArgumentError | id = null | Ném `ArgumentError` | ✅ PASS | Null check đúng |
| **TC-Q13** | `deleteQuestion` | Xóa đúng câu theo id | Thêm 2 câu, xóa câu đầu theo id | Còn 1 câu, text = "Giữ lại" | ✅ PASS | Xóa chính xác |
| **TC-Q14** | `deleteQuestion` | id <= 0 - ném ArgumentError | id = 0 | Ném `ArgumentError` | ✅ PASS | Validation đúng |
| **TC-Q15** | `searchQuestions` | Tìm kiếm từ khóa khớp - trả về kết quả | keyword = "tốc độ", DB có 2 câu (1 khớp, 1 không) | Trả về 1 câu chứa "Tốc độ" | ✅ PASS | Tìm kiếm đúng |
| **TC-Q16** | `searchQuestions` | Từ khóa rỗng - trả về tất cả | keyword = "", DB có 2 câu | Trả về 2 câu (toàn bộ danh sách) | ✅ PASS | Fallback đúng |
| **TC-Q17** | `getTotalCount` | Đếm đúng số câu sau khi thêm 4 | Thêm 4 câu hỏi | `getTotalCount()` == 4 | ✅ PASS | Count chính xác |
| **TC-Q18** | `getDistinctTopics` | Không trùng lặp chủ đề | 4 câu: 2 "Biển báo", 1 "Quy tắc", 1 "Biển báo" | 2 chủ đề, không trùng: ["Biển báo","Quy tắc"] | ✅ PASS | Dedup đúng |
| **TC-Q19** | `getCriticalQuestions` | Lọc đúng câu điểm liệt | 3 câu: 1 isCritical=true, 2 isCritical=false | Trả về 1 câu, isCritical = true | ✅ PASS | Flag lọc đúng |
| **TC-Q20** | `deleteAllQuestions` | Xóa toàn bộ - DB trở về rỗng | Thêm 5 câu rồi gọi `deleteAllQuestions()` | `getTotalCount()` == 0 | ✅ PASS | Xóa sạch |

### 1.2 Tổng kết theo nhóm hàm – QuestionService

| Nhóm hàm | Tổng TC | Đạt | Ghi chú |
|---|:---:|:---:|---|
| `addQuestion()` | 5 | 5 | Validate text, options, correctIndex, topic đều đúng |
| `getAllQuestions()` | 2 | 2 | DB rỗng và có dữ liệu đều xử lý chính xác |
| `getQuestionsByTopic()` | 3 | 3 | Lọc đúng topic; topic rỗng ném lỗi; không tìm thấy → trả rỗng |
| `updateQuestion()` | 2 | 2 | Update thành công; null-id ném lỗi đúng |
| `deleteQuestion()` | 2 | 2 | Xóa đúng row; id ≤ 0 ném lỗi đúng |
| `searchQuestions()` | 2 | 2 | Từ khóa khớp; keyword rỗng → fallback getAllQuestions |
| `getTotalCount()` | 1 | 1 | Đếm chính xác sau mỗi lần insert |
| `getDistinctTopics()` | 1 | 1 | Deduplicate và sort() đúng thứ tự |
| `getCriticalQuestions()` | 1 | 1 | Lọc flag isCritical=true chính xác |
| `deleteAllQuestions()` | 1 | 1 | Xóa toàn bộ, count trở về 0 |
| **TỔNG** | **20** | **20** | ✅ 100% |

---

## 2. KIỂM THỬ `ExamResultService`

`ExamResultService` quản lý toàn bộ vòng đời kết quả thi, bao gồm lưu trữ, truy vấn theo mode/topic, thống kê nâng cao và xóa dữ liệu. Service đảm bảo nhất quán dữ liệu với SQLite.

### 2.1 Bảng kịch bản kiểm thử & kết quả

| Mã TC | Nhóm hàm | Mô tả kịch bản | Dữ liệu đầu vào | Kết quả mong đợi | Kết quả | Ghi chú |
|---|---|---|---|---|:---:|---|
| **TC-R01** | `saveResult` | Lưu kết quả thi hợp lệ - trả về id > 0 | ExamResult hợp lệ (22/25, passed=true, mode="exam") | id trả về là số nguyên dương | ✅ PASS | id = 1 |
| **TC-R02** | `saveResult` | Lưu rồi getAllResults - dữ liệu khớp | Lưu kết quả 22/25, passed=true | correctAnswers=22, passed=true | ✅ PASS | Dữ liệu nhất quán |
| **TC-R03** | `saveResult` | Lưu kết quả trượt failedCritical | passed=false, failedCritical=true, correct=20 | failedCritical=true, passed=false | ✅ PASS | Flag đúng |
| **TC-R04** | `saveResult` | Lưu nhiều kết quả - sắp xếp mới nhất trước | Lưu 3 kết quả: correct=10, 15, 20 theo thứ tự | list.first.correctAnswers == 20 (mới nhất trước) | ✅ PASS | ORDER BY đúng |
| **TC-R05** | `getAllResults` | DB rỗng - trả về danh sách trống | Chưa có kết quả nào | Danh sách trống | ✅ PASS | list.length = 0 |
| **TC-R06** | `getResultsByMode` | Lọc theo mode "exam" - trả về 2 | DB: 2 "exam" + 1 "practice", lọc "exam" | Trả về 2 kết quả | ✅ PASS | Lọc mode đúng |
| **TC-R07** | `getResultsByMode` | Lọc theo mode "practice" - trả về 3 | DB: 1 "exam" + 3 "practice", lọc "practice" | Trả về 3 kết quả | ✅ PASS | Lọc mode đúng |
| **TC-R08** | `getResultsByTopic` | Lọc theo chủ đề đúng | DB: 1 topic="Biển báo" + 1 topic=null, lọc "Biển báo" | Trả về 1 kết quả, topic = "Biển báo" | ✅ PASS | Lọc topic đúng |
| **TC-R09** | `getStats` | Stats DB rỗng - tất cả bằng 0 | Chưa có kết quả nào | totalAttempts=0, passRate=0 | ✅ PASS | ExamStats.empty() |
| **TC-R10** | `getStats` | Tính passRate chính xác (66.67%) | 3 lần thi: 2 passed, 1 failed | passRate ≈ 66.67%, passed=2, failed=1 | ✅ PASS | Tính toán đúng |
| **TC-R11** | `getStats` | Tính averageScore chính xác (90%) | 2 kết quả: 20/25 (80%) và 25/25 (100%) | averageScore ≈ 90% | ✅ PASS | Trung bình đúng |
| **TC-R12** | `getStats` | Tính bestScore chính xác (100%) | 3 kết quả: 60%, 80%, 100% | bestScore ≈ 100% | ✅ PASS | Max đúng |
| **TC-R13** | `clearAllResults` | Xóa toàn bộ - DB trở về rỗng | Lưu 5 kết quả rồi `clearAllResults()` | `getAllResults()` trả về [] | ✅ PASS | Xóa sạch |
| **TC-R14** | `clearAllResults` | clearAll trên DB rỗng - không ném lỗi | DB rỗng, gọi `clearAllResults()` | Thực thi bình thường, không exception | ✅ PASS | Idempotent |

### 2.2 Tổng kết theo nhóm hàm – ExamResultService

| Nhóm hàm | Tổng TC | Đạt | Ghi chú |
|---|:---:|:---:|---|
| `saveResult()` | 4 | 4 | Lưu thành công; failedCritical; sort mới nhất trước |
| `getAllResults()` | 1 | 1 | DB rỗng trả về [] đúng |
| `getResultsByMode()` | 2 | 2 | Lọc "exam" và "practice" cả 2 chính xác |
| `getResultsByTopic()` | 1 | 1 | Lọc topic, null-topic không bị mix |
| `getStats()` | 4 | 4 | Empty stats; passRate; averageScore; bestScore tất cả đúng |
| `clearAllResults()` | 2 | 2 | Xóa toàn bộ; clear trên DB rỗng không crash |
| **TỔNG** | **14** | **14** | ✅ 100% |

---

## 3. TỔNG KẾT KIỂM THỬ

| Service | Tổng TC | Đạt (PASS) | Thất bại (FAIL) | Tỷ lệ đạt |
|---|:---:|:---:|:---:|:---:|
| `QuestionService` | 20 | 20 | 0 | **100%** |
| `ExamResultService` | 14 | 14 | 0 | **100%** |
| **TỔNG CỘNG** | **34** | **34** | **0** | **✅ 100%** |

### 3.1 Nhận xét & Đánh giá

✅ Tất cả **34 test case** đều PASS, đạt tỷ lệ **100%**. Không có test case nào FAIL.

**Điểm mạnh của bộ test:**

- **SQLite in-memory** (`sqflite_ffi`): Test hoàn toàn độc lập, không cần thiết bị thật hay emulator.
- **Dependency Injection**: `DatabaseHelper` được inject vào service, dễ mock và tái sử dụng trong test.
- **Bao phủ đầy đủ**: Cả happy path (dữ liệu hợp lệ) và edge case (rỗng, null, out-of-range) đều được kiểm thử.
- **Validation logic**: `ArgumentError` được ném đúng với message rõ ràng cho từng vi phạm.
- **Thống kê nâng cao**: `passRate`, `averageScore`, `bestScore` đều được verify với `closeTo()` chính xác đến 2 chữ số thập phân.

### 3.2 Lệnh chạy kiểm thử

```bash
# Chạy toàn bộ test
flutter test

# Chạy từng file test
flutter test test/services/question_service_test.dart
flutter test test/services/exam_result_service_test.dart
```

---

*Flutter GPLX A1 – Tuần 4 | Ngày tạo: 20/04/2026*