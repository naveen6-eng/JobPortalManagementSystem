package com.jobportal.servlet;

import com.jobportal.dao.ApplicationDAO;
import com.jobportal.model.Application;
import com.jobportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller allowing Job Seekers to view their submitted applications.
 */
@WebServlet(name = "MyApplicationsServlet", urlPatterns = {"/seeker/my-applications"})
public class MyApplicationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ApplicationDAO applicationDAO;

    @Override
    public void init() throws ServletException {
        this.applicationDAO = new ApplicationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        List<Application> myApplications = applicationDAO.getApplicationsBySeekerId(user.getId());
        request.setAttribute("myApplications", myApplications);
        request.getRequestDispatcher("/seeker/my-applications.jsp").forward(request, response);
    }
}
