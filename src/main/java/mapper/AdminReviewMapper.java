package mapper;

import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface AdminReviewMapper {
    int countAll();

    List<Map<String,Object>> findPage(@Param("offset") int offset,
                                      @Param("size") int size);

    int deleteById(@Param("reviewId") Long reviewId);
}
