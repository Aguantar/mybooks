package service;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import mapper.AdminOrderMapper;
import model.view.OrderItemView;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminOrderService {

    private final AdminOrderMapper adminOrderMapper;

    public Map<String,Object> list(String q, String status, int page, int size){
        if (page < 1) page = 1;
        if (size < 1) size = 20;
        int offset = (page - 1) * size;

        int total = adminOrderMapper.count(q, status);
        int totalPages = (int)Math.ceil(total / (double)size);

        List<Map<String, Object>> content = adminOrderMapper.findPage(q, status, offset, size);

        Map<String,Object> m = new HashMap<>();
        m.put("content", content);
        m.put("page", page);
        m.put("size", size);
        m.put("totalPages", totalPages);
        m.put("totalElements", total);
        m.put("q", q);
        m.put("status", status);
        return m;
    }

    public Map<String, Long> getStatusCounts() {
        List<Map<String,Object>> rows = adminOrderMapper.countByStatus();

        Map<String, Long> out = new HashMap<>();
        // 기본값 0 세팅
        out.put("PENDING", 0L);
        out.put("PAID", 0L);
        out.put("SHIPPED", 0L);
        out.put("DELIVERED", 0L);
        out.put("CANCELLED", 0L);

        for (Map<String,Object> r : rows) {
            String st = String.valueOf(r.get("status"));       // XML 별칭 "status"
            Long cnt  = Long.valueOf(String.valueOf(r.get("cnt"))); // XML 별칭 "cnt"
            out.put(st, cnt);
        }
        return out;
    }

    @Data @AllArgsConstructor
    public static class Detail {
        private Map<String,Object> order;          // orderId, loginId, status, totalAmount, address, postcode, courier, trackingNo, shippedAt, deliveredAt
        private List<OrderItemView> items;         // 표지/제목/수량/단가/소계
    }

    public Detail detail(Long orderId){
        Map<String,Object> order = adminOrderMapper.findOrder(orderId);
        if (order == null) return new Detail(null, null);
        List<OrderItemView> items = adminOrderMapper.findItems(orderId);
        return new Detail(order, items);
    }

    /** 상태 변경 (배송정보 포함) */
    public boolean changeStatus(Long orderId, String from, String to, String courier, String trackingNo){
        if (to == null || to.isEmpty()) return false;

        // SHIPPED 전환 시 배송정보 필수
        if ("SHIPPED".equals(to)) {
            if (courier == null || courier.trim().isEmpty()) return false;
            if (trackingNo == null || trackingNo.trim().isEmpty()) return false;
        } else {
            // 다른 상태 전환은 배송정보 무시
            courier = null;
            trackingNo = null;
        }

        int updated = adminOrderMapper.adminUpdateStatus(orderId, from, to, courier, trackingNo);
        return updated > 0;
    }

    /** 에러 메시지 버전 */
    public boolean changeStatus(Long orderId, String from, String to, String courier, String trackingNo, StringBuilder err){
        boolean ok = changeStatus(orderId, from, to, courier, trackingNo);
        if (!ok && err != null) {
            if ("SHIPPED".equals(to)) {
                err.append("발송 처리에 필요한 배송정보(택배사/송장번호)가 누락되었거나, 현재 상태가 ").append(from).append(" 이(가) 아닐 수 있습니다.");
            } else if ("DELIVERED".equals(to)) {
                err.append("배송 완료 처리에 실패했습니다. 현재 상태가 ").append(from).append(" 이(가) 아닐 수 있습니다.");
            } else {
                err.append("상태 변경에 실패했습니다.");
            }
        }
        return ok;
    }
}
