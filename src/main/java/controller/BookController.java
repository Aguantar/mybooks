package controller;

import model.Book;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import service.BookService;

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

        BookService.Page<Book> result = bookService.search(q, page, 10);
        model.addAttribute("q", q == null ? "" : q);
        model.addAttribute("page", result.getPage());
        model.addAttribute("size", result.getSize());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalElements", result.getTotalElements());
        model.addAttribute("books", result.getContent());
        return "bookstore/book";
    }

    // 실시간 검색/페이징 API(JSON)
    @GetMapping(value = "/api/books", produces = "application/json;charset=UTF-8")
    @ResponseBody
    public BookService.Page<Book> listApi(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        return bookService.search(q, page, size);
    }

    // 상세 페이지 (경로/파라미터 모두 bookId로 통일)
    @GetMapping("/bookstore/book/{bookId}")
    public String detail(@PathVariable("bookId") Long bookId, Model model) {
        Book book = bookService.getById(bookId);
        if (book == null) {
            return "redirect:/bookstore/books";
        }

        // ← 추가: 이전/다음 도서 id 조회
        Long prevId = bookService.getPrevId(bookId);
        Long nextId = bookService.getNextId(bookId);

        model.addAttribute("book", book);
        model.addAttribute("prevId", prevId); // 없으면 null
        model.addAttribute("nextId", nextId); // 없으면 null
        return "bookstore/bookDetail";
    }



}
