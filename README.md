# Bài tập môn Hệ quản trị cơ sở dữ liệu-TEE560, Lớp: 59KMT
## YÊU CẦU BÀI TẬP 
### Phần mở đầu:
- Thông tin cá nhân: Vũ Tuấn Đạt
- MSSV: K235480106105
- Yêu cầu đầu bài: Thiết kế và Khởi tạo Cấu trúc Dữ liệu quản lý thư viện
- Cách làm:
    - Giai đoạn 1 (Thiết kế): Phân tích thực thể, xác định các kiểu dữ liệu tối ưu (Unicode cho tên sách, Money cho giá tiền). Thiết lập sơ đồ quan hệ đảm bảo tính toàn vẹn dữ liệu thông qua Primary Key và Foreign Key.

   - Giai đoạn 2 (Logic hóa): Sử dụng các System Functions (như DATEDIFF, GETDATE, FORMAT) để làm nền tảng, sau đó xây dựng các User-Defined Functions riêng để đóng gói các công thức nghiệp vụ đặc thù của thư viện.

   - Giai đoạn 3 (Tương tác): Viết các Stored Procedures để chuẩn hóa việc nhập liệu, đảm bảo dữ liệu đi vào hệ thống luôn đi qua các bước kiểm tra (Validation) nghiêm ngặt.

   - Giai đoạn 4 (Tự động hóa): Thiết lập Triggers để đồng bộ dữ liệu giữa các bảng (ví dụ: Nhật ký nhập kho). Đồng thời, thử nghiệm lỗi đệ quy để hiểu rõ giới hạn của hệ thống (mức lồng nhau tối đa 32 cấp).

   - Giai đoạn 5 (Tối ưu): Thực hiện duyệt dữ liệu bằng Cursor để xử lý các bài toán tuần tự, sau đó đối chiếu với giải pháp Set-based (dùng CASE WHEN) để chứng minh hiệu năng vượt trội của việc xử lý tập hợp trong SQL.
### Phần I. Thiết kế và Khởi tạo Cấu trúc Dữ liệu

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

### Phần II. Xây dựng Function

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

#### 4. Viết 01 Inline Table-Valued Function
**Yêu cầu:** Trả về danh sách sách thuộc một thể loại cụ thể dựa trên tên thể loại.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/62102bae-8a02-43b9-9e32-74d01c116fc5" />

Khai thác hàm:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fd95131e-05bc-4e1a-a277-68f6fe61f44c" />

#### 5. Viết 01 Multi-statement Table-Valued Function
**Yêu cầu:** Phân loại độc giả dựa trên số tiền ký quỹ. (Dưới 50k: Bronze, 50k-150k: Silver, trên 150k: Gold)

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5e9c3d38-2e22-485a-b7b0-b6f03621329f" />

Khai thác hàm:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2b6cb556-b559-4c19-a834-31c10f349ab4" />


### Phần III. Xây dựng Store Procedure
#### 1. Stored Procedure có sẵn trong SQL Sever (System SP)

System Stored Procedures là các thủ tục được Microsoft viết sẵn, lưu trữ trong database master và bắt đầu bằng tiền tố sp_ chúng giúp quản trị viên hệ thống quản lý databasae nhanh chóng.

Một vài System SP đặc sắc:

- sp_help: Cung cấp thông tin chi tiết về một đối tượng (bảng, cột ràng buộc, dữ liệu).
      - Cách dùng: EXEC sp_help 'Sach';
- sp_rename: Dùng để đổi tên một đối tượng (như bảng hoặc cột) mà không cần xóa đi tạo lại.
      - Cách dùng: EXEC sp_rename 'TenBangCu', 'TenBangMoi';
- sp_helpdb: Hiển thị thông tin về các database đang có trên server hoặc thông tin chi tiết của một DB cụ thể.
      - Cách dùng: EXEC sp_helpdb 'QuanLyThuVien_K235480106105';

  #### 2. Thực hành viết SP

  - SP thực hiện INSERT dữ liệu có kiểm tra logic

  **Yêu cầu:** Tạo SP để nhập thêm sách mới. Kiểm tra nếu GiaTien nhỏ hơn hoặc bằng 0 thì không cho nhập và báo lỗi.

 <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/369fecac-313b-4c4d-91ce-22d009f18816" />

Trường hợp giá lỗi:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/f860d8e7-0daf-4a3f-9ee2-5c5cfacef009" />

Trường hợp không lỗi:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/a15c029f-2a94-4cdf-b145-a53bfa068867" />

- SP sử dụng tham số OUTPUT

**Yêu cầu:** Tính tổng số lượng sách đang có trong thư viện và trả về qua tham số OUTPUT.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/51aeb43c-c899-4038-8b18-9b4ffc6b4d66" />

Kết quả:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/636e434e-826a-4ccc-b342-fb59e362425b" />

- SP trả về tập kết quả (Result set) từ lệnh SELECT join nhiều bảng

**Yêu cầu:** Xuất báo cáo danh sách bao gồm: Mã sách, Tên sách, Tên thể loại và Giá tiền.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/e3d1f266-72cd-42e4-bbeb-2337da3826f0" />

Kết quả:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9a1f2ab8-1d72-42ce-910b-5f1dca413566" />

### Phần IV: Trigger và Xử lý logic nghiệp 

1. Viết 01 Trigger tự động xử lý logic nghiệp vụ thực tế

Giả sử: Khi thư viện nhập thêm một lượng sách mới vào bảng [Sach] (bảng A), chúng ta cần ghi lại lịch sử nhập kho và một bảng khác gọi là [NhatKyNhapKho] (bảng B) để tiện theo dõi sau này.

- Bước 1: Tạo bảng B (NhatKyNhapKho)

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/6d36620f-be87-4717-bb62-240da73037f4" />

- Bước 2: Tạo Trigger trên bảng [Sach]

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fecc0366-822b-4f27-8c53-2bcee2c32c2f" />

Trigger này sử dụng bảng ảo inserted (chứa dữ liệu vừa được thêm vào). Ngay sau khi thêm sách mới, nó sẽ tự động "copy" thông tin đó và bảng nhật ký.

2. Thử nghiệm Trigger thực tế

Giả thuyết đưa ra:

- Trigger 1 (Trên bảng A): Khi insert vào bảng A, hãy update bảng B.
- Trigger 2 (Trên bảng B): Khi bảng B được update, hãy update ngược lại bảng A.

Nhập 1 cuốn sách mới
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/e6eec9d2-f87d-4938-97a4-ba7a90b76eef" />

Kiểm tra bảng nhật ký
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2c967d07-e47b-4306-8910-bd0477e7ec7e" />

Ta sẽ thấy một dòng mới trong bảng NhatKyNhapKho với MaSach là 'S999' và SoLuongMoi là 10, dù không hề viết lệnh insert vào bảng này.

3. Thử nghiệm Trigger vòng lặp

Ta thử thêm một cuốn sách khác để kích hoạt chuỗi: Insert Sach --> Update DocGia --> Update Sach...

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/67b56aaa-c9bc-4d09-bb44-8965e0f8111c" />

Hệ thống đã đếm ngược trigeer A gọi B, B gọi A... lặp đi lặp lại đến lần thứ 32 thì SQL Sever "chóng mặt" nên đã tự ngắt lệnh để bảo vệ máy tính không bị treo. Đây gọi là hiện tượng Recursive Triggers (Trigger đệ quy). Nếu không kiểm soát tốt, nó sẽ gây lỗi logic nghiệm trọng hoặc làm cạn kiệt tài nguyên máy chủ.

- Nhận xét: Ta cần hạn chế tối đa việc viết các trigger tác động chéo lên nhau theo vòng tròn. Trigger nên ngắn gọn, đơn giản và tránh gây ra các tác động dây chuyền quá phức tạp.

### Phần V: Cursor và Duyệt dữ liệu 

**Bài toán**: Duyệt qua danh sách sách, kiểm tra "thâm niên" và "số lượng tồn". Nếu sách quá cũ (trên 800 ngày) và còn nhiều hàng, hãy in ra thông báo "Cần xả kho ngay"; nếu sách mới và sắp hết hàng, in "Cần nhập thêm".

1. Sử dụng CURSOR để xử lý từng bản ghi

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/39f6a98b-63ea-4277-ad1e-1dd5535adf16" />

Check thời gian chạy
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/f19cb165-792e-42a6-b3cb-76001dcf510b" />

2. Sử dụng SET-BASED (Xử lý tập hợp)

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ecb2c023-1cf2-4124-b32f-312b176f11a6" />

Check thời gian chạy
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c63ebd0c-2709-4561-80b1-0dbab62a0146" />

- Nhật xét: Cách không dùng Cursor (Set-based) luôn nhanh hơn gấp nhiều lần. Vì SQL Sever được tối ưu hóa để xử lý bảng dữ liệu, việc dùng Cursor giống như thuê một chiếc xe tải nhưng chỉ để chở từng viên gạch một - rất lãng phí tài nguyên.

3. Bài toán "Chỉ Cursor mới giải quyết được" 

Thực tế, gần như mọi thứ đều có thể dùng SQL thuần (kết hợp với CTE hoặc Window Functions) để giải quyết. Tuy nhiên, bài toán Duyệt tồn kho theo phương pháp FIFO (First In - First Out) là cực kỳ khó nếu không có Cursor.

Kịch bản: Thư viện có nhiều đợt nhập cuốn sách "Dắc Nhân Tâm" với giá khác nhau. Khi có người mượn làm mất sách và phải đền, bạn phải trừ dần số lượng vào từng đợt nhập (đợt nào nhập trước trừ trước).

- Đợt 1: Nhập 10 cuốn (1/1/2024)
- Đợt 2: Nhập 10 cuốn (1/2/2024)
- Khách làm mất 12 cuốn.
- Vì ta cần lấy 12 cuốn, trừ hết 10 cuốn của đợt 1, sau đó lấy số dư (2 cuốn) để trừ tiếp vào đợt 2. Hành động của dòng thứ 2 phụ thuộc hoàn toàn vào kết quả tính toán còn dư của dòng thứ 1. SQL thuần xử lý các dòng độc lập nên rất khó để "ghi nhớ" số dư này nếu không dùng Cursor để đi từng bước.

Cursor là công cụ cuối cùng khi các giải pháp Set-based bế tắc, vì nó gây tốn CPU và làm khóa (lock) bảng dữ liệu lâu hơn bình thường.
