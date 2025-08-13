package service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import mapper.BookMapper;
import mapper.OrderMapper;
import mapper.UserMapper;
import model.Book;
import model.Order;
import model.OrderItem;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final BookMapper bookMapper;
    private final OrderMapper orderMapper;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** 쿠키에서 buynow 우선, 없으면 cart 파싱 */
    public List<Item> readCartItemsFromCookies(HttpServletRequest req) {
        String buy = getCookie(req, "buynow");
        if (buy != null && !buy.isEmpty()) {
            Item i = parseOne(buy);
            return (i == null) ? Collections.emptyList() : Collections.singletonList(i);
        }
        String cart = getCookie(req, "cart");
        return parseList(cart);
    }

    public static class Item {
        public Long bookId;
        public int qty;
    }

    private String getCookie(HttpServletRequest req, String name) {
        if (req.getCookies() == null) return null;
        for (Cookie c : req.getCookies()) {
            if (name.equals(c.getName())) return decode(c.getValue());
        }
        return null;
    }
    private String decode(String v) {
        try { return java.net.URLDecoder.decode(v, "UTF-8"); } catch (Exception e) { return v; }
    }

    private Item parseOne(String json) {
        try { return objectMapper.readValue(json, Item.class); } catch (Exception e) { return null; }
    }
    private List<Item> parseList(String json) {
        if (json == null || json.trim().isEmpty()) return Collections.emptyList();
        try {
            List<Item> list = objectMapper.readValue(json, new TypeReference<List<Item>>() {});
            // 정합성 보정
            List<Item> safe = new ArrayList<>();
            for (Item i : list) {
                if (i == null || i.bookId == null) continue;
                int q = i.qty <= 0 ? 1 : i.qty;
                safe.add(new Item(){ { bookId = i.bookId; qty = q; } });
            }
            return safe;
        } catch (Exception e) { return Collections.emptyList(); }
    }

    // ===== 화면용 DTO =====
    public static class CheckoutLine {
        // 필드는 그대로 두되, JSP EL용 게터 추가
        public Book book;
        public int qty;
        public int lineTotal;

        public Book getBook()      { return book; }
        public int  getQty()       { return qty; }
        public int  getLineTotal() { return lineTotal; }
    }
    public static class CheckoutSummary {
        public List<CheckoutLine> lines = new ArrayList<>();
        public int totalAmount;

        public List<CheckoutLine> getLines() { return lines; }
        public int getTotalAmount()          { return totalAmount; }
        public boolean empty()               { return lines.isEmpty(); }
    }

    /** DB 가격/재고로 재계산한 견적 */
    public CheckoutSummary buildSummary(List<Item> items) {
        CheckoutSummary sum = new CheckoutSummary();
        if (items == null || items.isEmpty()) return sum;

        List<Long> ids = items.stream().map(i -> i.bookId).distinct().collect(Collectors.toList());
        if (ids.isEmpty()) return sum;

        List<Book> books = bookMapper.findByIds(ids);
        Map<Long, Book> bookMap = books.stream().collect(Collectors.toMap(Book::getBookId, b -> b));

        int total = 0;
        for (Item i : items) {
            Book b = bookMap.get(i.bookId);
            if (b == null) continue;                // 품목 누락 시 제외
            int qty = Math.max(1, i.qty);
            int line = b.getPrice() * qty;
            CheckoutLine cl = new CheckoutLine();
            cl.book = b; cl.qty = qty; cl.lineTotal = line;
            sum.lines.add(cl);
            total += line;
        }
        sum.totalAmount = total;
        return sum;
    }

    /** 실제 주문 생성: 재고 차감 포함 (모두 성공/실패, 원자적) */
    @Transactional
    public Long placeOrder(String loginId, List<Item> items, String address, String postcode) {
        if (loginId == null || loginId.isEmpty()) throw new IllegalStateException("로그인 필요");
        if (items == null || items.isEmpty())     throw new IllegalArgumentException("주문 항목이 비어있음");
        if (address == null || address.isEmpty()) throw new IllegalArgumentException("주소가 필요합니다");
        if (postcode == null || postcode.isEmpty()) throw new IllegalArgumentException("우편번호가 필요합니다");

        Long userId = userMapper.selectUserIdByLoginId(loginId);
        if (userId == null) throw new IllegalStateException("사용자를 찾을 수 없습니다");

        // DB 기준으로 금액 재산출
        CheckoutSummary summary = buildSummary(items);
        if (summary.empty()) throw new IllegalStateException("유효한 주문 항목이 없습니다");

        // 1) orders INSERT (status=PENDING)
        Order order = new Order();
        order.setUserId(userId);
        order.setStatus("PENDING");
        order.setTotalAmount(summary.totalAmount);
        order.setAddress(address);
        order.setPostcode(postcode);
        orderMapper.insertOrder(order); // order.orderId 채워짐

        // 2) 각 항목 INSERT + 재고 차감(조건부)
        for (CheckoutLine cl : summary.lines) {
            int affected = bookMapper.decreaseStockIfEnough(cl.book.getBookId(), cl.qty);
            if (affected == 0) throw new IllegalStateException("재고 부족: " + cl.book.getTitle());

            OrderItem oi = new OrderItem();
            oi.setOrderId(order.getOrderId());
            oi.setBookId(cl.book.getBookId());
            oi.setQuantity(cl.qty);
            oi.setUnitPrice(cl.book.getPrice());
            orderMapper.insertOrderItem(oi);
        }

        return order.getOrderId();
    }
}
