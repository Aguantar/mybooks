<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>BookMarket</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; }
    body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background: #f9f9f9; color: #333; padding-top: 80px; }

    :root {
      --primary:#1a237e; --accent:#4caf50; --text-gray:#555; --bg-card:#fff; --shadow:rgba(0,0,0,0.08);
      --container-w: 1200px;
      --side-size: 56px;
      --side-gap:  8px;
    }

    header { position: fixed; top:0; left:0; right:0; height:80px; background:#fff; box-shadow:0 2px 8px var(--shadow);
      display:flex; align-items:center; padding:0 20px; z-index:1000; }
    .logo { font-size:1.6em; font-weight:bold; color:var(--primary); }
    .logo a { text-decoration:none; color:inherit; }

    .text-btn { display:inline-flex; align-items:center; justify-content:center; padding:0 14px; height:40px;
      background:var(--primary); color:#fff; border:none; border-radius:4px; font-size:.95em; text-decoration:none; cursor:pointer; margin-left:8px; white-space:nowrap; transition:filter .2s; }
    .text-btn:hover { filter:brightness(1.1); }

    .search-bar { flex:1; margin:0 20px; display:flex; }
    .search-bar input { flex:1; height:40px; padding:0 12px; border:1px solid #ccc; border-right:none; border-radius:20px 0 0 20px; font-size:.95em; outline:none; }
    .search-bar .text-btn { border-radius:0 20px 20px 0; margin-left:0; }

    .icons { display:flex; align-items:center; }
    form.logout-form { margin:0; }

    .container { max-width:1200px; margin:0 auto; padding:20px; }
    .section-title { font-size:1.5em; font-weight:bold; margin-bottom:16px; }

    /* === 베스트셀러 캐러셀 (1행 대체) === */
    .bests-wrap{ margin-bottom:24px; }
    .bests-hd{ display:flex; align-items:center; justify-content:space-between; margin:4px 2px 10px; }
    .bests-hd .tit{ font-size:1.1em; font-weight:800; color:#111; }
    .carousel{
      position:relative; width:100%; height: 260px;
      border:1px solid #eee; border-radius:8px; background:#fff; overflow:hidden;
      box-shadow:0 6px 16px var(--shadow);
    }
    .carousel-track{ display:flex; width:100%; height:100%; transform: translateX(0); }
    .carousel .slide{
      min-width:100%; height:100%;
      display:flex; gap:18px; padding:16px; align-items:stretch; text-decoration:none; color:inherit;
    }
    .slide .rank{ font-weight:900; font-size:22px; color:#1a237e; }
    .slide .cover{
      flex:0 0 200px; height:100%;
      background:#f3f3f3 center/cover no-repeat; border:1px solid #eee; border-radius:8px;
    }
    .slide .info{ display:flex; flex-direction:column; gap:8px; justify-content:center; min-width:0; }
    .slide .title{ font-size:1.2em; font-weight:800; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .slide .author{ color:#666; }
    .slide .meta{ color:#555; font-size:.95em; }
    .cbtn{
      position:absolute; top:50%; transform:translateY(-50%);
      width:40px; height:40px; border-radius:999px; border:1px solid #ddd; background:#fff;
      display:flex; align-items:center; justify-content:center; cursor:pointer; user-select:none;
      box-shadow:0 4px 12px rgba(0,0,0,.12);
    }
    .cbtn.prev{ left:10px } .cbtn.next{ right:10px }
    .dots{ position:absolute; bottom:10px; left:50%; transform:translateX(-50%); display:flex; gap:6px }
    .dot{ width:8px; height:8px; border-radius:50%; background:#ddd }
    .dot.on{ background:#1a237e }

    /* === 5 x 2 그리드(=10개) === */
    .book-grid { display:grid; grid-template-columns:repeat(5, 1fr); gap:24px; }
    .book-card { position:relative; background:var(--bg-card); border:1px solid #eee; border-radius:6px; overflow:hidden;
      text-decoration:none; color:inherit; transition:box-shadow .2s, transform .2s; cursor:pointer; }
    .book-card:hover { box-shadow:0 4px 16px var(--shadow); transform:translateY(-4px); }
    .cover { width:100%; height:240px; background-size:cover; background-position:center; }
    .book-info { padding:12px; }
    .book-title { font-size:.95em; font-weight:600; margin:0 0 4px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .book-author { font-size:.85em; color:var(--text-gray); margin:0; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .book-price { margin-top:6px; font-weight:800; color:#1a237e; }  /* ▶ 가격 스타일 */

    .overlay { position:absolute; inset:0; background:rgba(0,0,0,0.4); display:flex; align-items:center; justify-content:center; opacity:0; transition:opacity .3s; }
    .book-card:hover .overlay { opacity:1; }
    .overlay-text { padding:8px 16px; background:#fff; border-radius:4px; font-size:.9em; font-weight:600; color:var(--primary); }

    /* === 페이지 네비게이션 === */
    .pagination { display:flex; justify-content:center; align-items:center; gap:6px; margin:28px 0 40px; }
    .page-link, .page-current, .page-disabled { padding:6px 10px; border:1px solid #ddd; border-radius:4px; text-decoration:none; color:#333; font-size:.95em; }
    .page-current { background:var(--primary); color:#fff; border-color:var(--primary); font-weight:700; }
    .page-disabled { color:#aaa; background:#f0f0f0; pointer-events:none; }

    /* === 좌우 고정 네비 === */
    .side-btn{
      position: fixed; top: 50%; transform: translateY(-50%);
      width: var(--side-size); height: var(--side-size); border-radius: 999px;
      background: rgba(255,255,255,0.95); border:1px solid rgba(0,0,0,0.12);
      display:flex; align-items:center; justify-content:center;
      font-size:22px; font-weight:700; color:#333; text-decoration:none;
      box-shadow: 0 6px 18px rgba(0,0,0,.12);
      backdrop-filter: blur(6px);
      z-index:1100; user-select:none; transition:transform .12s ease, box-shadow .12s ease;
    }
    .side-btn:hover{ transform: translateY(-50%) scale(1.04); box-shadow: 0 8px 20px rgba(0,0,0,.16); }
    .side-btn:active{ transform: translateY(-50%) scale(0.98); }
    .side-btn.left  { left: calc(50% - (var(--container-w) / 2) - var(--side-gap) - var(--side-size)); }
    .side-btn.right { left: calc(50% + (var(--container-w) / 2) + var(--side-gap)); }
    .side-btn.disabled{ opacity:.35; pointer-events:none; }

    @media (max-width: 1240px){
      .side-btn.left{ left: 10px; }
      .side-btn.right{ left: auto; right: 10px; }
    }

    @media (max-width: 1000px) {
      .book-grid { grid-template-columns: repeat(3, 1fr); }
      .carousel{ height: 300px; }
      .slide .cover{ flex-basis: 180px; }
    }
    @media (max-width: 600px)  {
      .search-bar { flex-direction:column; gap:6px; }
      .search-bar input,.search-bar .text-btn { width:100%; border-radius:8px; }
      .book-grid { grid-template-columns: repeat(2, 1fr); }
      .slide{ gap:12px; }
      .slide .cover{ flex-basis: 130px; }
    }
  </style>
</head>
<body>
<header>
  <div class="logo">
    <a href="${pageContext.request.contextPath}/bookstore/books">BookMarket</a>
  </div>

  <!-- 검색 -->
  <form class="search-bar" action="${pageContext.request.contextPath}/bookstore/books" method="get">
    <input id="searchInput" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="검색어 입력" autocomplete="off"/>
    <button type="submit" class="text-btn" title="검색">검색</button>
  </form>

  <div class="icons">
    <c:choose>
      <c:when test="${empty sessionScope.loginId}">
        <a href="${pageContext.request.contextPath}/cart" class="text-btn">장바구니</a>
        <a href="${pageContext.request.contextPath}/loginForm" class="text-btn">로그인</a>
        <a href="${pageContext.request.contextPath}/register"  class="text-btn">회원가입</a>
      </c:when>
      <c:otherwise>
        <a href="${pageContext.request.contextPath}/cart"   class="text-btn">장바구니</a>
        <sec:authorize access="hasRole('ADMIN')">
          <a href="${pageContext.request.contextPath}/admin/dashboard" class="text-btn">관리자</a>
        </sec:authorize>

        <a href="${pageContext.request.contextPath}/mypage/orders" class="text-btn">주문내역</a>
        <form class="logout-form" action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
          <sec:csrfInput/>
          <button type="submit" class="text-btn">로그아웃</button>
        </form>
      </c:otherwise>
    </c:choose>
  </div>
</header>

<div class="container">
  <div class="section-title">
    전체 도서 목록 (총 <span id="totalCount"><c:out value="${totalElements}"/></span>권)
  </div>

  <!-- ===== 베스트셀러 (1페이지 & 검색어 없음 & 서버가 bests 내려줄 때만) ===== -->
  <c:set var="showBests" value="${(empty q) and (page le 1) and (not empty bests)}"/>
  <div id="bestsBox" class="bests-wrap" style="${showBests ? '' : 'display:none'}">
    <div class="bests-hd">
      <div class="tit">베스트셀러 Top 5</div>
    </div>
    <div class="carousel" id="bestCarousel" aria-label="베스트셀러">
      <div class="carousel-track" id="bestTrack">
        <c:forEach var="b" items="${bests}" varStatus="st">
          <a class="slide" href="${pageContext.request.contextPath}/bookstore/book/${b.bookId}">
            <div class="cover" style="background-image:url('${b.coverImage}');"></div>
            <div class="info">
              <div class="rank">${st.index + 1}위</div>
              <div class="title"><c:out value="${b.title}"/></div>
              <div class="author">저자: <c:out value="${b.author}"/></div>
              <div class="meta">배송완료 누적 판매 기준</div>
            </div>
          </a>
        </c:forEach>
      </div>
      <button type="button" class="cbtn prev" id="bestPrev" aria-label="이전">‹</button>
      <button type="button" class="cbtn next" id="bestNext" aria-label="다음">›</button>
      <div class="dots" id="bestDots">
        <c:forEach var="b" items="${bests}" varStatus="st">
          <div class="dot ${st.index==0 ? 'on' : ''}"></div>
        </c:forEach>
      </div>
    </div>
  </div>

  <!-- ===== 도서 그리드 (1페이지는 5권=1행, 그 외 페이지는 10권=2행) ===== -->
  <div id="bookGrid" class="book-grid">
    <c:forEach var="book" items="${books}">
      <a class="book-card" href="${pageContext.request.contextPath}/bookstore/book/${book.bookId}">
        <div class="cover" style="background-image:url('${book.coverImage}');"></div>
        <div class="book-info">
          <div class="book-title"><c:out value="${book.title}"/></div>
          <div class="book-author"><c:out value="${book.author}"/></div>
          <!-- ▶ 가격 SSR -->
          <div class="book-price"><fmt:formatNumber value="${book.price}" pattern="#,###"/> 원</div>
        </div>
        <div class="overlay"><span class="overlay-text">자세히 보기</span></div>
      </a>
    </c:forEach>
  </div>

  <!-- ===== 페이지 네비 계산 ===== -->
  <c:choose>
    <c:when test="${empty totalPages or totalPages lt 1}">
      <c:set var="tp" value="1"/>
    </c:when>
    <c:otherwise>
      <c:set var="tp" value="${totalPages}"/>
    </c:otherwise>
  </c:choose>
  <c:set var="cur" value="${empty page ? 1 : page}"/>

  <c:set var="startPage" value="${cur - 2}"/>
  <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/></c:if>
  <c:set var="endPage" value="${startPage + 4}"/>
  <c:if test="${endPage > tp}"><c:set var="endPage" value="${tp}"/></c:if>
  <c:if test="${endPage - startPage lt 4}">
    <c:set var="startPage" value="${endPage - 4}"/>
    <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/></c:if>
  </c:if>

  <!-- ===== 페이지 네비게이션 ===== -->
  <div class="pagination" id="pagination">
    <c:choose>
      <c:when test="${cur <= 1}">
        <span class="page-disabled">이전</span>
      </c:when>
      <c:otherwise>
        <c:url var="prevUrl" value="/bookstore/books">
          <c:param name="q" value="${q}"/>
          <c:param name="page" value="${cur-1}"/>
        </c:url>
        <a class="page-link" data-page="${cur-1}" href="${prevUrl}">이전</a>
      </c:otherwise>
    </c:choose>

    <c:forEach var="p" begin="${startPage}" end="${endPage}">
      <c:choose>
        <c:when test="${p == cur}">
          <span class="page-current">${p}</span>
        </c:when>
        <c:otherwise>
          <c:url var="pageUrl" value="/bookstore/books">
            <c:param name="q" value="${q}"/>
            <c:param name="page" value="${p}"/>
          </c:url>
          <a class="page-link" data-page="${p}" href="${pageUrl}">${p}</a>
        </c:otherwise>
      </c:choose>
    </c:forEach>

    <c:choose>
      <c:when test="${cur >= tp}">
        <span class="page-disabled">다음</span>
      </c:when>
      <c:otherwise>
        <c:url var="nextUrl" value="/bookstore/books">
          <c:param name="q" value="${q}"/>
          <c:param name="page" value="${cur+1}"/>
        </c:url>
        <a class="page-link" data-page="${cur+1}" href="${nextUrl}">다음</a>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<!-- ===== 좌우 고정 네비 ===== -->
<c:url var="sidePrevUrl" value="/bookstore/books">
  <c:param name="q" value="${q}"/>
  <c:param name="page" value="${cur-1}"/>
</c:url>
<c:url var="sideNextUrl" value="/bookstore/books">
  <c:param name="q" value="${q}"/>
  <c:param name="page" value="${cur+1}"/>
</c:url>

<a id="navPrev"
   class="side-btn left ${cur <= 1 ? 'disabled' : ''}"
   href="${cur <= 1 ? '#' : sidePrevUrl}"
   data-page="${cur-1}"
   aria-label="이전 페이지">&#10094;</a>

<a id="navNext"
   class="side-btn right ${cur >= tp ? 'disabled' : ''}"
   href="${cur >= tp ? '#' : sideNextUrl}"
   data-page="${cur+1}"
   aria-label="다음 페이지">&#10095;</a>

<!-- ===== 스크립트 ===== -->
<script>
  (function(){
    var ctx   = '<c:out value="${pageContext.request.contextPath}"/>';
    var input = document.getElementById('searchInput');
    var grid  = document.getElementById('bookGrid');
    var pager = document.getElementById('pagination');
    var total = document.getElementById('totalCount');
    var prevBtn = document.getElementById('navPrev');
    var nextBtn = document.getElementById('navNext');

    // 베스트 박스 / 캐러셀 엘리먼트
    var bestsBox = document.getElementById('bestsBox');
    var track = document.getElementById('bestTrack');
    var prev = document.getElementById('bestPrev');
    var next = document.getElementById('bestNext');
    var dotsWrap = document.getElementById('bestDots');

    var timer = null;
    var lastReq = 0;

    function escapeHtml(s){
      return String(s || '').replace(/[&<>"']/g, function(c){
        return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c];
      });
    }

    // ▶ 가격 포맷터(클라이언트)
    function fmtWon(v){
      var n = Number(v);
      if (isNaN(n)) return '';
      try { return n.toLocaleString('ko-KR') + ' 원'; }
      catch(e){ return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ',') + ' 원'; }
    }

    // ===== 캐러셀 (무한 루프) =====
    var autoId = null;
    function updateDots(){
      if(!dotsWrap || !track) return;
      var dots = dotsWrap.children;
      if(!dots || dots.length === 0) return;
      var first = track.firstElementChild;
      var idx = Number(first?.dataset?.origIndex || 0);
      for(var i=0;i<dots.length;i++) dots[i].classList.toggle('on', i===idx);
    }
    function goNext(){
      if(!track || track.children.length === 0) return;
      track.style.transition = 'transform .45s ease';
      track.style.transform = 'translateX(-100%)';
      track.addEventListener('transitionend', function h(){
        track.removeEventListener('transitionend', h);
        track.appendChild(track.firstElementChild);
        track.style.transition = 'none';
        track.style.transform = 'translateX(0)';
        setTimeout(function(){ track.style.transition = ''; }, 20);
        updateDots();
      });
    }
    function goPrev(){
      if(!track || track.children.length === 0) return;
      track.insertBefore(track.lastElementChild, track.firstElementChild);
      track.style.transition = 'none';
      track.style.transform = 'translateX(-100%)';
      setTimeout(function(){
        track.style.transition = 'transform .45s ease';
        track.style.transform = 'translateX(0)';
      }, 20);
      setTimeout(updateDots, 80);
    }
    function startAuto(){ stopAuto(); autoId = setInterval(goNext, 3000); }
    function stopAuto(){ if(autoId){ clearInterval(autoId); autoId = null; } }

    if (track){
      Array.prototype.forEach.call(track.children, function(slide, i){
        slide.dataset.origIndex = String(i);
      });
      updateDots();
      startAuto();
      track.addEventListener('mouseenter', stopAuto);
      track.addEventListener('mouseleave', startAuto);
    }
    if (prev) prev.addEventListener('click', function(){ stopAuto(); goPrev(); startAuto(); });
    if (next) next.addEventListener('click', function(){ stopAuto(); goNext(); startAuto(); });

    // ===== 도서 그리드 렌더 (AJAX) =====
    function renderBooks(items){
      if(!items || items.length === 0){
        grid.innerHTML = '<p>검색 결과가 없습니다.</p>';
        return;
      }
      var html = '';
      for (var i=0;i<items.length;i++){
        var b = items[i];
        var cover = b.coverImage ? String(b.coverImage).replace(/'/g,"\\'") : '';
        html += '<a class="book-card" href="' + ctx + '/bookstore/book/' + b.bookId + '">'
                +   '<div class="cover" style="background-image:url(\'' + cover + '\');"></div>'
                +   '<div class="book-info">'
                +     '<div class="book-title">' + escapeHtml(b.title) + '</div>'
                +     '<div class="book-author">' + escapeHtml(b.author) + '</div>'
                +     '<div class="book-price">' + fmtWon(b.price) + '</div>'  // ▶ 가격 AJAX
                +   '</div>'
                +   '<div class="overlay"><span class="overlay-text">자세히 보기</span></div>'
                + '</a>';
      }
      grid.innerHTML = html;
    }

    // ===== 캐러셀 노출 토글 =====
    function toggleBests(q, page){
      if(!bestsBox) return;
      var show = (!q || q.trim()==='') && (page === 1);
      bestsBox.style.display = show ? '' : 'none';
      if (show) startAuto(); else stopAuto();
    }

    function updateSideNav(cur, tp, q){
      if (prevBtn){
        var prevPage = Math.max(1, cur - 1);
        var prevUrl  = ctx + '/bookstore/books?q=' + encodeURIComponent(q || '') + '&page=' + prevPage;
        prevBtn.setAttribute('data-page', String(prevPage));
        prevBtn.setAttribute('href', prevUrl);
        prevBtn.classList.toggle('disabled', cur <= 1);
      }
      if (nextBtn){
        var nextPage = Math.min(tp, cur + 1);
        var nextUrl  = ctx + '/bookstore/books?q=' + encodeURIComponent(q || '') + '&page=' + nextPage;
        nextBtn.setAttribute('data-page', String(nextPage));
        nextBtn.setAttribute('href', nextUrl);
        nextBtn.classList.toggle('disabled', cur >= tp);
      }
    }

    function renderPagination(cur, tp, q){
      var start = Math.max(1, cur - 2);
      var end   = Math.min(tp, start + 4);
      if (end - start < 4) start = Math.max(1, end - 4);

      var html = '';
      if(cur <= 1){
        html += '<span class="page-disabled">이전</span>';
      }else{
        var prevUrl = ctx + '/bookstore/books?q=' + encodeURIComponent(q || '') + '&page=' + (cur-1);
        html += '<a class="page-link" data-page="' + (cur-1) + '" href="' + prevUrl + '">이전</a>';
      }
      for(var p=start; p<=end; p++){
        if(p === cur){
          html += '<span class="page-current">' + p + '</span>';
        }else{
          var pageUrl = ctx + '/bookstore/books?q=' + encodeURIComponent(q || '') + '&page=' + p;
          html += '<a class="page-link" data-page="' + p + '" href="' + pageUrl + '">' + p + '</a>';
        }
      }
      if(cur >= tp){
        html += '<span class="page-disabled">다음</span>';
      }else{
        var nextUrl = ctx + '/bookstore/books?q=' + encodeURIComponent(q || '') + '&page=' + (cur+1);
        html += '<a class="page-link" data-page="' + (cur+1) + '" href="' + nextUrl + '">다음</a>';
      }

      if (pager) pager.innerHTML = html;
      updateSideNav(cur, tp, q);
    }

    // ===== 페이지 API 호출 (1페이지 & 검색어 없음 -> size=5, 그 외 size=10) =====
    async function fetchPage(q, page, size, pushUrl){
      page = page || 1;
      var effectiveSize = ((!q || q.trim()==='') && page === 1) ? 5 : 10;
      pushUrl = (pushUrl !== false);
      var myReq = ++lastReq;
      var url = ctx + '/api/books?q=' + encodeURIComponent(q || '') + '&page=' + page + '&size=' + effectiveSize;
      var res = await fetch(url, { headers:{ 'Accept':'application/json' }});
      if (myReq !== lastReq) return;
      var data = await res.json();
      renderBooks(data.content);
      renderPagination(data.page, (data.navTotalPages || data.totalPages || 1), q);
      toggleBests(q, data.page);
      if (total) total.textContent = (data.totalElements != null ? data.totalElements : 0);
      if (pushUrl){
        var newUrl = ctx + '/bookstore/books?q=' + encodeURIComponent(q || '') + '&page=' + data.page;
        history.replaceState(null, '', newUrl);
      }
    }

    // 입력 실시간 검색 (디바운스 300ms)
    if (input){
      input.addEventListener('input', function(){
        clearTimeout(timer);
        timer = setTimeout(function(){ fetchPage(input.value, 1, 10, true); }, 300);
      });
      if (input.form){
        input.form.addEventListener('submit', function(e){
          e.preventDefault();
          fetchPage(input.value, 1, 10, true);
        });
      }
    }

    // 하단 pager AJAX 전환
    if (pager){
      pager.addEventListener('click', function(e){
        var a = e.target.closest ? e.target.closest('a.page-link') : null;
        if (!a) return;
        var pAttr = a.getAttribute('data-page');
        var p = pAttr != null ? parseInt(pAttr, 10) : NaN;
        if (!isNaN(p) && grid) {
          e.preventDefault();
          fetchPage(input ? input.value : '', p, 10, true);
        }
      });
    }

    // 좌우 고정 버튼도 AJAX 전환
    function handleSideClick(e){
      var a = e.currentTarget;
      if (!a || a.classList.contains('disabled')) return;
      var p = parseInt(a.getAttribute('data-page'), 10);
      if (!isNaN(p) && grid) {
        e.preventDefault();
        fetchPage(input ? input.value : '', p, 10, true);
      }
    }
    if (prevBtn) prevBtn.addEventListener('click', handleSideClick);
    if (nextBtn) nextBtn.addEventListener('click', handleSideClick);

    // 초기 상태 보정
    var CUR = ${cur}; var TP = ${tp};
    updateSideNav(CUR, TP, input ? input.value : '');
    toggleBests(input ? input.value : '', CUR);
  })();
</script>

</body>
</html>
