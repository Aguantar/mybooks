package mapper;

import org.apache.ibatis.annotations.Param;
import model.view.OrderItemView;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

public interface AdminOrderMapper {

    int count(@Param("q") String q, @Param("status") String status);


    // 누적 매출
    long sumRevenue();
    List<Map<String, Object>> countByStatus();

    // 최근 주문 N건 (대시보드용)
    List<Map<String,Object>> findRecent(@Param("limit") int limit);

    List<Map<String,Object>> findPage(@Param("q") String q,
                                      @Param("status") String status,
                                      @Param("offset") int offset,
                                      @Param("size") int size);

    Map<String,Object> findOrder(@Param("orderId") Long orderId);

    List<OrderItemView> findItems(@Param("orderId") Long orderId);

    int adminUpdateStatus(@Param("orderId") Long orderId,
                          @Param("from") String from,
                          @Param("to") String to,
                          @Param("courier") String courier,
                          @Param("trackingNo") String trackingNo);

}
