package service;

import lombok.RequiredArgsConstructor;
import mapper.AdminUserMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class AdminUserService {

    private final AdminUserMapper adminUserMapper;

    public Map<String,Object> list(String q, String status, int page, int size){
        if (page < 1) page = 1;
        if (size < 1) size = 20;
        int offset = (page - 1) * size;

        int total = adminUserMapper.count(q, status);
        int totalPages = (int)Math.ceil(total / (double)size);

        List<Map<String,Object>> rows = adminUserMapper.findPage(q, status, offset, size);

        LinkedHashSet<String> cols = new LinkedHashSet<>();
        String[] preferred = {"USER_ID","LOGIN_ID","NAME","EMAIL","PHONE","ROLE","STATUS","CREATED_AT"};
        for (String c : preferred) {
            if (!rows.isEmpty() && rows.get(0).containsKey(c)) cols.add(c);
        }
        for (Map<String,Object> r : rows) cols.addAll(r.keySet());

        Map<String,Object> m = new HashMap<>();
        m.put("content", rows);
        m.put("columns", new ArrayList<>(cols));
        m.put("page", page);
        m.put("size", size);
        m.put("totalPages", totalPages);
        m.put("totalElements", total);
        m.put("q", q);
        m.put("status", status);
        return m;
    }

    public boolean update(Long id, String role, String status){
        if (id == null) return false;
        if (role == null || role.trim().isEmpty()) return false;
        if (status == null || status.trim().isEmpty()) status = "ACTIVE";

        // 표준화
        String normStatus = status.trim().toUpperCase(Locale.ROOT);

        String r = role.trim().toUpperCase(Locale.ROOT);
        String dbRole = r.startsWith("ROLE_") ? r : "ROLE_" + r; // DB 제약조건에 맞춤

        // 검증 (DB 허용값과 일치해야 함)
        if (!dbRole.equals("ROLE_ADMIN") && !dbRole.equals("ROLE_CUSTOMER")) return false;
        if (!normStatus.equals("ACTIVE") && !normStatus.equals("INACTIVE")) return false;

        int u = adminUserMapper.updateRoleStatus(id, dbRole, normStatus);
        return u == 1;
    }
}
