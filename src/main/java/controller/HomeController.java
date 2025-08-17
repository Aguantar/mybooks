package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        // 서버 시작 후 루트(/) 접속 시 /bookstore/books로 이동
        return "redirect:/bookstore/books";
    }
}

