// src/main/java/mapper/ReviewMapper.java
package mapper;

import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ReviewMapper {
    List<Map<String,Object>> listByBook(@Param("bookId") Long bookId,
                                        @Param("userId") Long userId);

    int eligibilityCount(@Param("userId") Long userId,
                         @Param("bookId") Long bookId);

    int hasMyReview(@Param("userId") Long userId,
                    @Param("bookId") Long bookId);

    int insert(@Param("bookId") Long bookId,
               @Param("userId") Long userId,
               @Param("content") String content);

    int update(@Param("reviewId") Long reviewId,
               @Param("userId") Long userId,
               @Param("content") String content);

    int delete(@Param("reviewId") Long reviewId,
               @Param("userId") Long userId);
}
