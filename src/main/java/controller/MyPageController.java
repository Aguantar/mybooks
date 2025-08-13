package controller;

import lombok.RequiredArgsConstructor;
import lombok.var;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import service.MyOrderService;

import java.security.Principal; // ✅ 추가

@Controller
@RequiredArgsConstructor
public class MyPageController {

    private final MyOrderService myOrderService;

    @GetMapping("/mypage/orders")
    public String orders(Principal principal, Model model) {
        String loginId = principal.getName();      // ✅ 항상 값 들어옴
        model.addAttribute("orders", myOrderService.list(loginId));
        model.addAttribute("loginId", loginId);     // 헤더에서 쓰려면 사용
        return "mypage/orders";
    }

    @GetMapping("/mypage/orders/{orderId}")
    public String orderDetail(@PathVariable Long orderId,
                              Principal principal,
                              Model model) {
        String loginId = principal.getName();       // ✅
        var d = myOrderService.detail(loginId, orderId);
        if (d.getOrder() == null) return "redirect:/mypage/orders";
        model.addAttribute("order", d.getOrder());
        model.addAttribute("items", d.getItems());
        model.addAttribute("loginId", loginId);
        return "mypage/orderDetail";
    }

    @PostMapping("/mypage/orders/{orderId}/cancel")
    public String cancel(@PathVariable Long orderId,
                         Principal principal,
                         RedirectAttributes ra) {
        String loginId = principal.getName();       // ✅
        boolean ok = myOrderService.cancel(loginId, orderId);
        ra.addFlashAttribute("msg", ok ? "주문이 취소되었습니다." : "취소할 수 없는 상태입니다.");
        return "redirect:/mypage/orders/" + orderId;
    }
}
