package com.jobportal.servlet;

import com.jobportal.dao.JobDAO;
import com.jobportal.model.Job;
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
 * Controller allowing employers to view all jobs they have posted.
 */
@WebServlet(name = "MyJobsServlet", urlPatterns = {"/employer/my-jobs"})
public class MyJobsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private JobDAO jobDAO;

    @Override
    public void init() throws ServletException {
        this.jobDAO = new JobDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        List<Job> myJobs = jobDAO.getJobsByEmployerId(user.getId());
        request.setAttribute("myJobs", myJobs);
        request.getRequestDispatcher("/employer/my-jobs.jsp").forward(request, response);
    }
}
