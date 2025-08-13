<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>관리자 - 도서 관리</title>
    <style>
        body{font-family:-apple-system,BlinkMacSystemFont,'Noto Sans KR',sans-serif;margin:0;background:#f6f7fb;color:#222;}
        .wrap{max-width:1100px;margin:30px auto;padding:0 16px;}
        .top{display:flex;gap:12px;align-items:center;margin-bottom:16px;}
        .top h1{font-size:20px;margin:0;}
        .top form{margin-left:auto;display:flex;gap:8px}
        .btn{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 12px;border:1px solid #ddd;background:#fff;border-radius:8px;cursor:pointer;text-decoration:none;color:#222}
        .btn.primary{background:#1a237e;border-color:#1a237e;color:#fff}
        .table{width:100%;border-collapse:collapse;background:#fff;border:1px solid #eee;border-radius:8px;overflow:hidden}
        .table th,.table td{padding:10px;border-bottom:1px solid #eee;font-size:14px;vertical-align:top}
        .table th{background:#fafafa;text-align:left;font-weight:700}
        .thumb{width:60px;height:80px;background:#eee center/cover no-repeat;border:1px solid #ddd;border-radius:4px}
        .msg{margin:10px 0;padding:10px;border-radius:6px}
        .msg.ok{background:#e8f5e9;border:1px solid #a5d6a7}
        .msg.err{background:#ffebee;border:1px solid #ef9a9a}
        .pager{display:flex;justify-content:center;gap:6px;margin:16px 0}
        .pager a,.pager span{padding:6px 10px;border:1px solid #ddd;border-radius:6px;text-decoration:none;color:#222;font-size:14px}
        .pager .cur{background:#1a237e;color:#fff;border-color:#1a237e}
    </style>
</head>
<body>
<div class="wrap">
    <c:set var="size" value="${empty size ? 6 : size}"/>

    <div class="top">
        <h1>도서 관리</h1>
        <a class="btn" href="${pageContext.request.contextPath}/bookstore/books">메인으로</a>

        <a class="btn primary" href="${pageContext.request.contextPath}/admin/books/new">+ 새 도서</a>
        <form action="${pageContext.request.contextPath}/admin/books" method="get">
            <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="제목/저자 검색" style="height:36px;padding:0 10px;border:1px solid #ddd;border-radius:8px;"/>
            <button class="btn" type="submit">검색</button>
        </form>
    </div>

    <c:if test="${not empty msg}">
        <div class="msg ok">${msg}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="msg err">${error}</div>
    </c:if>

    <table class="table">
        <thead>
        <tr>
            <th>표지</th>
            <th>제목 / 저자</th>
            <th style="width:120px;">가격</th>
            <th style="width:90px;">재고</th>
            <th style="width:180px;">관리</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="b" items="${content}">
            <tr>
                <td>
                    <div class="thumb" style="background-image:url('${fn:escapeXml(b.coverImage)}');"></div>
                </td>
                <td>
                    <div style="font-weight:700">${fn:escapeXml(b.title)}</div>
                    <div style="color:#666">${fn:escapeXml(b.author)}</div>
                </td>
                <td><c:out value="${b.price}"/> 원</td>
                <td><c:out value="${b.stock}"/> 권</td>
                <td>
                    <a class="btn" href="${pageContext.request.contextPath}/admin/books/${b.bookId}/edit">수정</a>
                    <form action="${pageContext.request.contextPath}/admin/books/${b.bookId}/delete" method="post" style="display:inline">
                        <sec:csrfInput/>
                        <button class="btn" type="submit" onclick="return confirm('삭제하시겠습니까?')">삭제</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty content}">
            <tr><td colspan="5" style="text-align:center;color:#888;padding:20px">데이터가 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>

    <c:set var="tp" value="${totalPages}"/>
    <c:set var="cur" value="${page}"/>

    <div class="pager">
        <c:choose>
            <c:when test="${cur <= 1}">
                <span>이전</span>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/admin/books?q=${fn:escapeXml(q)}&page=${cur-1}&size=${size}">이전</a>
            </c:otherwise>
        </c:choose>

        <c:set var="start" value="${cur-2}"/><c:if test="${start<1}"><c:set var="start" value="1"/></c:if>
        <c:set var="end" value="${start+4}"/><c:if test="${end>tp}"><c:set var="end" value="${tp}"/></c:if>
        <c:if test="${end-start < 4}"><c:set var="start" value="${end-4}"/><c:if test="${start<1}"><c:set var="start" value="1"/></c:if></c:if>

        <c:forEach var="p" begin="${start}" end="${end}">
            <c:choose>
                <c:when test="${p == cur}">
                    <span class="cur">${p}</span>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/admin/books?q=${fn:escapeXml(q)}&page=${p}&size=${size}">${p}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${cur >= tp}">
                <span>다음</span>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/admin/books?q=${fn:escapeXml(q)}&page=${cur+1}&size=${size}">다음</a>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
