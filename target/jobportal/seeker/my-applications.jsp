<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.jobportal.model.Application" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Application> myApplications = (List<Application>) request.getAttribute("myApplications");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy - hh:mm a");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Applications - JobPortal</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

    <!-- Navigation Bar -->
    <jsp:include page="/includes/navbar.jsp" />

    <main class="container my-5">
        <!-- Notifications -->
        <jsp:include page="/includes/alerts.jsp" />

        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h3 class="fw-bold mb-1">My Submitted Applications</h3>
                <p class="text-muted small mb-0">Track all jobs you have applied for and monitor their status</p>
            </div>
            <a href="<%= ctx %>/home" class="btn btn-outline-primary fw-semibold">
                Explore More Jobs
            </a>
        </div>

        <% if (myApplications == null || myApplications.isEmpty()) { %>
            <div class="card p-5 text-center border-0 shadow-sm rounded-4 bg-white">
                <div class="fs-1 text-muted mb-3">📄</div>
                <h4 class="text-secondary">No Applications Submitted Yet</h4>
                <p class="text-muted">You haven't applied to any job postings yet. Browse open vacancies and apply today!</p>
                <div>
                    <a href="<%= ctx %>/home" class="btn btn-primary px-4 mt-2">Browse Available Jobs</a>
                </div>
            </div>
        <% } else { %>
            <div class="card shadow-sm border-0 rounded-3 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th scope="col" class="ps-3">#</th>
                                <th scope="col">Job Title &amp; Company</th>
                                <th scope="col">Location</th>
                                <th scope="col">Offered Salary</th>
                                <th scope="col">Applied Date</th>
                                <th scope="col" class="text-center">Resume</th>
                                <th scope="col" class="text-center">Status</th>
                                <th scope="col" class="text-end pe-3">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int counter = 1;
                                for (Application app : myApplications) { 
                            %>
                                <tr>
                                    <td class="ps-3 text-muted"><%= counter++ %></td>
                                    <td>
                                        <div class="fw-bold text-dark"><%= app.getJobTitle() %></div>
                                        <div class="text-muted small">🏢 <%= app.getCompany() %></div>
                                    </td>
                                    <td>
                                        <span class="badge-location">📍 <%= app.getLocation() %></span>
                                    </td>
                                    <td>
                                        <span class="badge-salary">💰 <%= app.getSalary() %></span>
                                    </td>
                                    <td class="text-secondary small">
                                        <%= (app.getApplicationDate() != null) ? sdf.format(app.getApplicationDate()) : "N/A" %>
                                    </td>
                                    <td class="text-center">
                                        <% if (app.getResumePath() != null && !app.getResumePath().trim().isEmpty()) { %>
                                            <a href="<%= ctx %>/seeker/download-resume?applicationId=<%= app.getId() %>" 
                                               class="badge bg-primary text-decoration-none px-2 py-1" target="_blank" title="View Uploaded Resume">
                                                📄 View
                                            </a>
                                        <% } else { %>
                                            <span class="text-muted small">None</span>
                                        <% } %>
                                    </td>
                                    <td class="text-center">
                                        <% 
                                            String st = app.getStatus();
                                            if ("SHORTLISTED".equalsIgnoreCase(st)) { 
                                        %>
                                            <span class="badge bg-success px-3 py-2">
                                                🎉 Shortlisted
                                            </span>
                                        <% } else if ("REJECTED".equalsIgnoreCase(st)) { %>
                                            <span class="badge bg-danger px-3 py-2">
                                                ❌ Not Selected
                                            </span>
                                        <% } else { %>
                                            <span class="badge bg-warning text-dark px-3 py-2">
                                                ⏳ Under Review
                                            </span>
                                        <% } %>
                                    </td>
                                    <td class="text-end pe-3">
                                        <div class="d-inline-flex gap-1 align-items-center">
                                            <button type="button" class="btn btn-outline-info btn-sm" 
                                                    data-bs-toggle="modal" data-bs-target="#seekerAppModal<%= app.getId() %>"
                                                    title="View My Questionnaire Answers">
                                                📋 My Answers
                                            </button>
                                            <a href="<%= ctx %>/job/details?id=<%= app.getJobId() %>" class="btn btn-outline-primary btn-sm">
                                                Job Details
                                            </a>
                                        </div>

                                        <!-- Seeker Questionnaire Answers Modal -->
                                        <div class="modal fade text-start" id="seekerAppModal<%= app.getId() %>" tabindex="-1" aria-labelledby="seekerModalLabel<%= app.getId() %>" aria-hidden="true">
                                            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                                                <div class="modal-content">
                                                    <div class="modal-header bg-dark text-white">
                                                        <h5 class="modal-title fw-bold" id="seekerModalLabel<%= app.getId() %>">
                                                            My Application: <%= app.getJobTitle() %> at <%= app.getCompany() %>
                                                        </h5>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body p-4">
                                                        <!-- Application Status Banner -->
                                                        <div class="p-3 mb-3 rounded-3 bg-light d-flex justify-content-between align-items-center border">
                                                            <div>
                                                                <span class="text-muted small">Application Status:</span>
                                                                <h6 class="fw-bold mb-0 mt-1">
                                                                    <% if ("SHORTLISTED".equalsIgnoreCase(st)) { %>
                                                                        <span class="text-success">🎉 Shortlisted</span>
                                                                    <% } else if ("REJECTED".equalsIgnoreCase(st)) { %>
                                                                        <span class="text-danger">❌ Not Selected</span>
                                                                    <% } else { %>
                                                                        <span class="text-warning">⏳ Under Review (Pending)</span>
                                                                    <% } %>
                                                                </h6>
                                                            </div>
                                                            <div>
                                                                <% if (app.getResumePath() != null && !app.getResumePath().trim().isEmpty()) { %>
                                                                    <a href="<%= ctx %>/seeker/download-resume?applicationId=<%= app.getId() %>" 
                                                                       class="btn btn-outline-primary btn-sm" target="_blank">
                                                                        📄 View My Resume
                                                                    </a>
                                                                <% } %>
                                                            </div>
                                                        </div>

                                                        <!-- Section A: Personal Information -->
                                                        <div class="card mb-3 border-0 bg-light">
                                                            <div class="card-body">
                                                                <h6 class="fw-bold text-primary mb-3">👤 Personal Information Submitted</h6>
                                                                <div class="row g-2 small">
                                                                    <div class="col-sm-6">
                                                                        <strong>Full Name:</strong> <%= app.getFullName() != null ? app.getFullName() : "N/A" %>
                                                                    </div>
                                                                    <div class="col-sm-6">
                                                                        <strong>Email:</strong> <%= app.getEmail() != null ? app.getEmail() : "N/A" %>
                                                                    </div>
                                                                    <div class="col-sm-6">
                                                                        <strong>Mobile Number:</strong> <%= app.getMobileNumber() != null ? app.getMobileNumber() : "N/A" %>
                                                                    </div>
                                                                    <div class="col-sm-6">
                                                                        <strong>Location:</strong> <%= app.getCurrentLocation() != null ? app.getCurrentLocation() : "N/A" %>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <!-- Section B: Interview Answers -->
                                                        <div class="card mb-3 border-0 bg-light">
                                                            <div class="card-body">
                                                                <h6 class="fw-bold text-primary mb-3">💼 Interview Responses</h6>
                                                                
                                                                <div class="mb-3">
                                                                    <div class="fw-semibold text-secondary small">1. Why should we hire you?</div>
                                                                    <div class="p-2 bg-white rounded border mt-1">
                                                                        <%= app.getWhyHireYou() != null ? app.getWhyHireYou() : "<span class='text-muted'>No answer recorded</span>" %>
                                                                    </div>
                                                                </div>

                                                                <div class="mb-3">
                                                                    <div class="fw-semibold text-secondary small">2. Work Experience</div>
                                                                    <div class="p-2 bg-white rounded border mt-1">
                                                                        <span class="badge <%= "Yes".equalsIgnoreCase(app.getHasExperience()) ? "bg-success" : "bg-info text-dark" %> me-2">
                                                                            <%= "Yes".equalsIgnoreCase(app.getHasExperience()) ? "Experienced" : "Fresher" %>
                                                                        </span>
                                                                        <span><%= app.getExperienceDetails() != null ? app.getExperienceDetails() : "Fresher" %></span>
                                                                    </div>
                                                                </div>

                                                                <div class="mb-3">
                                                                    <div class="fw-semibold text-secondary small">3. Salary Expectations</div>
                                                                    <div class="p-2 bg-white rounded border mt-1 fw-semibold text-dark">
                                                                        💰 <%= app.getSalaryExpectation() != null ? app.getSalaryExpectation() : "Negotiable" %>
                                                                    </div>
                                                                </div>

                                                                <div class="mb-2">
                                                                    <div class="fw-semibold text-secondary small">4. Why do you want this job?</div>
                                                                    <div class="p-2 bg-white rounded border mt-1">
                                                                        <%= app.getWhyThisJob() != null ? app.getWhyThisJob() : "<span class='text-muted'>No answer recorded</span>" %>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
