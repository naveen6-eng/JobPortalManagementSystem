$baseUrl = "http://localhost:8080/jobportal"

Write-Host "=========================================="
Write-Host "1. Testing Database Integrity (Real Applications Preserved)"
Write-Host "=========================================="
$env:MYSQL_PWD = "naveen"
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -e "USE job_portal; SELECT id, job_id, seeker_id, status, resume_path FROM applications WHERE id IN (7, 10, 11);"

Write-Host "`n=========================================="
Write-Host "2. Creating Test Resume Files"
Write-Host "=========================================="
$tempDir = "C:\JobPortalManagementSystem\uploads\test_temp"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

$validPdf = "$tempDir\sample_resume.pdf"
[System.IO.File]::WriteAllText($validPdf, "%PDF-1.4 Mock resume content for testing by Naveen Kethavath.")

$invalidTxt = "$tempDir\sample_resume.txt"
[System.IO.File]::WriteAllText($invalidTxt, "This is a plain text file, not a resume.")

$oversizedPdf = "$tempDir\oversized_resume.pdf"
$largeBytes = New-Object byte[] (6 * 1024 * 1024) # 6 MB (over 5 MB limit)
[System.IO.File]::WriteAllBytes($oversizedPdf, $largeBytes)

Write-Host "Created test files in $tempDir"

Write-Host "`n=========================================="
Write-Host "3. Testing Job Seeker Login & Application Flow"
Write-Host "=========================================="
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Login as seeker@portal.com (Seeker ID 2)
$loginResp = Invoke-WebRequest -Uri "$baseUrl/login" -Method POST -Body @{
    email = "seeker@portal.com"
    password = "password123"
} -WebSession $webSession -MaximumRedirection 0 -ErrorAction SilentlyContinue

Write-Host "Seeker Login Status:" $loginResp.StatusCode "Location:" $loginResp.Headers["Location"]

# Find a job where seeker 2 hasn't applied yet
$jobsResp = Invoke-WebRequest -Uri "$baseUrl/home" -WebSession $webSession
Write-Host "Home page loaded with seeker session."

# Test: Apply without resume (empty post) -> Should be rejected
Write-Host "`nTest 3a: Submitting application with NO file..."
try {
    $boundary = [System.Guid]::NewGuid().ToString()
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes("--$boundary`r`nContent-Disposition: form-data; name=`"jobId`"`r`n`r`n3`r`n--$boundary--`r`n")
    $noFileResp = Invoke-WebRequest -Uri "$baseUrl/seeker/apply" -Method POST -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyBytes -WebSession $webSession -MaximumRedirection 0 -ErrorAction SilentlyContinue
    Write-Host "Response Code:" $noFileResp.StatusCode "Redirect:" $noFileResp.Headers["Location"]
    if ($noFileResp.Headers["Location"] -like "*error=*") {
        Write-Host "PASS: Empty resume was rejected properly!" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Empty resume was not rejected!" -ForegroundColor Red
    }
} catch {
    Write-Host "Error during empty file test: $_"
}

# Test 3b: Submitting invalid file type (.txt)
Write-Host "`nTest 3b: Submitting application with invalid file type (.txt)..."
try {
    $boundary = [System.Guid]::NewGuid().ToString()
    $fileContent = [System.IO.File]::ReadAllBytes($invalidTxt)
    $header = "--$boundary`r`nContent-Disposition: form-data; name=`"jobId`"`r`n`r`n3`r`n--$boundary`r`nContent-Disposition: form-data; name=`"resume`"; filename=`"sample_resume.txt`"`r`nContent-Type: text/plain`r`n`r`n"
    $footer = "`r`n--$boundary--`r`n"
    $fullBytes = [System.Text.Encoding]::UTF8.GetBytes($header) + $fileContent + [System.Text.Encoding]::UTF8.GetBytes($footer)

    $txtResp = Invoke-WebRequest -Uri "$baseUrl/seeker/apply" -Method POST -ContentType "multipart/form-data; boundary=$boundary" -Body $fullBytes -WebSession $webSession -MaximumRedirection 0 -ErrorAction SilentlyContinue
    Write-Host "Response Code:" $txtResp.StatusCode "Redirect:" $txtResp.Headers["Location"]
    if ($txtResp.Headers["Location"] -like "*Invalid+file+type*" -or $txtResp.Headers["Location"] -like "*Invalid%20file%20type*") {
        Write-Host "PASS: .txt file was rejected properly with invalid file type error!" -ForegroundColor Green
    } else {
        Write-Host "FAIL: .txt file was not rejected as expected!" -ForegroundColor Red
    }
} catch {
    Write-Host "Error during txt file test: $_"
}

# Test 3c: Submitting valid .pdf resume to Job 3 (posted by employer 3, recruiter@google.com)
Write-Host "`nTest 3c: Submitting valid PDF resume to Job 3..."
try {
    $boundary = [System.Guid]::NewGuid().ToString()
    $fileContent = [System.IO.File]::ReadAllBytes($validPdf)
    $header = "--$boundary`r`nContent-Disposition: form-data; name=`"jobId`"`r`n`r`n3`r`n--$boundary`r`nContent-Disposition: form-data; name=`"resume`"; filename=`"sample_resume.pdf`"`r`nContent-Type: application/pdf`r`n`r`n"
    $footer = "`r`n--$boundary--`r`n"
    $fullBytes = [System.Text.Encoding]::UTF8.GetBytes($header) + $fileContent + [System.Text.Encoding]::UTF8.GetBytes($footer)

    $pdfResp = Invoke-WebRequest -Uri "$baseUrl/seeker/apply" -Method POST -ContentType "multipart/form-data; boundary=$boundary" -Body $fullBytes -WebSession $webSession -MaximumRedirection 0 -ErrorAction SilentlyContinue
    Write-Host "Response Code:" $pdfResp.StatusCode "Redirect:" $pdfResp.Headers["Location"]
    if ($pdfResp.Headers["Location"] -like "*success=*") {
        Write-Host "PASS: Valid PDF application succeeded!" -ForegroundColor Green
    } else {
        Write-Host "FAIL: Valid application failed. Location: $($pdfResp.Headers['Location'])" -ForegroundColor Red
    }
} catch {
    Write-Host "Error during valid pdf test: $_"
}

# Clean up test temp files
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
