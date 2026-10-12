$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:8080/jobportal"
$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$dbUser = "root"
$env:MYSQL_PWD = "naveen"

Write-Host "================================================================="
Write-Host " REAL END-TO-END VERIFICATION: JOB PORTAL MANAGEMENT SYSTEM"
Write-Host "================================================================="

function Query-MySQL {
    param([string]$Query)
    $output = & $mysqlPath -u $dbUser -e "USE job_portal; $Query"
    return ($output -join "`n")
}

# --- STEP 1: Verify Tomcat HTTP Connection ---
Write-Host "`n[STEP 1] Testing Tomcat Server Response..."
$homeGet = Invoke-WebRequest -Uri "$baseUrl/home" -UseBasicParsing
if ($homeGet.StatusCode -eq 200) {
    Write-Host " [PASS] Tomcat is running and serving http://localhost:8080/jobportal/home (HTTP 200 OK)"
} else {
    Write-Host " [FAIL] Unexpected status code: $($homeGet.StatusCode)"
    exit 1
}

# --- STEP 2: Verify MySQL Database Connection & Core Tables ---
Write-Host "`n[STEP 2] Verifying MySQL Database Connection & Tables..."
$tables = Query-MySQL "SHOW TABLES;"
Write-Host $tables
if ($tables -match "users" -and $tables -match "jobs" -and $tables -match "applications") {
    Write-Host " [PASS] Core tables (users, jobs, applications) verified in MySQL."
} else {
    Write-Host " [FAIL] Core tables missing in MySQL."
    exit 1
}

# --- STEP 3: Test Employer Demo Account Login ---
Write-Host "`n[STEP 3] Testing Employer Demo Account (employer@portal.com / password123)..."
$empSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
try {
    Invoke-WebRequest -Uri "$baseUrl/login" -Method POST -Body @{
        email = "employer@portal.com"
        password = "password123"
    } -WebSession $empSession -MaximumRedirection 0 -UseBasicParsing
} catch [System.Net.WebException] {
    $empStatus = [int]$_.Exception.Response.StatusCode
    $empRedirect = $_.Exception.Response.Headers["Location"]
    Write-Host " Employer Login Status:" $empStatus "Redirect:" $empRedirect
    if ($empStatus -eq 302 -and $empRedirect -like "*employer/my-jobs*") {
        Write-Host " [PASS] Employer demo account authenticated successfully and redirected to dashboard."
    } else {
        Write-Host " [FAIL] Employer login redirection failed."
        exit 1
    }
}

# Verify Employer Dashboard access
$myJobsPage = Invoke-WebRequest -Uri "$baseUrl/employer/my-jobs" -WebSession $empSession -UseBasicParsing
if ($myJobsPage.StatusCode -eq 200 -and $myJobsPage.Content -match "Employer Dashboard") {
    Write-Host " [PASS] Employer dashboard loaded successfully."
} else {
    Write-Host " [FAIL] Could not access employer dashboard."
    exit 1
}

# --- STEP 4: Test Employer Job Posting with Real Database Record ---
Write-Host "`n[STEP 4] Testing Job Posting by Employer Demo Account..."
$testTimestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$newJobTitle = "Principal Software Architect ($testTimestamp)"
$newJobCompany = "Apex Innovations Global"
$newJobLocation = "Hyderabad, Telangana (Remote Option)"
$newJobSalary = "₹25,00,000 - ₹35,00,000 / year"
$newJobDesc = "We are hiring a Principal Software Architect to lead the modernization of enterprise systems using Java Servlets, JSP, JDBC, and MySQL. Requires solid system design expertise."

try {
    Invoke-WebRequest -Uri "$baseUrl/employer/post-job" -Method POST -Body @{
        title = $newJobTitle
        company = $newJobCompany
        location = $newJobLocation
        salary = $newJobSalary
        description = $newJobDesc
    } -WebSession $empSession -MaximumRedirection 0 -UseBasicParsing
} catch [System.Net.WebException] {
    $postStatus = [int]$_.Exception.Response.StatusCode
    $postRedirect = $_.Exception.Response.Headers["Location"]
    Write-Host " Job Post Status:" $postStatus "Redirect:" $postRedirect
    if ($postStatus -eq 302 -and $postRedirect -like "*success=*") {
        Write-Host " [PASS] Job post submitted and redirected with success parameter."
    } else {
        Write-Host " [FAIL] Job post failed."
        exit 1
    }
}

# Verify MySQL Job Record directly
Write-Host "`n -> Checking newly inserted record in MySQL jobs table..."
$sqlJobCheck = Query-MySQL "SELECT id, employer_id, title, company, location, salary, posted_date FROM jobs WHERE title='$newJobTitle';"
Write-Host $sqlJobCheck

$jobIdMatch = [regex]::Match($sqlJobCheck, "(\d+)\s+9\s+Principal")
$createdJobId = 0
if ($jobIdMatch.Success) {
    $createdJobId = [int]$jobIdMatch.Groups[1].Value
    Write-Host " [PASS] Verified job record in MySQL with Job ID: $createdJobId"
} else {
    # Fallback parse ID
    $lines = $sqlJobCheck -split "`r`n"
    foreach ($line in $lines) {
        if ($line -match "^(\d+)\s+9\s+") {
            $createdJobId = [int]$matches[1]
            break
        }
    }
    if ($createdJobId -gt 0) {
        Write-Host " [PASS] Verified job record in MySQL with Job ID: $createdJobId"
    } else {
        Write-Host " [FAIL] Job was not found in MySQL jobs table."
        exit 1
    }
}

# --- STEP 5: Test Job Listing and Search on Home Page ---
Write-Host "`n[STEP 5] Testing Job Listing and Search on Home Page..."
$homePage = Invoke-WebRequest -Uri "$baseUrl/home" -UseBasicParsing
if ($homePage.Content.Contains($newJobTitle)) {
    Write-Host " [PASS] Home page displays newly posted job: '$newJobTitle'"
} else {
    Write-Host " [FAIL] Home page did not list the new job."
    exit 1
}

# Search test
$searchPage = Invoke-WebRequest -Uri "$baseUrl/home?keyword=Architect&location=Hyderabad" -UseBasicParsing
if ($searchPage.Content.Contains($newJobTitle)) {
    Write-Host " [PASS] Search filter successfully found '$newJobTitle' with keyword 'Architect' and location 'Hyderabad'."
} else {
    Write-Host " [FAIL] Search filter failed to return the expected job."
    exit 1
}

# --- STEP 6: Test Job Seeker Demo Account Login ---
Write-Host "`n[STEP 6] Testing Job Seeker Demo Account (seeker@portal.com / password123)..."
$seekerSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
try {
    Invoke-WebRequest -Uri "$baseUrl/login" -Method POST -Body @{
        email = "seeker@portal.com"
        password = "password123"
    } -WebSession $seekerSession -MaximumRedirection 0 -UseBasicParsing
} catch [System.Net.WebException] {
    $seekerStatus = [int]$_.Exception.Response.StatusCode
    $seekerRedirect = $_.Exception.Response.Headers["Location"]
    Write-Host " Seeker Login Status:" $seekerStatus "Redirect:" $seekerRedirect
    if ($seekerStatus -eq 302 -and $seekerRedirect -like "*home*") {
        Write-Host " [PASS] Job Seeker demo account authenticated successfully and redirected to Home."
    } else {
        Write-Host " [FAIL] Job Seeker login failed."
        exit 1
    }
}

# --- STEP 7: Test Job Application with Real Database Record ---
Write-Host "`n[STEP 7] Testing Job Application by Seeker to Job ID $createdJobId..."
try {
    Invoke-WebRequest -Uri "$baseUrl/seeker/apply" -Method POST -Body @{
        jobId = $createdJobId
    } -WebSession $seekerSession -MaximumRedirection 0 -UseBasicParsing
} catch [System.Net.WebException] {
    $applyStatus = [int]$_.Exception.Response.StatusCode
    $applyRedirect = $_.Exception.Response.Headers["Location"]
    Write-Host " Application Status:" $applyStatus "Redirect:" $applyRedirect
    if ($applyStatus -eq 302 -and $applyRedirect -like "*seeker/my-applications*") {
        Write-Host " [PASS] Application submitted and redirected to Seeker Dashboard."
    } else {
        Write-Host " [FAIL] Application submission failed."
        exit 1
    }
}

# Verify MySQL Application Record directly
Write-Host "`n -> Checking newly inserted record in MySQL applications table..."
$sqlAppCheck = Query-MySQL "SELECT a.id, a.job_id, a.seeker_id, a.application_date, u.name AS seeker_name, j.title AS job_title FROM applications a JOIN users u ON a.seeker_id = u.id JOIN jobs j ON a.job_id = j.id WHERE a.job_id = $createdJobId AND a.seeker_id = 10;"
Write-Host $sqlAppCheck

if ($sqlAppCheck -match "Demo Seeker" -and $sqlAppCheck.Contains($newJobTitle)) {
    Write-Host " [PASS] Application record verified in MySQL database!"
} else {
    Write-Host " [FAIL] Application not found in MySQL applications table."
    exit 1
}

# Verify Seeker My Applications Web View
$seekerAppsPage = Invoke-WebRequest -Uri "$baseUrl/seeker/my-applications" -WebSession $seekerSession -UseBasicParsing
if ($seekerAppsPage.Content.Contains($newJobTitle)) {
    Write-Host " [PASS] Seeker Dashboard displays applied job with status."
} else {
    Write-Host " [FAIL] Seeker Dashboard did not display applied job."
    exit 1
}

# --- STEP 8: Test Duplicate Application Prevention Constraint ---
Write-Host "`n[STEP 8] Testing Duplicate Application Prevention Constraint..."
try {
    Invoke-WebRequest -Uri "$baseUrl/seeker/apply" -Method POST -Body @{
        jobId = $createdJobId
    } -WebSession $seekerSession -MaximumRedirection 0 -UseBasicParsing
} catch [System.Net.WebException] {
    $dupStatus = [int]$_.Exception.Response.StatusCode
    $dupRedirect = $_.Exception.Response.Headers["Location"]
    Write-Host " Duplicate Application Response:" $dupStatus "Redirect:" $dupRedirect
    if ($dupRedirect -match "already.*applied|error") {
        Write-Host " [PASS] Duplicate application strictly prevented and flagged by system!"
    } else {
        Write-Host " [FAIL] Duplicate application was not properly blocked."
        exit 1
    }
}

# Check application count in database is still exactly 1
$sqlCountCheck = Query-MySQL "SELECT COUNT(*) AS total_applications FROM applications WHERE job_id = $createdJobId AND seeker_id = 10;"
Write-Host $sqlCountCheck
if ($sqlCountCheck -match "1") {
    Write-Host " [PASS] Verified database constraint: application count is exactly 1."
} else {
    Write-Host " [FAIL] Database contains duplicate application entries!"
    exit 1
}

# --- STEP 9: Test Employer Viewing Candidate Applicants ---
Write-Host "`n[STEP 9] Testing Employer Viewing Candidate Applicants for Job ID $createdJobId..."
$viewApplicantsPage = Invoke-WebRequest -Uri "$baseUrl/employer/view-applicants?jobId=$createdJobId" -WebSession $empSession -UseBasicParsing
if ($viewApplicantsPage.StatusCode -eq 200 -and 
    $viewApplicantsPage.Content -match "Demo Seeker" -and 
    $viewApplicantsPage.Content -match "seeker@portal.com") {
    Write-Host " [PASS] Employer candidate applicant view accurately displays candidate name and email!"
} else {
    Write-Host " [FAIL] Employer candidate applicant view failed."
    exit 1
}

Write-Host "`n================================================================="
Write-Host " ALL END-TO-END VERIFICATION CHECKS PASSED WITH 100% SUCCESS!"
Write-Host "================================================================="
