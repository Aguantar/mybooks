// src/main/java/controller/ReviewApiController.java
package controller;

import lombok.RequiredArgsConstructor;
import mapper.ReviewMapper;
import mapper.UserMapper;
import model.User;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/books/{bookId}/reviews")
public class ReviewApiController {

    private final ReviewMapper reviewMapper;
    private final UserMapper userMapper;

    private Long currentUserIdOrNull() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) return null;
        String loginId = auth.getName();
        User u = userMapper.findByUsername(loginId);
        return (u == null) ? null : u.getUserId();
    }

    @GetMapping
    public List<Map<String,Object>> list(@PathVariable Long bookId) {
        Long uid = currentUserIdOrNull();
        return reviewMapper.listByBook(bookId, uid);
    }

    @GetMapping("/eligibility")
    public Map<String,Object> eligibility(@PathVariable Long bookId) {
        Long uid = currentUserIdOrNull();
        boolean can = false;
        if (uid != null) {
            // 구매(배송완료)했고, 아직 내 리뷰가 없다면 작성 가능
            can = reviewMapper.eligibilityCount(uid, bookId) > 0
                    && reviewMapper.hasMyReview(uid, bookId) == 0;
        }
        return Collections.singletonMap("canWrite", can);
    }

    @PostMapping
    public ResponseEntity<?> create(@PathVariable Long bookId, @RequestBody Map<String,String> body) {
        Long uid = currentUserIdOrNull();
        if (uid == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        // 구매확정(배송완료) + 중복 작성 방지
        if (reviewMapper.eligibilityCount(uid, bookId) <= 0) return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        if (reviewMapper.hasMyReview(uid, bookId) > 0) return ResponseEntity.status(HttpStatus.CONFLICT).body("already-exists");

        String content = Optional.ofNullable(body.get("content")).orElse("").trim();
        if (content.length() < 3) return ResponseEntity.badRequest().body("too-short");

        reviewMapper.insert(bookId, uid, content);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PutMapping("/{reviewId}")
    public ResponseEntity<?> update(@PathVariable Long bookId,
                                    @PathVariable Long reviewId,
                                    @RequestBody Map<String,String> body) {
        Long uid = currentUserIdOrNull();
        if (uid == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        String content = Optional.ofNullable(body.get("content")).orElse("").trim();
        if (content.length() < 3) return ResponseEntity.badRequest().body("too-short");

        int rows = reviewMapper.update(reviewId, uid, content);
        if (rows == 0) return ResponseEntity.status(HttpStatus.FORBIDDEN).build(); // 남의 글 or 없음
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{reviewId}")
    public ResponseEntity<?> delete(@PathVariable Long bookId, @PathVariable Long reviewId) {
        Long uid = currentUserIdOrNull();
        if (uid == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        int rows = reviewMapper.delete(reviewId, uid);
        if (rows == 0) return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        return ResponseEntity.ok().build();
    }
}
