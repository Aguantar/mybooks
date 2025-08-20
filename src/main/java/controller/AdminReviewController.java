package controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import service.AdminReviewService;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/reviews")
public class AdminReviewController {

    private final AdminReviewService adminReviewService;

    @GetMapping
    public String list(@RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size,
                       Model model) {
        int total = adminReviewService.countAll();
        int s = Math.min(Math.max(1, size), 50);
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) s));

        List<Map<String,Object>> content = adminReviewService.findPage(page, s);

        model.addAttribute("content", content);
        model.addAttribute("page", page);
        model.addAttribute("size", s);
        model.addAttribute("totalPages", totalPages);
        return "admin/reviews";
    }

    @PostMapping("/{reviewId}/delete")
    public String delete(@PathVariable Long reviewId, RedirectAttributes ra) {
        int rows = adminReviewService.delete(reviewId);
        if (rows > 0) {
            ra.addFlashAttribute("msg", "리뷰가 삭제되었습니다.");
        } else {
            ra.addFlashAttribute("error", "삭제할 리뷰가 없거나 실패했습니다.");
        }
        return "redirect:/admin/reviews";
    }
}
