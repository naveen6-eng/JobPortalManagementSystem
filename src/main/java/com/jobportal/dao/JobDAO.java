package com.jobportal.dao;

import com.jobportal.model.Job;
import com.jobportal.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Job postings (jobs table).
 * Uses PreparedStatement for all database queries.
 */
public class JobDAO {

    /**
     * Inserts a new job posting.
     * @param job Job details
     * @return generated job ID, or -1 on failure
     */
    public int postJob(Job job) {
        String sql = "INSERT INTO jobs (employer_id, title, company, location, salary, description) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, job.getEmployerId());
            ps.setString(2, job.getTitle().trim());
            ps.setString(3, job.getCompany().trim());
            ps.setString(4, job.getLocation().trim());
            ps.setString(5, job.getSalary().trim());
            ps.setString(6, job.getDescription().trim());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error posting job: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return -1;
    }

    /**
     * Retrieves all available jobs ordered from newest to oldest.
     * @return List of Job objects
     */
    public List<Job> getAllJobs() {
        List<Job> list = new ArrayList<>();
        String sql = "SELECT j.id, j.employer_id, j.title, j.company, j.location, j.salary, " +
                     "       j.description, j.posted_date, u.name AS employer_name " +
                     "FROM jobs j " +
                     "JOIN users u ON j.employer_id = u.id " +
                     "ORDER BY j.posted_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Job job = mapResultSetToJob(rs);
                job.setEmployerName(rs.getString("employer_name"));
                list.add(job);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all jobs: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Searches jobs by keyword and/or location.
     */
    public List<Job> searchJobs(String keyword, String location) {
        List<Job> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT j.id, j.employer_id, j.title, j.company, j.location, j.salary, " +
                "       j.description, j.posted_date, u.name AS employer_name " +
                "FROM jobs j " +
                "JOIN users u ON j.employer_id = u.id " +
                "WHERE 1=1 ");

        List<String> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(j.title) LIKE ? OR LOWER(j.company) LIKE ? OR LOWER(j.description) LIKE ?) ");
            String term = "%" + keyword.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }
        if (location != null && !location.trim().isEmpty()) {
            sql.append("AND LOWER(j.location) LIKE ? ");
            params.add("%" + location.trim().toLowerCase() + "%");
        }
        sql.append("ORDER BY j.posted_date DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Job job = mapResultSetToJob(rs);
                job.setEmployerName(rs.getString("employer_name"));
                list.add(job);
            }
        } catch (SQLException e) {
            System.err.println("Error searching jobs: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Retrieves all jobs posted by a specific employer, including applicant counts.
     * @param employerId ID of the employer
     * @return List of Job objects
     */
    public List<Job> getJobsByEmployerId(int employerId) {
        List<Job> list = new ArrayList<>();
        String sql = "SELECT j.id, j.employer_id, j.title, j.company, j.location, j.salary, " +
                     "       j.description, j.posted_date, " +
                     "       COUNT(a.id) AS applicant_count " +
                     "FROM jobs j " +
                     "LEFT JOIN applications a ON j.id = a.job_id " +
                     "WHERE j.employer_id = ? " +
                     "GROUP BY j.id, j.employer_id, j.title, j.company, j.location, j.salary, j.description, j.posted_date " +
                     "ORDER BY j.posted_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, employerId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Job job = mapResultSetToJob(rs);
                job.setApplicationCount(rs.getInt("applicant_count"));
                list.add(job);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching jobs by employer: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Retrieves a single job by its ID.
     */
    public Job getJobById(int id) {
        String sql = "SELECT j.id, j.employer_id, j.title, j.company, j.location, j.salary, " +
                     "       j.description, j.posted_date, u.name AS employer_name " +
                     "FROM jobs j " +
                     "JOIN users u ON j.employer_id = u.id " +
                     "WHERE j.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                Job job = mapResultSetToJob(rs);
                job.setEmployerName(rs.getString("employer_name"));
                return job;
            }
        } catch (SQLException e) {
            System.err.println("Error fetching job by ID: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    private Job mapResultSetToJob(ResultSet rs) throws SQLException {
        return new Job(
                rs.getInt("id"),
                rs.getInt("employer_id"),
                rs.getString("title"),
                rs.getString("company"),
                rs.getString("location"),
                rs.getString("salary"),
                rs.getString("description"),
                rs.getTimestamp("posted_date")
        );
    }
}
