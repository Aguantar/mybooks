<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>주문 상세 #<c:out value="${order.orderId}"/> - BookMarket</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        *{box-sizing:border-box}
        body{margin:0;font-family:'Noto Sans KR',sans-serif;background:#f9f9fb;color:#333;padding-top:80px}
        :root{--primary:#1a237e;--muted:#6b7280;--ok:#2e7d32;--warn:#f59e0b;--bad:#c62828;--card:#fff;--bd:#e5e7eb;--shadow:rgba(0,0,0,.06)}

        header{position:fixed;top:0;left:0;right:0;height:80px;background:#fff;box-shadow:0 2px 10px var(--shadow);display:flex;align-items:center;padding:0 20px;z-index:1000}
        .logo{font-weight:700;color:var(--primary);font-size:20px}
        .logo a{text-decoration:none;color:inherit}
        .spacer{flex:1}
        .btn{display:inline-flex;align-items:center;gap:8px;padding:10px 14px;border:1px solid var(--bd);border-radius:8px;background:#fff;color:#111;text-decoration:none;cursor:pointer}
        .btn.primary{background:var(--primary);border-color:var(--primary);color:#fff}
        .btn.danger{background:#fff;border-color:#fca5a5;color:#b91c1c}
        .btn:disabled{opacity:.5;cursor:not-allowed}

        .container{max-width:1040px;margin:24px auto;padding:0 16px}
        .card{background:var(--card);border:1px solid var(--bd);border-radius:10px;box-shadow:0 8px 20px var(--shadow);overflow:hidden}
        .card-hd{padding:16px 18px;border-bottom:1px solid var(--bd);display:flex;align-items:center;gap:12px}
        .card-bd{padding:18px}

        .meta-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        .meta-item{background:#fafafa;border:1px solid var(--bd);border-radius:8px;padding:12px}
        .meta-item .label{font-size:12px;color:var(--muted);margin-bottom:4px}
        .meta-item .val{font-weight:700}

        .badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:12px;font-weight:700}
        .badge.pending{background:#fff7ed;color:#b45309;border:1px solid #fed7aa}
        .badge.paid{background:#ecfdf5;color:#047857;border:1px solid #a7f3d0}
        .badge.canceled{background:#fef2f2;color:#b91c1c;border:1px solid #fecaca}

        table{width:100%;border-collapse:collapse}
        th,td{padding:12px;border-bottom:1px solid var(--bd);vertical-align:middle}
        th{background:#fafafa;text-align:left;color:#111}
        .thumb{width:56px;height:72px;border:1px solid var(--bd);border-radius:6px;object-fit:cover;background:#f3f4f6}
        .title{font-weight:700}
        .muted{color:var(--muted);font-size:12px}
        .right{text-align:right}
        .total-row td{font-weight:800;border-top:2px solid #111}

        .actions{display:flex;gap:10px;flex-wrap:wrap;margin-top:14px}
        .msg{margin:16px 0;padding:10px 12px;border:1px solid #d1fae5;background:#ecfdf5;border-radius:8px;color:#065f46}
        .msg.err{border-color:#fecaca;background:#fef2f2;color:#991b1b}

        @media (max-width:780px){
            .meta-grid{grid-template-columns:1fr}
            .hide-sm{display:none}
        }
    </style>
</head>
<body>

<header>
    <div class="logo"><a href="${pageContext.request.contextPath}/bookstore/books">BookMarket</a></div>
    <div class="spacer"></div>
    <sec:authorize access="isAuthenticated()">
        <a class="btn" href="${pageContext.request.contextPath}/mypage/orders">내 주문</a>
        <a class="btn" href="${pageContext.request.contextPath}/cart">장바구니</a>
        <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline">
            <sec:csrfInput/>
            <button class="btn" type="submit">로그아웃</button>
        </form>
    </sec:authorize>
    <sec:authorize access="!isAuthenticated()">
        <a class="btn" href="${pageContext.request.contextPath}/loginForm">로그인</a>
    </sec:authorize>
</header>

<div class="container">

    <!-- 플래시 메시지 -->
    <c:if test="${not empty msg}">
        <div class="msg"><c:out value="${msg}"/></div>
    </c:if>

    <div class="card">
        <div class="card-hd">
            <div style="font-weight:800">주문 상세 #<c:out value="${order.orderId}"/></div>
            <div>
                <c:set var="st" value="${fn:toUpperCase(order.status)}"/>
                <c:choose>
                    <c:when test="${st eq 'PAID'}"><span class="badge paid">결제완료</span></c:when>
                    <c:when test="${st eq 'PENDING'}"><span class="badge pending">결제대기</span></c:when>
                    <c:when test="${st eq 'CANCELED'}"><span class="badge canceled">취소됨</span></c:when>
                    <c:otherwise><span class="badge"><c:out value="${order.status}"/></span></c:otherwise>
                </c:choose>
            </div>
            <div class="spacer"></div>
            <!-- 상태가 PENDING일 때만 취소 버튼 -->
            <c:if test="${st eq 'PENDING'}">
                <form id="cancelForm"
                      action="${pageContext.request.contextPath}/mypage/orders/${order.orderId}/cancel"
                      method="post" style="margin:0">
                    <sec:csrfInput/>
                    <button type="submit" class="btn danger">주문 취소</button>
                </form>
            </c:if>
        </div>

        <div class="card-bd">
            <!-- 주문 요약 -->
            <div class="meta-grid">
                <div class="meta-item">
                    <div class="label">주문번호</div>
                    <div class="val">#<c:out value="${order.orderId}"/></div>
                </div>
                <div class="meta-item">
                    <div class="label">총 결제금액</div>
                    <div class="val"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> 원</div>
                </div>
                <div class="meta-item">
                    <div class="label">배송지 주소</div>
                    <div class="val"><c:out value="${order.address}"/></div>
                </div>
                <div class="meta-item">
                    <div class="label">우편번호</div>
                    <div class="val"><c:out value="${order.postcode}"/></div>
                </div>
            </div>

            <!-- 품목 리스트 -->
            <div style="margin-top:18px;overflow:auto">
                <table>
                    <thead>
                    <tr>
                        <th class="hide-sm">표지</th>
                        <th>도서</th>
                        <th class="right">수량</th>
                        <th class="right">단가</th>
                        <th class="right">소계</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty items}">
                            <tr>
                                <td colspan="5" style="text-align:center;color:#777;padding:20px">품목이 없습니다.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="it" items="${items}">
                                <tr>
                                    <td class="hide-sm">
                                        <img class="thumb" src="<c:out value='${it.coverImage}'/>"
                                             alt="cover" onerror="this.style.visibility='hidden'"/>
                                    </td>
                                    <td>
                                        <div class="title"><c:out value="${it.bookTitle}"/></div>
                                        <div class="muted">#<c:out value="${it.bookId}"/></div>
                                    </td>
                                    <td class="right"><c:out value="${it.quantity}"/></td>
                                    <td class="right"><fmt:formatNumber value="${it.unitPrice}" pattern="#,###"/> 원</td>
                                    <td class="right">
                                        <fmt:formatNumber value="${it.quantity * it.unitPrice}" pattern="#,###"/> 원
                                    </td>
                                </tr>
                            </c:forEach>
                            <tr class="total-row">
                                <td class="hide-sm"></td>
                                <td></td>
                                <td></td>
                                <td class="right">총액</td>
                                <td class="right"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> 원</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- 하단 액션 -->
            <div class="actions">
                <a class="btn" href="${pageContext.request.contextPath}/mypage/orders">← 목록으로</a>
                <a class="btn primary" href="${pageContext.request.contextPath}/bookstore/books">계속 쇼핑</a>
            </div>
        </div>
    </div>
</div>

<script>
    (function(){
        var form = document.getElementById('cancelForm');
        if(form){
            form.addEventListener('submit', function(e){
                if(!confirm('이 주문을 취소하시겠습니까?')) e.preventDefault();
            });
        }
    })();
</script>
</body>
</html>
