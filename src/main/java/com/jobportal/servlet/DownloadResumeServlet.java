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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;

/**
 * Controller allowing authorized employers to view/download applicant resumes
 * for their own jobs only, and job seekers to view their own uploaded resumes.
 * Strictly prevents IDOR and path traversal.
 */
@WebServlet(name = "DownloadResumeServlet", urlPatterns = {"/employer/download-resume", "/seeker/download-resume"})
public class DownloadResumeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "C:\\JobPortalManagementSystem\\uploads\\resumes";

    private ApplicationDAO applicationDAO;

    @Override
    public void init() throws ServletException {
        this.applicationDAO = new ApplicationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (currentUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authentication required to download resume.");
            return;
        }

        String appIdParam = request.getParameter("applicationId");
        if (appIdParam == null || appIdParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing application ID.");
            return;
        }

        int applicationId;
        try {
            applicationId = Integer.parseInt(appIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid application ID format.");
            return;
        }

        Application application;
        if (currentUser.isEmployer()) {
            // Strictly check employer owns the job to which this applicant applied
            application = applicationDAO.getApplicationByIdAndEmployer(applicationId, currentUser.getId());
            if (application == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                        "Access Denied: You can only download resumes for candidates who applied to your own job postings.");
                return;
            }
        } else if (currentUser.isJobSeeker()) {
            // Job seeker can only view their own resume
            application = applicationDAO.getApplicationByIdAndSeeker(applicationId, currentUser.getId());
            if (application == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                        "Access Denied: You can only access your own submitted resumes.");
                return;
            }
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized role.");
            return;
        }

        String storedFileName = application.getResumePath();
        if (storedFileName == null || storedFileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No resume file attached to this application record.");
            return;
        }

        File baseFolder = new File(UPLOAD_DIR);
        File resumeFile = new File(baseFolder, storedFileName);

        // Security check: Guard against path traversal
        if (!resumeFile.getCanonicalPath().startsWith(baseFolder.getCanonicalPath())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid file path access.");
            return;
        }

        if (!resumeFile.exists() || !resumeFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Resume file not found on server storage.");
            return;
        }

        // Determine content type
        String lowerName = storedFileName.toLowerCase();
        String contentType;
        if (lowerName.endsWith(".pdf")) {
            contentType = "application/pdf";
        } else if (lowerName.endsWith(".docx")) {
            contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        } else if (lowerName.endsWith(".doc")) {
            contentType = "application/msword";
        } else {
            contentType = "application/octet-stream";
        }

        // Sanitize download display name
        String candidateName = application.getSeekerName() != null ? 
                application.getSeekerName().replaceAll("[^a-zA-Z0-9_-]", "_") : "Candidate";
        String extension = lowerName.substring(lowerName.lastIndexOf('.'));
        String downloadName = "Resume_" + candidateName + "_" + applicationId + extension;

        response.setContentType(contentType);
        response.setContentLengthLong(resumeFile.length());
        // Use inline so browsers preview PDF in new tab, and download DOC/DOCX
        response.setHeader("Content-Disposition", "inline; filename=\"" + downloadName + "\"");
        response.setHeader("Cache-Control", "private, max-age=3600");

        try (FileInputStream in = new FileInputStream(resumeFile);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        }
    }
}
