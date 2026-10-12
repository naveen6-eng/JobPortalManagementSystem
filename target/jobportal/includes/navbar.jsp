<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.jobportal.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
%>
<nav class="navbar navbar-expand-lg navbar-dark navbar-custom sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2" href="<%= ctx %>/home">
            <span class="fs-4">💼</span>
            <span class="fw-bold tracking-tight">JobPortal</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain" aria-controls="navMain" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navMain">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="<%= ctx %>/home">Explore Jobs</a>
                </li>
                <% if (currentUser != null && currentUser.isEmployer()) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= ctx %>/employer/my-jobs">My Posted Jobs</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-warning fw-semibold" href="<%= ctx %>/employer/post-job">+ Post a Job</a>
                    </li>
                <% } else if (currentUser != null && currentUser.isJobSeeker()) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= ctx %>/seeker/my-applications">My Applications</a>
                    </li>
                <% } %>
            </ul>

            <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-lg-center gap-2">
                <% if (currentUser == null) { %>
                    <li class="nav-item">
                        <a class="btn btn-outline-light btn-sm px-3" href="<%= ctx %>/login">Sign In</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-primary btn-sm px-3" href="<%= ctx %>/register">Create Account</a>
                    </li>
                <% } else { %>
                    <li class="nav-item text-light me-2">
                        <span class="badge <%= currentUser.isEmployer() ? "badge-role-employer" : "badge-role-seeker" %> p-2">
                            <%= currentUser.isEmployer() ? "👔 Employer" : "🎓 Job Seeker" %>: 
                            <strong><%= currentUser.getName() %></strong>
                        </span>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-outline-danger btn-sm px-3" href="<%= ctx %>/logout">Logout</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
