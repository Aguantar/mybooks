<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>관리자 - 사용자 관리</title>

    <%-- 공통 레이아웃/사이드바 스타일 --%>
    <%@ include file="/WEB-INF/views/admin/_layout.css.jspf" %>

    <style>
        /* 사용자 관리 페이지 전용(필요 최소) */
        .msg{margin:10px 0;padding:10px;border-radius:6px}
        .msg.ok{background:#e8f5e9;border:1px solid #a5d6a7}
        .msg.err{background:#ffebee;border:1px solid #ef9a9a}
        .pager{display:flex;justify-content:center;gap:6px;margin:16px 0}
        .pager a,.pager span{padding:6px 10px;border:1px solid #ddd;border-radius:6px;text-decoration:none;color:#222;font-size:14px;background:#fff}
        .pager .cur{background:#1a237e;color:#fff;border-color:#1a237e}
        .pill{display:inline-flex;gap:8px;flex-wrap:wrap}
        .pill form{display:inline}
        .pill .pbtn{
            height:28px;line-height:28px;padding:0 12px;border:1px solid #ddd;background:#fff;
            border-radius:999px;font-size:12px;cursor:pointer
        }
        .pill .pbtn.on{background:#1a237e;border-color:#1a237e;color:#fff}
        select.small{height:32px;border:1px solid #ddd;border-radius:6px;padding:0 8px;background:#fff}
        input.small{height:32px;padding:0 10px;border:1px solid #ddd;border-radius:8px}
        .btn{display:inline-flex;align-items:center;gap:6px;height:32px;padding:0 12px;border:1px solid #ddd;background:#fff;border-radius:8px;cursor:pointer;text-decoration:none;color:#222}
        .card h3{margin:0 0 10px}
    </style>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="layout">
    <%-- 공통 사이드바 --%>
    <%@ include file="/WEB-INF/views/admin/_sidebar.jspf" %>

    <main class="main">
        <h2 class="title">사용자 관리</h2>
        <a class="btn" href="${ctx}/admin">대시보드</a>

        <%-- 검색/필터 --%>
        <div class="card">
            <form action="${ctx}/admin/users" method="get" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
                <c:set var="fltStatus" value="${fn:toUpperCase(status)}"/>
                <select name="status" class="small">

                    <option value="">상태 전체</option>
                    <option value="ACTIVE"   ${fltStatus eq 'ACTIVE'   ? 'selected="selected"' : ''}>ACTIVE</option>
                    <option value="INACTIVE" ${fltStatus eq 'INACTIVE' ? 'selected="selected"' : ''}>INACTIVE</option>
                </select>
                <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="아이디/이름/이메일" class="small"/>
                <button class="btn" type="submit">검색</button>
            </form>

            <c:if test="${not empty msg}">
                <div class="msg ok">${msg}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="msg err">${error}</div>
            </c:if>
        </div>

        <%-- 목록 --%>
        <div class="card" style="margin-top:14px">
            <div style="overflow:auto">
                <table>
                    <thead>
                    <tr>
                        <th style="width:80px">ID</th>
                        <th>로그인ID</th>
                        <th>이름</th>
                        <th>이메일</th>
                        <th style="width:240px">ROLE</th>
                        <th style="width:260px">STATUS</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="u" items="${content}">
                        <%-- 현재 값 정규화 --%>
                        <c:set var="ROLEVAL"   value="${empty u.ROLE   ? '' : fn:toUpperCase(fn:trim(u.ROLE))}"/>
                        <c:set var="STATUSVAL" value="${empty u.STATUS ? '' : fn:toUpperCase(fn:trim(u.STATUS))}"/>
                        <c:set var="isAdmin"    value="${ROLEVAL eq 'ADMIN' or ROLEVAL eq 'ROLE_ADMIN'}"/>
                        <c:set var="isCustomer" value="${ROLEVAL eq 'CUSTOMER' or ROLEVAL eq 'ROLE_CUSTOMER'}"/>
                        <c:set var="isActive"   value="${STATUSVAL eq 'ACTIVE'}"/>
                        <c:set var="isInactive" value="${STATUSVAL eq 'INACTIVE'}"/>

                        <tr>
                            <td><c:out value="${u.USER_ID}"/></td>
                            <td><c:out value="${u.LOGIN_ID}"/></td>
                            <td><c:out value="${u.NAME}"/></td>
                            <td><c:out value="${u.EMAIL}"/></td>

                                <%-- ROLE: 사용자/관리자 즉시 반영 --%>
                            <td>
                                <div class="pill">
                                    <form action="${ctx}/admin/users/${u.USER_ID}" method="post">
                                        <sec:csrfInput/>
                                        <input type="hidden" name="role" value="CUSTOMER"/>
                                        <input type="hidden" name="status" value="${isInactive ? 'INACTIVE' : 'ACTIVE'}"/>
                                        <button type="submit" class="pbtn ${isCustomer ? 'on' : ''}">사용자</button>
                                    </form>

                                    <form action="${ctx}/admin/users/${u.USER_ID}" method="post">
                                        <sec:csrfInput/>
                                        <input type="hidden" name="role" value="ADMIN"/>
                                        <input type="hidden" name="status" value="${isInactive ? 'INACTIVE' : 'ACTIVE'}"/>
                                        <button type="submit" class="pbtn ${isAdmin ? 'on' : ''}">관리자</button>
                                    </form>
                                </div>
                            </td>

                                <%-- STATUS: active/inactive 즉시 반영 --%>
                            <td>
                                <div class="pill">
                                    <form action="${ctx}/admin/users/${u.USER_ID}" method="post">
                                        <sec:csrfInput/>
                                        <input type="hidden" name="role" value="${isAdmin ? 'ADMIN' : 'CUSTOMER'}"/>
                                        <input type="hidden" name="status" value="ACTIVE"/>
                                        <button type="submit" class="pbtn ${isActive ? 'on' : ''}">active</button>
                                    </form>

                                    <form action="${ctx}/admin/users/${u.USER_ID}" method="post">
                                        <sec:csrfInput/>
                                        <input type="hidden" name="role" value="${isAdmin ? 'ADMIN' : 'CUSTOMER'}"/>
                                        <input type="hidden" name="status" value="INACTIVE"/>
                                        <button type="submit" class="pbtn ${isInactive ? 'on' : ''}">inactive</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty content}">
                        <tr><td colspan="6" style="text-align:center;color:#888;padding:20px">데이터가 없습니다.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>

            <%-- 페이지네이션 --%>
            <c:set var="tp"  value="${totalPages}"/>
            <c:set var="cur" value="${page}"/>

            <div class="pager">
                <c:choose>
                    <c:when test="${cur <= 1}"><span>이전</span></c:when>
                    <c:otherwise>
                        <a href="${ctx}/admin/users?q=${fn:escapeXml(q)}&status=${status}&page=${cur-1}&size=${size}">이전</a>
                    </c:otherwise>
                </c:choose>

                <c:set var="start" value="${cur-2}"/><c:if test="${start<1}"><c:set var="start" value="1"/></c:if>
                <c:set var="end" value="${start+4}"/><c:if test="${end>tp}"><c:set var="end" value="${tp}"/></c:if>
                <c:if test="${end-start < 4}"><c:set var="start" value="${end-4}"/><c:if test="${start<1}"><c:set var="start" value="1"/></c:if></c:if>

                <c:forEach var="p" begin="${start}" end="${end}">
                    <c:choose>
                        <c:when test="${p == cur}"><span class="cur">${p}</span></c:when>
                        <c:otherwise>
                            <a href="${ctx}/admin/users?q=${fn:escapeXml(q)}&status=${status}&page=${p}&size=${size}">${p}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:choose>
                    <c:when test="${cur >= tp}"><span>다음</span></c:when>
                    <c:otherwise>
                        <a href="${ctx}/admin/users?q=${fn:escapeXml(q)}&status=${status}&page=${cur+1}&size=${size}">다음</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>
</body>
</html>
