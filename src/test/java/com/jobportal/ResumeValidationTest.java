package com.jobportal;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.*;

public class ResumeValidationTest {

    private static final long MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5 MB

    private boolean isValidResumeExtension(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return false;
        }
        String cleanName = Paths.get(fileName).getFileName().toString().toLowerCase();
        return cleanName.endsWith(".pdf") || cleanName.endsWith(".doc") || cleanName.endsWith(".docx");
    }

    private boolean isValidResumeSize(long fileSizeBytes) {
        return fileSizeBytes > 0 && fileSizeBytes <= MAX_FILE_SIZE_BYTES;
    }

    @Test
    @DisplayName("Accept valid PDF and DOC/DOCX resume file extensions")
    public void testValidResumeExtensions() {
        assertTrue(isValidResumeExtension("resume.pdf"));
        assertTrue(isValidResumeExtension("CV_John_Doe.PDF"));
        assertTrue(isValidResumeExtension("My_Resume.doc"));
        assertTrue(isValidResumeExtension("Naveen_Resume.DOCX"));
        assertTrue(isValidResumeExtension("C:\\Users\\John\\Documents\\candidate_cv.pdf"));
    }

    @Test
    @DisplayName("Reject invalid, executable, script, or image file extensions")
    public void testInvalidResumeExtensions() {
        assertFalse(isValidResumeExtension("malicious.exe"));
        assertFalse(isValidResumeExtension("script.sh"));
        assertFalse(isValidResumeExtension("notes.txt"));
        assertFalse(isValidResumeExtension("photo.png"));
        assertFalse(isValidResumeExtension("archive.zip"));
        assertFalse(isValidResumeExtension("document.pdf.exe"));
        assertFalse(isValidResumeExtension(""));
        assertFalse(isValidResumeExtension(null));
    }

    @Test
    @DisplayName("Validate resume size boundary conditions (Max 5 MB)")
    public void testResumeSizeLimits() {
        // 0 bytes (empty) should be rejected
        assertFalse(isValidResumeSize(0));
        assertFalse(isValidResumeSize(-1));

        // 1 KB, 2 MB, 5 MB should be accepted
        assertTrue(isValidResumeSize(1024));
        assertTrue(isValidResumeSize(2 * 1024 * 1024));
        assertTrue(isValidResumeSize(5 * 1024 * 1024)); // Exact 5 MB limit

        // 5 MB + 1 byte should be rejected
        assertFalse(isValidResumeSize((5 * 1024 * 1024) + 1));
        assertFalse(isValidResumeSize(10 * 1024 * 1024)); // 10 MB
    }
}
