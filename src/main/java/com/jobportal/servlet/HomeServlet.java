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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Controller for the Job Portal Home Page.
 * Lists available jobs, supports keyword/location search, and indicates application status.
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"", "/home", "/jobs"})
public class HomeServlet extends HttpServlet {
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
        String keyword = request.getParameter("keyword");
        String location = request.getParameter("location");

        List<Job> jobs;
        if ((keyword != null && !keyword.trim().isEmpty()) || (location != null && !location.trim().isEmpty())) {
            jobs = jobDAO.searchJobs(keyword, location);
        } else {
            jobs = jobDAO.getAllJobs();
        }

        // If a job seeker is logged in, find which jobs they already applied to
        HttpSession session = request.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null && user.isJobSeeker()) {
                List<Application> myApps = applicationDAO.getApplicationsBySeekerId(user.getId());
                Set<Integer> appliedJobIds = new HashSet<>();
                for (Application app : myApps) {
                    appliedJobIds.add(app.getJobId());
                }
                request.setAttribute("appliedJobIds", appliedJobIds);
            }
        }

        request.setAttribute("jobs", jobs);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("searchLocation", location);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
