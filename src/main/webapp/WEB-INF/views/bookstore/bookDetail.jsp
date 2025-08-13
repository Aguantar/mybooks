<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title><c:out value="${book.title}"/> - BookMarket</title>
    <style>
        *{box-sizing:border-box}
        :root{
            --primary:#1a237e; --text-gray:#555; --shadow:rgba(0,0,0,.08);
            --wrap-width:1040px;           /* wrap의 최대 너비(계산에 사용) */
        }
        body{margin:0;font-family:-apple-system,BlinkMacSystemFont,"Noto Sans KR",Segoe UI,Roboto,Arial,"Apple SD Gothic Neo",sans-serif;background:#fafafa;color:#222;padding-top:80px}

        /* 헤더 */
        header{position:fixed;top:0;left:0;right:0;height:80px;background:#fff;box-shadow:0 2px 8px var(--shadow);
            display:flex;align-items:center;padding:0 20px;z-index:1000}
        .logo{font-size:1.6em;font-weight:700;color:var(--primary)}
        .logo a{text-decoration:none;color:inherit}
        .text-btn{display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 14px;border-radius:6px;
            background:var(--primary);color:#fff;text-decoration:none;border:0;cursor:pointer;margin-left:8px}
        .icons{display:flex;align-items:center;margin-left:auto}
        form.logout-form{margin:0}

        /* 상세 카드 */
        .wrap{max-width:var(--wrap-width);margin:40px auto;background:#fff;border:1px solid #eee;border-radius:8px;
            box-shadow:0 6px 20px rgba(0,0,0,.06);overflow:hidden}
        .topbar{padding:14px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;gap:12px}
        .topbar a{text-decoration:none;color:#1a237e;font-weight:700}
        .content{display:flex;gap:28px;padding:24px}
        .cover{flex:0 0 360px;height:520px;background:#f4f4f4 center/cover no-repeat;border:1px solid #eee;border-radius:6px}
        .meta{flex:1;min-width:0}
        .title{font-size:24px;font-weight:800;margin:4px 0 8px}
        .author{color:#666;margin-bottom:16px}
        .price{font-size:22px;font-weight:800;color:#1a237e;margin:10px 0}
        .stock.ok{color:#2e7d32;font-weight:700}
        .stock.none{color:#c62828;font-weight:700}
        .desc{line-height:1.6;color:#333;white-space:pre-wrap;border-top:1px dashed #eee;margin-top:18px;padding-top:18px}
        .actions{display:flex;gap:12px;margin-top:18px}
        button.btn{height:44px;padding:0 18px;border-radius:8px;border:1px solid #ddd;background:#fff;cursor:pointer;font-weight:700}
        button.primary{background:#1a237e;color:#fff;border-color:#1a237e}
        button[disabled]{opacity:.45;cursor:not-allowed}

        @media (max-width:900px){.content{flex-direction:column}.cover{width:100%;height:420px}}

        /* 토스트 */
        .toast{position:fixed;left:50%;bottom:28px;transform:translateX(-50%);background:#323232;color:#fff;padding:10px 14px;border-radius:6px;opacity:0;transition:.25s;pointer-events:none}
        .toast.show{opacity:1}

        /* 카드 "밖"에 붙는 좌우 슬라이드(뷰포트 고정) */
        .side-btn{
            position:fixed; top:50%; transform:translateY(-50%);
            width:56px; height:56px; border-radius:999px;
            background:#fff; border:1px solid #ddd;
            display:flex; align-items:center; justify-content:center;
            font-size:24px; font-weight:700; color:#333; text-decoration:none;
            box-shadow:0 8px 22px rgba(0,0,0,.12);
            z-index:1100; user-select:none;
        }
        .side-btn:hover{filter:brightness(1.05)}
        /* wrap의 바깥 12px 지점에 위치. 화면이 더 좁아지면 최소 12px 여백 유지 */
        .side-btn.left {  left:  max(12px, calc((100vw - var(--wrap-width))/2 - 105px)); }
        .side-btn.right { right: max(12px, calc((100vw - var(--wrap-width))/2 - 105px)); }
        .side-btn.disabled{opacity:.35;pointer-events:none}
    </style>
</head>
<body>
<header>
    <div class="logo"><a href="${pageContext.request.contextPath}/bookstore/books">BookMarket</a></div>
    <div class="icons">
        <c:choose>
            <c:when test="${empty sessionScope.loginId}">
                <a href="${pageContext.request.contextPath}/cart" class="text-btn">장바구니</a>
                <a href="${pageContext.request.contextPath}/loginForm" class="text-btn">로그인</a>
                <a href="${pageContext.request.contextPath}/register" class="text-btn">회원가입</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/cart" class="text-btn">장바구니</a>
                <a href="${pageContext.request.contextPath}/mypage/orders" class="text-btn">주문내역</a>
                <form class="logout-form" action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                    <sec:csrfInput/><button type="submit" class="text-btn">로그아웃</button>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</header>

<!-- 상세 카드 -->
<div class="wrap">
    <div class="topbar">
        <a href="${pageContext.request.contextPath}/bookstore/books">← 목록으로</a>
    </div>

    <div class="content">
        <div class="cover" style="background-image:url('<c:out value="${book.coverImage}"/>');"></div>

        <div class="meta">
            <div class="title"><c:out value="${book.title}"/></div>
            <div class="author">저자: <c:out value="${book.author}"/></div>

            <div class="price"><c:out value="${book.price}"/> 원</div>

            <c:choose>
                <c:when test="${book.stock > 0}">
                    <div class="stock ok">재고 있음 · <c:out value="${book.stock}"/>권</div>
                </c:when>
                <c:otherwise>
                    <div class="stock none">일시 품절</div>
                </c:otherwise>
            </c:choose>

            <div class="actions">
                <button id="addCartBtn" class="btn" <c:if test="${book.stock le 0}">disabled</c:if>>장바구니 담기</button>
                <button id="buyNowBtn" class="btn primary" <c:if test="${book.stock le 0}">disabled</c:if>>바로구매</button>
            </div>

            <div class="desc"><c:out value="${book.description}"/></div>
        </div>
    </div>
</div>

<!-- wrap 바깥(문서 어디에 두어도 됨). position:fixed 로 화면 좌우에 붙음 -->
<c:url var="prevHref" value="/bookstore/book/${prevId}"/>
<c:url var="nextHref" value="/bookstore/book/${nextId}"/>

<a id="navPrev" class="side-btn left ${empty prevId ? 'disabled' : ''}"
   href="${empty prevId ? '#' : prevHref}" aria-label="이전 도서">&#10094;</a>

<a id="navNext" class="side-btn right ${empty nextId ? 'disabled' : ''}"
   href="${empty nextId ? '#' : nextHref}" aria-label="다음 도서">&#10095;</a>

<div id="toast" class="toast">담겼습니다.</div>

<!-- 장바구니/바로구매 쿠키 -->
<script>
    (function(){
        var ctx    = '<c:out value="${pageContext.request.contextPath}"/>';
        var bookId = ${book.bookId};
        var addBtn = document.getElementById('addCartBtn');
        var buyBtn = document.getElementById('buyNowBtn');
        var toast  = document.getElementById('toast');

        function showToast(msg){
            if(!toast) return; toast.textContent = msg; toast.classList.add('show');
            setTimeout(function(){ toast.classList.remove('show'); }, 1200);
        }
        function setCookie(n,v,d){var p=[n+'='+encodeURIComponent(v)];
            if(d){var t=new Date();t.setTime(t.getTime()+d*24*60*60*1000);p.push('Expires='+t.toUTCString())}
            p.push('Path=/');p.push('SameSite=Lax');document.cookie=p.join('; ');
        }
        function getCookie(n){var k=n+'=',a=document.cookie.split(';');for(var i=0;i<a.length;i++){var c=a[i].trim();if(c.indexOf(k)===0)return decodeURIComponent(c.substring(k.length))}return null}
        function readJsonCookie(n,def){try{var v=getCookie(n);if(!v)return def;return JSON.parse(v)}catch(e){return def}}
        function writeJsonCookie(n,obj,d){setCookie(n,JSON.stringify(obj),d)}
        function addToCart(id,qty){qty=qty||1;var cart=readJsonCookie('cart',[]),f=false;
            for(var i=0;i<cart.length;i++){if(cart[i]&&Number(cart[i].bookId)===Number(id)){cart[i].qty=Number(cart[i].qty||0)+qty;f=true;break}}
            if(!f)cart.push({bookId:Number(id),qty:Number(qty)});writeJsonCookie('cart',cart,7)}
        function buyNow(id,qty){qty=qty||1;writeJsonCookie('buynow',{bookId:Number(id),qty:Number(qty)},1);window.location.href=ctx+'/orders/checkout'}

        if(addBtn){addBtn.addEventListener('click',function(){addToCart(bookId,1);showToast('장바구니에 담겼습니다.')})}
        if(buyBtn){buyBtn.addEventListener('click',function(){buyNow(bookId,1)})}
    })();
</script>

<!-- 좌/우 클릭 + 키보드 -->
<script>
    (function(){
        var prev=document.getElementById('navPrev');
        var next=document.getElementById('navNext');
        function go(a){ if(!a || a.classList.contains('disabled')) return; window.location.href=a.getAttribute('href'); }
        if(prev) prev.addEventListener('click', function(e){ if(prev.classList.contains('disabled')) e.preventDefault(); });
        if(next) next.addEventListener('click', function(e){ if(next.classList.contains('disabled')) e.preventDefault(); });
        document.addEventListener('keydown', function(e){
            if(e.key==='ArrowLeft')  go(prev);
            if(e.key==='ArrowRight') go(next);
        });
    })();
</script>
</body>
</html>
