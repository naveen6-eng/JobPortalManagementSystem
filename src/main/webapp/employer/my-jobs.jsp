<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.jobportal.model.Job" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Job> myJobs = (List<Job>) request.getAttribute("myJobs");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Posted Jobs - Employer Dashboard</title>
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
                <h3 class="fw-bold mb-1">Employer Dashboard: Posted Jobs</h3>
                <p class="text-muted small mb-0">Manage your active job postings and view incoming candidate applications</p>
            </div>
            <a href="<%= ctx %>/employer/post-job" class="btn btn-primary fw-semibold shadow-sm">
                + Post New Job
            </a>
        </div>

        <% if (myJobs == null || myJobs.isEmpty()) { %>
            <div class="card p-5 text-center border-0 shadow-sm rounded-4">
                <div class="fs-1 text-muted mb-3">💼</div>
                <h4 class="text-secondary">No Jobs Posted Yet</h4>
                <p class="text-muted">You haven't posted any job vacancies. Click below to create your first posting.</p>
                <div>
                    <a href="<%= ctx %>/employer/post-job" class="btn btn-primary px-4 mt-2">Post Your First Job</a>
                </div>
            </div>
        <% } else { %>
            <div class="card shadow-sm border-0 rounded-3 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th scope="col" class="ps-3">Job Title &amp; Company</th>
                                <th scope="col">Location</th>
                                <th scope="col">Salary</th>
                                <th scope="col">Posted On</th>
                                <th scope="col" class="text-center">Applicants</th>
                                <th scope="col" class="text-end pe-3">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Job job : myJobs) { %>
                                <tr>
                                    <td class="ps-3">
                                        <div class="fw-bold text-dark"><%= job.getTitle() %></div>
                                        <div class="text-muted small">🏢 <%= job.getCompany() %></div>
                                    </td>
                                    <td>
                                        <span class="badge-location">📍 <%= job.getLocation() %></span>
                                    </td>
                                    <td>
                                        <span class="badge-salary">💰 <%= job.getSalary() %></span>
                                    </td>
                                    <td class="text-secondary small">
                                        <%= (job.getPostedDate() != null) ? sdf.format(job.getPostedDate()) : "N/A" %>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge rounded-pill <%= job.getApplicationCount() > 0 ? "bg-primary" : "bg-secondary" %> px-3 py-2">
                                            <%= job.getApplicationCount() %> Candidate<%= job.getApplicationCount() == 1 ? "" : "s" %>
                                        </span>
                                    </td>
                                    <td class="text-end pe-3">
                                        <div class="btn-group btn-group-sm">
                                            <a href="<%= ctx %>/job/details?id=<%= job.getId() %>" class="btn btn-outline-secondary">
                                                Preview
                                            </a>
                                            <a href="<%= ctx %>/employer/view-applicants?jobId=<%= job.getId() %>" class="btn btn-primary">
                                                View Applicants
                                            </a>
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
