<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String successMsg = (String) request.getAttribute("successMessage");
    if (successMsg == null) {
        successMsg = request.getParameter("success");
    }

    String errorMsg = (String) request.getAttribute("errorMessage");
    if (errorMsg == null) {
        errorMsg = request.getParameter("error");
    }
%>

<% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
    <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <span><%= successMsg %></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<% } %>

<% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
    <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <span><%= errorMsg %></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<% } %>
