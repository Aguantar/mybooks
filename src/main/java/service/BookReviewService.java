package service;

import lombok.RequiredArgsConstructor;
import mapper.BookReviewMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class BookReviewService {

    private final BookReviewMapper reviewMapper;

    public Map<String,Object> list(Long bookId, int page, int size){
        if (bookId == null) return Collections.emptyMap();
        if (page < 1) page = 1;
        if (size < 1) size = 10;

        int total = reviewMapper.countByBook(bookId);
        int totalPages = (int)Math.ceil(total / (double)size);
        int offset = (page - 1) * size;

        List<Map<String,Object>> rows = reviewMapper.findByBook(bookId, offset, size);

        Map<String,Object> m = new HashMap<>();
        m.put("content", rows);
        m.put("page", page);
        m.put("size", size);
        m.put("totalPages", totalPages);
        m.put("totalElements", total);
        return m;
    }

    public boolean canReview(Long userId, Long bookId){
        if (userId == null || bookId == null) return false;
        return reviewMapper.canReview(userId, bookId) > 0;
    }

    public boolean alreadyReviewed(Long userId, Long bookId){
        if (userId == null || bookId == null) return false;
        return reviewMapper.alreadyReviewed(userId, bookId) > 0;
    }

    public boolean create(Long userId, Long bookId, String content){
        if (userId == null || bookId == null) return false;
        String c = content == null ? "" : content.trim();
        if (c.isEmpty() || c.length() > 2000) return false;

        // 자격 검증
        if (reviewMapper.canReview(userId, bookId) == 0) return false;

        // 1개 제한
        if (reviewMapper.alreadyReviewed(userId, bookId) > 0) return false;

        return reviewMapper.insert(userId, bookId, c) == 1;
    }

    public boolean deleteOwn(Long reviewId, Long userId){
        if (reviewId == null || userId == null) return false;
        return reviewMapper.deleteOwn(reviewId, userId) == 1;
    }

    public boolean adminDelete(Long reviewId){
        if (reviewId == null) return false;
        return reviewMapper.adminDelete(reviewId) == 1;
    }
}
