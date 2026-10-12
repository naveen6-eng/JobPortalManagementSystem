$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:8080/jobportal"
$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$dbUser = "root"
$env:MYSQL_PWD = "naveen"

Write-Host "=========================================================================="
Write-Host " COMPREHENSIVE VERIFICATION: REMAINING REQUIREMENTS & ROLE SECURITY"
Write-Host "=========================================================================="

function Query-MySQL {
    param([string]$Query)
    $output = & $mysqlPath -u $dbUser -e "USE job_portal; $Query"
    return ($output -join "`n")
}

function Invoke-RawPost {
    param(
        [string]$Uri,
        [hashtable]$Body,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session
    )
    try {
        $resp = Invoke-WebRequest -Uri $Uri -Method POST -Body $Body -WebSession $Session -MaximumRedirection 0 -UseBasicParsing
        return @{ StatusCode = $resp.StatusCode; Location = $resp.Headers["Location"]; Content = $resp.Content }
    } catch [System.Net.WebException] {
        $res = $_.Exception.Response
        if ($res) {
            $loc = $res.Headers["Location"]
            return @{ StatusCode = [int]$res.StatusCode; Location = $loc; Content = "" }
        }
        throw $_
    }
}

function Invoke-RawGet {
    param(
        [string]$Uri,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session
    )
    try {
        $resp = Invoke-WebRequest -Uri $Uri -Method GET -WebSession $Session -MaximumRedirection 0 -UseBasicParsing
        return @{ StatusCode = $resp.StatusCode; Location = $resp.Headers["Location"]; Content = $resp.Content }
    } catch [System.Net.WebException] {
        $res = $_.Exception.Response
        if ($res) {
            $loc = $res.Headers["Location"]
            return @{ StatusCode = [int]$res.StatusCode; Location = $loc; Content = "" }
        }
        throw $_
    }
}

# -------------------------------------------------------------------------
# TEST 1: Password Validation & Rejection of Incorrect Passwords
# -------------------------------------------------------------------------
Write-Host "`n[TEST 1] Testing Incorrect Password Rejection..."
$badSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginBad = Invoke-WebRequest -Uri "$baseUrl/login" -Method POST -Body @{
    email = "employer@portal.com"
    password = "WrongPassword999!"
} -WebSession $badSession -UseBasicParsing

$hasErrorMsg = $loginBad.Content -match "Invalid email or password"
Write-Host " -> Status:" $loginBad.StatusCode
Write-Host " -> Contains Error Message:" $hasErrorMsg
if ($hasErrorMsg) {
    Write-Host " [PASS] Incorrect password was strictly rejected with error alert."
} else {
    Write-Host " [FAIL] Incorrect password was not rejected properly."
}

# -------------------------------------------------------------------------
# TEST 2: Successful Login for Employer & Job Seeker Demo Accounts
# -------------------------------------------------------------------------
Write-Host "`n[TEST 2] Testing Valid Demo Account Authentication..."
$empSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginEmp = Invoke-RawPost -Uri "$baseUrl/login" -Body @{
    email = "employer@portal.com"
    password = "password123"
} -Session $empSession
Write-Host " Employer Login Status:" $loginEmp.StatusCode "Redirect:" $loginEmp.Location
if ($loginEmp.StatusCode -eq 302 -and $loginEmp.Location -like "*employer/my-jobs*") {
    Write-Host " [PASS] Employer demo account logged in and redirected to employer dashboard."
} else {
    Write-Host " [FAIL] Employer login failed."
}

$seekerSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginSeeker = Invoke-RawPost -Uri "$baseUrl/login" -Body @{
    email = "seeker@portal.com"
    password = "password123"
} -Session $seekerSession
Write-Host " Seeker Login Status:" $loginSeeker.StatusCode "Redirect:" $loginSeeker.Location
if ($loginSeeker.StatusCode -eq 302 -and $loginSeeker.Location -like "*home*") {
    Write-Host " [PASS] Seeker demo account logged in and redirected to home."
} else {
    Write-Host " [FAIL] Seeker login failed."
}

# -------------------------------------------------------------------------
# TEST 3: Application Status Updates (SHORTLISTED & REJECTED)
# -------------------------------------------------------------------------
Write-Host "`n[TEST 3] Testing Application Status Update by Job Owner Employer..."
# Find an application belonging to Employer ID 9
$appRow = Query-MySQL "SELECT a.id, a.job_id, a.seeker_id, a.status FROM applications a JOIN jobs j ON a.job_id = j.id WHERE j.employer_id = 9 LIMIT 1;"
Write-Host "Target Application Record in MySQL:"
Write-Host $appRow

$appId = 0
$jobId = 0
$lines = $appRow -split "`n"
foreach ($line in $lines) {
    if ($line -match "^(\d+)\s+(\d+)\s+") {
        $appId = [int]$matches[1]
        $jobId = [int]$matches[2]
        break
    }
}
Write-Host " -> Using Target Application ID: $appId on Job ID: $jobId"

# 3A: Employer changes status to SHORTLISTED
Write-Host "`n -> 3A: Updating status to SHORTLISTED..."
$shortlistResp = Invoke-RawPost -Uri "$baseUrl/employer/update-status" -Body @{
    applicationId = $appId
    jobId = $jobId
    status = "SHORTLISTED"
} -Session $empSession
Write-Host " Status update response:" $shortlistResp.StatusCode "Location:" $shortlistResp.Location

$sqlCheckShortlist = Query-MySQL "SELECT id, job_id, seeker_id, status FROM applications WHERE id = $appId;"
Write-Host " MySQL Record after Shortlist:" $sqlCheckShortlist
if ($sqlCheckShortlist -match "SHORTLISTED") {
    Write-Host " [PASS] Application status successfully updated to SHORTLISTED in MySQL!"
} else {
    Write-Host " [FAIL] Status was not updated in MySQL."
}

# 3B: Job Seeker views updated status on their dashboard
Write-Host "`n -> 3B: Job Seeker checks dashboard for SHORTLISTED badge..."
$seekerAppsPage = Invoke-RawGet -Uri "$baseUrl/seeker/my-applications" -Session $seekerSession
$hasShortlistedBadge = $seekerAppsPage.Content.Contains("Shortlisted")
Write-Host " Seeker page contains 'Shortlisted':" $hasShortlistedBadge
if ($hasShortlistedBadge) {
    Write-Host " [PASS] Job Seeker dashboard displays updated SHORTLISTED status!"
} else {
    Write-Host " [FAIL] Seeker dashboard did not display SHORTLISTED status."
}

# 3C: Employer changes status to REJECTED
Write-Host "`n -> 3C: Updating status to REJECTED..."
$rejectResp = Invoke-RawPost -Uri "$baseUrl/employer/update-status" -Body @{
    applicationId = $appId
    jobId = $jobId
    status = "REJECTED"
} -Session $empSession
Write-Host " Status update response:" $rejectResp.StatusCode "Location:" $rejectResp.Location

$sqlCheckReject = Query-MySQL "SELECT id, job_id, seeker_id, status FROM applications WHERE id = $appId;"
Write-Host " MySQL Record after Reject:" $sqlCheckReject
if ($sqlCheckReject -match "REJECTED") {
    Write-Host " [PASS] Application status successfully updated to REJECTED in MySQL!"
} else {
    Write-Host " [FAIL] Status was not updated in MySQL."
}

# 3D: Job Seeker views updated status on their dashboard
Write-Host "`n -> 3D: Job Seeker checks dashboard for Not Selected badge..."
$seekerAppsPage2 = Invoke-RawGet -Uri "$baseUrl/seeker/my-applications" -Session $seekerSession
$hasRejectedBadge = $seekerAppsPage2.Content.Contains("Not Selected")
Write-Host " Seeker page contains 'Not Selected':" $hasRejectedBadge
if ($hasRejectedBadge) {
    Write-Host " [PASS] Job Seeker dashboard displays updated REJECTED (Not Selected) status!"
} else {
    Write-Host " [FAIL] Seeker dashboard did not display REJECTED status."
}

# -------------------------------------------------------------------------
# TEST 4: Authorization Check - Only Job Owner can Update Application
# -------------------------------------------------------------------------
Write-Host "`n[TEST 4] Testing Ownership Protection on Application Status Updates..."
# Attempt update using a Job Seeker session
$attackerSeekerUpdate = Invoke-RawPost -Uri "$baseUrl/employer/update-status" -Body @{
    applicationId = $appId
    jobId = $jobId
    status = "SHORTLISTED"
} -Session $seekerSession
Write-Host " Seeker attempt on employer endpoint -> Status:" $attackerSeekerUpdate.StatusCode "Location:" $attackerSeekerUpdate.Location
if ($attackerSeekerUpdate.Location -match "Access denied|error") {
    Write-Host " [PASS] Job seeker was blocked from updating application status by AuthFilter!"
} else {
    Write-Host " [FAIL] Security vulnerability: Job seeker bypassed role check."
}

# -------------------------------------------------------------------------
# TEST 5: Server-Side Role-Based Route Protection
# -------------------------------------------------------------------------
Write-Host "`n[TEST 5] Testing Server-Side Route Protection..."

# 5A: Employer tries to access Seeker page (/seeker/my-applications)
$empToSeeker = Invoke-RawGet -Uri "$baseUrl/seeker/my-applications" -Session $empSession
Write-Host " Employer accessing /seeker/my-applications -> Status:" $empToSeeker.StatusCode "Location:" $empToSeeker.Location
if ($empToSeeker.Location -match "Access denied|error") {
    Write-Host " [PASS] Employer is blocked from accessing Job Seeker pages."
} else {
    Write-Host " [FAIL] Employer was able to access Job Seeker pages."
}

# 5B: Job Seeker tries to access Employer page (/employer/my-jobs)
$seekerToEmp = Invoke-RawGet -Uri "$baseUrl/employer/my-jobs" -Session $seekerSession
Write-Host " Seeker accessing /employer/my-jobs -> Status:" $seekerToEmp.StatusCode "Location:" $seekerToEmp.Location
if ($seekerToEmp.Location -match "Access denied|error") {
    Write-Host " [PASS] Job Seeker is blocked from accessing Employer pages."
} else {
    Write-Host " [FAIL] Job Seeker was able to access Employer pages."
}

# 5C: Any user tries to access /admin/dashboard
$empToAdmin = Invoke-RawGet -Uri "$baseUrl/admin/dashboard" -Session $empSession
Write-Host " Accessing /admin/dashboard -> Status:" $empToAdmin.StatusCode "Location:" $empToAdmin.Location
if ($empToAdmin.Location -match "Access denied|error") {
    Write-Host " [PASS] Restricted admin routes are blocked on server side."
} else {
    Write-Host " [FAIL] Admin route was accessible."
}

# -------------------------------------------------------------------------
# TEST 6: Session Termination on Logout
# -------------------------------------------------------------------------
Write-Host "`n[TEST 6] Testing Session Invalidation on Logout..."
$logoutResp = Invoke-RawGet -Uri "$baseUrl/logout" -Session $empSession
Write-Host " Logout Status:" $logoutResp.StatusCode "Location:" $logoutResp.Location

# Attempt to access protected page with the invalidated session
$afterLogout = Invoke-RawGet -Uri "$baseUrl/employer/my-jobs" -Session $empSession
Write-Host " Post-Logout Access Status:" $afterLogout.StatusCode "Location:" $afterLogout.Location
if ($afterLogout.Location -match "login.*error") {
    Write-Host " [PASS] Session was completely invalidated! Subsequent requests redirect to login."
} else {
    Write-Host " [FAIL] Session remained active after logout!"
}

Write-Host "`n=========================================================================="
Write-Host " ALL TEST SUITE CHECKS COMPLETED!"
Write-Host "=========================================================================="
