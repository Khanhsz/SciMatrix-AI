# SciMatrix AI Team — Shared Literature Research Workspace

**Bản nhóm NCKH** triển khai trên **Vercel + Supabase + Gemini Interactions API**. Mỗi thành viên có tài khoản riêng, chia sẻ PDF và Literature Matrix trong dự án có phân quyền. Không còn phụ thuộc vào `localStorage` để lưu các paper.

> **Trạng thái kiểm thử:** mã TypeScript/TSX đã được kiểm tra cú pháp tĩnh; **chưa chạy được `npm install` / production build / kiểm thử Supabase + Gemini thật** trong môi trường đóng gói vì không truy cập được npm registry hoặc API key. Vì vậy, đây là mã nguồn **sẵn để cấu hình và thử triển khai**, không phải một production deployment đã được xác nhận hoạt động end-to-end. Hãy kiểm tra bản staging trước khi nhập dữ liệu quan trọng.

## 1. Những gì được hỗ trợ

| Nhóm chức năng | Chi tiết |
|---|---|
| Team workspace | Nhiều Collection, mỗi Collection có Owner và các thành viên |
| Authentication | Supabase email/password, email confirmation tùy cấu hình |
| Phân quyền | Owner (thiết lập/mời/xóa dự án), Editor (upload/sửa/xóa/synthesis), Viewer (xem và export) |
| Mời thành viên | Link mời một lần, 7 ngày, role Editor hoặc Viewer; Owner có thể đổi quyền/thu hồi thành viên |
| Shared Literature Matrix | 12 trường, chỉnh sửa và lưu ngay trong PostgreSQL |
| PDF | Supabase private bucket, URL tải tạm thời 2 phút, upload trực tiếp từ browser |
| Gemini AI | Gemini Interactions API: đọc PDF, trích xuất JSON, Evidence và Literature Synthesis |
| Đồng bộ | Supabase Realtime + nút đồng bộ thủ công + tải lại khi focus tab |
| Quota bảo vệ | Mỗi user tối đa 25 lần extract, 10 lần synthesize, 5 lần test Gemini / UTC day (SQL có thể sửa) |
| Nhập xuất | Import Excel bản cũ, Export Excel gồm Matrix, Evidence và Project Info |

**Chưa hỗ trợ:** chỉnh sửa đồng thời realtime theo ký tự, version history, khôi phục dữ liệu đã xóa, thay đổi/thu hồi quyền thành viên, xử lý PDF nền dài hạn, billing, email mời tự động. Nếu hai người sửa **cùng một ô**, lần lưu cuối sẽ thắng. Hai người sửa **khác ô** dùng RPC `update_paper_field` để tránh ghi đè toàn bộ trường khác.

## 2. Chuẩn bị

- Node.js **22 LTS** và npm để chạy local (khuyến nghị kiểm tra build trước khi deploy).
- Tài khoản **Supabase**: https://supabase.com/dashboard
- Tài khoản **Vercel**: https://vercel.com
- **GitHub** repository để triển khai Vercel.
- API key Google AI Studio: https://aistudio.google.com/apikey

## 3. Thiết lập Supabase (bắt buộc)

1. Tạo **Supabase project mới** (Database + Authentication + Storage).
2. Vào **SQL Editor → New query**.
3. Mở [`supabase/schema.sql`](supabase/schema.sql) và dán **toàn bộ nội dung** → **Run** **một lần** trong project mới.
4. Kiểm tra **Table Editor** xuất hiện `projects`, `project_members`, `papers`, `profiles`, `project_invites`, `ai_usage`.
5. Kiểm tra **Storage → Buckets** có bucket `papers` với **Public = OFF**.
6. Vào **Authentication → Providers → Email**: bật Email/Password; có thể yêu cầu xác nhận email để tránh tài khoản giả. Bảo đảm email SMTP hoạt động nếu dùng nhiều người.
7. Vào **Authentication → URL Configuration**:
   - **Site URL**: `https://YOUR-PROJECT.vercel.app`
   - **Redirect URLs**: thêm `https://YOUR-PROJECT.vercel.app/**`; với local có thể thêm `http://localhost:3000/**`.
8. Vào **Project Settings → API Keys** lấy **Project URL** và **publishable/anon key**. Không đưa service-role/secret key xuống trình duyệt.

Lưu ý: Script SQL được thiết kế cho **Supabase project mới**; nếu chạy lại nguyên file có thể lỗi trùng policy. Hãy thay đổi có kiểm soát hoặc thực hiện migration, không drop database thật để chạy lại.

## 4. Cấu hình biến môi trường

Tạo `.env.local` từ `.env.example`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_publishable_or_anon_key
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-3.8-flash
MAX_PDF_MB=15
```

- `NEXT_PUBLIC_SUPABASE_ANON_KEY` có thể lộ trong trình duyệt — **đó là chủ ý**, bảo mật dựa vào Supabase Auth + Row Level Security.
- `GEMINI_API_KEY` là **secret**: chỉ lưu ở server và Vercel Environment Variables; **không được** có `NEXT_PUBLIC_` phía trước.
- **Không** thêm `SUPABASE_SERVICE_ROLE_KEY` vào ứng dụng này (client và server đều dùng RLS theo JWT người dùng).
- `MAX_PDF_MB=15` là giới hạn của bucket được tạo bởi SQL. Muốn tăng phải sửa **cả** SQL bucket limit và `.env`.

## 5. Chạy local

```bash
npm install
npm run typecheck
npm run dev
```

Mở http://localhost:3000. Trên Windows có thể dùng `RUN_WINDOWS.bat`; script sẽ mở `.env.local` nếu chưa tồn tại.

Để kiểm tra production build:

```bash
npm run build
npm run start
```

## 6. Triển khai Vercel từ GitHub

Đứng trong thư mục `sci-matrix-ai-team`:

```bash
git init
git add .
git commit -m "SciMatrix AI Team workspace"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/sci-matrix-ai-team.git
git push -u origin main
```

1. Tạo private repository trước trên https://github.com/new và thay `YOUR_USERNAME` bằng tài khoản GitHub.
2. Mở https://vercel.com/new → Import repository.
3. Framework: **Next.js**; Root Directory: thư mục chứa `package.json`.
4. Trong **Environment Variables**, thêm 5 biến ở mục 4.
5. Nhấn **Deploy**. Nếu bạn thay đổi các biến, redeploy.
6. Lấy URL `https://YOUR-PROJECT.vercel.app` và cập nhật **Supabase Auth Site URL / Redirect URLs** (mục 3).
7. Đăng ký tài khoản Owner → tạo Collection → mời Editor và Viewer bằng link một lần.

**Ưu điểm khi dùng Vercel:** PDF được upload *trực tiếp* lên Supabase Storage nên không phải gửi PDF 15 MB vào Vercel Function (Vercel giới hạn request body khoảng 4.5 MB). Route `/api/extract` chỉ nhận `paperId`, kiểm tra JWT, tải PDF từ private Supabase bucket theo quyền người dùng, gọi Gemini và lưu kết quả. Server có `maxDuration=240`, nhưng Vercel plan/region vẫn có timeout và giới hạn thực tế riêng; các PDF lớn hoặc model quá chậm có thể không hoàn tất, cần hàng đợi background để xử lý ổn định ở quy mô lớn.

## 7. Quy trình nhóm sử dụng

1. **Owner** đăng ký/đăng nhập và tạo Collection NCKH.
2. Owner mở **Đề tài** nhập `Research Topic` và `Research Model` → **Lưu đề tài**.
3. Owner mở **Thành viên** → chọn Editor/Viewer → **Tạo link** → **Copy** và gửi riêng cho thành viên. Link dùng **một lần**, hết hạn sau **7 ngày**.
4. Thành viên mở link, đăng ký/đăng nhập email/password → tự tham gia workspace. Nếu xác minh email làm mở tab khác, thành viên có thể mở lại link mời **chưa dùng** sau khi đăng nhập.
5. **Editor** upload một/nhiều PDF, hệ thống tự phân tích từng file bằng Gemini rồi ghi vào 12 trường.
6. Thành viên cùng xem Matrix; Editor chỉnh sửa ô (lưu khi thoát khỏi ô), sửa Evidence; Viewer chỉ đọc/xuất Excel.
7. Khi có **ít nhất 2 paper Completed**, Owner/Editor tạo **Literature Synthesis** để tất cả thành viên xem.
8. Dùng **Export Excel** để lưu bản sao dữ liệu phục vụ kiểm tra, nộp báo cáo.

### Di chuyển dữ liệu từ bản local cũ

Trong app SciMatrix AI bản cũ, xuất **Excel** cho từng Collection. Trong bản Team: mở Collection → **Import Excel cũ**. Các trường và Evidence sẽ được nhập vào database nhóm. **PDF gốc không nằm trong file Excel nên không thể tự nhập lại**; các paper import được gắn cảnh báo "PDF chưa đính kèm", nhưng vẫn dùng để tổng hợp. Để có bản PDF trên cloud, nhóm cần upload lại PDF như một paper mới hoặc bổ sung workflow ghép tài liệu sau này.

## 8. Quy tắc bảo mật

- **Row Level Security (RLS)** áp dụng ở `projects`, `project_members`, `papers`, `profiles` và bucket `papers`.
- API Gemini chỉ chạy sau khi xác thực user bằng Supabase Auth, kiểm tra vai trò Editor/Owner, và tiêu thụ quota qua RPC trên DB.
- `service_role` không được sử dụng; dữ liệu các project khác nhau bị cách ly theo membership.
- Link mời là *bearer secret*: người nhận giữ token sẽ có quyền tham gia một lần. Không đưa link lên nhóm công khai, issue tracker, log hoặc screenshot. Không dùng link nếu nghi bị lộ.
- URL PDF ký tạm thời có hiệu lực **120 giây**; trong thời hạn đó, người có URL có thể truy cập mà không cần đăng nhập — không phát tán URL này.
- Các bài báo được gửi tới Google Gemini. Nếu thuộc dữ liệu nội bộ, có NDA, hoặc giới hạn bản quyền, cần bảo đảm việc upload và chia sẻ cho nhóm/Gemini được phép.
- Hạn mức AI theo user là **giới hạn ứng dụng**, không bảo đảm không phát sinh chi phí hoặc không vượt hạn mức của Google. Hãy giám sát Free Tier/quota và thiết lập giới hạn thanh toán (nếu có).
- Không nên mở đăng ký công khai khi chưa có CAPTCHA, email verification, giám sát abuse và cơ chế duyệt thành viên nếu mục đích sử dụng vượt nhóm nhỏ.

## 9. Checklist thử nghiệm trước khi mời cả nhóm

- [ ] `npm install`, `npm run typecheck`, `npm run build` thành công.
- [ ] Đăng ký 2 tài khoản khác nhau và xác minh email.
- [ ] Owner tạo project → Editor nhận link → Viewer nhận link.
- [ ] Viewer chỉ đọc, không thể thêm/sửa/xóa paper hoặc gọi Gemini API (kể cả request trực tiếp).
- [ ] Editor upload PDF ~5–10 MB trực tiếp lên Storage, kiểm tra xử lý AI.
- [ ] Tài khoản không tham gia dự án không xem được data/PDF qua Supabase REST/Storage.
- [ ] Hai tài khoản chỉnh sửa **hai ô khác nhau** trên cùng paper, nội dung đều còn sau reload.
- [ ] Literature Synthesis lưu lại và hiện ở cả 2 tài khoản.
- [ ] Import Excel bản cũ và Export Excel bản Team.
- [ ] Kiểm tra log ứng dụng không chứa API key, token mời hoặc PDF raw.

## 10. Một số lỗi thường gặp

- **Invalid login credentials**: kiểm tra email/password hoặc xác nhận email.
- **Không thấy project sau khi được mời**: kiểm tra link chưa dùng/hết hạn; thử lại trong sidebar.
- **new row violates row-level security policy**: kiểm tra script SQL đã chạy hết và user có role Editor/Owner.
- **Bucket not found**: script SQL chưa tạo bucket `papers` hoặc nhập sai Supabase URL/key.
- **Function payload too large**: bản Team upload PDF thẳng Supabase; kiểm tra bạn đang chạy đúng ZIP Team, không phải bản Local cũ.
- **HTTP 429 Gemini**: hết Free Tier/quota, hãy thử sau hoặc đổi model đang được cấp quyền.
- **Vercel build error**: xem Deployments → Build Logs. Chạy `npm run typecheck` / `npm run build` trên máy local để tái hiện.
- **Truy cập sau khi xác nhận email về sai domain**: cập nhật Supabase Auth Site URL / Redirect URLs.

## Tài liệu chính thức

- Supabase Auth: https://supabase.com/docs/guides/auth
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase Storage private buckets: https://supabase.com/docs/guides/storage/buckets/fundamentals
- Supabase Realtime: https://supabase.com/docs/guides/realtime/postgres-changes
- Vercel Next.js: https://vercel.com/docs/frameworks/full-stack/nextjs
- Vercel request limit: https://vercel.com/docs/errors/function_payload_too_large
- Gemini file input: https://ai.google.dev/gemini-api/docs/file-input-methods
