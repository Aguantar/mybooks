<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>관리자 - 도서 ${mode eq 'edit' ? '수정' : '등록'}</title>
    <style>
        body{font-family:-apple-system,BlinkMacSystemFont,'Noto Sans KR',sans-serif;margin:0;background:#f6f7fb;color:#222;}
        .wrap{max-width:900px;margin:30px auto;padding:0 16px;}
        .card{background:#fff;border:1px solid #eee;border-radius:10px;box-shadow:0 4px 14px rgba(0,0,0,.05);padding:18px;}
        .row{display:grid;grid-template-columns:220px 1fr;gap:18px}
        .thumb{width:220px;height:300px;background:#eee center/cover no-repeat;border:1px solid #ddd;border-radius:6px}
        .fld{display:flex;flex-direction:column;gap:8px;margin-bottom:12px}
        .fld label{font-weight:700}
        .fld input,.fld textarea{border:1px solid #ddd;border-radius:8px;padding:10px;font-size:14px;width:100%}
        .actions{display:flex;gap:8px;margin-top:10px}
        .btn{display:inline-flex;align-items:center;height:40px;padding:0 14px;border:1px solid #ddd;background:#fff;border-radius:8px;cursor:pointer;text-decoration:none;color:#222}
        .btn.primary{background:#1a237e;border-color:#1a237e;color:#fff}
    </style>
</head>
<body>
<div class="wrap">
    <div class="card">
        <h2 style="margin:4px 0 14px">${mode eq 'edit' ? '도서 수정' : '도서 등록'}</h2>

        <c:if test="${not empty error}">
            <div style="background:#ffebee;border:1px solid #ef9a9a;padding:10px;border-radius:6px;margin-bottom:12px">${error}</div>
        </c:if>

        <div class="row">
            <div>
                <div id="preview" class="thumb" style="background-image:url('${book.coverImage}');"></div>
            </div>
            <div>
                <form action="<c:out value='${mode eq "edit" ? pageContext.request.contextPath.concat("/admin/books/").concat(book.bookId) : pageContext.request.contextPath.concat("/admin/books")}'/>" method="post">
                    <sec:csrfInput/>
                    <div class="fld">
                        <label>제목</label>
                        <input type="text" name="title" value="${book.title}" required/>
                    </div>
                    <div class="fld">
                        <label>저자</label>
                        <input type="text" name="author" value="${book.author}" required/>
                    </div>
                    <div class="fld">
                        <label>가격(원)</label>
                        <input type="number" name="price" value="${book.price}" min="0" step="1" required/>
                    </div>
                    <div class="fld">
                        <label>재고(권)</label>
                        <input type="number" name="stock" value="${book.stock}" min="0" step="1" required/>
                    </div>
                    <div class="fld">
                        <label>표지 이미지 URL</label>
                        <input id="coverInput" type="url" name="coverImage" value="${book.coverImage}" placeholder="https://...jpg"/>
                    </div>
                    <div class="fld">
                        <label>상세 설명</label>
                        <textarea name="description" rows="7">${book.description}</textarea>
                    </div>

                    <div class="actions">
                        <button class="btn primary" type="submit">${mode eq 'edit' ? '수정하기' : '등록하기'}</button>
                        <a class="btn" href="${pageContext.request.contextPath}/admin/books">목록으로</a>
                        <a class="btn" href="${pageContext.request.contextPath}/bookstore/book/${book.bookId}" target="_blank"
                           style="${mode eq 'edit' ? '' : 'display:none'}">상세보기</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
    (function(){
        var input = document.getElementById('coverInput');
        var prev  = document.getElementById('preview');
        if(input && prev){
            input.addEventListener('input', function(){
                var url = input.value || '';
                prev.style.backgroundImage = url ? "url('"+url.replace(/'/g,'\\\'')+"')" : 'none';
            });
        }
    })();
</script>
</body>
</html>
