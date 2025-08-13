<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>주문 내역 - BookMarket</title>
    <style>
        body{font-family:-apple-system,BlinkMacSystemFont,"Noto Sans KR",Segoe UI,Roboto,Arial; background:#fafafa; margin:0; color:#222;}
        .wrap{max-width:1000px; margin:32px auto; background:#fff; border:1px solid #eee; border-radius:8px; overflow:hidden; box-shadow:0 4px 16px rgba(0,0,0,.06)}
        .head{padding:16px 20px; border-bottom:1px solid #f0f0f0; display:flex; justify-content:space-between; align-items:center}
        table{width:100%; border-collapse:collapse}
        th,td{padding:12px; border-bottom:1px solid #f3f3f3; text-align:left}
        .empty{padding:24px; color:#666}
    </style>
</head>
<body>
<div class="wrap">
    <div class="head">
        <div><a href="${pageContext.request.contextPath}/bookstore/books">← 목록으로</a></div>
        <div>주문 내역</div>
    </div>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="empty">주문 내역이 없습니다.</div>
        </c:when>
        <c:otherwise>
            <table>
                <thead>
                <tr><th>주문번호</th><th>상태</th><th>총액</th><th></th></tr>
                </thead>
                <tbody>
                <c:forEach var="o" items="${orders}">
                    <tr>
                        <td>#<c:out value="${o.orderId}"/></td>
                        <td><c:out value="${o.status}"/></td>
                        <td><c:out value="${o.totalAmount}"/> 원</td>
                        <td><a href="${pageContext.request.contextPath}/mypage/orders/${o.orderId}">상세보기</a></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
