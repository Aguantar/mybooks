package service;

import lombok.RequiredArgsConstructor;
import mapper.AdminDashboardMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {
    private final AdminDashboardMapper mapper;

    public Map<String,Object> overview() {
        Map<String,Object> m = new HashMap<>();
        m.put("userTotal",     mapper.countUsers());
        m.put("userActive",    mapper.countUsersByStatus("ACTIVE"));
        m.put("userInactive",  mapper.countUsersByStatus("INACTIVE"));

        m.put("orderTotal",    mapper.countOrders());
        m.put("orderPending",  mapper.countOrdersByStatus("PENDING"));
        m.put("orderPaid",     mapper.countOrdersByStatus("PAID"));
        m.put("orderShipped",  mapper.countOrdersByStatus("SHIPPED"));
        m.put("orderDelivered",mapper.countOrdersByStatus("DELIVERED"));
        m.put("orderCanceled", mapper.countOrdersByStatus("CANCELED"));

        m.put("revenue", Optional.ofNullable(mapper.sumRevenue()).orElse(0L));
        return m;
    }

    public List<Map<String,Object>> recent(int limit) {
        if (limit < 1) limit = 10;
        return mapper.recentOrders(limit);
    }
}
