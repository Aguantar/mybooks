<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>관리자 - 주문 상세</title>
  <style>
    body{font-family:-apple-system,BlinkMacSystemFont,'Noto Sans KR',sans-serif;margin:0;background:#f6f7fb;color:#222;}
    .wrap{max-width:900px;margin:30px auto;padding:0 16px;}
    .top{display:flex;gap:8px;align-items:center;margin-bottom:16px}
    .btn{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 12px;border:1px solid #ddd;background:#fff;border-radius:8px;cursor:pointer;text-decoration:none;color:#222}
    .btn.primary{background:#1a237e;border-color:#1a237e;color:#fff}
    .card{background:#fff;border:1px solid #eee;border-radius:8px;padding:14px}
    .row{display:grid;grid-template-columns:140px 1fr;gap:12px}
    .badge{display:inline-block;padding:2px 8px;border-radius:999px;font-size:12px;border:1px solid #ddd;background:#fff}
    .items{margin-top:14px}
    .item{display:grid;grid-template-columns:80px 1fr 80px 100px 100px;gap:10px;padding:10px 0;border-bottom:1px solid #f0f0f0;align-items:center}
    .thumb{width:70px;height:90px;background:#eee center/cover no-repeat;border:1px solid #ddd;border-radius:4px}
    .actions{display:flex;gap:8px;margin-top:12px;flex-wrap:wrap}
    .msg{margin:10px 0;padding:10px;border-radius:6px}
    .msg.ok{background:#e8f5e9;border:1px solid #a5d6a7}
    .msg.err{background:#ffebee;border:1px solid #ef9a9a}
    .input{height:36px;padding:0 10px;border:1px solid #ddd;border-radius:8px}
  </style>
</head>
<body>
<div class="wrap">
  <div class="top">
    <a class="btn" href="${pageContext.request.contextPath}/admin/orders">목록으로</a>
    <a class="btn" href="${pageContext.request.contextPath}/bookstore/books">메인으로</a>
  </div>

  <!-- 플래시 메시지 -->
  <c:if test="${not empty msg}">
    <div class="msg ok">${msg}</div>
  </c:if>
  <c:if test="${not empty error}">
    <div class="msg err">${error}</div>
  </c:if>

  <div class="card">
    <h3 style="margin:0 0 10px">주문 #<c:out value="${order.orderId}"/></h3>

    <!-- 주문 기본정보 -->
    <div class="row">
      <div>주문자</div><div><c:out value="${order.loginId}"/></div>
      <div>상태</div><div><span class="badge"><c:out value="${order.status}"/></span></div>
      <div>총액</div><div><c:out value="${order.totalAmount}"/> 원</div>
      <div>주소</div><div><c:out value="${order.address}"/></div>
      <div>우편번호</div><div><c:out value="${order.postcode}"/></div>

      <!-- 배송정보(있을 때만 노출) -->
      <c:if test="${not empty order.courier}">
        <div>택배사</div><div><c:out value="${order.courier}"/></div>
      </c:if>
      <c:if test="${not empty order.trackingNo}">
        <div>송장번호</div><div><c:out value="${order.trackingNo}"/></div>
      </c:if>
      <c:if test="${not empty order.shippedAt}">
        <div>발송시각</div>
        <div><fmt:formatDate value="${order.shippedAt}" pattern="yyyy-MM-dd HH:mm"/></div>
      </c:if>
      <c:if test="${not empty order.deliveredAt}">
        <div>배송완료시각</div>
        <div><fmt:formatDate value="${order.deliveredAt}" pattern="yyyy-MM-dd HH:mm"/></div>
      </c:if>
    </div>

    <!-- 상태 변경 액션 -->
    <div class="actions">
      <!-- PENDING: 결제 확인(PAID) + 주문 취소 -->
      <c:if test="${order.status == 'PENDING'}">
        <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/status"
              method="post" style="display:inline">
          <sec:csrfInput/>
          <input type="hidden" name="from" value="PENDING"/>
          <input type="hidden" name="to" value="PAID"/>
          <button class="btn primary" type="submit">결제 확인(PAID)</button>
        </form>

        <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/cancel"
              method="post" style="display:inline">
          <sec:csrfInput/>
          <button class="btn" type="submit"
                  onclick="return confirm('이 주문을 취소하시겠습니까?')">
            주문 취소
          </button>
        </form>
      </c:if>

      <!-- PAID: 발송 처리(SHIPPED) — 택배사/송장 필수 -->
      <c:if test="${order.status == 'PAID'}">
        <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/status"
              method="post" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
          <sec:csrfInput/>
          <input type="hidden" name="from" value="PAID"/>
          <input type="hidden" name="to" value="SHIPPED"/>

          <input class="input" type="text" name="courier" placeholder="택배사" required/>
          <input class="input" type="text" name="trackingNo" placeholder="송장번호" required/>

          <button class="btn primary" type="submit">발송 처리(SHIPPED)</button>
        </form>
      </c:if>

      <!-- SHIPPED: 배송 완료(DELIVERED) -->
      <c:if test="${order.status == 'SHIPPED'}">
        <form action="${pageContext.request.contextPath}/admin/orders/${order.orderId}/status"
              method="post" style="display:inline">
          <sec:csrfInput/>
          <input type="hidden" name="from" value="SHIPPED"/>
          <input type="hidden" name="to" value="DELIVERED"/>
          <button class="btn primary" type="submit">배송 완료(DELIVERED)</button>
        </form>
      </c:if>
      <!-- DELIVERED / CANCELLED: 버튼 없음 -->
    </div>

    <!-- 품목 -->
    <div class="items">
      <h4 style="margin:14px 0 8px">품목</h4>
      <c:forEach var="it" items="${items}">
        <div class="item">
          <div class="thumb" style="background-image:url('${fn:escapeXml(it.coverImage)}');"></div>
          <div><c:out value="${it.bookTitle}"/></div>
          <div>수량: <c:out value="${it.quantity}"/></div>
          <div>단가: <c:out value="${it.unitPrice}"/></div>
          <div>소계: <c:out value="${it.unitPrice * it.quantity}"/></div>
        </div>
      </c:forEach>
      <c:if test="${empty items}">
        <div style="color:#888">품목이 없습니다.</div>
      </c:if>
    </div>
  </div>
</div>
</body>
</html>
