<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="header">
  <div class="logo">
    <a href="${ctx}/bookstore/books">📚 BookMarket</a>
  </div>

  <div class="nav">
    <!-- 검색: GET /bookstore/books?q=...  (실시간 검색 JS가 #searchInput를 사용) -->
    <form class="search-bar" action="${ctx}/bookstore/books" method="get">
      <input id="searchInput"
             type="text"
             name="q"
             value="${fn:escapeXml(param.q)}"
             placeholder="검색어 입력"
             autocomplete="off" />
      <!-- 버튼은 숨겨도 엔터로 전송 가능 (JS 없을 때도 동작) -->
      <button type="submit" style="display:none;">검색</button>
    </form>

    <div class="user-menu">
      <c:if test="${empty sessionScope.loginId}">
        <a href="${ctx}/loginForm">로그인</a>
        <a href="${ctx}/register">회원가입</a>
      </c:if>

      <c:if test="${not empty sessionScope.loginId}">
        <a href="${ctx}/cart">🛒 장바구니</a>
        <a href="${ctx}/mypage">👤 내 정보</a>
        <form action="${ctx}/logout" method="post" style="display:inline;">
          <sec:csrfInput/>
          <button type="submit">로그아웃</button>
        </form>
      </c:if>
    </div>
  </div>
</div>
