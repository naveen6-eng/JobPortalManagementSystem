package com.jobportal.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for hashing and verifying passwords securely using BCrypt.
 */
public class PasswordUtil {

    private static final int LOG_ROUNDS = 12;

    /**
     * Hashes a plaintext password using BCrypt with salt
     * @param plainTextPassword plain password string
     * @return BCrypt hashed string
     */
    public static String hashPassword(String plainTextPassword) {
        if (plainTextPassword == null || plainTextPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty.");
        }
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(LOG_ROUNDS));
    }

    /**
     * Checks if a plaintext password matches an existing BCrypt hash
     * @param plainTextPassword candidate password
     * @param hashedPassword stored hash
     * @return true if password matches, false otherwise
     */
    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        if (plainTextPassword == null || hashedPassword == null || hashedPassword.trim().isEmpty()) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainTextPassword, hashedPassword);
        } catch (IllegalArgumentException | StringIndexOutOfBoundsException e) {
            return false;
        }
    }
}
