<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>관리자 - 리뷰 관리</title>

    <%-- 공통 레이아웃/사이드바 CSS --%>
    <%@ include file="/WEB-INF/views/admin/_layout.css.jspf" %>

    <style>
        .table{width:100%;border-collapse:collapse;background:#fff;border:1px solid #eee;border-radius:8px;overflow:hidden;table-layout:auto}
        .table th,.table td{padding:10px;border-bottom:1px solid #eee;font-size:14px;vertical-align:top}
        .table th{background:#fafafa;text-align:left;font-weight:700}

        /* 고정폭(작게) — 내용 칸이 넓어지도록 */
        .col-id{width:72px}
        .col-book{width:260px}
        .col-who{width:150px}
        .col-when{width:160px}
        .col-act{width:110px}

        /* 책 정보는 작게/간결하게 */
        .thumb{width:44px;height:58px;background:#eee center/cover no-repeat;border:1px solid #ddd;border-radius:4px;flex:0 0 44px}
        .book-cell{display:flex;gap:10px;align-items:flex-start}
        .book-title a{font-size:14px;font-weight:600;color:#111;text-decoration:none}
        .book-id{display:inline-block;margin-top:4px;font-size:11px;color:#6b7280}

        /* 작성자/작성일은 작고 옅게 */
        .muted{color:#6b7280;font-size:12px}

        /* 내용은 크게 + 더 많이 보이게 */
        .content-big{font-size:15px;line-height:1.7}
        .clamp-5{
            display:-webkit-box;-webkit-line-clamp:5;-webkit-box-orient:vertical;
            overflow:hidden;white-space:normal;
        }

        .btn{display:inline-flex;align-items:center;gap:6px;height:32px;padding:0 12px;border:1px solid #ddd;background:#fff;border-radius:8px;cursor:pointer;text-decoration:none;color:#222}
        .btn.danger{border-color:#fca5a5;color:#b91c1c;background:#fff}

        .msg{margin:10px 0;padding:10px;border-radius:6px}
        .msg.ok{background:#e8f5e9;border:1px solid #a5d6a7}
        .msg.err{background:#ffebee;border:1px solid #ef9a9a}
        .pager{
            display:flex; justify-content:center; gap:6px; margin:16px 0;
        }
        .pager a,.pager span{
            padding:6px 10px; border:1px solid #ddd; border-radius:6px;
            text-decoration:none; color:#222; font-size:14px;
        }
        .pager .cur{ background:#1a237e; color:#fff; border-color:#1a237e; }
        .pager .disabled{ opacity:.45; cursor:default; }

    </style>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="layout">
    <%-- 공통 사이드바 --%>
    <%@ include file="/WEB-INF/views/admin/_sidebar.jspf" %>

    <main class="main">
        <h2 class="title">리뷰 관리</h2>

        <c:if test="${not empty msg}"><div class="msg ok">${msg}</div></c:if>
        <c:if test="${not empty error}"><div class="msg err">${error}</div></c:if>

        <table class="table">
            <thead>
            <tr>
                <th class="col-id">리뷰ID</th>
                <th class="col-book">도서</th>
                <th class="col-who">작성자</th>
                <th>내용</th> <%-- 남은 너비 대부분 차지 --%>
                <th class="col-when">작성일</th>
                <th class="col-act">관리</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="r" items="${content}">
                <tr>
                    <td class="col-id">#<c:out value="${r.reviewId}"/></td>

                    <td class="col-book">
                        <div class="book-cell">
                            <div class="thumb" style="background-image:url('<c:out value="${r.coverImage}"/>')"></div>
                            <div>
                                <div class="book-title">
                                    <a href="${ctx}/bookstore/book/${r.bookId}" target="_blank">
                                        <c:out value="${r.bookTitle}"/>
                                    </a>
                                </div>
                                <div class="book-id">#<c:out value="${r.bookId}"/></div>
                            </div>
                        </div>
                    </td>

                    <td class="col-who">
                        <div><c:out value="${r.userName}"/></div>
                        <div class="muted">UID: <c:out value="${r.userId}"/></div>
                    </td>

                    <td>
                        <div class="content-big clamp-5"><c:out value="${r.content}"/></div>
                    </td>

                    <td class="col-when muted"><c:out value="${r.createdAt}"/></td>

                    <td class="col-act">
                        <form action="${ctx}/admin/reviews/${r.reviewId}/delete" method="post" style="display:inline">
                            <sec:csrfInput/>
                            <button type="submit" class="btn danger" onclick="return confirm('이 리뷰를 삭제하시겠습니까?')">삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty content}">
                <tr>
                    <td colspan="6" style="text-align:center;color:#888;padding:20px">리뷰가 없습니다.</td>
                </tr>
            </c:if>
            </tbody>
        </table>

        <%-- 페이지네이션(그대로) --%>
        <c:set var="tp"  value="${totalPages}"/>
        <c:set var="cur" value="${page}"/>
        <c:set var="size" value="${empty size ? 10 : size}"/>
        <c:set var="tp"   value="${empty totalPages || totalPages < 1 ? 1 : totalPages}"/>
        <c:set var="cur"  value="${empty page || page < 1 ? 1 : page}"/>

        <div class="pager">
            <!-- 이전 -->
            <c:choose>
                <c:when test="${cur <= 1}">
                    <span class="disabled">이전</span>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/admin/reviews?page=${cur-1}&size=${size}">이전</a>
                </c:otherwise>
            </c:choose>

            <!-- 가운데 숫자: 최대 5개 -->
            <c:set var="start" value="${cur-2}"/><c:if test="${start < 1}"><c:set var="start" value="1"/></c:if>
            <c:set var="end" value="${start + 4}"/><c:if test="${end > tp}"><c:set var="end" value="${tp}"/></c:if>
            <c:if test="${end - start < 4}">
                <c:set var="start" value="${end - 4}"/>
                <c:if test="${start < 1}"><c:set var="start" value="1"/></c:if>
            </c:if>

            <c:forEach var="p" begin="${start}" end="${end}">
                <c:choose>
                    <c:when test="${p == cur}">
                        <span class="cur">${p}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/admin/reviews?page=${p}&size=${size}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <!-- 다음 -->
            <c:choose>
                <c:when test="${cur >= tp}">
                    <span class="disabled">다음</span>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/admin/reviews?page=${cur+1}&size=${size}">다음</a>
                </c:otherwise>
            </c:choose>
        </div>

    </main>
</div>
</body>
</html>
