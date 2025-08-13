<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>주문 완료</title>
  <style>
    body{font-family:-apple-system,BlinkMacSystemFont,"Noto Sans KR"; background:#fafafa; margin:0; color:#222;}
    .box{max-width:720px; margin:60px auto; background:#fff; border:1px solid #eee; border-radius:8px; padding:24px; text-align:center; box-shadow:0 4px 16px rgba(0,0,0,.06)}
    a.btn{display:inline-block; margin-top:14px; padding:10px 16px; border:1px solid #1a237e; color:#fff; background:#1a237e; border-radius:8px; text-decoration:none; font-weight:700}
  </style>
</head>
<body>
<div class="box">
  <h2>주문이 완료되었습니다 🎉</h2>
  <p>주문번호: <strong>#${orderId}</strong></p>
  <a class="btn" href="${pageContext.request.contextPath}/bookstore/books">계속 쇼핑하기</a>
</div>
</body>
</html>
