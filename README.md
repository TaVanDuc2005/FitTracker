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
│   ├── food_base.dart              # Lớp trừu tượng chung cho Food/WaterLog.
│   ├── food.dart                   # Model món ăn, kế thừa từ FoodBase.
│   ├── water_log.dart              # Model lượng nước uống, kế thừa từ FoodBase.
│   ├── meal.dart                   # Model cho một bữa ăn: thời gian, danh sách món.
│   ├── user.dart                   # Thông tin người dùng: tên, giới tính, tuổi, chiều cao, cân nặng.
│   ├── bmi_entry.dart              # Lưu giá trị BMI theo thời gian.
│   ├── bmr_entry.dart              # Lưu giá trị BMR.
│   ├── chart_data.dart             # Dữ liệu biểu đồ lịch sử cân nặng hoặc dinh dưỡng.
│   ├── macro_goal_model.dart       # Mục tiêu dinh dưỡng hằng ngày: P/C/F.
│   ├── nutrient_summary.dart       # Tổng hợp macro đã ăn trong ngày.
│   ├── tdee_entry.dart             # Lưu giá trị TDEE đã tính.
│   └── weight_history.dart         # Lịch sử cân nặng để vẽ biểu đồ.

├── screens/
│   ├── initial_screen/
│   │   ├── dietary_restrictions_screen.dart     # Chọn chế độ ăn kiêng/dị ứng.
│   │   ├── enter_name_screen.dart               # Nhập tên người dùng.
│   │   ├── health_goal_screen.dart              # Chọn mục tiêu sức khoẻ: giảm/tăng/cân bằng.
│   │   ├── life_style_screen.dart               # Chọn mức độ vận động.
│   │   ├── list_dietary_restriction_screen.dart # Danh sách dị ứng/diet gợi ý.
│   │   ├── loading_screen.dart                  # Loading khi khởi tạo dữ liệu.
│   │   ├── onboarding_screen.dart               # Hướng dẫn khi vào lần đầu.
│   │   ├── underlying_disease.dart              # Chọn bệnh nền (nếu có).
│   │   ├── user_info_screen.dart                # Nhập thông tin cá nhân (tuổi, chiều cao,...).
│   │   └── welcome_screen.dart                  # Màn hình chào mừng đầu tiên.
│
│   └── active_screen/
│       ├── journal/
│       │   ├── food_search_screen.dart          # Tìm món ăn theo tên/loại.
│       │   ├── meal_summary_screen.dart         # Xem lại món đã chọn, xác nhận bữa ăn.
│       │   ├── journal_screen.dart              # Hiển thị nhật ký ăn uống theo ngày.
│       │   ├── food_detail_screen.dart          # Thông tin chi tiết món ăn + dinh dưỡng.
│       │   └── challenges_water_screen.dart     # Theo dõi lượng nước đã uống.
│
│       └── profile/
│           ├── profile_screen.dart              # Trang hồ sơ người dùng.
│           ├── info_user_screen.dart            # Thông tin cá nhân chi tiết, có thể chỉnh sửa.
│           └── setting_screen.dart              # Tuỳ chọn cài đặt (theme, ngôn ngữ,...).

├── services/
│   ├── database_service.dart         # Khởi tạo và thao tác với SQLite DB.
│   ├── food_service.dart             # Quản lý CRUD món ăn: thêm, xoá, sửa.
│   ├── water_log_service.dart        # CRUD lượng nước uống.
│   ├── meal_service.dart             # Quản lý bữa ăn và các món ăn trong bữa.
│   ├── user_service.dart             # Lưu, cập nhật, lấy thông tin người dùng.
│   ├── storage_service.dart          # (Tuỳ chọn) Lưu trữ trên cloud hoặc local device.
│   ├── bmi_service.dart              # Tính toán và lưu BMI.
│   ├── bmr_service.dart              # Tính toán BMR.
│   ├── tdee_service.dart             # Tính toán TDEE.
│   ├── bmi_tdee_service.dart         # Kết hợp BMI + TDEE nếu cần.
│   ├── macro_goal_service.dart       # Lưu mục tiêu macro (P/C/F).
│   ├── macro_suggestion_service.dart # Gợi ý tỉ lệ macro dựa trên mục tiêu.
│   ├── nutrient_service.dart         # Tổng hợp calories/macro từng ngày.
│   ├── route_chart_service.dart      # Chuẩn bị dữ liệu vẽ biểu đồ dinh dưỡng/cân nặng.
│   └── weight_history_service.dart   # Quản lý và hiển thị lịch sử cân nặng.

├── utils/
│   └── macro_utils.dart              # Tính toán tỉ lệ P/C/F theo % hoặc gram.

├── widgets/
│   ├── goal_progress.dart            # Hiển thị thanh tiến độ calories đạt được.
│   ├── macro_avg_chart.dart          # Biểu đồ cột hiển thị lượng macro trung bình.
│   └── macro_breakdown_chart.dart    # Biểu đồ tròn hiển thị tỉ lệ P/C/F.

└── main.dart                         # Điểm khởi chạy app, điều hướng và khởi tạo service.

