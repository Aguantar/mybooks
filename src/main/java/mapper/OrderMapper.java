package mapper;

import model.Order;
import model.OrderItem;
import model.view.OrderItemView;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface OrderMapper {
    int insertOrder(Order order);              // orderId를 selectKey로 채움
    int insertOrderItem(OrderItem item);       // orderItemId selectKey(선택)
    int updateOrderStatus(Long orderId, String status);
    List<Order> selectOrdersByUser(@Param("userId") Long userId);

    Order selectOrderByIdForUser(@Param("orderId") Long orderId,
                                 @Param("userId") Long userId);

    List<OrderItemView> selectOrderItemsWithBook(@Param("orderId") Long orderId);

    int updateOrderStatus(@Param("orderId") Long orderId,
                          @Param("userId") Long userId,
                          @Param("from") String from,
                          @Param("to") String to);
}


