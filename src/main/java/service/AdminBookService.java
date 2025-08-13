package service;

import lombok.RequiredArgsConstructor;
import mapper.AdminBookMapper;
import model.Book;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminBookService {

    private final AdminBookMapper adminBookMapper;

    public Map<String, Object> list(String q, int page, int size) {
        int total = adminBookMapper.count(q);
        if (page < 1) page = 1;
        int offset = (page - 1) * size;
        List<Book> rows = adminBookMapper.findPage(q, offset, size);

        int totalPages = (int)Math.ceil(total / (double)size);
        Map<String, Object> res = new HashMap<>();
        res.put("content", rows);
        res.put("page", page);
        res.put("size", size);
        res.put("totalElements", total);
        res.put("totalPages", Math.max(totalPages, 1));
        res.put("q", q);
        return res;
    }

    public Book get(Long id) { return adminBookMapper.findById(id); }

    public boolean create(Book b, StringBuilder err) {
        if (!validate(b, err)) return false;
        return adminBookMapper.insert(b) == 1;
    }

    public boolean update(Book b, StringBuilder err) {
        if (b.getBookId() == null) { if (err != null) err.append("잘못된 요청"); return false; }
        if (!validate(b, err)) return false;
        return adminBookMapper.update(b) == 1;
    }

    public boolean delete(Long id) {
        return adminBookMapper.delete(id) == 1;
    }

    private boolean validate(Book b, StringBuilder err) {
        if (b == null) { if (err!=null) err.append("데이터 없음"); return false; }
        if (isBlank(b.getTitle()))  { if (err!=null) err.append("제목은 필수입니다."); return false; }
        if (isBlank(b.getAuthor())) { if (err!=null) err.append("저자는 필수입니다."); return false; }
        if (b.getPrice() == null || b.getPrice() < 0) { if (err!=null) err.append("가격이 올바르지 않습니다."); return false; }
        if (b.getStock() == null || b.getStock() < 0) { if (err!=null) err.append("재고가 올바르지 않습니다."); return false; }
        // coverImage는 URL 텍스트이므로 빈 값 허용(없으면 placeholder)
        return true;
    }
    private boolean isBlank(String s){ return s==null || s.trim().isEmpty(); }
}
