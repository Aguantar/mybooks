<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>주문서 - BookMarket</title>
    <style>
        body{font-family:-apple-system,BlinkMacSystemFont,"Noto Sans KR",Segoe UI,Roboto,Arial; background:#fafafa; margin:0; color:#222;}
        .wrap{max-width:1000px; margin:32px auto; background:#fff; border:1px solid #eee; border-radius:8px; overflow:hidden; box-shadow:0 4px 16px rgba(0,0,0,.06)}
        .head{padding:16px 20px; border-bottom:1px solid #f0f0f0; display:flex; justify-content:space-between; align-items:center}
        .table{width:100%; border-collapse:collapse}
        .table th,.table td{padding:12px; border-bottom:1px solid #f3f3f3; text-align:left}
        .total{display:flex; justify-content:flex-end; padding:14px 20px; font-size:18px; font-weight:800}
        .form{padding:14px 20px; display:grid; gap:10px; grid-template-columns:120px 1fr}
        .form label{line-height:38px}
        .form input{height:38px; padding:0 10px; border:1px solid #ddd; border-radius:6px}
        .actions{padding:16px 20px; display:flex; gap:10px; justify-content:flex-end}
        .btn{height:40px; padding:0 16px; border:1px solid #1a237e; background:#1a237e; color:#fff; border-radius:8px; font-weight:700; cursor:pointer}
        .btn.sec{background:#fff; color:#1a237e}
        .warn{color:#c62828; font-size:14px}
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background: #f9f9f9;
            color: #333;
            padding-top: 80px; /* 고정 헤더 높이만큼 여백 */
        }

        :root {
            --primary:#1a237e;
            --accent:#4caf50;
            --text-gray:#555;
            --bg-card:#fff;
            --shadow:rgba(0,0,0,0.08);
        }

        header {
            position: fixed; top:0; left:0; right:0; height:80px;
            background:#fff; box-shadow:0 2px 8px var(--shadow);
            display:flex; align-items:center; padding:0 20px; z-index:1000;
        }

        .logo { font-size:1.6em; font-weight:bold; color:var(--primary); }
        .logo a { text-decoration:none; color:inherit; }

        .text-btn {
            display:inline-flex; align-items:center; justify-content:center;
            padding:0 14px; height:40px; background:var(--primary); color:#fff;
            border:none; border-radius:4px; font-size:.95em; text-decoration:none;
            cursor:pointer; margin-left:8px; white-space:nowrap; transition:filter .2s;
        }
        .text-btn:hover { filter:brightness(1.1); }

        .icons { display:flex; align-items:center; margin-left:auto; }

        form.logout-form { margin:0; }

    </style>
</head>
<body>
<header>
    <div class="logo">
        <a href="${pageContext.request.contextPath}/bookstore/books">BookMarket</a>
    </div>


    <div class="icons">
        <c:choose>
            <c:when test="${empty sessionScope.loginId}">
                <a href="${pageContext.request.contextPath}/cart"   class="text-btn">장바구니</a>
                <a href="${pageContext.request.contextPath}/loginForm" class="text-btn">로그인</a>
                <a href="${pageContext.request.contextPath}/register"  class="text-btn">회원가입</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/cart"   class="text-btn">장바구니</a>
                <a href="${pageContext.request.contextPath}/mypage/orders" class="text-btn">주문내역</a>
                <form class="logout-form" action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                    <sec:csrfInput/>
                    <button type="submit" class="text-btn">로그아웃</button>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</header>
<div class="wrap">
    <div class="head">
        <div><a href="${pageContext.request.contextPath}/bookstore/books">← 계속 쇼핑</a></div>
        <div>주문서 작성</div>
    </div>

    <table class="table">
        <thead>
        <tr><th>도서</th><th>단가</th><th>수량</th><th>소계</th></tr>
        </thead>
        <tbody>
        <c:forEach var="ln" items="${lines}">
            <tr>
                <td><strong><c:out value="${ln.book.title}"/></strong><br/><span style="color:#666"><c:out value="${ln.book.author}"/></span></td>
                <td><c:out value="${ln.book.price}"/> 원</td>
                <td><c:out value="${ln.qty}"/></td>
                <td><c:out value="${ln.lineTotal}"/> 원</td>
            </tr>
        </c:forEach>
        </tbody>
    </table>

    <div class="total">총 결제 금액: <span style="margin-left:6px;"><c:out value="${totalAmount}"/> 원</span></div>

    <form class="form" action="${pageContext.request.contextPath}/orders/submit" method="post">
        <label for="address">배송지 주소</label>
        <input id="address" name="address" type="text" placeholder="도로명 주소" required/>

        <label for="postcode">우편번호</label>
        <input id="postcode" name="postcode" type="text" placeholder="우편번호" required/>

        <div></div>
        <div class="warn">※ 결제 버튼을 누르면 재고가 다시 확인되고 부족 시 주문이 취소됩니다.</div>

        <div></div>
        <div class="actions">
            <a class="btn sec" href="${pageContext.request.contextPath}/bookstore/books">취소</a>
            <sec:csrfInput/>
            <button type="submit" class="btn">결제하기</button>
        </div>
    </form>

    <c:if test="${empty loginId}">
        <div style="padding:8px 20px 20px 20px; color:#c62828;">로그인이 필요합니다. <a href="${pageContext.request.contextPath}/loginForm">로그인</a></div>
    </c:if>
</div>
</body>
</html>
