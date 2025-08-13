package mapper;

import model.Book;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface AdminBookMapper {
    int count(@Param("q") String q);

    List<Book> findPage(@Param("q") String q,
                        @Param("offset") int offset,
                        @Param("size") int size);

    Book findById(@Param("id") Long id);

    int insert(Book book);

    int update(Book book);

    int delete(@Param("id") Long id);
}
