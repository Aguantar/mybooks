package controller;

import lombok.RequiredArgsConstructor;
import mapper.UserMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import service.BookReviewService;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/bookstore/book/{bookId}/reviews")
public class BookReviewController {

    private final BookReviewService reviewService;
    private final UserMapper userMapper;

    private Long currentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) return null;
        Object principal = auth.getPrincipal();
        if (principal == null || "anonymousUser".equals(principal)) return null;
        String loginId = auth.getName(); // LoginService 에서 username=loginId 로 설정됨
        return userMapper.selectUserIdByLoginId(loginId);
    }

    // 목록(JSON) - 누구나 조회 가능(상세 페이지에서 AJAX로 호출)
    @GetMapping(produces = "application/json;charset=UTF-8")
    @ResponseBody
    public Map<String,Object> list(@PathVariable Long bookId,
                                   @RequestParam(defaultValue = "1") int page,
                                   @RequestParam(defaultValue = "10") int size) {
        Map<String,Object> m = reviewService.list(bookId, page, size);
        Long uid = currentUserId();
        m.put("canReview", uid != null && reviewService.canReview(uid, bookId));
        m.put("alreadyReviewed", uid != null && reviewService.alreadyReviewed(uid, bookId));
        return m;
    }

    // 작성(JSON)
    @PostMapping(produces = "application/json;charset=UTF-8")
    @ResponseBody
    @PreAuthorize("hasRole('CUSTOMER')")
    public Map<String,Object> create(@PathVariable Long bookId,
                                     @RequestParam("content") String content) {
        Long uid = currentUserId();
        boolean ok = reviewService.create(uid, bookId, content);
        Map<String,Object> r = new HashMap<>();
        r.put("ok", ok);
        if (!ok) r.put("error", "작성 조건 불충족/중복/길이초과/권한 없음");
        return r;
    }

    // 삭제(JSON) - 본인 또는 관리자
    @PostMapping(path="/{reviewId}/delete", produces = "application/json;charset=UTF-8")
    @ResponseBody
    @PreAuthorize("hasAnyRole('CUSTOMER','ADMIN')")
    public Map<String,Object> delete(@PathVariable Long bookId,
                                     @PathVariable Long reviewId) {
        Long uid = currentUserId();
        boolean ok = reviewService.deleteOwn(reviewId, uid);
        if (!ok) {
            // 관리자면 강제 삭제 허용
            Authentication a = SecurityContextHolder.getContext().getAuthentication();
            boolean isAdmin = a != null && a.getAuthorities().stream()
                    .anyMatch(ga -> "ROLE_ADMIN".equals(ga.getAuthority()));
            if (isAdmin) ok = reviewService.adminDelete(reviewId);
        }
        Map<String,Object> r = new HashMap<>();
        r.put("ok", ok);
        return r;
    }
}
