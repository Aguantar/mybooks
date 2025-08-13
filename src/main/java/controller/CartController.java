package controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import service.OrderService;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class CartController {

    private final OrderService orderService;

    /** 장바구니 화면 */
    @GetMapping("/cart")
    public String cartPage(HttpServletRequest request, Model model, HttpSession session) {
        List<OrderService.Item> items = orderService.readCartItemsFromCookies(request);
        OrderService.CheckoutSummary summary = orderService.buildSummary(items);

        model.addAttribute("lines", summary.getLines());       // 주문 라인들
        model.addAttribute("totalAmount", summary.getTotalAmount());
        model.addAttribute("cartEmpty", summary.empty());
        model.addAttribute("loginId", session.getAttribute("loginId"));

        return "cart/index";
    }
}
