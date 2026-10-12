<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.jobportal.model.Job" %>
<%@ page import="com.jobportal.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Job job = (Job) request.getAttribute("job");
    Boolean hasApplied = (Boolean) request.getAttribute("hasApplied");
    if (hasApplied == null) {
        hasApplied = false;
    }
    User currentUser = (User) session.getAttribute("user");
    SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
    String ctx = request.getContextPath();

    if (job == null) {
        response.sendRedirect(ctx + "/home?error=Job not found.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= job.getTitle() %> at <%= job.getCompany() %> - JobPortal</title>
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

        <div class="row justify-content-center">
            <div class="col-lg-9">

                <div class="mb-3">
                    <a href="<%= ctx %>/home" class="btn btn-outline-secondary btn-sm">
                        &larr; Back to Job Listings
                    </a>
                </div>

                <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                    <div class="bg-primary text-white p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                            <div>
                                <h2 class="fw-bold mb-2"><%= job.getTitle() %></h2>
                                <h5 class="opacity-90 mb-3">🏢 <%= job.getCompany() %></h5>
                            </div>
                            <% if (hasApplied) { %>
                                <span class="badge bg-success fs-6 px-3 py-2">
                                    ✓ Applied Already
                                </span>
                            <% } %>
                        </div>

                        <div class="d-flex flex-wrap gap-2 mt-2">
                            <span class="badge bg-light text-dark px-3 py-2 fs-6">📍 <%= job.getLocation() %></span>
                            <span class="badge bg-warning text-dark px-3 py-2 fs-6">💰 <%= job.getSalary() %></span>
                            <span class="badge bg-light text-secondary px-3 py-2 fs-6">
                                📅 Posted: <%= (job.getPostedDate() != null) ? sdf.format(job.getPostedDate()) : "Recently" %>
                            </span>
                        </div>
                    </div>

                    <div class="card-body p-4 p-md-5">
                        <h4 class="fw-bold mb-3">Job Description &amp; Requirements</h4>
                        <div class="text-secondary lh-lg mb-5" style="white-space: pre-line;">
                            <%= job.getDescription() %>
                        </div>

                        <div class="border-top pt-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <div>
                                <% if (job.getEmployerName() != null && !job.getEmployerName().isEmpty()) { %>
                                    <p class="small text-muted mb-0">Posted by: <strong><%= job.getEmployerName() %></strong></p>
                                <% } %>
                            </div>

                            <div class="d-flex gap-2">
                                <% if (currentUser == null) { %>
                                    <a href="<%= ctx %>/login" class="btn btn-primary px-4 py-2 fw-semibold">
                                        Log In to Apply
                                    </a>
                                <% } else if (currentUser.isJobSeeker()) { %>
                                    <% if (hasApplied) { %>
                                        <button class="btn btn-secondary px-4 py-2" disabled>
                                            ✓ Application Submitted
                                        </button>
                                        <a href="<%= ctx %>/seeker/my-applications" class="btn btn-outline-primary px-4 py-2">
                                            View My Applications
                                        </a>
                                    <% } else { %>
                                        <a href="#applySection" class="btn btn-success px-4 py-2 fw-semibold shadow-sm">
                                            Apply with Resume &darr;
                                        </a>
                                    <% } %>
                                <% } else if (currentUser.isEmployer()) { %>
                                    <% if (currentUser.getId() == job.getEmployerId()) { %>
                                        <a href="<%= ctx %>/employer/view-applicants?jobId=<%= job.getId() %>" class="btn btn-primary px-4 py-2">
                                            View Candidates for this Job
                                        </a>
                                    <% } else { %>
                                        <span class="badge bg-secondary p-2">Logged in as Employer</span>
                                    <% } %>
                                <% } %>
                            </div>
                        </div>

                        <% if (currentUser != null && currentUser.isJobSeeker() && !hasApplied) { %>
                            <div class="card border-primary shadow-sm rounded-4 p-4 p-md-5 mt-4" id="applySection">
                                <div class="d-flex align-items-center gap-2 mb-3">
                                    <span class="fs-4">📝</span>
                                    <div>
                                        <h4 class="fw-bold mb-0 text-primary">Job Application &amp; Candidate Questionnaire</h4>
                                        <p class="text-muted small mb-0">Please complete all required fields and upload your resume to apply.</p>
                                    </div>
                                </div>

                                <form action="<%= ctx %>/seeker/apply?jobId=<%= job.getId() %>" method="POST" enctype="multipart/form-data" class="needs-validation">
                                    <input type="hidden" name="jobId" value="<%= job.getId() %>">

                                    <!-- SECTION A: PERSONAL INFORMATION -->
                                    <div class="p-3 mb-4 rounded-3 bg-light border">
                                        <h5 class="fw-bold text-dark mb-3 border-bottom pb-2">
                                            👤 Section A: Personal Information
                                        </h5>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label for="fullName" class="form-label fw-semibold">
                                                    Full Name <span class="text-danger">*</span>
                                                </label>
                                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                                       value="<%= currentUser.getName() != null ? currentUser.getName() : "" %>" 
                                                       placeholder="e.g. Alex Johnson" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="email" class="form-label fw-semibold">
                                                    Email Address <span class="text-danger">*</span>
                                                </label>
                                                <input type="email" class="form-control" id="email" name="email" 
                                                       value="<%= currentUser.getEmail() != null ? currentUser.getEmail() : "" %>" 
                                                       placeholder="e.g. candidate@example.com" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="mobileNumber" class="form-label fw-semibold">
                                                    Mobile Number <span class="text-danger">*</span>
                                                </label>
                                                <input type="tel" class="form-control" id="mobileNumber" name="mobileNumber" 
                                                       placeholder="e.g. +91 9876543210" pattern="[0-9+() -]{10,20}" required>
                                                <div class="form-text small">Enter a valid 10-digit mobile number with optional country code.</div>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="currentLocation" class="form-label fw-semibold">
                                                    Current Location / City <span class="text-danger">*</span>
                                                </label>
                                                <input type="text" class="form-control" id="currentLocation" name="currentLocation" 
                                                       placeholder="e.g. Bengaluru, Karnataka" required>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- SECTION B: INTERVIEW QUESTIONS -->
                                    <div class="p-3 mb-4 rounded-3 bg-light border">
                                        <h5 class="fw-bold text-dark mb-3 border-bottom pb-2">
                                            💼 Section B: Interview Questions
                                        </h5>
                                        
                                        <div class="mb-3">
                                            <label for="whyHireYou" class="form-label fw-semibold">
                                                1. Why should we hire you? <span class="text-danger">*</span>
                                            </label>
                                            <textarea class="form-control" id="whyHireYou" name="whyHireYou" rows="3" required
                                                      placeholder="I am a quick learner, responsible, and eager to contribute my skills to the team's success."></textarea>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-semibold d-block">
                                                2. Do you have prior work experience? <span class="text-danger">*</span>
                                            </label>
                                            <div class="form-check form-check-inline">
                                                <input class="form-check-input" type="radio" name="hasExperience" id="expYes" 
                                                       value="Yes" onchange="toggleExperience('Yes')" required>
                                                <label class="form-check-label fw-semibold" for="expYes">Yes (Experienced)</label>
                                            </div>
                                            <div class="form-check form-check-inline">
                                                <input class="form-check-input" type="radio" name="hasExperience" id="expNo" 
                                                       value="No" onchange="toggleExperience('No')" checked required>
                                                <label class="form-check-label fw-semibold" for="expNo">No (Fresher)</label>
                                            </div>
                                            
                                            <!-- If Experienced -->
                                            <div id="experienceDetailsContainer" class="mt-3" style="display: none;">
                                                <label for="experienceDetailsInput" class="form-label fw-semibold">
                                                    Relevant Experience &amp; Total Years <span class="text-danger">*</span>
                                                </label>
                                                <textarea class="form-control" id="experienceDetailsInput" name="experienceDetails" rows="2"
                                                          placeholder="e.g. 2 years of experience developing Java Servlets, RESTful APIs, and relational databases."></textarea>
                                            </div>

                                            <!-- If Fresher -->
                                            <div id="fresherNote" class="mt-2 text-muted small p-2 bg-white rounded border">
                                                🎓 Identifying as <strong>Fresher</strong>: Relevant skills gained through academic projects and practical learning.
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <label for="salaryExpectation" class="form-label fw-semibold">
                                                3. What are your salary expectations? <span class="text-danger">*</span>
                                            </label>
                                            <input type="text" class="form-control" id="salaryExpectation" name="salaryExpectation" 
                                                   placeholder="Negotiable, depending on the role and company standards" required>
                                            <div class="form-text small">Enter your expected CTC (e.g., ₹6,00,000 / year) or "Negotiable".</div>
                                        </div>

                                        <div class="mb-3">
                                            <label for="whyThisJob" class="form-label fw-semibold">
                                                4. Why do you want this job? <span class="text-danger">*</span>
                                            </label>
                                            <textarea class="form-control" id="whyThisJob" name="whyThisJob" rows="3" required
                                                      placeholder="This role matches my interests and skills and offers an opportunity to learn, grow, and contribute."></textarea>
                                        </div>
                                    </div>

                                    <!-- SECTION C: RESUME UPLOAD -->
                                    <div class="p-3 mb-4 rounded-3 bg-light border">
                                        <h5 class="fw-bold text-dark mb-3 border-bottom pb-2">
                                            📄 Section C: Resume Upload
                                        </h5>
                                        <div class="mb-2">
                                            <label for="resumeInput" class="form-label fw-semibold">
                                                Select Resume Document <span class="text-danger">*</span>
                                            </label>
                                            <input class="form-control" type="file" id="resumeInput" name="resume" 
                                                   accept=".pdf,.doc,.docx" required>
                                            <div class="form-text text-muted mt-2">
                                                Accepted formats: <strong>.pdf, .doc, .docx</strong> &bull; Max file size: <strong>5 MB</strong>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="d-grid gap-2">
                                        <button type="submit" class="btn btn-success btn-lg fw-semibold shadow-sm py-3">
                                            🚀 Submit Complete Application &amp; Resume
                                        </button>
                                    </div>
                                </form>
                            </div>

                            <script>
                                function toggleExperience(hasExp) {
                                    var container = document.getElementById('experienceDetailsContainer');
                                    var input = document.getElementById('experienceDetailsInput');
                                    var fresherNote = document.getElementById('fresherNote');
                                    if (hasExp === 'Yes') {
                                        container.style.display = 'block';
                                        input.setAttribute('required', 'required');
                                        fresherNote.style.display = 'none';
                                    } else {
                                        container.style.display = 'none';
                                        input.removeAttribute('required');
                                        fresherNote.style.display = 'block';
                                    }
                                }
                            </script>
                        <% } %>

                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
