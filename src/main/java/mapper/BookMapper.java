package mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import model.Book;

@Mapper
public interface BookMapper {


    int count(@Param("q") String q);

    List<Book> findPage(
            @Param("q") String q,
            @Param("offset") int offset,
            @Param("pageSize") int pageSize
    );

    Book findBookById(@Param("bookId") Long bookId);

    List<Book> findByIds(@org.apache.ibatis.annotations.Param("ids") java.util.List<Long> ids);
    int decreaseStockIfEnough(@org.apache.ibatis.annotations.Param("bookId") Long bookId,
                              @org.apache.ibatis.annotations.Param("qty") int qty);

    Long selectPrevId(Long bookId); // 현재보다 작은 것 중 최댓값
    Long selectNextId(Long bookId); // 현재보다 큰 것 중 최솟값

    int increaseStock(@org.apache.ibatis.annotations.Param("bookId") Long bookId,
                      @org.apache.ibatis.annotations.Param("qty") int qty);




    /* ----------------------- [관리자 기능] ----------------------- */

    /** 책 등록 */
    int insertBook(Book book);

    /** 책 정보 수정 */
    int updateBook(Book book);

    /** 책 삭제 */
    int deleteBook(@Param("bookId") Long bookId);

    /** 책 재고 수량 수정 */
    int updateBookStock(@Param("bookId") Long bookId,
                        @Param("stock") int stock);

    /** 가격 일괄 수정 (예: 할인 프로모션) */
    int updateBooksPrice(@Param("percent") double percent);

    /** 주문 시 책 재고 감소 */
    int decreaseStock(@Param("bookId") Long bookId,
                      @Param("quantity") int quantity);

    /* ----------------------- [유저 기능] ----------------------- */

    /** 전체 책 목록 조회 (최신순) */
    List<Book> findAllBooks();

    /** 단일 책 상세 조회 */


    /** 키워드 검색 (제목 + 저자 LIKE 검색) */
    List<Book> searchBooksByKeyword(@Param("keyword") String keyword);

    /** 가격대 필터 검색 */
    List<Book> searchBooksByPriceRange(@Param("min") int min,
                                          @Param("max") int max);

    /** 카테고리별 조회 */
    List<Book> findBooksByCategory(@Param("category") String category);
}
