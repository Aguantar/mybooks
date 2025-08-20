package mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface BookReviewMapper {

    // 해당 사용자/책이 'DELIVERED' 상태로 실제 구매했는지 검증
    int canReview(@Param("userId") Long userId, @Param("bookId") Long bookId);

    // 같은 책에 이미 리뷰 작성했는지(1개 제한 시 사용)
    int alreadyReviewed(@Param("userId") Long userId, @Param("bookId") Long bookId);

    // 책별 리뷰 카운트
    int countByBook(@Param("bookId") Long bookId);

    // 책별 리뷰 목록 (작성자 이름 포함)
    List<Map<String,Object>> findByBook(@Param("bookId") Long bookId,
                                        @Param("offset") int offset,
                                        @Param("size") int size);

    // 생성
    int insert(@Param("userId") Long userId,
               @Param("bookId") Long bookId,
               @Param("content") String content);

    // 본인 삭제
    int deleteOwn(@Param("reviewId") Long reviewId, @Param("userId") Long userId);

    // 관리자 삭제
    int adminDelete(@Param("reviewId") Long reviewId);
}
