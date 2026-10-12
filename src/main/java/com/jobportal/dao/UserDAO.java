package com.jobportal.dao;

import com.jobportal.model.User;
import com.jobportal.util.DBConnection;
import com.jobportal.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Data Access Object for User operations (users table).
 * Implements prepared statements and secure password hashing.
 */
public class UserDAO {

    /**
     * Registers a new user with hashed password.
     * @param user User object containing name, email, raw or hashed password, and role
     * @return generated user ID or -1 on failure
     */
    public int registerUser(User user) {
        String sql = "INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getName().trim());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getRole().toUpperCase());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error registering user: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return -1;
    }

    /**
     * Finds a user by email address.
     * @param email User email
     * @return User object or null if not found
     */
    public User findByEmail(String email) {
        String sql = "SELECT id, name, email, password_hash, role, created_at FROM users WHERE email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim().toLowerCase());
            rs = ps.executeQuery();

            if (rs.next()) {
                return new User(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("role"),
                        rs.getTimestamp("created_at")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error finding user by email: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Authenticates user with email and plaintext password using BCrypt.
     * @param email User email
     * @param plainPassword Plaintext password
     * @return User object if credentials are valid, null otherwise
     */
    public User authenticate(String email, String plainPassword) {
        User user = findByEmail(email);
        if (user != null && PasswordUtil.checkPassword(plainPassword, user.getPasswordHash())) {
            return user;
        }
        return null;
    }

    /**
     * Finds user by primary key ID.
     */
    public User findById(int id) {
        String sql = "SELECT id, name, email, password_hash, role, created_at FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new User(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password_hash"),
                        rs.getString("role"),
                        rs.getTimestamp("created_at")
                );
            }
        } catch (SQLException e) {
            System.err.println("Error finding user by ID: " + e.getMessage());
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Checks if email is already registered.
     */
    public boolean isEmailTaken(String email) {
        return findByEmail(email) != null;
    }
}
