package com.jobportal;

import com.jobportal.util.PasswordUtil;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    @DisplayName("Should hash password and verify valid credentials")
    public void testHashAndVerifySuccess() {
        String rawPassword = "securePassword123";
        String hash = PasswordUtil.hashPassword(rawPassword);

        assertNotNull(hash);
        assertTrue(hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$"));
        assertTrue(PasswordUtil.checkPassword(rawPassword, hash));
    }

    @Test
    @DisplayName("Should reject invalid password against hash")
    public void testRejectWrongPassword() {
        String rawPassword = "correctPassword";
        String hash = PasswordUtil.hashPassword(rawPassword);

        assertFalse(PasswordUtil.checkPassword("wrongPassword", hash));
    }

    @Test
    @DisplayName("Should handle null or empty passwords safely")
    public void testNullOrEmptyHandling() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword("   "));
        assertFalse(PasswordUtil.checkPassword(null, "hash"));
        assertFalse(PasswordUtil.checkPassword("pwd", null));
    }
}
