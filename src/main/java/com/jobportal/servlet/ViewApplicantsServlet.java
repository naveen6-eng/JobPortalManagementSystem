package com.jobportal.servlet;

import com.jobportal.dao.ApplicationDAO;
import com.jobportal.dao.JobDAO;
import com.jobportal.model.Application;
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
 * Controller allowing employers to view candidates who applied to their specific job posting.
 */
@WebServlet(name = "ViewApplicantsServlet", urlPatterns = {"/employer/view-applicants"})
public class ViewApplicantsServlet extends HttpServlet {
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
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String jobIdParam = request.getParameter("jobId");
        if (jobIdParam == null || jobIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/employer/my-jobs?error=Job ID is required.");
            return;
        }

        try {
            int jobId = Integer.parseInt(jobIdParam.trim());
            Job job = jobDAO.getJobById(jobId);

            // Verify existence and ownership
            if (job == null || job.getEmployerId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/employer/my-jobs?error=Unauthorized or job not found.");
                return;
            }

            List<Application> applicants = applicationDAO.getApplicantsByJobId(jobId, user.getId());
            request.setAttribute("job", job);
            request.setAttribute("applicants", applicants);
            request.getRequestDispatcher("/employer/view-applicants.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employer/my-jobs?error=Invalid job ID format.");
        }
    }
}
