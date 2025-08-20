package mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import model.User;
import java.util.List;

@Mapper
public interface UserMapper {
    // ★ XML의 #{username} 과 일치시킴
    User findByUsername(@Param("username") String username);

    User findByEmail(@Param("email") String email);

    int existsByUsername(@Param("loginId") String loginId);
    int existsByEmail(@Param("email") String email);

    int insertUser(User user);

    List<String> findRolesByUserId(@Param("userId") Long userId);

    // 이름 명시(권장)
    Long selectUserIdByLoginId(@Param("loginId") String loginId);
}
