package com.jobportal.servlet;

import com.jobportal.dao.UserDAO;
import com.jobportal.model.User;
import com.jobportal.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Controller handling user registration for Job Seekers and Employers.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        // Basic validations
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required.");
            retainFormFields(request, name, email, role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!"JOB_SEEKER".equalsIgnoreCase(role) && !"EMPLOYER".equalsIgnoreCase(role)) {
            request.setAttribute("errorMessage", "Please select a valid role (Job Seeker or Employer).");
            retainFormFields(request, name, email, role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters long.");
            retainFormFields(request, name, email, role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            retainFormFields(request, name, email, role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.isEmailTaken(email)) {
            request.setAttribute("errorMessage", "An account with this email address already exists.");
            retainFormFields(request, name, email, role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Hash password securely with BCrypt
        String hashedPassword = PasswordUtil.hashPassword(password);
        User newUser = new User(name.trim(), email.trim().toLowerCase(), hashedPassword, role.toUpperCase());

        int userId = userDAO.registerUser(newUser);
        if (userId > 0) {
            String encodedEmail = URLEncoder.encode(email.trim().toLowerCase(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login?success=Registration successful! Please log in.&email=" + encodedEmail);
        } else {
            request.setAttribute("errorMessage", "Registration failed due to a database error. Please try again.");
            retainFormFields(request, name, email, role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    private void retainFormFields(HttpServletRequest request, String name, String email, String role) {
        request.setAttribute("enteredName", name);
        request.setAttribute("enteredEmail", email);
        request.setAttribute("enteredRole", role);
    }
}
