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

/**
 * Controller allowing employers to post a new job vacancy.
 */
@WebServlet(name = "PostJobServlet", urlPatterns = {"/employer/post-job"})
public class PostJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private JobDAO jobDAO;

    @Override
    public void init() throws ServletException {
        this.jobDAO = new JobDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/employer/post-job.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String title = request.getParameter("title");
        String company = request.getParameter("company");
        String location = request.getParameter("location");
        String salary = request.getParameter("salary");
        String description = request.getParameter("description");

        if (title == null || title.trim().isEmpty() ||
            company == null || company.trim().isEmpty() ||
            location == null || location.trim().isEmpty() ||
            salary == null || salary.trim().isEmpty() ||
            description == null || description.trim().isEmpty()) {

            request.setAttribute("errorMessage", "All job posting fields are required.");
            request.setAttribute("enteredTitle", title);
            request.setAttribute("enteredCompany", company);
            request.setAttribute("enteredLocation", location);
            request.setAttribute("enteredSalary", salary);
            request.setAttribute("enteredDescription", description);
            request.getRequestDispatcher("/employer/post-job.jsp").forward(request, response);
            return;
        }

        Job job = new Job(user.getId(), title.trim(), company.trim(), location.trim(), salary.trim(), description.trim());
        int jobId = jobDAO.postJob(job);

        if (jobId > 0) {
            response.sendRedirect(request.getContextPath() + "/employer/my-jobs?success=Job posted successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to post job. Please try again.");
            request.getRequestDispatcher("/employer/post-job.jsp").forward(request, response);
        }
    }
}
