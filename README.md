# 📱 FitTracker – Ứng dụng theo dõi sức khỏe thông minh 💪

## 🧭 Giới thiệu

**FitTracker** là một ứng dụng sức khỏe di động chạy trên nền tảng **Android**, giúp người dùng quản lý và cải thiện sức khỏe một cách khoa học và hiệu quả. Ứng dụng hỗ trợ:

- Tính chỉ số **BMI**, **TDEE**.
- Gợi ý lộ trình phù hợp: **Tăng cân**, **Giảm cân**, **Giữ cân**.
- Theo dõi lượng **calo**, **dinh dưỡng**, **nước uống** mỗi ngày.
- Ghi log các bữa ăn: **Breakfast**, **Lunch**, **Dinner**.
- Hiển thị biểu đồ tiến độ **cân nặng** và **dinh dưỡng**.
- Nhắc nhở thông minh: log meal, uống nước, cập nhật cân nặng định kỳ.

---

## 🧱 Cấu trúc thư mục

```bash
lib/
├── models/
│   ├── food_base.dart          # Lớp trừu tượng chung cho Food/WaterLog.
│   ├── food.dart               # Model món ăn, kế thừa từ FoodBase.
│   ├── water_log.dart          # Model lượng nước uống, kế thừa từ FoodBase.
│   ├── meal.dart               # Model cho một bữa ăn: thời gian, danh sách món.
│   └── user.dart               # (Tuỳ chọn) Thông tin người dùng: tên, giới tính, tuổi, chiều cao, cân nặng.

├── screens/
│   ├── initial_screen/
│   │   ├── page1.dart → page8.dart   # Các bước nhập thông tin ban đầu.
│   │   └── page9.dart                # Màn hình loading xử lý thông tin đầu vào.
│   └── active_screen/
│       ├── journal/
│       │   ├── food_search_screen.dart     # Tìm món ăn theo tên/loại.
│       │   ├── meal_summary_screen.dart    # Xem lại món đã chọn, xác nhận bữa ăn.
│       │   └── journal_screen.dart         # Hiển thị nhật ký ăn uống theo ngày.
│       └── profile/
│           └── profile.dart                # Thông tin hồ sơ người dùng.

├── services/
│   ├── database_service.dart    # Khởi tạo và quản lý SQLite: tạo bảng, mở DB, truy vấn cơ bản.
│   ├── food_service.dart        # Quản lý CRUD món ăn: thêm, xoá, tìm kiếm theo tên.
│   ├── water_log_service.dart   # Quản lý CRUD lượng nước uống.
│   ├── meal_service.dart        # Thêm món vào bữa ăn, thống kê calories, tìm kiếm theo món.
│   ├── user_service.dart        # Lưu, cập nhật, lấy thông tin người dùng.
│   └── storage_service.dart     # (Tuỳ chọn) Lưu thông tin vào local hoặc nền tảng đám mây.

├── utils/
│   ├── constants.dart           # Các giá trị hằng số dùng toàn app: màu sắc, mức calo, ID mặc định,...
│   └── helpers.dart             # Hàm tiện ích: tính toán BMI, TDEE, chuyển đổi đơn vị, định dạng ngày...

├── widgets/
│   ├── food_item.dart           # Widget hiển thị 1 món ăn trong danh sách.
│   └── meal_item.dart           # Widget hiển thị 1 bữa ăn: tên, tổng calo, các món đi kèm.

└── main.dart                    # Điểm khởi chạy app: cấu hình Theme, Routes, Home screen,...

