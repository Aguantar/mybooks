package login;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class RoleBasedLoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private String adminTargetUrl = "/admin/dashboard";
    private String customerTargetUrl = "/bookstore/books";

    // === setters for Spring XML ===
    public void setAdminTargetUrl(String adminTargetUrl) { this.adminTargetUrl = adminTargetUrl; }
    public void setCustomerTargetUrl(String customerTargetUrl) { this.customerTargetUrl = customerTargetUrl; }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        request.getSession(true).setAttribute("loginId", authentication.getName());
        String target = determineTargetUrl(authentication);
        getRedirectStrategy().sendRedirect(request, response, target);
        clearAuthenticationAttributes(request);
    }

    protected String determineTargetUrl(Authentication auth) {
        if (hasRole(auth, "ROLE_ADMIN"))    return adminTargetUrl;
        if (hasRole(auth, "ROLE_CUSTOMER")) return customerTargetUrl;
        String def = getDefaultTargetUrl();
        return (def != null && !def.isEmpty()) ? def : "/";
    }

    private boolean hasRole(Authentication auth, String role) {
        for (GrantedAuthority ga : auth.getAuthorities()) {
            if (role.equals(ga.getAuthority())) return true;
        }
        return false;
    }

}
