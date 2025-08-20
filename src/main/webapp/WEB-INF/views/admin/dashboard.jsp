<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>관리자 대시보드</title>

    <%-- 공통 레이아웃/사이드바 CSS --%>
    <%@ include file="/WEB-INF/views/admin/_layout.css.jspf" %>

    <%-- 대시보드 전용 차트 라이브러리 --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* 그래프 섹션 높이 살짝 줄이기 */
        .chart-box canvas{max-height: 140px;}
    </style>
</head>
<body>

<div class="layout">
    <%-- 공통 사이드바 --%>
    <%@ include file="/WEB-INF/views/admin/_sidebar.jspf" %>

    <main class="main">
        <h2 class="title">대시보드</h2>

        <%-- 숫자 Fallback --%>
        <c:set var="USER_TOTAL"     value="${empty userTotal     ? 0 : userTotal}"/>
        <c:set var="USER_ACTIVE"    value="${empty userActive    ? 0 : userActive}"/>
        <c:set var="USER_INACTIVE"  value="${empty userInactive  ? 0 : userInactive}"/>
        <c:set var="REVENUE"        value="${empty revenue       ? 0 : revenue}"/>

        <%-- 총 도서/주문: 여러 이름 케이스 대응 --%>
        <c:set var="TOTAL_BOOKS"
               value="${not empty totalBooks ? totalBooks
                       : (not empty booksTotal ? booksTotal
                       : (not empty bookCount ? bookCount : 0))}"/>
        <c:set var="TOTAL_ORDERS"
               value="${not empty totalOrders ? totalOrders
                       : (not empty ordersTotal ? ordersTotal
                       : (not empty orderCount ? orderCount : 0))}"/>

        <div class="kpis">
            <div class="kpi">
                <div class="label">총 사용자</div>
                <div class="value"><c:out value="${USER_TOTAL}"/></div>
            </div>
            <div class="kpi">
                <div class="label">활성 사용자</div>
                <div class="value"><c:out value="${USER_ACTIVE}"/></div>
            </div>
            <div class="kpi">
                <div class="label">비활성 사용자</div>
                <div class="value"><c:out value="${USER_INACTIVE}"/></div>
            </div>
            <div class="kpi">
                <div class="label">누적 매출</div>
                <div class="value"><fmt:formatNumber value="${REVENUE}" pattern="#,###"/> 원</div>
            </div>
        </div>

        <div class="grid-2">
            <%-- 주문 상태 분포 (막대 차트) --%>
            <div class="card chart-box">
                <h3 style="margin:0 0 8px">주문 상태 분포</h3>

                <%-- 모델 키 이름 다양성 대응 --%>
                <c:set var="PENDING_CNT"   value="${not empty orderPending   ? orderPending   : (not empty pending   ? pending   : 0)}"/>
                <c:set var="PAID_CNT"      value="${not empty orderPaid      ? orderPaid      : (not empty paid      ? paid      : 0)}"/>
                <c:set var="SHIPPED_CNT"   value="${not empty orderShipped   ? orderShipped   : (not empty shipped   ? shipped   : 0)}"/>
                <c:set var="DELIVERED_CNT" value="${not empty orderDelivered ? orderDelivered : (not empty delivered ? delivered : 0)}"/>
                <%-- CANCELLED / CANCELED 모두 대응 --%>
                <c:set var="CANCELLED_CNT"
                       value="${not empty orderCancelled ? orderCancelled
                                : (not empty cancelled ? cancelled
                                : (not empty orderCanceled ? orderCanceled
                                : (not empty canceled ? canceled : 0)))}"/>

                <canvas id="orderChart" height="110"></canvas>
                <script>
                    (function () {
                        var ctx = document.getElementById('orderChart');
                        if (!ctx) return;

                        // 한글 라벨 & 데이터
                        var labels = ['결제대기','결제완료','배송중','배송완료','취소'];
                        var counts = [${PENDING_CNT}, ${PAID_CNT}, ${SHIPPED_CNT}, ${DELIVERED_CNT}, ${CANCELLED_CNT}];

                        // 상태별 색상
                        var colorMap = {
                            '결제대기': '#94a3b8', // slate-400
                            '결제완료': '#60a5fa', // blue-400
                            '배송중'  : '#34d399', // green-400
                            '배송완료': '#a78bfa', // violet-400
                            '취소'    : '#f87171'  // red-400
                        };
                        var bg = labels.map(function(l){ return colorMap[l]; });

                        new Chart(ctx, {
                            type: 'bar',
                            data: {
                                labels: labels,
                                datasets: [{
                                    data: counts,
                                    backgroundColor: bg,     // ✅ 상태별 막대 색
                                    borderColor: bg,         // (선택) 테두리도 같은 색
                                    borderWidth: 1,
                                    maxBarThickness: 40      // (선택) 막대 두께 제한
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
                                plugins: { legend: { display: false } }
                            }
                        });
                    })();
                </script>

            </div>

            <%-- 요약 --%>
            <div class="card">
                <h3 style="margin:0 0 8px">요약</h3>
                <table>
                    <tr><th style="width:160px">총 도서</th><td><c:out value="${TOTAL_BOOKS}"/></td></tr>
                    <tr><th>총 주문</th><td><c:out value="${TOTAL_ORDERS}"/></td></tr>
                </table>
            </div>
        </div>

        <%-- 최근 주문 --%>
        <div class="card">
            <h3 style="margin:0 0 8px">최근 주문 10건</h3>
            <div style="overflow:auto">
                <table>
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>아이디</th>
                        <th>상태</th>
                        <th style="text-align:right">금액</th>
                        <th>택배사</th>
                        <th>송장</th>
                        <th>발송</th>
                        <th>배송완료</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="o" items="${recent}">
                        <%-- 맵 키 대문자/카멜케이스 모두 대응 --%>
                        <c:set var="OID"     value="${empty o.ORDER_ID     ? o.orderId     : o.ORDER_ID}"/>
                        <c:set var="LOGINID" value="${empty o.LOGIN_ID     ? o.loginId     : o.LOGIN_ID}"/>
                        <c:set var="STATUS_EN"  value="${empty o.STATUS    ? o.status      : o.STATUS}"/>
                        <c:set var="AMOUNT"  value="${empty o.TOTAL_AMOUNT ? o.totalAmount : o.TOTAL_AMOUNT}"/>
                        <c:set var="COURIER" value="${empty o.COURIER      ? o.courier     : o.COURIER}"/>
                        <c:set var="TRACKNO" value="${empty o.TRACKING_NO  ? o.trackingNo  : o.TRACKING_NO}"/>
                        <c:set var="SHIPAT"  value="${empty o.SHIPPED_AT   ? o.shippedAt   : o.SHIPPED_AT}"/>
                        <c:set var="DELIVAT" value="${empty o.DELIVERED_AT ? o.deliveredAt : o.DELIVERED_AT}"/>

                        <%-- 상태 한글화 --%>
                        <c:set var="STATUS_UP" value="${fn:toUpperCase(STATUS_EN)}"/>
                        <c:choose>
                            <c:when test="${STATUS_UP eq 'PENDING'}"><c:set var="STATUS_KO" value="결제대기"/></c:when>
                            <c:when test="${STATUS_UP eq 'PAID'}"><c:set var="STATUS_KO" value="결제완료"/></c:when>
                            <c:when test="${STATUS_UP eq 'SHIPPED'}"><c:set var="STATUS_KO" value="배송중"/></c:when>
                            <c:when test="${STATUS_UP eq 'DELIVERED'}"><c:set var="STATUS_KO" value="배송완료"/></c:when>
                            <c:when test="${STATUS_UP eq 'CANCELLED' or STATUS_UP eq 'CANCELED'}"><c:set var="STATUS_KO" value="취소"/></c:when>
                            <c:otherwise><c:set var="STATUS_KO" value="${STATUS_EN}"/></c:otherwise>
                        </c:choose>

                        <tr>
                            <td><c:out value="${OID}"/></td>
                            <td><c:out value="${LOGINID}"/></td>
                            <td><c:out value="${STATUS_KO}"/></td>
                            <td style="text-align:right"><fmt:formatNumber value="${AMOUNT}" pattern="#,###"/></td>
                            <td><c:out value="${COURIER}"/></td>
                            <td><c:out value="${TRACKNO}"/></td>
                            <td><c:out value="${SHIPAT}"/></td>
                            <td><c:out value="${DELIVAT}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty recent}">
                        <tr><td colspan="8" style="text-align:center;color:#888;padding:16px">데이터가 없습니다.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>
</body>
</html>
