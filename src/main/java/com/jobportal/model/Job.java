package com.jobportal.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model representing a Job posting.
 */
public class Job implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int employerId;
    private String title;
    private String company;
    private String location;
    private String salary;
    private String description;
    private Timestamp postedDate;

    // Additional display fields (from joins or counts)
    private String employerName;
    private int applicationCount;

    public Job() {
    }

    public Job(int employerId, String title, String company, String location, String salary, String description) {
        this.employerId = employerId;
        this.title = title;
        this.company = company;
        this.location = location;
        this.salary = salary;
        this.description = description;
    }

    public Job(int id, int employerId, String title, String company, String location, String salary, String description, Timestamp postedDate) {
        this.id = id;
        this.employerId = employerId;
        this.title = title;
        this.company = company;
        this.location = location;
        this.salary = salary;
        this.description = description;
        this.postedDate = postedDate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEmployerId() {
        return employerId;
    }

    public void setEmployerId(int employerId) {
        this.employerId = employerId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getSalary() {
        return salary;
    }

    public void setSalary(String salary) {
        this.salary = salary;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getPostedDate() {
        return postedDate;
    }

    public void setPostedDate(Timestamp postedDate) {
        this.postedDate = postedDate;
    }

    public String getEmployerName() {
        return employerName;
    }

    public void setEmployerName(String employerName) {
        this.employerName = employerName;
    }

    public int getApplicationCount() {
        return applicationCount;
    }

    public void setApplicationCount(int applicationCount) {
        this.applicationCount = applicationCount;
    }
}
