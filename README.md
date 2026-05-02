# Bài tập môn Hệ quản trị cơ sở dữ liệu - TE560, Lớp: K59KMT
## YÊU CẦU BÀI TẬP 
### I. Thiết kế và Khởi tạo Cấu trúc Dữ liệu

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9132c81c-dd91-43e4-a149-31439af1e7ca" />
Tạo Database mới với tên QuanLyThuVien_K235480106105.

- Tạo 3 bảng có quan hệ với nhau.
- Bảng 1: [TheLoai] - Danh mục thể loại
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/53112b62-4279-43a6-97f4-f30d60875950" />

- PK (Primary Key): [MaTheLoai] là khóa chính, dùng để định danh duy nhất mỗi thể loại sách.

- Bảng 2: [Sach] - Thông tin sách
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fd07c7bf-1985-40eb-b0fc-21aefcce570b" />

- PK: [MaSach] định danh duy nhất cho mỗi đầu sách.
- FK: [MaTheLoai] Tham chiếu đến bảng [TheLoai].
- CK: [GiaTien] >= 0: Đảm bảo giá tiền không bị nhập sai thành số âm.

- Bảng 3: [DocGia] - Thông tin người mượn

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3a8e4e65-cbd6-4de0-a629-fc8ef36fff7b" />

- PK: [MaDocGia] khóa chính quản lý độc giả.
- Unique: [Email] đảm bảo mỗi độc giả chỉ có một tài khoản duy nhất dựa trên email.
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/aa57ea03-4d6b-48cf-b7c0-a377fef709a7" />
Khởi tạo 3 bảng thành công
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3ebb3e83-a442-4b3b-9a00-3292172c1029" />

- INSERT dữ liệu cho 3 bảng

### II. Xây dựng Function

#### 1. Các loại Function Built-in trong SQL Server
- Hàm có sẵn như:
  - Hàm tập hợp (Aggregate): Tính toán trên một tập dữ liệu (VD: SUM, COUNT, AVG, MAX, MIN)
  - Hàm chuỗi (String): Xử lý văn bản (VD: LEN, SUBSTRING, REPLACE, UPPER, LOWER)
  - Hàm ngày tháng (Date/Time): Xử lý thời gian (VD: GETDATE(), DATEPART, DATEDIFF, DATEADD)
  - Hàm hệ thống (System): Lấy thông tin về sever/database (VD: DB_NAME(), SUSER_NAME())
- Hàm "đặc sắc"
  - DATEDIFF: Tính toán khoảng cách giữa hai mốc thời gian. Rất quan trọng để tính số ngày mượn sách hoặc ngày quá hạn.
  - FORMAT: Định dạng dữ liệu theo chuẩn mong muốn (như tiền tệ VNĐ hoặc ngày tháng kiểu Việt Nam)
- Cho SQL khai thác hàm đó

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/83021d54-ee1e-4d5d-bff6-11a7397ae968" />

- Hàm FORMAT: Cột GiaNiemYet đã hiển thị đúng định dạng có dấu phân cách hàng nghìn và thêm đuôi VNĐ
- Hàm DATEDIFF: Cột SoNgayTrongKho đã tính ra số ngày thâm niên của sách từ năm 2024 đến hiện tại năm 
#### 2. Hàm do người dùng tự viết
- Mục đích hàm do người dùng tự viết trong SQL Sever: UDF được tạo ra để đóng gói các logic tính toán hoặc xử lý dữ liệu phức tạp mà ta thường xuyên phải sử dụng lại ở nhiều câu truy vấn khác nhau.
  - Tính tái sử dụng: Viết logic một lần, gọi ở bất cứ đâu trong SELECT, WHERE, JOIN).
  - Làm sạch mã nguồn: Giúp các câu lệnh SQL chính nhìn gọn gàng hơn, không bị "rác" bởi các công thức tính toán quá dài.
  - Đóng gói nghiệm vụ: Biến các quy tắc kinh doanh (như cách tính thâm niên sách, cách xếp hạng độc giả) thành một "hộp đen" chỉ cần truyền tham số là có kết quả.
- Các loại UDF và hời điểm sử dụng: Có 3 loại hàm phổ biến

    a) Scalar Function (Hàm vô hướng)
  
      - Trả về: Một giá trị đơn duy nhất (số, chuỗi, ngày tháng).
      - Khi nào dùng: Khi ta cần thực hiện một phép tính cụ thể cho từng dòng dữ liệu.4
      - Ví dụ: Tính tổng giá trị một đầu sách (Giá x Số Lượng).

    b) Inline Tabe-Valued Function (Hàm bảng nội tuyến)

      - Trả về: Một tập hợp kết quả dưới dạng bảng (Result set).
      - Đặc điểm: Chỉ chứa duy nhất một câu lệnh RETURN (SELECT...) không có khối BEGIN...END.
      - Khi nào dùng: Khi ta muốn tạo ra một "View có tham số" để lọc dữ liệu nhanh chóng.
      - Ví dụ: Lấy danh sách toàn bộ sách thuộc thể loại "Kinh tế".

  c) Multi-statement Table-Valued Function (Hàm bảng đa câu lệnh)

      - Trả về: Một bảng dữ liệu có cấu trúc được định nghĩa sẵn.
      - Đặc điểm: Có khối BEGIN...END, cho phép khai báo biến, sử dụng IF...ELSE, WHILE và chèn dữ liệu vào một biến bảng (table variable) trước khi trả về.
      - Khi nào dùng: Khi logic xử lý quá phức tạp, không thể giải quyết chỉ bằng một câu SELECT duy nhất.
      - Ví dụ: Xếp hạng độc giả dựa trên nhiều tiêu chí (tiền ký quỹ, số lần mượn, tuổi tác,...).
- Tại sao cần tự viết hàm khi đã có System Function

  Dù SQL Sever cung cấp rất nhiều hàm có sẵn như GETDATE, DATEDIFF, SUM... nhưng chúng vẫn không thể thay thế UDF vì:

  1. Tính đặc thù: Hàm hệ thống mang tính chất chung chung. Ví dụ: DATEDIFF chỉ tính được khoảng cách ngày, nhưng nó không biết "thâm niên sách trên 2 năm thì được coi là sách cũ".
  2. Tính nhất quán: Nếu công thức tính thuế hoặc phí phạt thay đổi, bạn chỉ cần sửa ở một nơi duy nhất (trong Function) thay vì đi tìm và sửa hàng trăm câu lệnh SQL rải rác khắp nơi.
  3. Xử lý Logic phức tạp: Các hàm hệ thống không thể thực hiện các bước kiểm tra điều kiện lồng nhau (IF-ELSE) hay xử lý nhiều bước tuần tự trên dữ liệu như Multi-statement TVF.
  
#### 3. Viết 01 Scalar Function

**Yêu cầu:** Tính tổng giá trị tồn kho của một đầu sách (Giá tiền x Số lượng).

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/73cf3a6e-e12f-406e-8ca1-468e1746209c" />

Khai thác hàm:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/8133437e-06c7-45c9-982f-fdac32b7e376" />














