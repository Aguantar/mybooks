package controller;

import model.Book; // 필요 없으면 제거해도 됨
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import service.OrderService;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
public class OrderController {

    private final OrderService orderService;

    // 명시적 생성자 주입 (Spring 4.3에선 @Autowired 없어도 되지만, 안전하게 붙임)
    @Autowired
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    // 1) 체크아웃 화면: buynow 우선, 없으면 cart
    @GetMapping("/orders/checkout")
    public String checkout(HttpServletRequest request, Model model, HttpSession session) {
        List<OrderService.Item> items = orderService.readCartItemsFromCookies(request);
        OrderService.CheckoutSummary summary = orderService.buildSummary(items);

        if (summary.empty()) {
            model.addAttribute("message", "구매할 상품이 없습니다.");
            return "orders/empty"; // 없으면 목록으로 redirect하도록 바꿔도 됨
        }

        model.addAttribute("lines", summary.lines);
        model.addAttribute("totalAmount", summary.totalAmount);

        Object loginId = session.getAttribute("loginId");
        model.addAttribute("loginId", loginId == null ? "" : loginId.toString());

        return "orders/checkout";
    }

    // 2) 주문 제출
    @PostMapping("/orders/submit")
    public String submit(@RequestParam("address") String address,
                         @RequestParam("postcode") String postcode,
                         HttpServletRequest request,
                         HttpServletResponse response,
                         HttpSession session,
                         Model model) {

        String loginId = (String) session.getAttribute("loginId");
        List<OrderService.Item> items = orderService.readCartItemsFromCookies(request);

        Long orderId = orderService.placeOrder(loginId, items, address, postcode);

        // buynow가 있으면 buynow만 삭제, 아니면 cart 삭제
        clearCookie(response, request, "buynow");
        if (getCookie(request, "buynow") == null) {
            clearCookie(response, request, "cart");
        }

        return "redirect:/orders/complete/" + orderId;
    }

    // 3) 완료 페이지
    @GetMapping("/orders/complete/{orderId}")
    public String complete(@PathVariable Long orderId, Model model) {
        model.addAttribute("orderId", orderId);
        return "orders/complete";
    }

    // ----- helpers -----
    private void clearCookie(HttpServletResponse resp, HttpServletRequest req, String name) {
        String ctx = req.getContextPath();
        javax.servlet.http.Cookie c = new javax.servlet.http.Cookie(name, "");
        c.setMaxAge(0);
        c.setPath((ctx == null || ctx.isEmpty()) ? "/" : ctx);
        resp.addCookie(c);
    }

    private String getCookie(HttpServletRequest req, String name) {
        if (req.getCookies() == null) return null;
        for (javax.servlet.http.Cookie c : req.getCookies()) {
            if (name.equals(c.getName())) return c.getValue();
        }
        return null;
    }
}
