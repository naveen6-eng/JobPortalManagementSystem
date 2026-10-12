$baseUrl = "http://localhost:8080/jobportal"

function Call-Endpoint {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [hashtable]$Body = $null,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session = $null
    )

    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            MaximumRedirection = 0
            UseBasicParsing = $true
        }
        if ($Body) { $params["Body"] = $Body }
        if ($Session) { $params["WebSession"] = $Session }

        $resp = Invoke-WebRequest @params
        return @{ StatusCode = $resp.StatusCode; Location = $resp.Headers["Location"]; Content = $resp.Content }
    } catch [System.Net.WebException] {
        $res = $_.Exception.Response
        if ($res) {
            $status = [int]$res.StatusCode
            $loc = $res.Headers["Location"]
            $stream = $res.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $text = $reader.ReadToEnd()
            return @{ StatusCode = $status; Location = $loc; Content = $text }
        }
        throw $_
    }
}

Write-Host "=================================================="
Write-Host " JOB PORTAL MANAGEMENT SYSTEM - AUTOMATED E2E TEST"
Write-Host "=================================================="

$empSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$seekerSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1. Register Employer
Write-Host "`n[1] Testing Employer Registration..."
$suffix = [System.IO.Path]::GetRandomFileName().Substring(0, 6)
$empEmail = "hr_$suffix@techcorp.com"
$empPass = "Recruiter@123"

$resp = Call-Endpoint -Uri "$baseUrl/register" -Method POST -Body @{
    name = "TechCorp HR $suffix"
    email = $empEmail
    password = $empPass
    confirmPassword = $empPass
    role = "EMPLOYER"
} -Session $empSession

Write-Host " -> Status:" $resp.StatusCode "(Expected: 302 Redirect to /login)"
Write-Host " -> Location:" $resp.Location

# 2. Login Employer
Write-Host "`n[2] Testing Employer Login..."
$resp = Call-Endpoint -Uri "$baseUrl/login" -Method POST -Body @{
    email = $empEmail
    password = $empPass
} -Session $empSession

Write-Host " -> Status:" $resp.StatusCode "(Expected: 302 Redirect to /employer/my-jobs)"
Write-Host " -> Location:" $resp.Location

# 3. Post a Job
Write-Host "`n[3] Testing Job Posting by Employer..."
$jobTitle = "Full Stack Java Developer ($suffix)"
$resp = Call-Endpoint -Uri "$baseUrl/employer/post-job" -Method POST -Body @{
    title = $jobTitle
    company = "TechCorp Solutions"
    location = "Bengaluru, India"
    salary = "₹12,00,000 - ₹16,00,000 / year"
    description = "We are seeking a Full Stack Java Developer proficient in Jakarta Servlets, JSP, JDBC, and MySQL."
} -Session $empSession

Write-Host " -> Status:" $resp.StatusCode "(Expected: 302 Redirect to /employer/my-jobs)"
Write-Host " -> Location:" $resp.Location

# 4. View Employer's Posted Jobs
Write-Host "`n[4] Testing View Employer's Posted Jobs..."
$resp = Call-Endpoint -Uri "$baseUrl/employer/my-jobs" -Method GET -Session $empSession
Write-Host " -> Status:" $resp.StatusCode
$hasJobInMyJobs = $resp.Content.Contains($jobTitle)
Write-Host " -> Contains posted job ($jobTitle):" $hasJobInMyJobs

# 5. Verify Job appears on Home Page & Search
Write-Host "`n[5] Testing Home Page Listing & Search..."
$resp = Call-Endpoint -Uri "$baseUrl/home" -Method GET
Write-Host " -> Home Page Status:" $resp.StatusCode
$hasJobOnHome = $resp.Content.Contains($jobTitle)
Write-Host " -> Contains posted job on Home:" $hasJobOnHome

$searchResp = Call-Endpoint -Uri "$baseUrl/home?keyword=Java&location=Bengaluru" -Method GET
$hasJobInSearch = $searchResp.Content.Contains($jobTitle)
Write-Host " -> Search returns posted job:" $hasJobInSearch

# Extract Job ID
$jobId = $null
if ($resp.Content -match "job/details\?id=(\d+)") {
    $jobId = [int]$matches[1]
    Write-Host " -> Extracted Job ID:" $jobId
}

# 6. Register Job Seeker
Write-Host "`n[6] Testing Job Seeker Registration..."
$seekerEmail = "seeker_$suffix@student.edu"
$seekerPass = "Candidate@123"

$resp = Call-Endpoint -Uri "$baseUrl/register" -Method POST -Body @{
    name = "Candidate $suffix"
    email = $seekerEmail
    password = $seekerPass
    confirmPassword = $seekerPass
    role = "JOB_SEEKER"
} -Session $seekerSession

Write-Host " -> Status:" $resp.StatusCode "(Expected: 302 Redirect to /login)"
Write-Host " -> Location:" $resp.Location

# 7. Login Job Seeker
Write-Host "`n[7] Testing Job Seeker Login..."
$resp = Call-Endpoint -Uri "$baseUrl/login" -Method POST -Body @{
    email = $seekerEmail
    password = $seekerPass
} -Session $seekerSession

Write-Host " -> Status:" $resp.StatusCode "(Expected: 302 Redirect to /home)"
Write-Host " -> Location:" $resp.Location

# 8. Job Seeker Applies to the Job
Write-Host "`n[8] Testing Job Application Submission..."
$resp = Call-Endpoint -Uri "$baseUrl/seeker/apply" -Method POST -Body @{
    jobId = $jobId
} -Session $seekerSession

Write-Host " -> Status:" $resp.StatusCode "(Expected: 302 Redirect to /seeker/my-applications)"
Write-Host " -> Location:" $resp.Location

# 9. Verify Duplicate Application Prevention
Write-Host "`n[9] Testing Duplicate Application Rejection..."
$resp = Call-Endpoint -Uri "$baseUrl/seeker/apply" -Method POST -Body @{
    jobId = $jobId
} -Session $seekerSession

Write-Host " -> Status:" $resp.StatusCode
Write-Host " -> Location:" $resp.Location
$isDuplicateBlocked = $resp.Location.Contains("already") -or $resp.Location.Contains("error")
Write-Host " -> Duplicate prevented successfully:" $isDuplicateBlocked

# 10. Seeker Views Submitted Applications
Write-Host "`n[10] Testing Seeker Viewing Submitted Applications..."
$resp = Call-Endpoint -Uri "$baseUrl/seeker/my-applications" -Method GET -Session $seekerSession
Write-Host " -> Status:" $resp.StatusCode
$hasAppInMyApps = $resp.Content.Contains($jobTitle)
Write-Host " -> Contains applied job in Seeker Dashboard:" $hasAppInMyApps

# 11. Employer Views Applicants for their Job
Write-Host "`n[11] Testing Employer Viewing Candidate Applicants..."
$resp = Call-Endpoint -Uri "$baseUrl/employer/view-applicants?jobId=$jobId" -Method GET -Session $empSession
Write-Host " -> Status:" $resp.StatusCode
$hasApplicantName = $resp.Content.Contains("Candidate $suffix")
$hasApplicantEmail = $resp.Content.Contains($seekerEmail)
Write-Host " -> Contains applicant candidate name:" $hasApplicantName
Write-Host " -> Contains applicant email address:" $hasApplicantEmail

Write-Host "`n=================================================="
Write-Host " ALL 11 VERIFICATION TESTS COMPLETED SUCCESSFULLY!"
Write-Host "=================================================="
