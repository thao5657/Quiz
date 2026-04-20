# Tuần 3 – Thiết kế Backend: API / Function

**Sinh viên:** Nguyễn Đức Thiện &nbsp;│&nbsp; **Ứng dụng:** Ôn thi GPLX A1 &nbsp;│&nbsp; **Ngôn ngữ:** Dart / Flutter &nbsp;│&nbsp; **DB:** SQLite (sqflite_ffi)

---

## Phần 1 – Danh sách API / Function chính

| STT | Nhóm | Tên Function/Method | Mô tả | Giao diện dùng | Tầng gọi | Loại |
|-----|------|---------------------|-------|----------------|----------|------|
| 1 | **ExamResultService** | `saveResult(result)` | Lưu kết quả thi vào SQLite | ResultScreen | Service → DB | **Ghi** |
| 2 | **ExamResultService** | `getAllResults()` | Lấy toàn bộ lịch sử thi (mới nhất trước) | HistoryScreen | Service → DB | **Đọc** |
| 3 | **ExamResultService** | `getResultsByMode(mode)` | Lọc kết quả theo mode thi/luyện tập | HistoryScreen | Service | **Đọc** |
| 4 | **ExamResultService** | `getResultsByTopic(topic)` | Lọc kết quả theo chủ đề | HistoryScreen | Service | **Đọc** |
| 5 | **ExamResultService** | `getStats()` | Thống kê tổng quan: tỉ lệ đậu, điểm TB, điểm cao nhất | HistoryScreen | Service | **Đọc** |
| 6 | **ExamResultService** | `clearAllResults()` | Xóa toàn bộ lịch sử thi | HistoryScreen | Service → DB | **Xóa** |
| 7 | **QuestionService** | `addQuestion(question)` | Thêm câu hỏi mới (có validation) | AdminAddEditScreen | Service → DB | **Ghi** |
| 8 | **QuestionService** | `getAllQuestions()` | Lấy tất cả câu hỏi từ SQLite | AdminScreen, ExamScreen | Service → DB | **Đọc** |
| 9 | **QuestionService** | `getQuestionsByTopic(topic)` | Lấy câu hỏi theo chủ đề cụ thể | PracticeScreen, TopicScreen | Service → DB | **Đọc** |
| 10 | **QuestionService** | `searchQuestions(keyword)` | Tìm kiếm theo từ khóa trong nội dung câu | AdminScreen | Service → DB | **Đọc** |
| 11 | **QuestionService** | `getTotalCount()` | Đếm tổng số câu hỏi | HomeScreen, AdminScreen | Service → DB | **Đọc** |
| 12 | **QuestionService** | `getDistinctTopics()` | Danh sách chủ đề không trùng, sắp xếp A-Z | TopicScreen | Service | **Đọc** |
| 13 | **QuestionService** | `getCriticalQuestions()` | Câu hỏi điểm liệt (isCritical = true) | ExamScreen | Service | **Đọc** |
| 14 | **QuestionService** | `updateQuestion(question)` | Cập nhật nội dung câu hỏi | AdminAddEditScreen | Service → DB | **Sửa** |
| 15 | **QuestionService** | `deleteQuestion(id)` | Xóa một câu hỏi theo id | AdminScreen | Service → DB | **Xóa** |
| 16 | **QuestionService** | `deleteAllQuestions()` | Xóa toàn bộ câu hỏi trong DB | AdminScreen | Service → DB | **Xóa** |
| 17 | **QuestionService** | `seedFromQuestionBank(questions)` | Import câu hỏi từ QuestionBank tĩnh vào SQLite | HomeScreen (init) | Service → DB | **Ghi** |

---

## Phần 2 – Thiết kế chi tiết từng Function (Input · Output · Database · Caller · Error Handling)

> ⚠ *Cột Input/Output dùng kiểu Dart thực tế từ source code. Cột DB là câu SQL tương đương logic trong DatabaseHelper.*

| Tên Function | Input (tham số đầu vào) | Output (kết quả trả về) | Thao tác Database | Nơi gọi (Caller) | Xử lý lỗi |
|---|---|---|---|---|---|
| **saveResult** *(ExamResultService)* | `ExamResult {`<br>`  date: DateTime`<br>`  totalQuestions: int`<br>`  correctAnswers: int`<br>`  timeTakenSeconds: int`<br>`  passed: bool`<br>`  failedCritical: bool`<br>`  questionResults: List`<br>`  mode: String` // 'exam' \| 'practice'<br>`  topic: String?` // null nếu thi toàn bộ<br>`}` | `Future<int>`<br>Trả về id tự tăng (>0)<br>nếu insert thất bại → ném exception | **Bảng:** `exam_results`<br>`INSERT INTO exam_results (date, totalQuestions, correctAnswers, timeTakenSeconds, passed, failedCritical, mode, topic) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`<br>Mapping: `passed` → int (1/0), `failedCritical` → int (1/0), `date` → ISO-8601 String, `topic` → nullable TEXT | `ResultScreen._saveResult()` gọi ngay khi màn hình khởi tạo | Không ném lỗi khi duplicate vì mỗi lần nộp bài là 1 record mới |
| **getAllResults** *(ExamResultService)* | (không có tham số) | `Future<List<ExamResult>>`<br>Danh sách mới nhất trước (ORDER BY id DESC)<br>Trả về `[]` nếu bảng rỗng | **Bảng:** `exam_results`<br>`SELECT * FROM exam_results ORDER BY id DESC`<br>Mapping ngược: `passed: (int)==1 → bool`, `failedCritical: (int)==1 → bool`, `date: String → DateTime.parse()` | `HistoryScreen._loadHistory()` | — |
| **getResultsByMode** *(ExamResultService)* | `String mode`<br>// 'exam' → chế độ thi chính thức<br>// 'practice' → chế độ ôn luyện | `Future<List<ExamResult>>`<br>Chỉ trả về record có `mode == tham số`<br>Lọc in-memory sau khi `getAllExamResults()` | Không query trực tiếp<br>Gọi `getAllExamResults()` → filter:<br>`all.where((r) => r.mode == mode)` | `HistoryScreen` (filter tab) | Không validate giá trị mode → trả `[]` nếu mode không khớp |
| **getResultsByTopic** *(ExamResultService)* | `String topic`<br>// Tên chủ đề, ví dụ:<br>// 'Khái niệm và quy tắc giao thông'<br>// 'Biển báo hiệu đường bộ' | `Future<List<ExamResult>>`<br>Kết quả ôn luyện theo chủ đề đó<br>Lọc in-memory từ toàn bộ bảng | Không query trực tiếp<br>Gọi `getAllExamResults()` → filter:<br>`all.where((r) => r.topic == topic)` | `HistoryScreen` (filter theo chủ đề) | Không throw nếu topic không tồn tại → trả `[]` |
| **getStats** *(ExamResultService)* | (không có tham số) | `Future<ExamStats>`<br>`ExamStats {`<br>`  totalAttempts: int`<br>`  examAttempts: int`<br>`  passedExams: int`<br>`  failedExams: int`<br>`  passRate: double`<br>`  averageScore: double`<br>`  bestScore: double`<br>`}`<br>Nếu chưa có dữ liệu → `ExamStats.empty()` (tất cả = 0) | `SELECT * FROM exam_results`<br>Tính toán in-memory:<br>`examOnly = filter mode=='exam'`<br>`passed = examOnly.where(r.passed)`<br>`passRate = passed/totalExam * 100`<br>`avgScore = sum(percentage) / all.length`<br>`bestScore = all.map(percentage).max()` | `HistoryScreen` (hiển thị thống kê đầu trang) | Trả `ExamStats.empty()` thay vì throw khi chưa có dữ liệu |
| **clearAllResults** *(ExamResultService)* | (không có tham số) | `Future<int>`<br>Số hàng bị xóa (>= 0)<br>0 nếu bảng đã rỗng | `DELETE FROM exam_results`<br>Xóa toàn bộ, không có WHERE<br>Không cascade sang bảng khác | `HistoryScreen._clearHistory()` sau khi user xác nhận dialog | — |
| **addQuestion** *(QuestionService)* | `QuestionDB {`<br>`  id: null` // auto-increment<br>`  text: String` // nội dung (≠ rỗng)<br>`  options: List<String>` // đúng 4 đáp án (≠ rỗng)<br>`  correctIndex: int` // 0–3<br>`  explanation: String?`<br>`  isCritical: bool`<br>`  topic: String` // (≠ rỗng)<br>`  imagePath: String?`<br>`}` | `Future<int>`<br>id mới được INSERT vào DB (> 0)<br>Ném `ArgumentError` nếu vi phạm:<br>- text rỗng<br>- options.length != 4<br>- options có phần tử rỗng<br>- correctIndex ngoài 0–3<br>- topic rỗng | **Bảng:** `questions`<br>`INSERT INTO questions (text, option0, option1, option2, option3, correctIndex, explanation, isCritical, topic, imagePath) VALUES (?,?,?,?,?,?,?,?,?,?)`<br>`conflictAlgorithm: REPLACE`<br>`isCritical` lưu int (1/0) | `AdminAddEditScreen._save()` (Add mode) | Throw `ArgumentError` trước khi INSERT, không để lỗi xuống DB |
| **getAllQuestions** *(QuestionService)* | (không có tham số) | `Future<List<QuestionDB>>`<br>Sắp xếp theo id ASC<br>Trả `[]` nếu bảng rỗng | `SELECT * FROM questions ORDER BY id ASC` | `AdminScreen._loadQuestions()`<br>`ExamScreen._loadQuestions()` | — |
| **getQuestionsByTopic** *(QuestionService)* | `String topic`<br>// Tên chủ đề cụ thể (≠ rỗng)<br>// Ném `ArgumentError` nếu `topic.trim().isEmpty` | `Future<List<QuestionDB>>`<br>Câu hỏi thuộc chủ đề đó, ORDER BY id ASC<br>Trả `[]` nếu không tìm thấy | `SELECT * FROM questions WHERE topic = ? ORDER BY id ASC` | `PracticeScreen._loadQuestions()`<br>`TopicScreen` (đếm số câu/chủ đề) | Throw `ArgumentError` nếu topic rỗng |
| **searchQuestions** *(QuestionService)* | `String keyword`<br>// Từ khóa tìm kiếm trong nội dung câu hỏi<br>// Nếu `keyword.trim().isEmpty` → trả tất cả câu | `Future<List<QuestionDB>>`<br>Câu hỏi chứa keyword trong field 'text'<br>Không phân biệt hoa/thường (LIKE %?%) | `SELECT * FROM questions WHERE text LIKE '%keyword%' ORDER BY id ASC`<br>keyword được `trim()` trước khi query | `AdminScreen` (ô tìm kiếm, onChange) | Không throw; keyword rỗng → `getAllQuestions()` |
| **getTotalCount** *(QuestionService)* | (không có tham số) | `Future<int>`<br>Tổng số câu hỏi trong bảng questions<br>0 nếu bảng rỗng | `SELECT COUNT(*) FROM questions`<br>Dùng `Sqflite.firstIntValue(result)` | `HomeScreen` (hiển thị số câu)<br>`AdminScreen` (thanh trạng thái) | — |
| **getDistinctTopics** *(QuestionService)* | (không có tham số) | `Future<List<String>>`<br>Danh sách tên chủ đề không trùng<br>Sắp xếp A-Z<br>Trả `[]` nếu DB rỗng | `SELECT * FROM questions`<br>→ `map(q.topic).toSet().toList()..sort()`<br>(Lọc + sắp xếp in-memory, không dùng DISTINCT trong SQL) | `TopicScreen._loadTopics()` | — |
| **getCriticalQuestions** *(QuestionService)* | (không có tham số) | `Future<List<QuestionDB>>`<br>Câu hỏi có `isCritical == true`<br>Dùng để đảm bảo bài thi có ≥1 câu điểm liệt | `SELECT * FROM questions`<br>→ filter in-memory:<br>`all.where((q) => q.isCritical)` | `ExamScreen._loadQuestions()` (logic ưu tiên câu điểm liệt) | Trả `[]` nếu không có câu điểm liệt |
| **updateQuestion** *(QuestionService)* | `QuestionDB {`<br>`  id: int` (bắt buộc, ≠ null)<br>`  text, options[4],`<br>`  correctIndex, explanation,`<br>`  isCritical, topic, imagePath`<br>`}`<br>// Throw `ArgumentError` nếu id == null<br>// Validation giống `addQuestion` | `Future<int>`<br>Số hàng được cập nhật<br>1 nếu thành công, 0 nếu id không tồn tại | `UPDATE questions SET text=?, option0=?, ... WHERE id = ?` | `AdminAddEditScreen._save()` (Edit mode) | Throw `ArgumentError` nếu id null hoặc vi phạm validation |
| **deleteQuestion** *(QuestionService)* | `int id`<br>// id của câu hỏi cần xóa<br>// Throw `ArgumentError` nếu id <= 0 | `Future<int>`<br>1 nếu xóa thành công<br>0 nếu id không tồn tại trong DB | `DELETE FROM questions WHERE id = ?` | `AdminScreen._deleteQuestion()` sau khi user xác nhận | Throw `ArgumentError` nếu id <= 0 |
| **deleteAllQuestions** *(QuestionService)* | (không có tham số) | `Future<int>`<br>Số hàng bị xóa (>= 0) | `DELETE FROM questions` | `AdminScreen` | — |
| **seedFromQuestionBank** *(QuestionService)* | `List<Question> questions`<br>// Danh sách câu hỏi tĩnh từ QuestionBank<br>// Không làm gì nếu `questions.isEmpty` | `Future<void>`<br>Không trả về giá trị<br>Dùng INSERT OR IGNORE (batch)<br>→ câu đã có trong DB không bị ghi đè | Batch INSERT:<br>`INSERT OR IGNORE INTO questions (text, option0-3, correctIndex, explanation, isCritical, topic, imagePath)`<br>Dùng `db.batch() + commit(noResult:true)` → hiệu quả hơn INSERT từng câu | `AdminScreen._seedData()`<br>`HomeScreen` (init lần đầu mở app) | Bỏ qua câu trùng (IGNORE), không throw |

---

## Phần 3 – Cấu trúc Model trả về: ExamStats

> ⚠ *ExamStats được trả về bởi `getStats()`. Tất cả trường là readonly, tính toán in-memory từ bảng `exam_results`.*

| Trường | Kiểu | Giá trị | Mô tả |
|--------|------|---------|-------|
| `totalAttempts` | `int` | ≥ 0 | Tổng số lượt thực hiện (thi chính thức + ôn luyện) |
| `examAttempts` | `int` | ≥ 0 | Số lượt thi chính thức (mode == 'exam') |
| `passedExams` | `int` | ≥ 0 | Số lần đạt trong các lần thi chính thức |
| `failedExams` | `int` | ≥ 0 | Số lần chưa đạt = examAttempts - passedExams |
| `passRate` | `double` | 0.0–100.0 | Tỉ lệ đậu (%) = passedExams / examAttempts × 100 |
| `averageScore` | `double` | 0.0–100.0 | Điểm trung bình (%) = sum(percentage) / all.length |
| `bestScore` | `double` | 0.0–100.0 | Điểm cao nhất (%) trong toàn bộ lịch sử |
