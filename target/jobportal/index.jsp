<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.jobportal.model.Job" %>
<%@ page import="com.jobportal.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // If accessed directly without HomeServlet forward, redirect to /home controller
    if (request.getAttribute("jobs") == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    List<Job> jobs = (List<Job>) request.getAttribute("jobs");
    Set<Integer> appliedJobIds = (Set<Integer>) request.getAttribute("appliedJobIds");
    User currentUser = (User) session.getAttribute("user");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String searchLocation = (String) request.getAttribute("searchLocation");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Job Portal Management System</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

    <!-- Navigation Bar -->
    <jsp:include page="/includes/navbar.jsp" />

    <!-- Hero Header & Search Section -->
    <div class="hero-banner shadow-sm">
        <div class="container text-center">
            <h1 class="display-5 fw-bold mb-3">Find Your Dream Job Today</h1>
            <p class="lead mb-4 opacity-90">Browse verified opportunities from top companies or post new openings</p>

            <!-- Search Form -->
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <form action="<%= ctx %>/home" method="GET" class="search-box-container">
                        <div class="row g-2 align-items-center">
                            <div class="col-md-5">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0">🔍</span>
                                    <input type="text" name="keyword" class="form-control border-start-0" 
                                           placeholder="Job title, keywords, or company..." 
                                           value="<%= searchKeyword != null ? searchKeyword : "" %>">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0">📍</span>
                                    <input type="text" name="location" class="form-control border-start-0" 
                                           placeholder="City or Location..." 
                                           value="<%= searchLocation != null ? searchLocation : "" %>">
                                </div>
                            </div>
                            <div class="col-md-3 d-grid gap-2 d-md-flex">
                                <button type="submit" class="btn btn-primary flex-grow-1 fw-semibold">Search</button>
                                <% if ((searchKeyword != null && !searchKeyword.isEmpty()) || (searchLocation != null && !searchLocation.isEmpty())) { %>
                                    <a href="<%= ctx %>/home" class="btn btn-outline-secondary">Reset</a>
                                <% } %>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content: Job Listings -->
    <main class="container my-4">
        <!-- Notification Alerts -->
        <jsp:include page="/includes/alerts.jsp" />

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-0">Available Opportunities</h3>
                <p class="text-muted small mb-0">
                    Showing <%= (jobs != null) ? jobs.size() : 0 %> active position<%= (jobs != null && jobs.size() == 1) ? "" : "s" %>
                </p>
            </div>
            <% if (currentUser != null && currentUser.isEmployer()) { %>
                <a href="<%= ctx %>/employer/post-job" class="btn btn-success fw-semibold shadow-sm">
                    + Post New Job
                </a>
            <% } %>
        </div>

        <% if (jobs == null || jobs.isEmpty()) { %>
            <div class="text-center py-5 bg-white rounded-3 border">
                <div class="fs-1 text-muted mb-3">📋</div>
                <h4 class="text-secondary">No Jobs Found</h4>
                <p class="text-muted">No vacancies match your search criteria. Try different search terms or clear filters.</p>
                <a href="<%= ctx %>/home" class="btn btn-outline-primary btn-sm mt-2">View All Jobs</a>
            </div>
        <% } else { %>
            <div class="row g-3">
                <% for (Job job : jobs) { 
                    boolean hasAlreadyApplied = (appliedJobIds != null && appliedJobIds.contains(job.getId()));
                %>
                    <div class="col-md-6 col-lg-4">
                        <div class="card h-100 job-card p-3 d-flex flex-column">
                            <div class="card-body p-0 d-flex flex-column">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title fw-bold text-dark mb-1">
                                        <a href="<%= ctx %>/job/details?id=<%= job.getId() %>" class="text-decoration-none text-dark">
                                            <%= job.getTitle() %>
                                        </a>
                                    </h5>
                                    <% if (hasAlreadyApplied) { %>
                                        <span class="badge bg-success">Applied</span>
                                    <% } %>
                                </div>

                                <h6 class="card-subtitle text-primary fw-semibold mb-3">
                                    🏢 <%= job.getCompany() %>
                                </h6>

                                <div class="d-flex flex-wrap gap-2 mb-3">
                                    <span class="badge-location">📍 <%= job.getLocation() %></span>
                                    <span class="badge-salary">💰 <%= job.getSalary() %></span>
                                </div>

                                <p class="card-text text-secondary small flex-grow-1">
                                    <% 
                                        String desc = job.getDescription();
                                        if (desc != null && desc.length() > 140) {
                                            desc = desc.substring(0, 140) + "...";
                                        }
                                    %>
                                    <%= desc %>
                                </p>

                                <div class="border-top pt-3 mt-3 d-flex justify-content-between align-items-center">
                                    <span class="text-muted small">
                                        Posted: <%= (job.getPostedDate() != null) ? sdf.format(job.getPostedDate()) : "Recently" %>
                                    </span>
                                    <div class="d-flex gap-2">
                                        <a href="<%= ctx %>/job/details?id=<%= job.getId() %>" class="btn btn-outline-primary btn-sm">
                                            Details
                                        </a>
                                        <% if (currentUser != null && currentUser.isJobSeeker()) { %>
                                            <% if (hasAlreadyApplied) { %>
                                                <button class="btn btn-secondary btn-sm" disabled>Applied</button>
                                            <% } else { %>
                                                <a href="<%= ctx %>/job/details?id=<%= job.getId() %>#applySection" class="btn btn-primary btn-sm">
                                                    Apply
                                                </a>
                                            <% } %>
                                        <% } else if (currentUser == null) { %>
                                            <a href="<%= ctx %>/login" class="btn btn-outline-secondary btn-sm">Apply</a>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
