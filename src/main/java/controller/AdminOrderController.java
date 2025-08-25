package controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import service.AdminOrderService;

import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/orders")
@PreAuthorize("hasRole('ADMIN')")
public class AdminOrderController {

    private final AdminOrderService adminOrderService;

    @GetMapping
    public String index(@RequestParam(value = "q", required = false) String q,
                        @RequestParam(value = "status", required = false) String status,
                        @RequestParam(value = "page", defaultValue = "1") int page,
                        @RequestParam(value = "size", defaultValue = "20") int size,
                        Model model){
        // 기존: 목록/페이징 모델 주입
        model.addAllAttributes(adminOrderService.list(q, status, page, size));

        // 추가: 상태별 개수 집계 (파이차트용)
        Map<String, Long> sc = adminOrderService.getStatusCounts(); // PENDING/PAID/SHIPPED/DELIVERED/CANCELLED
        long pending   = sc.getOrDefault("PENDING",   0L);
        long paid      = sc.getOrDefault("PAID",      0L);
        long shipped   = sc.getOrDefault("SHIPPED",   0L);
        long delivered = sc.getOrDefault("DELIVERED", 0L);
        long cancelled = sc.getOrDefault("CANCELLED", 0L);
        long total     = pending + paid + shipped + delivered + cancelled;

        model.addAttribute("pendingCnt",   pending);
        model.addAttribute("paidCnt",      paid);
        model.addAttribute("shippedCnt",   shipped);
        model.addAttribute("deliveredCnt", delivered);
        model.addAttribute("cancelledCnt", cancelled);
        model.addAttribute("totalCnt",     total);

        return "admin/orders/index";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable("id") Long id,
                         Model model,
                         RedirectAttributes ra){
        AdminOrderService.Detail d = adminOrderService.detail(id);
        if (d.getOrder() == null){
            ra.addFlashAttribute("error", "존재하지 않는 주문입니다.");
            return "redirect:/admin/orders";
        }
        model.addAttribute("order", d.getOrder());
        model.addAttribute("items", d.getItems());
        return "admin/orders/detail";
    }

    /** 상태 변경 (배송정보 포함) */
    @PostMapping("/{id}/status")
    public String changeStatus(@PathVariable("id") Long id,
                               @RequestParam(value = "from", required = false) String from,
                               @RequestParam("to") String to,
                               @RequestParam(value = "courier", required = false) String courier,
                               @RequestParam(value = "trackingNo", required = false) String trackingNo,
                               RedirectAttributes ra){
        StringBuilder err = new StringBuilder();
        boolean ok = adminOrderService.changeStatus(id, from, to, courier, trackingNo, err);
        ra.addFlashAttribute(ok ? "msg" : "error",
                ok ? "상태가 변경되었습니다." : err.toString());
        return "redirect:/admin/orders/" + id;
    }

    /** 빠른 취소 */
    @PostMapping("/{id}/cancel")
    public String cancel(@PathVariable Long id, RedirectAttributes ra) {
        StringBuilder err = new StringBuilder();
        // 필요에 따라 from을 제한하고 싶다면 "PENDING" 유지, 아니면 null로 바꿔도 됨
        boolean ok = adminOrderService.cancel(id, err);
        ra.addFlashAttribute(ok ? "msg" : "error", ok ? "주문이 취소되었습니다." : err.toString());
        return "redirect:/admin/orders/" + id;
    }
}
