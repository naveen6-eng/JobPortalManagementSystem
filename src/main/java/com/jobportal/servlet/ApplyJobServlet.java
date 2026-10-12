package com.jobportal.servlet;

import com.jobportal.dao.ApplicationDAO;
import com.jobportal.dao.JobDAO;
import com.jobportal.model.Application;
import com.jobportal.model.Job;
import com.jobportal.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * Controller handling Job Seeker applications with required personal information,
 * interview questionnaire responses, and resume file upload.
 * Enforces server-side validations and prevents duplicate applications.
 */
@WebServlet(name = "ApplyJobServlet", urlPatterns = {"/seeker/apply"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,        // 1 MB threshold before disk spooling
        maxFileSize = 5 * 1024 * 1024,          // 5 MB max file size
        maxRequestSize = 25 * 1024 * 1024       // 25 MB max request size
)
public class ApplyJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DEFAULT_UPLOAD_DIR = "C:\\JobPortalManagementSystem\\uploads\\resumes";
    private static final long MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5 MB

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9+() -]{10,20}$");

    private ApplicationDAO applicationDAO;
    private JobDAO jobDAO;

    @Override
    public void init() throws ServletException {
        this.applicationDAO = new ApplicationDAO();
        this.jobDAO = new JobDAO();

        // Ensure storage directory exists
        File uploadFolder = new File(DEFAULT_UPLOAD_DIR);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String jobIdParam = request.getParameter("jobId");
        if (jobIdParam != null && !jobIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/job/details?id=" + jobIdParam.trim());
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !user.isJobSeeker()) {
            response.sendRedirect(request.getContextPath() + "/login?error=Please log in as a Job Seeker to apply.");
            return;
        }

        // Pre-parse query string for jobId in case multipart payload exceeds limit
        int queryJobId = -1;
        String qs = request.getQueryString();
        if (qs != null && qs.contains("jobId=")) {
            for (String param : qs.split("&")) {
                if (param.startsWith("jobId=")) {
                    try {
                        queryJobId = Integer.parseInt(param.substring(6));
                    } catch (NumberFormatException ignored) {}
                }
            }
        }

        String jobIdParam = null;
        Part resumePart = null;
        try {
            jobIdParam = request.getParameter("jobId");
            resumePart = request.getPart("resume");
        } catch (IllegalStateException | ServletException e) {
            int targetJobId = queryJobId;
            String target = (targetJobId > 0) ? ("/job/details?id=" + targetJobId + "&") : "/home?";
            response.sendRedirect(request.getContextPath() + target + "error=" 
                    + URLEncoder.encode("Resume file exceeds the maximum allowed size of 5 MB.", StandardCharsets.UTF_8));
            return;
        }

        int jobId = -1;
        if (jobIdParam != null && !jobIdParam.trim().isEmpty()) {
            try {
                jobId = Integer.parseInt(jobIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }
        if (jobId <= 0 && queryJobId > 0) {
            jobId = queryJobId;
        }

        if (jobId <= 0) {
            response.sendRedirect(request.getContextPath() + "/home?error=Invalid job selected.");
            return;
        }

        Job job = jobDAO.getJobById(jobId);
        if (job == null) {
            response.sendRedirect(request.getContextPath() + "/home?error=Selected job no longer exists.");
            return;
        }

        // Prevent duplicate application
        if (applicationDAO.hasApplied(jobId, user.getId())) {
            response.sendRedirect(request.getContextPath() + "/seeker/my-applications?error=" 
                    + URLEncoder.encode("You have already applied for this job.", StandardCharsets.UTF_8));
            return;
        }

        // --- 1. VALIDATE PERSONAL INFORMATION ---
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String mobileNumber = request.getParameter("mobileNumber");
        String currentLocation = request.getParameter("currentLocation");

        if (fullName == null || fullName.trim().isEmpty()) {
            redirectWithError(request, response, jobId, "Full Name is required.");
            return;
        }
        if (email == null || email.trim().isEmpty() || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            redirectWithError(request, response, jobId, "A valid Email Address is required.");
            return;
        }
        if (mobileNumber == null || mobileNumber.trim().isEmpty() || !PHONE_PATTERN.matcher(mobileNumber.trim()).matches()) {
            redirectWithError(request, response, jobId, "A valid Mobile Number (at least 10 digits) is required.");
            return;
        }
        if (currentLocation == null || currentLocation.trim().isEmpty()) {
            redirectWithError(request, response, jobId, "Current Location is required.");
            return;
        }

        // --- 2. VALIDATE INTERVIEW QUESTIONS ---
        String whyHireYou = request.getParameter("whyHireYou");
        String hasExperience = request.getParameter("hasExperience");
        String experienceDetails = request.getParameter("experienceDetails");
        String salaryExpectation = request.getParameter("salaryExpectation");
        String whyThisJob = request.getParameter("whyThisJob");

        if (whyHireYou == null || whyHireYou.trim().isEmpty()) {
            redirectWithError(request, response, jobId, "Please answer 'Why should we hire you?'.");
            return;
        }

        if (hasExperience == null || (!"Yes".equalsIgnoreCase(hasExperience.trim()) && !"No".equalsIgnoreCase(hasExperience.trim()))) {
            redirectWithError(request, response, jobId, "Please indicate whether you have work experience (Yes or No).");
            return;
        }

        hasExperience = "Yes".equalsIgnoreCase(hasExperience.trim()) ? "Yes" : "No";

        if ("Yes".equals(hasExperience)) {
            if (experienceDetails == null || experienceDetails.trim().isEmpty()) {
                redirectWithError(request, response, jobId, "Please describe your relevant experience and years of experience.");
                return;
            }
        } else {
            if (experienceDetails == null || experienceDetails.trim().isEmpty()) {
                experienceDetails = "Fresher (Relevant skills gained through academic projects and practical learning)";
            }
        }

        if (salaryExpectation == null || salaryExpectation.trim().isEmpty()) {
            redirectWithError(request, response, jobId, "Please enter your salary expectations (or Negotiable).");
            return;
        }

        if (whyThisJob == null || whyThisJob.trim().isEmpty()) {
            redirectWithError(request, response, jobId, "Please answer 'Why do you want this job?'.");
            return;
        }

        // --- 3. VALIDATE RESUME UPLOAD ---
        if (resumePart == null || resumePart.getSize() == 0) {
            redirectWithError(request, response, jobId, "Resume is required. Please upload your resume (PDF or DOC/DOCX).");
            return;
        }

        if (resumePart.getSize() > MAX_FILE_SIZE_BYTES) {
            redirectWithError(request, response, jobId, "Resume file exceeds the maximum allowed size of 5 MB.");
            return;
        }

        String submittedFileName = resumePart.getSubmittedFileName();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            redirectWithError(request, response, jobId, "Invalid file name. Please choose a valid file.");
            return;
        }

        // Sanitize file name to prevent directory traversal
        String baseFileName = Paths.get(submittedFileName).getFileName().toString();
        String lowerName = baseFileName.toLowerCase();

        String extension = "";
        if (lowerName.endsWith(".pdf")) {
            extension = ".pdf";
        } else if (lowerName.endsWith(".docx")) {
            extension = ".docx";
        } else if (lowerName.endsWith(".doc")) {
            extension = ".doc";
        } else {
            redirectWithError(request, response, jobId, "Invalid file type. Only PDF and DOC/DOCX files are supported.");
            return;
        }

        // Generate safe unique filename
        String safeFileName = "resume_user" + user.getId() + "_job" + jobId + "_" 
                + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 6) + extension;

        File uploadFolder = new File(DEFAULT_UPLOAD_DIR);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        File targetFile = new File(uploadFolder, safeFileName);
        try {
            resumePart.write(targetFile.getAbsolutePath());
        } catch (IOException e) {
            System.err.println("Error saving resume file: " + e.getMessage());
            redirectWithError(request, response, jobId, "Failed to store resume on server. Please try again.");
            return;
        }

        // --- 4. BUILD APPLICATION OBJECT & SAVE ---
        Application app = new Application();
        app.setJobId(jobId);
        app.setSeekerId(user.getId());
        app.setResumePath(safeFileName);
        app.setFullName(fullName.trim());
        app.setEmail(email.trim());
        app.setMobileNumber(mobileNumber.trim());
        app.setCurrentLocation(currentLocation.trim());
        app.setWhyHireYou(whyHireYou.trim());
        app.setHasExperience(hasExperience);
        app.setExperienceDetails(experienceDetails.trim());
        app.setSalaryExpectation(salaryExpectation.trim());
        app.setWhyThisJob(whyThisJob.trim());

        boolean applied = applicationDAO.applyJob(app);
        if (applied) {
            response.sendRedirect(request.getContextPath() + "/seeker/my-applications?success=" 
                    + URLEncoder.encode("Application and questionnaire submitted successfully for " + job.getTitle() + " at " + job.getCompany() + "!", StandardCharsets.UTF_8));
        } else {
            // Clean up file if database insert failed
            if (targetFile.exists()) {
                targetFile.delete();
            }
            redirectWithError(request, response, jobId, "Unable to submit application. Please try again.");
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, int jobId, String errorMsg)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/job/details?id=" + jobId + "#applySection&error=" 
                + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
    }
}
