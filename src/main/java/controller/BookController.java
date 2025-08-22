package controller;

import model.Book;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import service.BookService;

import java.util.LinkedHashMap;
import java.util.Map;

@Controller
public class BookController {

    private final BookService bookService;
    public BookController(BookService bookService) { this.bookService = bookService; }

    // 서버사이드 목록(초기 진입/SSR)
    @GetMapping("/bookstore/books")
    public String listPage(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "page", defaultValue = "1") int page,
            Model model) {

        // ▼ 1페이지 & 검색어 없음이면 5개만, 아니면 10개
        boolean firstPageNoQuery = (page <= 1) && (q == null || q.trim().isEmpty());
        int pageSize = firstPageNoQuery ? 5 : 10;

        BookService.Page<Book> result = bookService.search(q, page, pageSize);

        model.addAttribute("q", q == null ? "" : q);
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalElements", result.getTotalElements());
        model.addAttribute("books", result.getContent());

        // ▼ 1페이지 & 검색어 없음일 때만 베스트셀러 캐러셀 데이터 제공
        if (firstPageNoQuery) {
            // BookService에 findBestSellers(int limit) 메서드가 있어야 합니다.
            model.addAttribute("bests", bookService.findBestSellers(5));
        }

        return "bookstore/book";
    }

    // 실시간 검색/페이징 API(JSON)
    @GetMapping(value = "/api/books", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<?> listApi(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        try {
            boolean firstPageNoQuery = (page <= 1) && (q == null || q.trim().isEmpty());
            int effectiveSize = firstPageNoQuery ? 5 : size;

            BookService.Page<Book> p = bookService.search(q, page, effectiveSize);
            return ResponseEntity.ok(p);

        } catch (Exception ex) {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("error", "INTERNAL_SERVER_ERROR");
            body.put("message", ex.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
        }
    }

    // 상세 페이지 (경로/파라미터 모두 bookId로 통일)
    @GetMapping("/bookstore/book/{bookId}")
    public String detail(@PathVariable("bookId") Long bookId, Model model) {
        Book book = bookService.getById(bookId);
        if (book == null) {
            return "redirect:/bookstore/books";
        }

        Long prevId = bookService.getPrevId(bookId);
        Long nextId = bookService.getNextId(bookId);

        model.addAttribute("book", book);
        model.addAttribute("prevId", prevId);
        model.addAttribute("nextId", nextId);
        return "bookstore/bookDetail";
    }
}
