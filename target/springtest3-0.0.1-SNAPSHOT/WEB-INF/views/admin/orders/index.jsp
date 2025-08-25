<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>관리자 - 주문 관리</title>

    <%@ include file="/WEB-INF/views/admin/_layout.css.jspf" %>

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        .btn{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 12px;border:1px solid #ddd;background:#fff;border-radius:8px;cursor:pointer;text-decoration:none;color:#222}
        .btn.danger{border-color:#fca5a5;color:#b91c1c;background:#fff}
        .btn.primary{background:#1a237e;border-color:#1a237e;color:#fff}
        .btn[disabled]{opacity:.45;cursor:not-allowed}

        .msg{margin:10px 0;padding:10px;border-radius:6px}
        .msg.ok{background:#e8f5e9;border:1px solid #a5d6a7}
        .msg.err{background:#ffebee;border:1px solid #ef9a9a}

        .pager{display:flex;justify-content:center;gap:6px;margin:16px 0}
        .pager a,.pager span{padding:6px 10px;border:1px solid #ddd;border-radius:6px;text-decoration:none;color:#222;font-size:14px;background:#fff}
        .pager .cur{background:#1a237e;color:#fff;border-color:#1a237e}

        .badge{display:inline-block;padding:3px 10px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid transparent}
        .badge.gray{background:#f3f4f6;color:#374151;border-color:#e5e7eb}
        .badge.blue{background:#eff6ff;color:#1d4ed8;border-color:#bfdbfe}
        .badge.orange{background:#fff7ed;color:#b45309;border-color:#fed7aa}
        .badge.green{background:#ecfdf5;color:#047857;border-color:#a7f3d0}
        .badge.red{background:#fef2f2;color:#b91c1c;border-color:#fecaca}

        select.small{height:36px;border:1px solid #ddd;border-radius:8px;padding:0 8px;background:#fff}
        input.small{height:36px;padding:0 10px;border:1px solid #ddd;border-radius:8px}
        table{width:100%;border-collapse:collapse}
        th,td{padding:10px;border-bottom:1px solid #eee;text-align:left;vertical-align:middle}
        th{background:#fafafa}

        tr.rowlink{cursor:pointer}
        tr.rowlink:hover{background:#fafafa}

        /* 좌측 목록 + 우측 통계 2열 */
        .grid-2{
            display:grid;
            grid-template-columns: 2fr 1fr;
            gap:14px;
            align-items:start;
        }
        @media (max-width:1100px){
            .grid-2{ grid-template-columns: 1fr; }
        }

        /* 파이차트 카드 */
        .chart-card .slot{padding:14px}
        .chart-card h3{margin:0 0 8px;font-size:14px}
        .chart-box{height:260px; display:flex; align-items:center; justify-content:center}
        .chart-box canvas{max-height:240px}
        .chart-legend{font-size:12px;color:#555;margin-top:6px}
    </style>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="layout">
    <%@ include file="/WEB-INF/views/admin/_sidebar.jspf" %>

    <main class="main">
        <h2 class="title">주문 관리</h2>
        <a class="btn" href="${ctx}/admin">대시보드</a>

        <!-- 상단 검색/필터 바 (좌측 정렬) -->
        <div class="card">
            <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;justify-content:flex-start">
                <form action="${ctx}/admin/orders" method="get" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
                    <c:set var="fltStatus" value="${fn:toUpperCase(status)}"/>
                    <select name="status" class="small" aria-label="상태">
                        <option value="" ${empty fltStatus ? 'selected="selected"' : ''}>전체 상태</option>
                        <c:forEach var="st" items="${['PENDING','PAID','SHIPPED','DELIVERED','CANCELLED']}">
                            <option value="${st}" ${fltStatus==st ? 'selected="selected"' : ''}>${st}</option>
                        </c:forEach>
                    </select>
                    <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="주문번호/아이디" class="small"/>
                    <button class="btn" type="submit">검색</button>
                </form>
            </div>

            <c:if test="${not empty msg}"><div class="msg ok">${msg}</div></c:if>
            <c:if test="${not empty error}"><div class="msg err">${error}</div></c:if>
        </div>

        <!-- 목록(좌) + 통계(우) -->
        <div class="grid-2" style="margin-top:14px">

            <!-- 좌: 목록 카드 -->
            <div class="card">
                <div style="overflow:auto">
                    <table>
                        <thead>
                        <tr>
                            <th style="width:120px">주문번호</th>
                            <th style="width:180px">아이디</th>
                            <th style="width:140px">상태</th>
                            <th style="width:160px">금액</th>
                            <th>관리</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="o" items="${content}">
                            <c:set var="stUp" value="${fn:toUpperCase(o.status)}"/>
                            <c:choose>
                                <c:when test="${stUp == 'PENDING'}"><c:set var="stKo" value="결제대기"/><c:set var="stCls" value="gray"/></c:when>
                                <c:when test="${stUp == 'PAID'}"><c:set var="stKo" value="결제완료"/><c:set var="stCls" value="blue"/></c:when>
                                <c:when test="${stUp == 'SHIPPED'}"><c:set var="stKo" value="배송중"/><c:set var="stCls" value="orange"/></c:when>
                                <c:when test="${stUp == 'DELIVERED'}"><c:set var="stKo" value="배송완료"/><c:set var="stCls" value="green"/></c:when>
                                <c:when test="${stUp == 'CANCELLED' or stUp == 'CANCELED'}"><c:set var="stKo" value="취소"/><c:set var="stCls" value="red"/></c:when>
                                <c:otherwise><c:set var="stKo" value="${o.status}"/><c:set var="stCls" value="gray"/></c:otherwise>
                            </c:choose>

                            <tr class="rowlink" onclick="location.href='${ctx}/admin/orders/${o.orderId}'">
                                <td>#<c:out value="${o.orderId}"/></td>
                                <td><c:out value="${o.loginId}"/></td>
                                <td><span class="badge ${stCls}"><c:out value="${stKo}"/></span></td>
                                <td><fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/> 원</td>
                                <td onclick="event.stopPropagation()">
                                    <c:choose>
                                        <c:when test="${stUp == 'PENDING' or stUp == 'PAID'}">
                                            <form action="${ctx}/admin/orders/${o.orderId}/cancel" method="post" style="display:inline">
                                                <sec:csrfInput/>
                                                <button type="submit" class="btn danger"
                                                        onclick="return confirm('주문 #${o.orderId} 를 취소하시겠습니까?')">취소</button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn danger" disabled title="취소는 PENDING/PAID 상태에서만 가능합니다.">취소</button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>


                            </tr>
                        </c:forEach>

                        <c:if test="${empty content}">
                            <tr><td colspan="6" style="text-align:center;color:#888;padding:20px">데이터가 없습니다.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- 페이지네이션 -->
                <c:set var="tp"  value="${totalPages}"/>
                <c:set var="cur" value="${page}"/>
                <div class="pager">
                    <c:choose>
                        <c:when test="${cur <= 1}"><span>이전</span></c:when>
                        <c:otherwise>
                            <a href="${ctx}/admin/orders?q=${fn:escapeXml(q)}&status=${status}&page=${cur-1}&size=${size}">이전</a>
                        </c:otherwise>
                    </c:choose>

                    <c:set var="start" value="${cur-2}"/><c:if test="${start<1}"><c:set var="start" value="1"/></c:if>
                    <c:set var="end" value="${start+4}"/><c:if test="${end>tp}"><c:set var="end" value="${tp}"/></c:if>
                    <c:if test="${end-start < 4}">
                        <c:set var="start" value="${end-4}"/>
                        <c:if test="${start<1}"><c:set var="start" value="1"/></c:if>
                    </c:if>

                    <c:forEach var="p" begin="${start}" end="${end}">
                        <c:choose>
                            <c:when test="${p == cur}"><span class="cur">${p}</span></c:when>
                            <c:otherwise>
                                <a href="${ctx}/admin/orders?q=${fn:escapeXml(q)}&status=${status}&page=${p}&size=${size}">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:choose>
                        <c:when test="${cur >= tp}"><span>다음</span></c:when>
                        <c:otherwise>
                            <a href="${ctx}/admin/orders?q=${fn:escapeXml(q)}&status=${status}&page=${cur+1}&size=${size}">다음</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- 우: 통계 카드 (파이 2개) -->
            <div class="card chart-card">
                <div class="slot">
                    <h3>상태 비율</h3>
                    <div class="chart-box"><canvas id="chartStatus"></canvas></div>
                    <div class="chart-legend">PENDING / PAID / SHIPPED / DELIVERED</div>
                </div>
                <div class="slot" style="border-top:1px solid #eee">
                    <h3>취소 비율</h3>
                    <div class="chart-box"><canvas id="chartCancel"></canvas></div>
                    <div class="chart-legend">전체 주문 중 취소 비중</div>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    (function(){
        // 서버에서 내려준 집계 값 (없으면 0)
        var PENDING   = Number('${pendingCnt   != null ? pendingCnt   : 0}');
        var PAID      = Number('${paidCnt      != null ? paidCnt      : 0}');
        var SHIPPED   = Number('${shippedCnt   != null ? shippedCnt   : 0}');
        var DELIVERED = Number('${deliveredCnt != null ? deliveredCnt : 0}');
        var CANCELLED = Number('${cancelledCnt != null ? cancelledCnt : 0}');
        var TOTAL     = Number('${totalCnt     != null ? totalCnt     : 0}');

        // 1) 상태 파이 (4분할, 취소는 제외)
        var el1 = document.getElementById('chartStatus');
        if (el1 && (PENDING+PAID+SHIPPED+DELIVERED) > 0){
            new Chart(el1, {
                type: 'pie',
                data: {
                    labels: ['결제대기','결제완료','배송중','배송완료'],
                    datasets: [{
                        data: [PENDING, PAID, SHIPPED, DELIVERED]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { position: 'bottom' },
                        tooltip: {
                            callbacks: {
                                label: function(ctx){
                                    var sum = PENDING+PAID+SHIPPED+DELIVERED;
                                    var val = ctx.parsed || 0;
                                    var pct = sum ? (val*100/sum).toFixed(1) : 0;
                                    return ctx.label + ': ' + val + ' ('+pct+'%)';
                                }
                            }
                        }
                    }
                }
            });
        }

        // 2) 취소 비율 (취소 vs 비취소)
        var el2 = document.getElementById('chartCancel');
        var nonCancelled = Math.max(0, TOTAL - CANCELLED);
        if (el2 && TOTAL > 0){
            new Chart(el2, {
                type: 'pie',
                data: {
                    labels: ['취소','OTHER'],
                    datasets: [{
                        data: [CANCELLED, nonCancelled]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { position: 'bottom' },
                        tooltip: {
                            callbacks: {
                                label: function(ctx){
                                    var val = ctx.parsed || 0;
                                    var pct = (val*100/TOTAL).toFixed(1);
                                    return ctx.label + ': ' + val + ' ('+pct+'%)';
                                }
                            }
                        }
                    }
                }
            });
        }
    })();
</script>
</body>
</html>
