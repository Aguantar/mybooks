package mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface AdminDashboardMapper {
    int countUsers();
    int countUsersByStatus(@Param("status") String status);

    int countOrders();
    int countOrdersByStatus(@Param("status") String status);

    Long sumRevenue(); // null일 수 있으니 Long

    List<Map<String,Object>> recentOrders(@Param("limit") int limit);
}
