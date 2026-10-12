package com.jobportal.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model representing a job Application submitted by a Job Seeker.
 * Contains core application metadata, resume file reference,
 * personal details, and interview questionnaire responses.
 */
public class Application implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int jobId;
    private int seekerId;
    private Timestamp applicationDate;
    private String status = "PENDING";
    private String resumePath;

    // Associated job details (convenience for views)
    private String jobTitle;
    private String company;
    private String location;
    private String salary;

    // Associated seeker details (for employer applicant view)
    private String seekerName;
    private String seekerEmail;

    // A. Personal Information Questionnaire
    private String fullName;
    private String email;
    private String mobileNumber;
    private String currentLocation;

    // B. Interview Questions Questionnaire
    private String whyHireYou;
    private String hasExperience;        // "Yes" or "No"
    private String experienceDetails;
    private String salaryExpectation;
    private String whyThisJob;

    public Application() {
    }

    public Application(int jobId, int seekerId) {
        this.jobId = jobId;
        this.seekerId = seekerId;
    }

    public Application(int jobId, int seekerId, String resumePath) {
        this.jobId = jobId;
        this.seekerId = seekerId;
        this.resumePath = resumePath;
    }

    public Application(int id, int jobId, int seekerId, Timestamp applicationDate) {
        this.id = id;
        this.jobId = jobId;
        this.seekerId = seekerId;
        this.applicationDate = applicationDate;
    }

    public Application(int id, int jobId, int seekerId, Timestamp applicationDate, String status) {
        this.id = id;
        this.jobId = jobId;
        this.seekerId = seekerId;
        this.applicationDate = applicationDate;
        this.status = status;
    }

    public Application(int id, int jobId, int seekerId, Timestamp applicationDate, String status, String resumePath) {
        this.id = id;
        this.jobId = jobId;
        this.seekerId = seekerId;
        this.applicationDate = applicationDate;
        this.status = status;
        this.resumePath = resumePath;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getJobId() {
        return jobId;
    }

    public void setJobId(int jobId) {
        this.jobId = jobId;
    }

    public int getSeekerId() {
        return seekerId;
    }

    public void setSeekerId(int seekerId) {
        this.seekerId = seekerId;
    }

    public Timestamp getApplicationDate() {
        return applicationDate;
    }

    public void setApplicationDate(Timestamp applicationDate) {
        this.applicationDate = applicationDate;
    }

    public String getJobTitle() {
        return jobTitle;
    }

    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
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

    public String getSeekerName() {
        return seekerName != null ? seekerName : fullName;
    }

    public void setSeekerName(String seekerName) {
        this.seekerName = seekerName;
    }

    public String getSeekerEmail() {
        return seekerEmail != null ? seekerEmail : email;
    }

    public void setSeekerEmail(String seekerEmail) {
        this.seekerEmail = seekerEmail;
    }

    public String getStatus() {
        return status != null ? status : "PENDING";
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResumePath() {
        return resumePath;
    }

    public void setResumePath(String resumePath) {
        this.resumePath = resumePath;
    }

    // Questionnaire Getters and Setters

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMobileNumber() {
        return mobileNumber;
    }

    public void setMobileNumber(String mobileNumber) {
        this.mobileNumber = mobileNumber;
    }

    public String getCurrentLocation() {
        return currentLocation;
    }

    public void setCurrentLocation(String currentLocation) {
        this.currentLocation = currentLocation;
    }

    public String getWhyHireYou() {
        return whyHireYou;
    }

    public void setWhyHireYou(String whyHireYou) {
        this.whyHireYou = whyHireYou;
    }

    public String getHasExperience() {
        return hasExperience;
    }

    public void setHasExperience(String hasExperience) {
        this.hasExperience = hasExperience;
    }

    public String getExperienceDetails() {
        return experienceDetails;
    }

    public void setExperienceDetails(String experienceDetails) {
        this.experienceDetails = experienceDetails;
    }

    public String getSalaryExpectation() {
        return salaryExpectation;
    }

    public void setSalaryExpectation(String salaryExpectation) {
        this.salaryExpectation = salaryExpectation;
    }

    public String getWhyThisJob() {
        return whyThisJob;
    }

    public void setWhyThisJob(String whyThisJob) {
        this.whyThisJob = whyThisJob;
    }
}
