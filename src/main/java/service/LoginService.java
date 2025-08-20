package service;

import mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Locale;

@Service("loginService")
public class LoginService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // DB에서 사용자 조회 (status, role 포함해서 가져오도록 mapper/모델 보강되어 있어야 함)
        model.User m = userMapper.findByUsername(username);
        if (m == null) {
            throw new UsernameNotFoundException("사용자 없음: " + username);
        }

        // 1) 차단 사용자(INACTIVE) 로그인 금지 (맞춤 메시지)
        String status = m.getStatus(); // users.status (ACTIVE / INACTIVE)
        if (status != null && !"ACTIVE".equalsIgnoreCase(status)) {
            throw new DisabledException("차단된 사용자입니다.\n관리자에게 문의하십시오.\n관리자 이메일 : will2019@naver.com");
        }

        // 2) ROLE 보정: DB에는 ADMIN / CUSTOMER 로 저장 → Spring Security는 ROLE_ 접두사 필요
        String role = (m.getRole() == null ? "CUSTOMER" : m.getRole().toUpperCase(Locale.ROOT));
        if (role.startsWith("ROLE_")) {
            role = role.substring("ROLE_".length()); // 혹시 이미 붙어있으면 중복 방지
        }
        GrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + role);

        // 3) UserDetails 반환
        return org.springframework.security.core.userdetails.User.builder()
                .username(m.getLoginId())
                .password(m.getPassword()) // 인코딩된 비밀번호
                .authorities(Collections.singletonList(authority))
                // 여기서는 DisabledException을 이미 던졌으므로 enabled=true 유지
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .disabled(false)
                .build();
    }
}
