# Triển khai SciMatrix AI Team lên Vercel — checklist ngắn

## A. Supabase (khoảng 1 lần thiết lập)

1. Tạo Project mới tại https://supabase.com/dashboard
2. SQL Editor → chạy toàn bộ file `supabase/schema.sql` (**một lần** trên Project trống).
3. Kiểm tra Storage bucket `papers` là **Private**.
4. Authentication → Email → cho phép đăng ký Email/Password; cân nhắc bật email confirmation.
5. Lấy **Project URL** và **publishable/anon key** trong Project Settings → API Keys.

## B. GitHub → Vercel

1. Đưa toàn bộ thư mục `sci-matrix-ai-team` lên **private GitHub repository**.
2. Vercel → New Project → Import repository → Framework **Next.js**.
3. Environment Variables (Production):

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
GEMINI_API_KEY=YOUR_GEMINI_AI_STUDIO_KEY
GEMINI_MODEL=gemini-3.8-flash
MAX_PDF_MB=15
```

4. Deploy. Lấy URL thực tế `https://YOUR_PROJECT.vercel.app`.
5. Supabase → Authentication → URL Configuration: đặt **Site URL** trùng URL trên và thêm `https://YOUR_PROJECT.vercel.app/**` ở Redirect URLs.
6. Redeploy nếu thay đổi biến môi trường.

## C. Nhóm NCKH bắt đầu sử dụng

1. Trưởng nhóm đăng ký và tạo Collection.
2. Nhập Research Topic / Research Model.
3. Thành viên → Tạo link mời Editor hoặc Viewer → gửi riêng từng người.
4. Thành viên đăng ký/đăng nhập và mở link mời.
5. Editor Upload PDF; AI trích xuất 12 trường. Hai Editor chỉnh sửa hai ô khác nhau, bấm ra ngoài để lưu.
6. Owner/Editor tạo Synthesis; Viewer xem và Export Excel.

**Chú ý:** Không có tài khoản Supabase/Vercel/GitHub/API key của bạn trong ZIP. Vì thế ZIP chưa phải website đang chạy; cần thực hiện các bước cấu hình và deploy. Chưa xác minh production build tại thời điểm tạo file do npm registry không truy cập được trong môi trường đóng gói.
