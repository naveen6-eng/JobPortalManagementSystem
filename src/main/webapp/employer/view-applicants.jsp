<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.jobportal.model.Job" %>
<%@ page import="com.jobportal.model.Application" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Job job = (Job) request.getAttribute("job");
    List<Application> applicants = (List<Application>) request.getAttribute("applicants");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy - hh:mm a");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Applicants for <%= job != null ? job.getTitle() : "Job" %> - Employer Dashboard</title>
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

        <div class="mb-3">
            <a href="<%= ctx %>/employer/my-jobs" class="btn btn-outline-secondary btn-sm">
                &larr; Back to My Posted Jobs
            </a>
        </div>

        <% if (job != null) { %>
            <div class="card border-0 shadow-sm p-4 mb-4 rounded-3 bg-white">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h4 class="fw-bold mb-1"><%= job.getTitle() %></h4>
                        <div class="text-muted">
                            🏢 <%= job.getCompany() %> &bull; 📍 <%= job.getLocation() %> &bull; 💰 <%= job.getSalary() %>
                        </div>
                    </div>
                    <div>
                        <span class="badge bg-primary fs-6 px-3 py-2">
                            Total Candidates: <%= (applicants != null) ? applicants.size() : 0 %>
                        </span>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 rounded-3 overflow-hidden">
                <div class="card-header bg-dark text-white p-3">
                    <h5 class="mb-0 fw-semibold">👥 Candidate Applications</h5>
                </div>

                <% if (applicants == null || applicants.isEmpty()) { %>
                    <div class="card-body p-5 text-center">
                        <div class="fs-1 text-muted mb-3">📬</div>
                        <h5 class="text-secondary">No Applications Received Yet</h5>
                        <p class="text-muted small">When candidates apply for this position, their contact details will appear here.</p>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" class="ps-3">#</th>
                                    <th scope="col">Candidate Name</th>
                                    <th scope="col">Email Address</th>
                                    <th scope="col">Application Date</th>
                                    <th scope="col" class="text-center">Resume</th>
                                    <th scope="col" class="text-center">Current Status</th>
                                    <th scope="col" class="text-end pe-3">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    int counter = 1;
                                    for (Application app : applicants) { 
                                        String st = app.getStatus();
                                %>
                                    <tr>
                                        <td class="ps-3 text-muted"><%= counter++ %></td>
                                        <td class="fw-semibold text-dark">
                                            🎓 <%= app.getSeekerName() %>
                                        </td>
                                        <td>
                                            <code><%= app.getSeekerEmail() %></code>
                                        </td>
                                        <td class="text-secondary small">
                                            <%= (app.getApplicationDate() != null) ? sdf.format(app.getApplicationDate()) : "N/A" %>
                                        </td>
                                        <td class="text-center">
                                            <% if (app.getResumePath() != null && !app.getResumePath().trim().isEmpty()) { %>
                                                <a href="<%= ctx %>/employer/download-resume?applicationId=<%= app.getId() %>" 
                                                   class="btn btn-outline-primary btn-sm px-2 py-1 fw-semibold" target="_blank" title="View/Download Resume">
                                                    📄 View Resume
                                                </a>
                                            <% } else { %>
                                                <span class="text-muted small">No resume attached</span>
                                            <% } %>
                                        </td>
                                        <td class="text-center">
                                            <% if ("SHORTLISTED".equalsIgnoreCase(st)) { %>
                                                <span class="badge bg-success px-3 py-2">✓ Shortlisted</span>
                                            <% } else if ("REJECTED".equalsIgnoreCase(st)) { %>
                                                <span class="badge bg-danger px-3 py-2">✗ Rejected</span>
                                            <% } else { %>
                                                <span class="badge bg-warning text-dark px-3 py-2">⏳ Pending</span>
                                            <% } %>
                                        </td>
                                        <td class="text-end pe-3">
                                            <div class="d-inline-flex gap-1 align-items-center">
                                                <!-- View Questionnaire Modal Trigger -->
                                                <button type="button" class="btn btn-outline-primary btn-sm" 
                                                        data-bs-toggle="modal" data-bs-target="#appModal<%= app.getId() %>"
                                                        title="View Application Questionnaire">
                                                    📋 Answers
                                                </button>

                                                <!-- Shortlist Form -->
                                                <form action="<%= ctx %>/employer/update-status" method="POST" class="d-inline">
                                                    <input type="hidden" name="applicationId" value="<%= app.getId() %>">
                                                    <input type="hidden" name="jobId" value="<%= job.getId() %>">
                                                    <input type="hidden" name="status" value="SHORTLISTED">
                                                    <button type="submit" class="btn btn-outline-success btn-sm" 
                                                            <%= "SHORTLISTED".equalsIgnoreCase(st) ? "disabled" : "" %>
                                                            title="Mark as Shortlisted">
                                                        Shortlist
                                                    </button>
                                                </form>

                                                <!-- Reject Form -->
                                                <form action="<%= ctx %>/employer/update-status" method="POST" class="d-inline">
                                                    <input type="hidden" name="applicationId" value="<%= app.getId() %>">
                                                    <input type="hidden" name="jobId" value="<%= job.getId() %>">
                                                    <input type="hidden" name="status" value="REJECTED">
                                                    <button type="submit" class="btn btn-outline-danger btn-sm" 
                                                            <%= "REJECTED".equalsIgnoreCase(st) ? "disabled" : "" %>
                                                            title="Mark as Rejected">
                                                        Reject
                                                    </button>
                                                </form>

                                                <!-- Email Button -->
                                                <a href="mailto:<%= app.getSeekerEmail() %>?subject=Regarding your application for <%= job.getTitle() %>" 
                                                   class="btn btn-outline-secondary btn-sm" title="Email Candidate">
                                                    ✉️
                                                </a>
                                            </div>

                                            <!-- Questionnaire Modal -->
                                            <div class="modal fade text-start" id="appModal<%= app.getId() %>" tabindex="-1" aria-labelledby="modalLabel<%= app.getId() %>" aria-hidden="true">
                                                <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                                                    <div class="modal-content">
                                                        <div class="modal-header bg-primary text-white">
                                                            <h5 class="modal-title fw-bold" id="modalLabel<%= app.getId() %>">
                                                                Candidate Questionnaire: <%= app.getSeekerName() %>
                                                            </h5>
                                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body p-4">
                                                            <!-- Section A: Personal Info -->
                                                            <div class="card mb-3 border-0 bg-light">
                                                                <div class="card-body">
                                                                    <h6 class="fw-bold text-primary mb-3">👤 Personal Information</h6>
                                                                    <div class="row g-2 small">
                                                                        <div class="col-sm-6">
                                                                            <strong>Full Name:</strong> <%= app.getFullName() != null ? app.getFullName() : app.getSeekerName() %>
                                                                        </div>
                                                                        <div class="col-sm-6">
                                                                            <strong>Email:</strong> <%= app.getEmail() != null ? app.getEmail() : app.getSeekerEmail() %>
                                                                        </div>
                                                                        <div class="col-sm-6">
                                                                            <strong>Mobile:</strong> <%= app.getMobileNumber() != null ? app.getMobileNumber() : "Not provided" %>
                                                                        </div>
                                                                        <div class="col-sm-6">
                                                                            <strong>Location:</strong> <%= app.getCurrentLocation() != null ? app.getCurrentLocation() : "Not provided" %>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <!-- Section B: Interview Questions -->
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
                                                                        <div class="fw-semibold text-secondary small">2. Prior Work Experience</div>
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

                                                            <!-- Section C: Resume -->
                                                            <div class="d-flex justify-content-between align-items-center p-3 bg-light rounded">
                                                                <div>
                                                                    <strong>Attached Resume:</strong>
                                                                </div>
                                                                <div>
                                                                    <% if (app.getResumePath() != null && !app.getResumePath().trim().isEmpty()) { %>
                                                                        <a href="<%= ctx %>/employer/download-resume?applicationId=<%= app.getId() %>" 
                                                                           class="btn btn-primary btn-sm" target="_blank">
                                                                            📄 View / Download Resume
                                                                        </a>
                                                                    <% } else { %>
                                                                        <span class="text-muted small">No resume attached</span>
                                                                    <% } %>
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
                <% } %>
            </div>
        <% } %>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
