package com.jobportal.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model representing a registered User (Job Seeker or Employer).
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String email;
    private String passwordHash;
    private String role; // "JOB_SEEKER" or "EMPLOYER"
    private Timestamp createdAt;

    public User() {
    }

    public User(String name, String email, String passwordHash, String role) {
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
    }

    public User(int id, String name, String email, String passwordHash, String role, Timestamp createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isEmployer() {
        return "EMPLOYER".equalsIgnoreCase(this.role);
    }

    public boolean isJobSeeker() {
        return "JOB_SEEKER".equalsIgnoreCase(this.role);
    }
}
