package com.jobportal.dao;

import com.jobportal.model.Application;
import com.jobportal.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Applications (applications table).
 * Enforces single application per job-seeker pair and handles
 * resume persistence as well as application questionnaires.
 */
public class ApplicationDAO {

    /**
     * Submits a new job application with questionnaire answers and resume path.
     * @param app Application model populated with questionnaire and resume data
     * @return true if successful, false if already applied or error occurs
     */
    public boolean applyJob(Application app) {
        if (app == null || hasApplied(app.getJobId(), app.getSeekerId())) {
            return false;
        }

        String sql = "INSERT INTO applications (" +
                     "  job_id, seeker_id, resume_path, full_name, email, mobile_number, " +
                     "  current_location, why_hire_you, has_experience, experience_details, " +
                     "  salary_expectation, why_this_job" +
                     ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, app.getJobId());
            ps.setInt(2, app.getSeekerId());
            ps.setString(3, app.getResumePath());
            ps.setString(4, app.getFullName());
            ps.setString(5, app.getEmail());
            ps.setString(6, app.getMobileNumber());
            ps.setString(7, app.getCurrentLocation());
            ps.setString(8, app.getWhyHireYou());
            ps.setString(9, app.getHasExperience());
            ps.setString(10, app.getExperienceDetails());
            ps.setString(11, app.getSalaryExpectation());
            ps.setString(12, app.getWhyThisJob());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error submitting application with questionnaire: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Overload for backwards compatibility with resume path.
     */
    public boolean applyJob(int jobId, int seekerId, String resumePath) {
        Application app = new Application(jobId, seekerId, resumePath);
        return applyJob(app);
    }

    /**
     * Overload for backwards compatibility without resume.
     */
    public boolean applyJob(int jobId, int seekerId) {
        return applyJob(jobId, seekerId, null);
    }

    /**
     * Checks if a job seeker has already applied to a specific job.
     */
    public boolean hasApplied(int jobId, int seekerId) {
        String sql = "SELECT id FROM applications WHERE job_id = ? AND seeker_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.setInt(2, seekerId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("Error checking application status: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(rs, ps, conn);
        }
    }

    /**
     * Helper to map result set columns to Application model.
     */
    private Application mapResultSetToApplication(ResultSet rs) throws SQLException {
        Application app = new Application(
                rs.getInt("id"),
                rs.getInt("job_id"),
                rs.getInt("seeker_id"),
                rs.getTimestamp("application_date"),
                rs.getString("status"),
                rs.getString("resume_path")
        );
        app.setFullName(rs.getString("full_name"));
        app.setEmail(rs.getString("email"));
        app.setMobileNumber(rs.getString("mobile_number"));
        app.setCurrentLocation(rs.getString("current_location"));
        app.setWhyHireYou(rs.getString("why_hire_you"));
        app.setHasExperience(rs.getString("has_experience"));
        app.setExperienceDetails(rs.getString("experience_details"));
        app.setSalaryExpectation(rs.getString("salary_expectation"));
        app.setWhyThisJob(rs.getString("why_this_job"));
        return app;
    }

    /**
     * Retrieves all applications submitted by a specific job seeker with questionnaire data.
     * Joins with jobs table to retrieve job title, company, location, and salary.
     */
    public List<Application> getApplicationsBySeekerId(int seekerId) {
        List<Application> list = new ArrayList<>();
        String sql = "SELECT a.id, a.job_id, a.seeker_id, a.application_date, a.status, a.resume_path, " +
                     "       a.full_name, a.email, a.mobile_number, a.current_location, " +
                     "       a.why_hire_you, a.has_experience, a.experience_details, " +
                     "       a.salary_expectation, a.why_this_job, " +
                     "       j.title, j.company, j.location, j.salary " +
                     "FROM applications a " +
                     "JOIN jobs j ON a.job_id = j.id " +
                     "WHERE a.seeker_id = ? " +
                     "ORDER BY a.application_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, seekerId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Application app = mapResultSetToApplication(rs);
                app.setJobTitle(rs.getString("title"));
                app.setCompany(rs.getString("company"));
                app.setLocation(rs.getString("location"));
                app.setSalary(rs.getString("salary"));
                list.add(app);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching applications for seeker: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Retrieves all applicants for a specific job, verifying employer ownership.
     * Joins with users table to get fallback applicant name and email, and includes
     * all questionnaire responses.
     */
    public List<Application> getApplicantsByJobId(int jobId, int employerId) {
        List<Application> list = new ArrayList<>();
        String sql = "SELECT a.id, a.job_id, a.seeker_id, a.application_date, a.status, a.resume_path, " +
                     "       a.full_name, a.email, a.mobile_number, a.current_location, " +
                     "       a.why_hire_you, a.has_experience, a.experience_details, " +
                     "       a.salary_expectation, a.why_this_job, " +
                     "       u.name AS user_seeker_name, u.email AS user_seeker_email, " +
                     "       j.title AS job_title, j.company " +
                     "FROM applications a " +
                     "JOIN users u ON a.seeker_id = u.id " +
                     "JOIN jobs j ON a.job_id = j.id " +
                     "WHERE a.job_id = ? AND j.employer_id = ? " +
                     "ORDER BY a.application_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.setInt(2, employerId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Application app = mapResultSetToApplication(rs);
                // Prefer questionnaire name/email if provided, fallback to user record
                String name = app.getFullName();
                if (name == null || name.trim().isEmpty()) {
                    name = rs.getString("user_seeker_name");
                }
                String email = app.getEmail();
                if (email == null || email.trim().isEmpty()) {
                    email = rs.getString("user_seeker_email");
                }
                app.setSeekerName(name);
                app.setSeekerEmail(email);
                app.setJobTitle(rs.getString("job_title"));
                app.setCompany(rs.getString("company"));
                list.add(app);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching applicants for job: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Updates an applicant's status to SHORTLISTED or REJECTED.
     * Enforces that ONLY the employer who owns the posted job can update the status.
     * @param applicationId ID of the application record
     * @param newStatus "SHORTLISTED" or "REJECTED"
     * @param employerId ID of the authenticated employer
     * @return true if updated successfully, false if unauthorized or record not found
     */
    public boolean updateApplicationStatus(int applicationId, String newStatus, int employerId) {
        if (newStatus == null) {
            return false;
        }
        String statusUpper = newStatus.trim().toUpperCase();
        if (!"SHORTLISTED".equals(statusUpper) && !"REJECTED".equals(statusUpper)) {
            return false;
        }

        String sql = "UPDATE applications a " +
                     "JOIN jobs j ON a.job_id = j.id " +
                     "SET a.status = ? " +
                     "WHERE a.id = ? AND j.employer_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, statusUpper);
            ps.setInt(2, applicationId);
            ps.setInt(3, employerId);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error updating application status: " + e.getMessage());
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Retrieves application details specifically for the job-owning employer.
     * Enforces that only the employer who posted the job can access the applicant's resume
     * and questionnaire answers.
     * @param applicationId ID of the application
     * @param employerId ID of the authenticated employer
     * @return Application with resume and questionnaire details if owned, null otherwise
     */
    public Application getApplicationByIdAndEmployer(int applicationId, int employerId) {
        String sql = "SELECT a.id, a.job_id, a.seeker_id, a.application_date, a.status, a.resume_path, " +
                     "       a.full_name, a.email, a.mobile_number, a.current_location, " +
                     "       a.why_hire_you, a.has_experience, a.experience_details, " +
                     "       a.salary_expectation, a.why_this_job, " +
                     "       u.name AS user_seeker_name, u.email AS user_seeker_email, " +
                     "       j.title AS job_title, j.company " +
                     "FROM applications a " +
                     "JOIN jobs j ON a.job_id = j.id " +
                     "JOIN users u ON a.seeker_id = u.id " +
                     "WHERE a.id = ? AND j.employer_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicationId);
            ps.setInt(2, employerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Application app = mapResultSetToApplication(rs);
                String name = app.getFullName();
                if (name == null || name.trim().isEmpty()) {
                    name = rs.getString("user_seeker_name");
                }
                String email = app.getEmail();
                if (email == null || email.trim().isEmpty()) {
                    email = rs.getString("user_seeker_email");
                }
                app.setSeekerName(name);
                app.setSeekerEmail(email);
                app.setJobTitle(rs.getString("job_title"));
                app.setCompany(rs.getString("company"));
                return app;
            }
        } catch (SQLException e) {
            System.err.println("Error fetching employer application: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Retrieves application details specifically for the job seeker who submitted it.
     * @param applicationId ID of the application
     * @param seekerId ID of the authenticated seeker
     * @return Application with resume and questionnaire details if owned, null otherwise
     */
    public Application getApplicationByIdAndSeeker(int applicationId, int seekerId) {
        String sql = "SELECT a.id, a.job_id, a.seeker_id, a.application_date, a.status, a.resume_path, " +
                     "       a.full_name, a.email, a.mobile_number, a.current_location, " +
                     "       a.why_hire_you, a.has_experience, a.experience_details, " +
                     "       a.salary_expectation, a.why_this_job, " +
                     "       j.title AS job_title, j.company " +
                     "FROM applications a " +
                     "JOIN jobs j ON a.job_id = j.id " +
                     "WHERE a.id = ? AND a.seeker_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicationId);
            ps.setInt(2, seekerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Application app = mapResultSetToApplication(rs);
                app.setJobTitle(rs.getString("job_title"));
                app.setCompany(rs.getString("company"));
                return app;
            }
        } catch (SQLException e) {
            System.err.println("Error fetching seeker application: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }
}
