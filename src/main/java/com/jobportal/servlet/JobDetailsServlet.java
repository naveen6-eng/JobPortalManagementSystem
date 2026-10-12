package com.jobportal.servlet;

import com.jobportal.dao.ApplicationDAO;
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

/**
 * Controller for displaying full details of a single job posting.
 */
@WebServlet(name = "JobDetailsServlet", urlPatterns = {"/job/details"})
public class JobDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private JobDAO jobDAO;
    private ApplicationDAO applicationDAO;

    @Override
    public void init() throws ServletException {
        this.jobDAO = new JobDAO();
        this.applicationDAO = new ApplicationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home?error=Invalid job requested.");
            return;
        }

        try {
            int jobId = Integer.parseInt(idParam.trim());
            Job job = jobDAO.getJobById(jobId);

            if (job == null) {
                response.sendRedirect(request.getContextPath() + "/home?error=Job not found.");
                return;
            }

            // Check if current user is a job seeker and has already applied
            boolean hasApplied = false;
            HttpSession session = request.getSession(false);
            if (session != null) {
                User user = (User) session.getAttribute("user");
                if (user != null && user.isJobSeeker()) {
                    hasApplied = applicationDAO.hasApplied(jobId, user.getId());
                }
            }

            request.setAttribute("job", job);
            request.setAttribute("hasApplied", hasApplied);
            request.getRequestDispatcher("/job-details.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home?error=Invalid job ID format.");
        }
    }
}
