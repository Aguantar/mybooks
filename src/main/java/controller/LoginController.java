package controller;

import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.AuthenticationException; // ★ 추가
import org.springframework.security.web.WebAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

@Controller
public class LoginController {

    @GetMapping("/loginForm")
    public String loginForm(
            @RequestParam(value="error",  required=false) String error,
            @RequestParam(value="logout", required=false) String logout,
            HttpServletRequest request,
            Model model) {

        if (logout != null) {
            model.addAttribute("msg", "정상적으로 로그아웃 되었습니다.");
        }

        if (error != null) {
            String msg = "아이디 또는 비밀번호가 올바르지 않습니다.";
            HttpSession session = request.getSession(false);
            if (session != null) {
                Exception ex = (Exception) session.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
                if (ex instanceof DisabledException) {
                    msg = ex.getMessage();
                } else if (ex instanceof AuthenticationException && ex.getCause() instanceof DisabledException) {
                    // ★ DisabledException 이 내부에 래핑된 경우도 처리
                    msg = ex.getCause().getMessage();
                }
                session.removeAttribute(WebAttributes.AUTHENTICATION_EXCEPTION); // 재노출 방지
            }
            model.addAttribute("errorMsg", msg);
        }
        return "login/loginForm";
    }
}
