package com.jobportal;

import com.jobportal.dao.ApplicationDAO;
import com.jobportal.dao.JobDAO;
import com.jobportal.dao.UserDAO;
import com.jobportal.model.Application;
import com.jobportal.model.Job;
import com.jobportal.model.User;
import com.jobportal.util.PasswordUtil;
import org.junit.jupiter.api.*;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DAOTest {

    private static UserDAO userDAO;
    private static JobDAO jobDAO;
    private static ApplicationDAO applicationDAO;

    private static String employerEmail;
    private static String seekerEmail;
    private static int employerId;
    private static int seekerId;
    private static int jobId;

    @BeforeAll
    public static void setup() {
        userDAO = new UserDAO();
        jobDAO = new JobDAO();
        applicationDAO = new ApplicationDAO();

        String suffix = UUID.randomUUID().toString().substring(0, 8);
        employerEmail = "employer_" + suffix + "@test.com";
        seekerEmail = "seeker_" + suffix + "@test.com";
    }

    @Test
    @Order(1)
    @DisplayName("Test 1: User Registration for Employer and Seeker")
    public void testUserRegistration() {
        String empHash = PasswordUtil.hashPassword("empPass123");
        User emp = new User("Test Employer", employerEmail, empHash, "EMPLOYER");
        employerId = userDAO.registerUser(emp);
        assertTrue(employerId > 0, "Employer should be registered with generated ID");

        String seekerHash = PasswordUtil.hashPassword("seekerPass123");
        User seeker = new User("Test Seeker", seekerEmail, seekerHash, "JOB_SEEKER");
        seekerId = userDAO.registerUser(seeker);
        assertTrue(seekerId > 0, "Seeker should be registered with generated ID");

        // Verify duplicate registration rejection
        int dupId = userDAO.registerUser(new User("Dup Employer", employerEmail, empHash, "EMPLOYER"));
        assertEquals(-1, dupId, "Duplicate email registration should fail");
    }

    @Test
    @Order(2)
    @DisplayName("Test 2: User Authentication with BCrypt")
    public void testUserAuthentication() {
        User validEmp = userDAO.authenticate(employerEmail, "empPass123");
        assertNotNull(validEmp, "Authentication should succeed with correct credentials");
        assertEquals("EMPLOYER", validEmp.getRole());

        User invalidPwd = userDAO.authenticate(employerEmail, "wrongPass");
        assertNull(invalidPwd, "Authentication should fail with incorrect password");

        User invalidEmail = userDAO.authenticate("nonexistent@test.com", "anyPass");
        assertNull(invalidEmail, "Authentication should fail with nonexistent email");
    }

    @Test
    @Order(3)
    @DisplayName("Test 3: Job Posting by Employer")
    public void testPostJob() {
        Job job = new Job(
                employerId,
                "Software Engineer - Java",
                "Apex Cloud Systems",
                "Hyderabad, India",
                "₹10,00,000 - ₹14,00,000",
                "Build scalable microservices using Java Servlets, JSP and MySQL."
        );

        jobId = jobDAO.postJob(job);
        assertTrue(jobId > 0, "Job posting should succeed with positive ID");

        Job retrieved = jobDAO.getJobById(jobId);
        assertNotNull(retrieved, "Retrieved job should not be null");
        assertEquals("Software Engineer - Java", retrieved.getTitle());
        assertEquals("Apex Cloud Systems", retrieved.getCompany());
    }

    @Test
    @Order(4)
    @DisplayName("Test 4: Job Retrieval and Search")
    public void testJobRetrievalAndSearch() {
        List<Job> allJobs = jobDAO.getAllJobs();
        assertFalse(allJobs.isEmpty(), "Job list should not be empty");

        List<Job> keywordMatch = jobDAO.searchJobs("Engineer", null);
        assertFalse(keywordMatch.isEmpty(), "Keyword search should return matching jobs");

        List<Job> locMatch = jobDAO.searchJobs(null, "Hyderabad");
        assertFalse(locMatch.isEmpty(), "Location search should return matching jobs");

        List<Job> noMatch = jobDAO.searchJobs("AstronomerXYZNonExistent", "Mars");
        assertTrue(noMatch.isEmpty(), "Search for nonexistent title should return empty list");
    }

    @Test
    @Order(5)
    @DisplayName("Test 5: Job Seeker Application with Questionnaire and Duplicate Prevention")
    public void testJobApplicationAndDuplicateConstraint() {
        Application app = new Application();
        app.setJobId(jobId);
        app.setSeekerId(seekerId);
        app.setResumePath("test_resume.pdf");
        app.setFullName("Test Seeker");
        app.setEmail(seekerEmail);
        app.setMobileNumber("+91 9876543210");
        app.setCurrentLocation("Hyderabad, India");
        app.setWhyHireYou("I am a quick learner and passionate software engineer.");
        app.setHasExperience("Yes");
        app.setExperienceDetails("2 years in Java, Spring Boot, MySQL.");
        app.setSalaryExpectation("₹8,00,000 / year");
        app.setWhyThisJob("Excellent learning environment and strong engineering culture.");

        // First application with questionnaire and resume should succeed
        boolean appliedFirst = applicationDAO.applyJob(app);
        assertTrue(appliedFirst, "First application with questionnaire should succeed");

        // hasApplied should return true
        assertTrue(applicationDAO.hasApplied(jobId, seekerId), "hasApplied should return true");

        // Second application to the same job must be prevented!
        boolean appliedDuplicate = applicationDAO.applyJob(app);
        assertFalse(appliedDuplicate, "Duplicate application must be rejected");
    }

    @Test
    @Order(6)
    @DisplayName("Test 6: Seeker and Employer Application Queries with Questionnaire Verification")
    public void testApplicationQueries() {
        // Seeker views their applications
        List<Application> seekerApps = applicationDAO.getApplicationsBySeekerId(seekerId);
        assertFalse(seekerApps.isEmpty(), "Seeker should see submitted application");
        Application sApp = seekerApps.get(0);
        assertEquals(jobId, sApp.getJobId());
        assertEquals("test_resume.pdf", sApp.getResumePath());
        assertEquals("Test Seeker", sApp.getFullName());
        assertEquals(seekerEmail, sApp.getEmail());
        assertEquals("+91 9876543210", sApp.getMobileNumber());
        assertEquals("Hyderabad, India", sApp.getCurrentLocation());
        assertEquals("I am a quick learner and passionate software engineer.", sApp.getWhyHireYou());
        assertEquals("Yes", sApp.getHasExperience());
        assertEquals("2 years in Java, Spring Boot, MySQL.", sApp.getExperienceDetails());
        assertEquals("₹8,00,000 / year", sApp.getSalaryExpectation());
        assertEquals("Excellent learning environment and strong engineering culture.", sApp.getWhyThisJob());

        // Employer views applicants for their job
        List<Application> employerApplicants = applicationDAO.getApplicantsByJobId(jobId, employerId);
        assertFalse(employerApplicants.isEmpty(), "Employer should see candidate applications");
        Application empApp = employerApplicants.get(0);
        assertEquals(seekerId, empApp.getSeekerId());
        assertEquals("Test Seeker", empApp.getSeekerName());
        assertEquals("test_resume.pdf", empApp.getResumePath());
        assertEquals("₹8,00,000 / year", empApp.getSalaryExpectation());

        // Employer ownership check: Job owner can fetch application details
        Application ownerApp = applicationDAO.getApplicationByIdAndEmployer(empApp.getId(), employerId);
        assertNotNull(ownerApp, "Job owner employer must be able to view application details");
        assertEquals("test_resume.pdf", ownerApp.getResumePath());
        assertEquals("+91 9876543210", ownerApp.getMobileNumber());

        // Security check: Unauthorized employer (different ID) CANNOT view application or questionnaire
        Application unauthorizedApp = applicationDAO.getApplicationByIdAndEmployer(empApp.getId(), employerId + 9999);
        assertNull(unauthorizedApp, "Unauthorized employer must NOT be allowed to access applicant questionnaire or resume");

        // Seeker ownership check: Submitting seeker can fetch application details
        Application seekerDetailApp = applicationDAO.getApplicationByIdAndSeeker(sApp.getId(), seekerId);
        assertNotNull(seekerDetailApp, "Job seeker must be able to view their own application");
        assertEquals("test_resume.pdf", seekerDetailApp.getResumePath());

        // Security check: Different seeker CANNOT access other seeker's application
        Application otherSeekerApp = applicationDAO.getApplicationByIdAndSeeker(sApp.getId(), seekerId + 9999);
        assertNull(otherSeekerApp, "Other job seeker must NOT be allowed to access another candidate's application");
    }

    @Test
    @Order(7)
    @DisplayName("Test 7: Verify Pre-configured Demo Accounts Authenticate")
    public void testDemoAccountsVerification() {
        User demoEmp = userDAO.authenticate("employer@portal.com", "password123");
        assertNotNull(demoEmp, "Demo employer should authenticate with password123");
        assertEquals("EMPLOYER", demoEmp.getRole());

        User demoSeeker = userDAO.authenticate("seeker@portal.com", "password123");
        assertNotNull(demoSeeker, "Demo seeker should authenticate with password123");
        assertEquals("JOB_SEEKER", demoSeeker.getRole());
    }

    @Test
    @Order(8)
    @DisplayName("Test 8: Employer Updates Application Status & Ownership Verification")
    public void testApplicationStatusUpdatesAndOwnership() {
        List<Application> apps = applicationDAO.getApplicantsByJobId(jobId, employerId);
        assertFalse(apps.isEmpty(), "Should have at least 1 application");
        Application targetApp = apps.get(0);
        int appId = targetApp.getId();

        // 1. Initial status should be PENDING
        assertEquals("PENDING", targetApp.getStatus());

        // 2. Owner employer updates status to SHORTLISTED -> Should succeed
        boolean updatedShortlist = applicationDAO.updateApplicationStatus(appId, "SHORTLISTED", employerId);
        assertTrue(updatedShortlist, "Job owner employer should be allowed to shortlist application");

        // Verify status reflects in seeker's view
        List<Application> seekerAppsAfterShortlist = applicationDAO.getApplicationsBySeekerId(seekerId);
        assertEquals("SHORTLISTED", seekerAppsAfterShortlist.get(0).getStatus());

        // 3. Unauthorized employer (different ID, e.g. employerId + 999) attempts update -> Must FAIL
        boolean unauthorizedUpdate = applicationDAO.updateApplicationStatus(appId, "REJECTED", employerId + 999);
        assertFalse(unauthorizedUpdate, "Unauthorized employer must NOT be allowed to update application status");

        // 4. Invalid status string -> Must FAIL
        boolean invalidStatusUpdate = applicationDAO.updateApplicationStatus(appId, "INVALID_STATUS", employerId);
        assertFalse(invalidStatusUpdate, "Invalid status values must be rejected");

        // 5. Owner employer updates status to REJECTED -> Should succeed
        boolean updatedReject = applicationDAO.updateApplicationStatus(appId, "REJECTED", employerId);
        assertTrue(updatedReject, "Job owner employer should be allowed to reject application");

        // Verify status reflects in seeker's view as REJECTED
        List<Application> seekerAppsAfterReject = applicationDAO.getApplicationsBySeekerId(seekerId);
        assertEquals("REJECTED", seekerAppsAfterReject.get(0).getStatus());
    }

    @Test
    @Order(9)
    @DisplayName("Test 9: Invalid Passwords & Role Checks")
    public void testSecurityAndRoleValidation() {
        // Wrong password should be rejected
        User wrongPwdUser = userDAO.authenticate(employerEmail, "WrongPassword999!");
        assertNull(wrongPwdUser, "Incorrect password must be rejected");

        // Non-existent email should be rejected
        User nonExistentUser = userDAO.authenticate("ghost_user_404@example.com", "anyPassword");
        assertNull(nonExistentUser, "Non-existent user must be rejected");

        // Role verification
        User emp = userDAO.findByEmail(employerEmail);
        assertNotNull(emp);
        assertTrue(emp.isEmployer());
        assertFalse(emp.isJobSeeker());

        User seeker = userDAO.findByEmail(seekerEmail);
        assertNotNull(seeker);
        assertTrue(seeker.isJobSeeker());
        assertFalse(seeker.isEmployer());
    }
}
