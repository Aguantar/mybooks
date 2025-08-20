package service;

import lombok.RequiredArgsConstructor;
import mapper.AdminReviewMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminReviewService {

    private final AdminReviewMapper adminReviewMapper;

    public int countAll() {
        return adminReviewMapper.countAll();
    }

    public List<Map<String,Object>> findPage(int page, int size) {
        int p = Math.max(1, page);
        int s = Math.min(Math.max(1, size), 50);
        int offset = (p - 1) * s;
        return adminReviewMapper.findPage(offset, s);
    }

    public int delete(Long reviewId) {
        return adminReviewMapper.deleteById(reviewId);
    }
}
