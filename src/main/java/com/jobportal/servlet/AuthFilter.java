package com.jobportal.servlet;

import com.jobportal.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Authentication and Role-based Access Control Filter.
 * Protects /employer/* and /seeker/* routes based on session user.
 */
@WebFilter(urlPatterns = {"/employer/*", "/seeker/*", "/admin/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Prevent browser caching on protected pages
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String pathWithinApp = uri.substring(contextPath.length());

        if (currentUser == null) {
            // Not logged in: store target URI and redirect to login
            req.getSession(true).setAttribute("redirectAfterLogin", uri);
            res.sendRedirect(contextPath + "/login?error=Please log in to access this page.");
            return;
        }

        // Role-based authorization checks
        if (pathWithinApp.startsWith("/admin/")) {
            // The system does not have an admin role; prevent all unauthorized access
            res.sendRedirect(contextPath + "/home?error=Access denied: Administrator privileges required.");
            return;
        } else if (pathWithinApp.startsWith("/employer/")) {
            if (!currentUser.isEmployer()) {
                res.sendRedirect(contextPath + "/home?error=Access denied: Employer privileges required.");
                return;
            }
        } else if (pathWithinApp.startsWith("/seeker/")) {
            if (!currentUser.isJobSeeker()) {
                res.sendRedirect(contextPath + "/home?error=Access denied: Job Seeker privileges required.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
