<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String enteredEmail = (String) request.getAttribute("enteredEmail");
    if (enteredEmail == null) {
        enteredEmail = request.getParameter("email");
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - Job Portal Management System</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

    <!-- Navigation Bar -->
    <jsp:include page="/includes/navbar.jsp" />

    <main class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">

                <!-- Notifications -->
                <jsp:include page="/includes/alerts.jsp" />

                <div class="card auth-card p-4">
                    <div class="card-body">
                        <div class="text-center mb-4">
                            <h3 class="fw-bold">Welcome Back</h3>
                            <p class="text-muted small">Sign in to your Job Portal account</p>
                        </div>

                        <form action="<%= ctx %>/login" method="POST">
                            <div class="mb-3">
                                <label for="email" class="form-label fw-semibold">Email Address</label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       placeholder="name@example.com" required 
                                       value="<%= enteredEmail != null ? enteredEmail : "" %>">
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label fw-semibold">Password</label>
                                <input type="password" class="form-control" id="password" name="password" 
                                       placeholder="Enter your password" required>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold mb-3">
                                Sign In
                            </button>
                        </form>

                        <div class="text-center mt-3 border-top pt-3">
                            <p class="small text-muted mb-0">Don't have an account yet? 
                                <a href="<%= ctx %>/register" class="fw-semibold text-primary text-decoration-none">
                                    Register here
                                </a>
                            </p>
                        </div>

                        <!-- Demo credentials helper for quick viva evaluation -->
                        <div class="alert alert-light border mt-4 p-2 small">
                            <div class="fw-semibold text-secondary mb-1">💡 Quick Demo Credentials:</div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span>Employer: <code>employer@portal.com</code></span>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0" 
                                        onclick="fillCredentials('employer@portal.com', 'password123')">Fill</button>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mt-1">
                                <span>Seeker: <code>seeker@portal.com</code></span>
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0" 
                                        onclick="fillCredentials('seeker@portal.com', 'password123')">Fill</button>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/includes/footer.jsp" />

    <script>
        function fillCredentials(email, pwd) {
            document.getElementById('email').value = email;
            document.getElementById('password').value = pwd;
        }
    </script>
</body>
</html>
