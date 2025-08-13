package controller;

import lombok.RequiredArgsConstructor;
import model.Book;
import org.springframework.beans.propertyeditors.CustomNumberEditor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import service.AdminBookService;

import java.math.BigDecimal;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/books")
@PreAuthorize("hasRole('ADMIN')")
public class AdminBookController {

    private final AdminBookService adminBookService;
    private static final int DEFAULT_PAGE_SIZE = 6;   // ← 기본 6개

    /** 폼 바인딩 보강: 공백 -> null, 숫자 비워도 null 허용 */
    @InitBinder
    void initBinder(WebDataBinder binder) {
        // "   " -> null
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
        // 숫자 필드 비워도(null) 들어오게 허용
        binder.registerCustomEditor(Integer.class, new CustomNumberEditor(Integer.class, true));
        binder.registerCustomEditor(Long.class, new CustomNumberEditor(Long.class, true));
        binder.registerCustomEditor(BigDecimal.class, new CustomNumberEditor(BigDecimal.class, true));
    }

    @GetMapping
    public String index(@RequestParam(value="q", required=false) String q,
                        @RequestParam(value="page", defaultValue="1") int page,
                        @RequestParam(value="size", required=false) Integer size,
                        Model model) {

        int pageSize = (size == null || size < 1 || size > 100) ? DEFAULT_PAGE_SIZE : size; // 안전 보정

        model.addAllAttributes(adminBookService.list(q, page, pageSize));
        // JSP에서 검색/페이징 링크에 다시 써먹을 값들
        model.addAttribute("q", q);
        model.addAttribute("page", page);
        model.addAttribute("size", pageSize);

        return "admin/books/index";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        if (!model.containsAttribute("book")) {
            model.addAttribute("book", new Book());
        }
        model.addAttribute("mode", "create");
        return "admin/books/form";
    }

    @PostMapping
    public String create(@ModelAttribute("book") Book book,
                         BindingResult binding,
                         RedirectAttributes ra) {

        if (binding.hasErrors()) {
            ra.addFlashAttribute("error", "입력값을 확인해주세요.");
            ra.addFlashAttribute("org.springframework.validation.BindingResult.book", binding);
            ra.addFlashAttribute("book", book);
            return "redirect:/admin/books/new";
        }

        // 필수값 간단 검증 (원하면 서비스로 이동)
        if (book.getTitle() == null || book.getAuthor() == null || book.getCoverImage() == null) {
            ra.addFlashAttribute("error", "제목/저자/표지URL은 필수입니다.");
            ra.addFlashAttribute("book", book);
            return "redirect:/admin/books/new";
        }

        StringBuilder err = new StringBuilder();
        if (adminBookService.create(book, err)) {
            ra.addFlashAttribute("msg", "도서가 등록되었습니다. (#" + book.getBookId() + ")");
            return "redirect:/admin/books";
        } else {
            ra.addFlashAttribute("error", err.toString());
            ra.addFlashAttribute("book", book);
            return "redirect:/admin/books/new";
        }
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, RedirectAttributes ra) {
        Book b = adminBookService.get(id);
        if (b == null) {
            ra.addFlashAttribute("error", "존재하지 않는 도서입니다.");
            return "redirect:/admin/books";
        }
        if (!model.containsAttribute("book")) {
            model.addAttribute("book", b);
        }
        model.addAttribute("mode", "edit");
        return "admin/books/form";
    }

    @PostMapping("/{id}")
    public String update(@PathVariable Long id,
                         @ModelAttribute("book") Book book,
                         BindingResult binding,
                         RedirectAttributes ra) {

        if (binding.hasErrors()) {
            ra.addFlashAttribute("error", "입력값을 확인해주세요.");
            ra.addFlashAttribute("org.springframework.validation.BindingResult.book", binding);
            ra.addFlashAttribute("book", book);
            return "redirect:/admin/books/" + id + "/edit";
        }

        book.setBookId(id);
        StringBuilder err = new StringBuilder();
        if (adminBookService.update(book, err)) {
            ra.addFlashAttribute("msg", "도서가 수정되었습니다.");
            return "redirect:/admin/books";
        } else {
            ra.addFlashAttribute("error", err.toString());
            ra.addFlashAttribute("book", book);
            return "redirect:/admin/books/" + id + "/edit";
        }
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes ra) {
        if (adminBookService.delete(id)) {
            ra.addFlashAttribute("msg", "도서가 삭제되었습니다.");
        } else {
            ra.addFlashAttribute("error", "삭제할 수 없습니다.");
        }
        return "redirect:/admin/books";
    }
}
