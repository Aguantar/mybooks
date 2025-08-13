package service;

import lombok.RequiredArgsConstructor;
import mapper.BookMapper;
import mapper.OrderMapper;
import mapper.UserMapper;
import model.Order;
import model.view.OrderItemView;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MyOrderService {

    private final OrderMapper orderMapper;
    private final BookMapper  bookMapper;
    private final UserMapper  userMapper;

    public List<Order> list(String loginId){
        Long userId = userMapper.selectUserIdByLoginId(loginId);
        if (userId == null) return Collections.emptyList();
        return orderMapper.selectOrdersByUser(userId);
    }

    public OrderDetail detail(String loginId, Long orderId){
        Long userId = userMapper.selectUserIdByLoginId(loginId);
        Order order  = orderMapper.selectOrderByIdForUser(orderId, userId);
        OrderDetail d = new OrderDetail();
        d.setOrder(order);
        if (order != null){
            d.setItems(orderMapper.selectOrderItemsWithBook(orderId));
        } else {
            d.setItems(Collections.emptyList());
        }
        return d;
    }

    @Transactional
    public boolean cancel(String loginId, Long orderId){
        Long userId = userMapper.selectUserIdByLoginId(loginId);
        // 상태 PENDING -> CANCELLED로 전이될 때만 성공
        int changed = orderMapper.updateOrderStatus(orderId, userId, "PENDING", "CANCELLED");
        if (changed == 0) return false;

        // 재고 롤백
        List<OrderItemView> items = orderMapper.selectOrderItemsWithBook(orderId);
        for (OrderItemView it : items) {
            bookMapper.increaseStock(it.getBookId(), it.getQuantity());
        }
        return true;
    }

    @lombok.Data
    public static class OrderDetail {
        private model.Order order;
        private List<OrderItemView> items;
    }
}
