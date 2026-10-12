<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String enteredName = (String) request.getAttribute("enteredName");
    String enteredEmail = (String) request.getAttribute("enteredEmail");
    String enteredRole = (String) request.getAttribute("enteredRole");
    if (enteredRole == null) {
        enteredRole = "JOB_SEEKER";
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Job Portal Management System</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

    <!-- Navigation Bar -->
    <jsp:include page="/includes/navbar.jsp" />

    <main class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-6">

                <!-- Notifications -->
                <jsp:include page="/includes/alerts.jsp" />

                <div class="card auth-card p-4">
                    <div class="card-body">
                        <div class="text-center mb-4">
                            <h3 class="fw-bold">Create an Account</h3>
                            <p class="text-muted small">Choose your role to get started</p>
                        </div>

                        <form action="<%= ctx %>/register" method="POST">
                            <div class="mb-3">
                                <label for="name" class="form-label fw-semibold">Full Name</label>
                                <input type="text" class="form-control" id="name" name="name" 
                                       placeholder="e.g. Alex Johnson" required
                                       value="<%= enteredName != null ? enteredName : "" %>">
                            </div>

                            <div class="mb-3">
                                <label for="email" class="form-label fw-semibold">Email Address</label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       placeholder="name@example.com" required
                                       value="<%= enteredEmail != null ? enteredEmail : "" %>">
                            </div>

                            <!-- Role Selection -->
                            <div class="mb-3">
                                <label class="form-label fw-semibold">I am registering as:</label>
                                <div class="row g-2">
                                    <div class="col-6">
                                        <div class="form-check p-3 border rounded h-100">
                                            <input class="form-check-input ms-0 me-2" type="radio" name="role" 
                                                   id="roleSeeker" value="JOB_SEEKER" 
                                                   <%= "JOB_SEEKER".equalsIgnoreCase(enteredRole) ? "checked" : "" %>>
                                            <label class="form-check-label fw-bold" for="roleSeeker">
                                                🎓 Job Seeker
                                                <div class="text-muted fw-normal small">Apply for jobs</div>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="form-check p-3 border rounded h-100">
                                            <input class="form-check-input ms-0 me-2" type="radio" name="role" 
                                                   id="roleEmployer" value="EMPLOYER"
                                                   <%= "EMPLOYER".equalsIgnoreCase(enteredRole) ? "checked" : "" %>>
                                            <label class="form-check-label fw-bold" for="roleEmployer">
                                                👔 Employer
                                                <div class="text-muted fw-normal small">Post jobs & hire</div>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6 mb-3 mb-md-0">
                                    <label for="password" class="form-label fw-semibold">Password</label>
                                    <input type="password" class="form-control" id="password" name="password" 
                                           placeholder="Min 6 characters" required minlength="6">
                                </div>
                                <div class="col-md-6">
                                    <label for="confirmPassword" class="form-label fw-semibold">Confirm Password</label>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                           placeholder="Re-enter password" required minlength="6">
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold mb-3">
                                Register
                            </button>
                        </form>

                        <div class="text-center mt-3 border-top pt-3">
                            <p class="small text-muted mb-0">Already have an account? 
                                <a href="<%= ctx %>/login" class="fw-semibold text-primary text-decoration-none">
                                    Sign In here
                                </a>
                            </p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

</body>
</html>
