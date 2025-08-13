package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class BookRedirectController {

    @GetMapping("/bookstore")
    public String redirectToBooks() {
        return "redirect:/bookstore/books";
    }
}