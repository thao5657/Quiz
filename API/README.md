# Thiết kế Backend (API/Function)

## 1. Bảng mô tả danh sách API/Function chính

| STT | Tên Function | Màn hình sử dụng | Mô tả chức năng |
|-----|-------------|------------------|-----------------|
| 1 | `getExamQuestions()` | ExamScreen (Thi thử) | Truy xuất ngẫu nhiên 25 câu hỏi từ ngân hàng dữ liệu để tạo thành một đề thi hoàn chỉnh |
| 2 | `getByTopic(topic)` | PracticeScreen (Luyện tập theo chủ đề) | Lọc và lấy toàn bộ danh sách câu hỏi theo một chủ đề cụ thể |
| 3 | `getTopics()` | TopicScreen (Danh sách chủ đề) | Trả về danh sách tất cả các chủ đề hiện có trong ngân hàng đề thi |
| 4 | `submitExam(answers)` | ExamScreen → ResultScreen | Nhận câu trả lời, chấm điểm, đếm số câu đúng, kiểm tra điểm liệt và xác định kết quả cuối cùng |
| 5 | `saveExamResult(result)` | ResultScreen | Lưu trữ kết quả thi vào bộ nhớ máy (SharedPreferences) |
| 6 | `loadExamHistory()` | HistoryScreen (Lịch sử thi) | Đọc dữ liệu từ bộ nhớ thiết bị và trả về danh sách các lần thi trước đó |
| 7 | `clearExamHistory()` | HistoryScreen (Lịch sử thi) | Xóa toàn bộ dữ liệu lịch sử thi đã lưu trên thiết bị |

### Mô tả các Function

**`getExamQuestions()`**: Chức năng này có nhiệm vụ truy xuất ngẫu nhiên 25 câu hỏi từ ngân hàng dữ liệu để tạo thành một đề thi hoàn chỉnh. Hàm này được sử dụng chính tại màn hình ExamScreen (Thi thử).

**`getByTopic(topic)`**: Cho phép lọc và lấy toàn bộ danh sách câu hỏi theo một chủ đề cụ thể (tham số topic). Chức năng này phục vụ cho màn hình PracticeScreen (Luyện tập theo chủ đề), giúp người dùng tập trung ôn tập mảng kiến thức nhất định.

**`getTopics()`**: Hàm này trả về danh sách tất cả các chủ đề hiện có trong ngân hàng đề thi, hiển thị tại màn hình TopicScreen (Danh sách chủ đề) để người dùng lựa chọn trước khi luyện tập.

**`submitExam(answers)`**: Đây là hàm xử lý logic quan trọng nhất. Nó sẽ nhận vào danh sách câu trả lời của người dùng, thực hiện chấm điểm, đếm số câu đúng, kiểm tra các câu điểm liệt và xác định kết quả cuối cùng. Chức năng này điều hướng người dùng từ màn hình ExamScreen sang ResultScreen.

**`saveExamResult(result)`**: Sau khi có kết quả, hàm này sẽ thực hiện lưu trữ dữ liệu vào bộ nhớ máy (sử dụng SharedPreferences). Việc lưu trữ diễn ra tại màn hình ResultScreen để đảm bảo người dùng có thể xem lại lịch sử sau này.

**`loadExamHistory()`**: Chức năng này đọc dữ liệu từ bộ nhớ thiết bị và trả về danh sách các lần thi trước đó của người dùng. Dữ liệu này được trình bày tại màn hình HistoryScreen (Lịch sử thi).

**`clearExamHistory()`**: Cho phép người dùng dọn dẹp và xóa toàn bộ dữ liệu lịch sử thi đã lưu trên thiết bị khi có nhu cầu, thao tác trực tiếp tại màn hình HistoryScreen.

> **Luồng hoạt động:** Người dùng chọn chủ đề (`getTopics`) → Luyện tập (`getByTopic`) hoặc Thi thử (`getExamQuestions`) → Gửi bài và chấm điểm (`submitExam`) → Lưu kết quả (`saveExamResult`) → Xem lại hoặc xóa lịch sử (`loadExamHistory` / `clearExamHistory`).

---

## 2. Bảng thiết kế chi tiết từng API/Function

| STT | Tên Function | Đầu vào | Đầu ra | Lưu trữ |
|-----|-------------|---------|--------|---------|
| 1 | `getExamQuestions()` | Không có | `List<Question>` — 25 câu hỏi ngẫu nhiên | Không |
| 2 | `getByTopic(topic)` | `String topic` — tên chủ đề cần lọc | `List<Question>` — danh sách câu hỏi theo chủ đề | Không |
| 3 | `getTopics()` | Không có | `List<String>` — danh sách tên các chủ đề | Không |
| 4 | `submitExam(answers)` | Danh sách câu hỏi kèm câu trả lời của người dùng | `ExamResult` (gồm `correctAnswers: int`, ...) | Chỉ tính toán tức thời trên bộ nhớ, không lưu DB |
| 5 | `saveExamResult(result)` | `ExamResult` — đối tượng kết quả thi | Trạng thái thành công / thất bại | Chuyển sang JSON, lưu vào SharedPreferences (key: `exam_history`), tối đa 50 bản ghi |
| 6 | `loadExamHistory()` | Không có | `List<ExamResult>` — danh sách kết quả đã lưu | Đọc từ SharedPreferences, giải mã từ chuỗi JSON |
| 7 | `clearExamHistory()` | Không có (cần xác nhận người dùng) | `void` | Thực hiện `remove(key)` để xóa sạch lịch sử trên thiết bị |

### Mô tả chi tiết

**`getExamQuestions()`**
- **Đầu vào:** Không có.
- **Đầu ra:** Trả về một danh sách (`List<Question>`) gồm 25 câu hỏi được chọn ngẫu nhiên.

**`getByTopic(topic)`**
- **Đầu vào:** Một chuỗi văn bản (`String`) là tên chủ đề cần lọc.
- **Đầu ra:** Danh sách các câu hỏi thuộc về chủ đề đó.

**`getTopics()`**
- **Đầu vào:** Không có.
- **Đầu ra:** Một danh sách các chuỗi (`List<String>`) chứa tên của tất cả các chủ đề hiện có.

**`submitExam(answers)`**
- **Đầu vào:** Danh sách các câu hỏi kèm câu trả lời của người dùng.
- **Đầu ra:** Một đối tượng `ExamResult` chứa thông tin như số câu đúng (`correctAnswers: int`).
- **Lưu trữ:** Hàm này không lưu vào Database mà chỉ tính toán tức thời trên bộ nhớ.

> Các hàm dưới đây tương tác trực tiếp với thiết bị thông qua SharedPreferences với key định danh là `'exam_history'`.

**`saveExamResult(result)`**
- **Đầu vào:** Đối tượng kết quả thi (`ExamResult`).
- **Đầu ra:** Trả về trạng thái thành công hoặc thất bại.
- **Lưu trữ:** Chuyển đổi dữ liệu sang định dạng JSON và lưu vào máy. Hệ thống giới hạn tối đa 50 bản ghi gần nhất.

**`loadExamHistory()`**
- **Đầu vào:** Không có.
- **Đầu ra:** Danh sách các kết quả thi đã lưu (`List<ExamResult>`).
- **Lưu trữ:** Đọc từ SharedPreferences và giải mã từ chuỗi JSON.

**`clearExamHistory()`**
- **Đầu vào:** Không có (nhưng cần yêu cầu người dùng xác nhận trước khi thực hiện).
- **Đầu ra:** Trả về trạng thái trống (`void`) sau khi xóa.
- **Lưu trữ:** Thực hiện thao tác `remove(key)` để xóa sạch lịch sử thi trên thiết bị.