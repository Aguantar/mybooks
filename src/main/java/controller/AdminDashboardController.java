// src/main/java/controller/AdminDashboardController.java
package controller;

import lombok.RequiredArgsConstructor;
import mapper.AdminBookMapper;
import mapper.AdminDashboardMapper;   // ✅ 대시보드 전용 매퍼
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminDashboardController {

    private final AdminBookMapper adminBookMapper;
    private final AdminDashboardMapper dashboardMapper; // ✅ 이 매퍼로 KPI/차트/최근주문 전부 조회

    @GetMapping({"", "/dashboard"})
    public String dashboard(Model model) {
        // KPI
        int userTotal    = dashboardMapper.countUsers();
        int userActive   = dashboardMapper.countUsersByStatus("ACTIVE");
        int userInactive = dashboardMapper.countUsersByStatus("INACTIVE");
        Long revenueVal  = dashboardMapper.sumRevenue();   // null 안전 처리
        long revenue     = (revenueVal == null ? 0L : revenueVal);

        // 총 도서/총 주문
        int totalBooks   = adminBookMapper.count(null);
        int totalOrders  = dashboardMapper.countOrders();

        // 주문 상태 (DB 철자: CANCELLED)
        int pending     = dashboardMapper.countOrdersByStatus("PENDING");
        int paid        = dashboardMapper.countOrdersByStatus("PAID");
        int shipped     = dashboardMapper.countOrdersByStatus("SHIPPED");
        int delivered   = dashboardMapper.countOrdersByStatus("DELIVERED");
        int cancelled   = dashboardMapper.countOrdersByStatus("CANCELLED");

        // 최근 주문 10건
        List<Map<String, Object>> recent = dashboardMapper.recentOrders(10);

        // JSP가 기대하는 키로 바인딩
        model.addAttribute("userTotal", userTotal);
        model.addAttribute("userActive", userActive);
        model.addAttribute("userInactive", userInactive);
        model.addAttribute("revenue", revenue);

        model.addAttribute("totalBooks", totalBooks);
        model.addAttribute("totalOrders", totalOrders);

        model.addAttribute("pending", pending);
        model.addAttribute("paid", paid);
        model.addAttribute("shipped", shipped);
        model.addAttribute("delivered", delivered);
        model.addAttribute("cancelled", cancelled);

        // 차트 Fallback 키도 함께
        model.addAttribute("orderPending", pending);
        model.addAttribute("orderPaid", paid);
        model.addAttribute("orderShipped", shipped);
        model.addAttribute("orderDelivered", delivered);
        model.addAttribute("orderCancelled", cancelled);

        model.addAttribute("recent", recent);

        return "admin/dashboard";
    }
}
