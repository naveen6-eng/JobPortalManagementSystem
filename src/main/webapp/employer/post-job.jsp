<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String enteredTitle = (String) request.getAttribute("enteredTitle");
    String enteredCompany = (String) request.getAttribute("enteredCompany");
    String enteredLocation = (String) request.getAttribute("enteredLocation");
    String enteredSalary = (String) request.getAttribute("enteredSalary");
    String enteredDescription = (String) request.getAttribute("enteredDescription");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Post a New Job - JobPortal</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

    <!-- Navigation Bar -->
    <jsp:include page="/includes/navbar.jsp" />

    <main class="container my-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">

                <!-- Notifications -->
                <jsp:include page="/includes/alerts.jsp" />

                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-header bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                        <h4 class="mb-0 fw-bold">📢 Post a New Job Opening</h4>
                        <a href="<%= ctx %>/employer/my-jobs" class="btn btn-outline-light btn-sm">My Posted Jobs</a>
                    </div>
                    <div class="card-body p-4">
                        <form action="<%= ctx %>/employer/post-job" method="POST">
                            <div class="mb-3">
                                <label for="title" class="form-label fw-semibold">Job Title <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="title" name="title" 
                                       placeholder="e.g. Full Stack Java Developer" required
                                       value="<%= enteredTitle != null ? enteredTitle : "" %>">
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6 mb-3 mb-md-0">
                                    <label for="company" class="form-label fw-semibold">Company Name <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="company" name="company" 
                                           placeholder="e.g. TechCorp Solutions" required
                                           value="<%= enteredCompany != null ? enteredCompany : "" %>">
                                </div>
                                <div class="col-md-6">
                                    <label for="location" class="form-label fw-semibold">Job Location <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="location" name="location" 
                                           placeholder="e.g. Bangalore / Remote" required
                                           value="<%= enteredLocation != null ? enteredLocation : "" %>">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="salary" class="form-label fw-semibold">Salary / Compensation <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="salary" name="salary" 
                                       placeholder="e.g. ₹8,00,000 - ₹12,00,000 / year" required
                                       value="<%= enteredSalary != null ? enteredSalary : "" %>">
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label fw-semibold">Job Description &amp; Requirements <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="description" name="description" rows="6" 
                                          placeholder="Describe roles, responsibilities, required skills, and qualification..." 
                                          required><%= enteredDescription != null ? enteredDescription : "" %></textarea>
                            </div>

                            <div class="d-flex justify-content-end gap-2">
                                <a href="<%= ctx %>/employer/my-jobs" class="btn btn-outline-secondary px-4">Cancel</a>
                                <button type="submit" class="btn btn-primary px-4 fw-semibold">
                                    Publish Job Opening
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
