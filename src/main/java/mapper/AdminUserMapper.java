package mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface AdminUserMapper {

    int count(@Param("q") String q, @Param("status") String status);

    List<Map<String,Object>> findPage(@Param("q") String q,
                                      @Param("status") String status,
                                      @Param("offset") int offset,
                                      @Param("size") int size);

    int updateRoleStatus(@Param("id") Long id,
                         @Param("role") String role,
                         @Param("status") String status);
}
