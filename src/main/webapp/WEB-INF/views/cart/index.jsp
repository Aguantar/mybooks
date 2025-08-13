<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>장바구니 - BookMarket</title>
    <style>
        body{font-family:-apple-system,BlinkMacSystemFont,"Noto Sans KR",Segoe UI,Roboto,Arial;margin:0;background:#fafafa;color:#222}
        .wrap{max-width:1000px;margin:32px auto;background:#fff;border:1px solid #eee;border-radius:8px;overflow:hidden;box-shadow:0 6px 20px rgba(0,0,0,.06)}
        .head{display:flex;justify-content:space-between;align-items:center;padding:16px 20px;border-bottom:1px solid #f0f0f0}
        .btn{height:38px;padding:0 14px;border-radius:8px;border:1px solid #1a237e;background:#1a237e;color:#fff;cursor:pointer}
        .btn.sec{background:#fff;color:#1a237e}
        .table{width:100%;border-collapse:collapse}
        .table th,.table td{padding:12px;border-bottom:1px solid #f3f3f3;text-align:left;vertical-align:middle}
        .qty{display:inline-flex;align-items:center;border:1px solid #ddd;border-radius:8px;overflow:hidden}
        .qty button{width:34px;height:34px;border:0;background:#f7f7f7;cursor:pointer}
        .qty input{width:44px;height:34px;border:0;text-align:center}
        .total{display:flex;justify-content:flex-end;padding:16px 20px;font-size:18px;font-weight:800}
        .actions{display:flex;gap:10px;justify-content:flex-end;padding:16px 20px}
        .empty{padding:40px;text-align:center;color:#666}
        a{color:#1a237e;text-decoration:none}
        img.cover{width:54px;height:78px;object-fit:cover;border:1px solid #eee;border-radius:4px;background:#f4f4f4;margin-right:10px}
        .title{font-weight:700}
        .danger{color:#c62828}

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
                <a href="${pageContext.request.contextPath}/mypage" class="text-btn">내 정보</a>
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
        <div>장바구니</div>
        <div><a href="${pageContext.request.contextPath}/bookstore/books">← 계속 쇼핑</a></div>
    </div>

    <c:if test="${cartEmpty}">
        <div class="empty">
            장바구니가 비어 있습니다. <a href="${pageContext.request.contextPath}/bookstore/books">도서 보러가기</a>
        </div>
    </c:if>

    <c:if test="${not cartEmpty}">
        <table class="table" id="cartTable">
            <thead>
            <tr>
                <th>상품</th>
                <th>단가</th>
                <th style="width:160px;">수량</th>
                <th>소계</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="ln" items="${lines}">
                <tr data-book-id="${ln.book.bookId}">
                    <td>
                        <div style="display:flex;align-items:center;">
                            <img class="cover" src="${ln.book.coverImage}" alt="cover"/>
                            <div>
                                <div class="title"><c:out value="${ln.book.title}"/></div>
                                <div style="color:#666"><c:out value="${ln.book.author}"/></div>
                            </div>
                        </div>
                    </td>
                    <td><c:out value="${ln.book.price}"/> 원</td>
                    <td>
                        <div class="qty">
                            <button type="button" class="dec">-</button>
                            <input type="number" class="qty-input" min="1" value="${ln.qty}" />
                            <button type="button" class="inc">+</button>
                        </div>
                    </td>
                    <td class="line-total"><c:out value="${ln.lineTotal}"/> 원</td>
                    <td><button type="button" class="btn sec remove">삭제</button></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

        <div class="total">총 결제 금액: <span style="margin-left:6px;"><c:out value="${totalAmount}"/> 원</span></div>

        <div class="actions">
            <button type="button" id="clearBtn" class="btn sec">전체 비우기</button>
            <button type="button" id="checkoutBtn" class="btn">주문하기</button>
        </div>
    </c:if>
</div>

<script>
    (function(){
        var ctx = '<c:out value="${pageContext.request.contextPath}"/>';

        // ---- cookie helpers (bookDetail과 동일) ----
        function setCookie(name, value, days){
            var expires = '';
            if (days){
                var d = new Date();
                d.setTime(d.getTime() + days*24*60*60*1000);
                expires = '; expires=' + d.toUTCString();
            }
            document.cookie = name + '=' + encodeURIComponent(value) + expires + '; path=' + (ctx || '/') + '; SameSite=Lax';
        }
        function getCookie(name){
            var nameEQ = name + '=';
            var ca = document.cookie.split(';');
            for (var i=0;i<ca.length;i++){
                var c = ca[i].trim();
                if (c.indexOf(nameEQ) === 0) return decodeURIComponent(c.substring(nameEQ.length));
            }
            return null;
        }
        function readCart(){
            try{
                var v = getCookie('cart');
                if(!v) return [];
                var arr = JSON.parse(v);
                return Array.isArray(arr) ? arr : [];
            }catch(e){ return []; }
        }
        function writeCart(arr){
            setCookie('cart', JSON.stringify(arr || []), 7);
        }
        function updateQty(bookId, qty){
            var cart = readCart();
            var id = Number(bookId);
            var found = false;
            for (var i=0;i<cart.length;i++){
                if (cart[i] && Number(cart[i].bookId) === id){
                    if (qty <= 0) { cart.splice(i,1); } else { cart[i].qty = qty; }
                    found = true;
                    break;
                }
            }
            if (!found && qty > 0){ cart.push({bookId:id, qty:qty}); }
            writeCart(cart);
        }
        function removeLine(bookId){
            var cart = readCart().filter(function(it){ return Number(it.bookId) !== Number(bookId); });
            writeCart(cart);
        }
        function clearCart(){
            writeCart([]);
        }
        function deleteCookie(name){
            document.cookie = name + '=; Max-Age=0; path=' + (ctx || '/') + '; SameSite=Lax';
        }

        // ---- UI events ----
        var table = document.getElementById('cartTable');
        if (table){
            table.addEventListener('click', function(e){
                var tr = e.target.closest('tr[data-book-id]');
                if (!tr) return;
                var bookId = tr.getAttribute('data-book-id');
                if (e.target.classList.contains('inc')){
                    var input = tr.querySelector('.qty-input');
                    var v = parseInt(input.value||'1',10); v = isNaN(v)?1:v+1;
                    input.value = v;
                    updateQty(bookId, v);
                    location.reload(); // 서버가 합계 재계산
                }
                if (e.target.classList.contains('dec')){
                    var input2 = tr.querySelector('.qty-input');
                    var v2 = parseInt(input2.value||'1',10); v2 = isNaN(v2)?1:(v2-1);
                    if (v2 < 1) v2 = 0; // 0이면 삭제
                    input2.value = Math.max(0, v2);
                    if (v2 === 0) removeLine(bookId); else updateQty(bookId, v2);
                    location.reload();
                }
                if (e.target.classList.contains('remove')){
                    removeLine(bookId);
                    location.reload();
                }
            });

            // 직접 입력 변경
            table.addEventListener('change', function(e){
                if (!e.target.classList.contains('qty-input')) return;
                var tr = e.target.closest('tr[data-book-id]');
                if (!tr) return;
                var bookId = tr.getAttribute('data-book-id');
                var v = parseInt(e.target.value||'1',10);
                if (isNaN(v) || v < 1){ removeLine(bookId); } else { updateQty(bookId, v); }
                location.reload();
            });
        }

        // 전체 비우기
        var clearBtn = document.getElementById('clearBtn');
        if (clearBtn){
            clearBtn.addEventListener('click', function(){
                clearCart();
                location.reload();
            });
        }

        // 주문하기 (카트 기반 결제): buynow 쿠키를 지워 cart가 우선되도록
        var checkoutBtn = document.getElementById('checkoutBtn');
        if (checkoutBtn){
            checkoutBtn.addEventListener('click', function(){
                deleteCookie('buynow');
                window.location.href = ctx + '/orders/checkout';
            });
        }
    })();
</script>
</body>
</html>
