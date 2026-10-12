package com.jobportal.servlet;

import com.jobportal.dao.ApplicationDAO;
import com.jobportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller allowing employers to update an application status (SHORTLISTED or REJECTED).
 * Strictly verifies that only the employer who owns the job can modify the application.
 */
@WebServlet(name = "UpdateApplicationStatusServlet", urlPatterns = {"/employer/update-status"})
public class UpdateApplicationStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ApplicationDAO applicationDAO;

    @Override
    public void init() throws ServletException {
        this.applicationDAO = new ApplicationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/employer/my-jobs");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (currentUser == null || !currentUser.isEmployer()) {
            response.sendRedirect(request.getContextPath() + "/login?error=Employer login required.");
            return;
        }

        String appIdParam = request.getParameter("applicationId");
        String jobIdParam = request.getParameter("jobId");
        String newStatus = request.getParameter("status");

        if (appIdParam == null || jobIdParam == null || newStatus == null) {
            response.sendRedirect(request.getContextPath() + "/employer/my-jobs?error=Missing required parameters.");
            return;
        }

        try {
            int applicationId = Integer.parseInt(appIdParam.trim());
            int jobId = Integer.parseInt(jobIdParam.trim());
            String statusUpper = newStatus.trim().toUpperCase();

            if (!"SHORTLISTED".equals(statusUpper) && !"REJECTED".equals(statusUpper)) {
                response.sendRedirect(request.getContextPath() + "/employer/view-applicants?jobId=" + jobId + "&error=Invalid status value.");
                return;
            }

            boolean updated = applicationDAO.updateApplicationStatus(applicationId, statusUpper, currentUser.getId());

            if (updated) {
                response.sendRedirect(request.getContextPath() + "/employer/view-applicants?jobId=" + jobId + 
                        "&success=Applicant status updated to " + statusUpper + " successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/employer/view-applicants?jobId=" + jobId + 
                        "&error=Unauthorized: You can only update applications for your own job postings.");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employer/my-jobs?error=Invalid application or job ID.");
        }
    }
}
