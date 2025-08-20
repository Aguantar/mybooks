<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title><c:out value="${book.title}"/> - BookMarket</title>

    <!-- AJAX CSRF 메타 태그 (Spring Security) -->
    <sec:csrfMetaTags/>

    <style>
        *{box-sizing:border-box}
        :root{
            --primary:#1a237e; --text-gray:#555; --shadow:rgba(0,0,0,.08);
            --wrap-width:1040px;
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

        /* 좌우 이동 버튼 */
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
        .side-btn.left {  left:  max(12px, calc((100vw - var(--wrap-width))/2 - 105px)); }
        .side-btn.right { right: max(12px, calc((100vw - var(--wrap-width))/2 - 105px)); }
        .side-btn.disabled{opacity:.35;pointer-events:none}

        /* === 리뷰 섹션 === */
        .reviews{max-width:var(--wrap-width);margin:18px auto;background:#fff;border:1px solid #eee;border-radius:8px;
            box-shadow:0 6px 20px rgba(0,0,0,.04);overflow:hidden}
        .reviews .hd{padding:14px 18px;border-bottom:1px solid #f0f0f0;font-weight:800}
        .review-form{padding:14px 18px;border-bottom:1px solid #f6f6f6}
        .review-form textarea{width:100%;min-height:90px;padding:10px;border:1px solid #ddd;border-radius:8px;resize:vertical}
        .review-form .row{display:flex;gap:10px;margin-top:8px;align-items:center}
        .review-form .hint{color:#666;font-size:13px}
        .review-form .btn{height:38px;padding:0 14px;border-radius:8px;border:1px solid #ddd;background:#fff;cursor:pointer}
        .review-form .btn.primary{background:#1a237e;color:#fff;border-color:#1a237e}
        .review-empty{padding:20px;color:#777;text-align:center}
        .review-list{list-style:none;margin:0;padding:0}
        .review-item{padding:14px 18px;border-top:1px solid #f3f3f3}
        .review-item .who{font-weight:700}
        .review-item .when{color:#888;font-size:12px;margin-left:6px}
        .review-item .body{margin-top:6px;white-space:pre-wrap;line-height:1.6}
        .review-item .ops{margin-top:6px}
        .review-item .ops button{height:28px;padding:0 10px;border-radius:6px;border:1px solid #ddd;background:#fff;cursor:pointer;font-size:12px}
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

<!-- 리뷰 섹션 -->
<div class="reviews" id="reviewsBox">
    <div class="hd">리뷰</div>

    <!-- 작성 영역 -->
    <div class="review-form" id="reviewForm" style="display:none">
        <textarea id="reviewContent" placeholder="이 책에 대한 의견을 남겨주세요. (배송완료 고객만 작성 가능) [한글 최대 50자 작성 가능]"></textarea>
        <div class="row">
            <div class="hint" id="reviewHint"></div>
            <div style="margin-left:auto;display:flex;gap:8px">
                <button class="btn" type="button" id="btnCancelReview" style="display:none">취소</button>
                <button class="btn primary" type="button" id="btnSubmitReview">등록</button>
            </div>
        </div>
    </div>

    <!-- 비로그인/비자격 안내 -->
    <div class="review-form" id="reviewNotice" style="display:none">
        <div class="hint" id="reviewNoticeText"></div>
    </div>

    <!-- 목록 -->
    <ul class="review-list" id="reviewList"></ul>
    <div class="review-empty" id="reviewEmpty" style="display:none">아직 등록된 리뷰가 없습니다.</div>
</div>

<!-- wrap 바깥: 이전/다음 -->
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
            for(var i=0;i<i<cart.length;i++){if(cart[i]&&Number(cart[i].bookId)===Number(id)){cart[i].qty=Number(cart[i].qty||0)+qty;f=true;break}}
            if(!f)cart.push({bookId:Number(id),qty:Number(qty)});writeJsonCookie('cart',cart,7)}
        function buyNow(id,qty){qty=qty||1;writeJsonCookie('buynow',{bookId:Number(id),qty:Number(qty)},1);window.location.href=ctx+'/orders/checkout'}

        if(addBtn){addBtn.addEventListener('click',function(){addToCart(bookId,1);showToast('장바구니에 담겼습니다.')})}
        if(buyBtn){buyBtn.addEventListener('click',function(){buyNow(bookId,1)})}
    })();
</script>

<!-- 리뷰 AJAX (목록/작성/삭제) -->
<script>
    (function(){
        var ctx = '<c:out value="${pageContext.request.contextPath}"/>';
        var bookId = ${book.bookId};
        var IS_LOGIN = ${empty sessionScope.loginId ? 'false' : 'true'};

        var listEl = document.getElementById('reviewList');
        var emptyEl = document.getElementById('reviewEmpty');
        var formWrap = document.getElementById('reviewForm');
        var noticeWrap = document.getElementById('reviewNotice');
        var noticeText = document.getElementById('reviewNoticeText');
        var hintEl = document.getElementById('reviewHint');
        var ta = document.getElementById('reviewContent');
        var btnSubmit = document.getElementById('btnSubmitReview');
        var btnCancel = document.getElementById('btnCancelReview');

        // CSRF from meta
        var CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.getAttribute('content');
        var CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content');

        function esc(s){return (s==null?'':String(s))
            .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
            .replace(/"/g,'&quot;').replace(/'/g,'&#39;')}

        function fmtDate(iso){
            if(!iso) return '';
            try{ var d=new Date(iso); return d.toLocaleString(); }catch(e){ return iso; }
        }

        function setWriteUI(canWrite){
            if (canWrite){
                formWrap.style.display = 'block';
                noticeWrap.style.display = 'none';
                hintEl.textContent = '실명: 주문 계정의 이름으로 게시됩니다.';
            }else{
                formWrap.style.display = 'none';
                noticeWrap.style.display = 'block';
                noticeText.innerHTML = IS_LOGIN
                    ? '구매(배송완료) 고객 & 미작성시에만 리뷰를 작성할 수 있습니다.'
                    : '로그인 후 구매(배송완료) 고객만 리뷰를 작성할 수 있습니다.';
            }
        }

        async function checkEligibility(){
            try{
                var r = await fetch(ctx + '/api/books/' + bookId + '/reviews/eligibility', {credentials:'same-origin'});
                if(!r.ok) throw 0;
                var j = await r.json();
                setWriteUI(!!j.canWrite);
            }catch(_){
                setWriteUI(false);
            }
        }

        function applyWriteFormVisibility(rows){
            if(!IS_LOGIN) return; // 비로그인 시 이미 notice로 안내
            var mine = (rows||[]).some(function(x){ return !!(x.mine || x.MINE); });
            if(mine){
                // 이미 내가 쓴 리뷰가 있으면 작성 폼 숨김
                formWrap.style.display = 'none';
                noticeWrap.style.display = 'block';
                noticeText.textContent = '이미 작성하신 리뷰가 있습니다. 수정 또는 삭제를 이용하세요.';
            }
        }

        function renderList(rows){
            listEl.innerHTML = '';
            if(!rows || rows.length===0){
                emptyEl.style.display='block';
                return;
            }
            emptyEl.style.display='none';

            rows.forEach(function(row){
                var li = document.createElement('li');
                li.className = 'review-item';

                var id   = row.reviewId || row.REVIEW_ID;
                var who  = esc(row.userName || row.USER_NAME || '알 수 없음');
                var when = esc(row.createdAt || row.CREATED_AT || '');
                var body = String(row.content || row.CONTENT || '');

                li.innerHTML =
                    '<div class="who">'+ who +'<span class="when">'+ fmtDate(when) +'</span></div>' +
                    '<div class="body"></div>' +
                    '<div class="ops"></div>';

                var bodyEl = li.querySelector('.body');
                bodyEl.textContent = body;

                var mine = !!(row.mine || row.MINE);
                if (mine){
                    var ops = li.querySelector('.ops');

                    var btnEdit = document.createElement('button');
                    btnEdit.textContent='수정';
                    btnEdit.addEventListener('click', function(){
                        enterEditMode(li, id, body);
                    });
                    ops.appendChild(btnEdit);

                    var btnDel = document.createElement('button');
                    btnDel.textContent='삭제';
                    btnDel.style.marginLeft = '6px';
                    btnDel.addEventListener('click', function(){
                        if(!confirm('리뷰를 삭제하시겠습니까?')) return;
                        delReview(id);
                    });
                    ops.appendChild(btnDel);
                }

                listEl.appendChild(li);
            });

            applyWriteFormVisibility(rows);
        }

        function enterEditMode(li, reviewId, oldContent){
            var bodyEl = li.querySelector('.body');
            var opsEl  = li.querySelector('.ops');

            // 이미 편집 중이면 무시
            if(li._editing) return;
            li._editing = true;

            // 기존 내용 백업
            var oldHtml = bodyEl.innerHTML;
            var oldOps  = opsEl.innerHTML;

            // 편집 UI
            bodyEl.innerHTML =
                '<textarea class="rv-edit" style="width:100%;min-height:80px;padding:8px;border:1px solid #ddd;border-radius:8px;"></textarea>';
            bodyEl.querySelector('textarea').value = oldContent;

            opsEl.innerHTML = '';
            var btnSave = document.createElement('button');
            btnSave.textContent = '저장';
            btnSave.addEventListener('click', async function(){
                var newVal = bodyEl.querySelector('textarea').value.trim();
                if(newVal.length < 3){ alert('3자 이상 입력해주세요.'); return; }
                try{
                    await putReview(reviewId, newVal);
                    await loadList();
                }catch(_){
                    alert('수정에 실패했습니다.');
                }finally{
                    li._editing = false;
                }
            });

            var btnCancel = document.createElement('button');
            btnCancel.textContent = '취소';
            btnCancel.style.marginLeft='6px';
            btnCancel.addEventListener('click', function(){
                bodyEl.innerHTML = oldHtml;
                opsEl.innerHTML  = oldOps;
                li._editing = false;
            });

            opsEl.appendChild(btnSave);
            opsEl.appendChild(btnCancel);
        }

        async function loadList(){
            try{
                var r = await fetch(ctx + '/api/books/' + bookId + '/reviews', {credentials:'same-origin'});
                if(!r.ok) throw 0;
                var j = await r.json();
                renderList(j);
            }catch(_){
                listEl.innerHTML = '';
                emptyEl.style.display = 'block';
                emptyEl.textContent = '리뷰를 불러오지 못했습니다.';
            }
        }

        async function postReview(){
            var content = (ta.value || '').trim();
            if(content.length < 3){
                alert('3자 이상 입력해주세요.');
                ta.focus(); return;
            }
            var opt = {
                method:'POST',
                credentials:'same-origin',
                headers:{'Content-Type':'application/json'}
            };
            if (CSRF_TOKEN && CSRF_HEADER) opt.headers[CSRF_HEADER] = CSRF_TOKEN;
            opt.body = JSON.stringify({content: content});
            btnSubmit.disabled = true;
            try{
                var r = await fetch(ctx + '/api/books/' + bookId + '/reviews', opt);
                if(r.status===409){ alert('이미 등록한 리뷰가 있습니다. 수정 기능을 이용하세요.'); return; }
                if(r.status===403){ alert('구매(배송완료) 고객만 작성할 수 있습니다.'); return; }
                if(!r.ok){ alert('등록에 실패했습니다.'); return; }
                ta.value='';
                await loadList();
            }finally{
                btnSubmit.disabled=false;
            }
        }

        async function putReview(reviewId, content){
            var opt = {
                method:'PUT',
                credentials:'same-origin',
                headers:{'Content-Type':'application/json'},
                body: JSON.stringify({content: content})
            };
            if (CSRF_TOKEN && CSRF_HEADER) opt.headers[CSRF_HEADER] = CSRF_TOKEN;
            var r = await fetch(ctx + '/api/books/' + bookId + '/reviews/' + reviewId, opt);
            if(!r.ok) throw new Error('update failed');
        }

        async function delReview(reviewId){
            if(!reviewId) return;
            var opt = { method:'DELETE', credentials:'same-origin', headers:{} };
            if (CSRF_TOKEN && CSRF_HEADER) opt.headers[CSRF_HEADER] = CSRF_TOKEN;
            var r = await fetch(ctx + '/api/books/' + bookId + '/reviews/' + reviewId, opt);
            if(!r.ok){ alert('삭제에 실패했습니다.'); return; }
            await loadList();
        }

        // 이벤트 바인딩
        if(btnSubmit) btnSubmit.addEventListener('click', postReview);
        if(btnCancel) btnCancel.addEventListener('click', function(){ ta.value=''; });

        // 초기 로드
        loadList();
        checkEligibility();
    })();
</script>



<!-- 좌/우 키보드 이동 -->
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
