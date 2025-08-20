package controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import service.AdminUserService;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final AdminUserService adminUserService;

    @GetMapping
    public String index(@RequestParam(value="q", required=false) String q,
                        @RequestParam(value="status", required=false) String status,
                        @RequestParam(value="page", defaultValue="1") int page,
                        @RequestParam(value="size", defaultValue="20") int size,
                        Model model){
        model.addAllAttributes(adminUserService.list(q, status, page, size));
        return "admin/users/index";
    }

    /** 행 단위 저장 */
    @PostMapping("/{id}")
    public String update(@PathVariable Long id,
                         @RequestParam("role") String role,
                         @RequestParam("status") String status,
                         @RequestHeader(value = "Referer", required = false) String referer,
                         RedirectAttributes ra) {

        boolean ok = adminUserService.update(id, role, status);
        ra.addFlashAttribute(ok ? "msg" : "error",
                ok ? "사용자(#" + id + ") 정보가 저장되었습니다."
                        : "저장 실패: ROLE/STATUS 값을 확인해주세요.");

        // 가능하면 기존 목록(검색/페이지 포함)으로 복귀
        if (referer != null && referer.contains("/admin/users")) {
            return "redirect:" + referer.substring(referer.indexOf("/admin/users"));
        }
        return "redirect:/admin/users";
    }
}
