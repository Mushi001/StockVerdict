package org.henriette.stockverdict.services;

import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.models.Otp;
import org.henriette.stockverdict.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import org.mindrot.jbcrypt.BCrypt;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Properties;

/**
 * Service class for managing {@link Users} and their authentication via {@link Otp}.
 * Handles user registration, login, email OTPs, and password hashing.
 */
public class UserService {

    /**
     * Hashes a plain text password using BCrypt.
     *
     * @param plainPassword the raw password to secure
     * @return the hashed BCrypt string
     */
    private String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }

    private boolean checkPassword(String plainPassword, String hashedPassword) {
        if (hashedPassword != null && hashedPassword.startsWith("$2b$")) {
            hashedPassword = "$2a$" + hashedPassword.substring(4);
        }
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }

    /**
     * Registers a new user in the system.
     * Hashes their password and sets their creation timestamps.
     *
     * @param user the user details to persist
     * @return true if successfully registered, false on error
     */
    public boolean registerUser(Users user) {
        Session session = null;
        Transaction transaction = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            user.setPassword(hashPassword(user.getPassword()));
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());

            session.persist(user);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Authenticates a user primarily using their email and password.
     *
     * @param email    the plain text email address
     * @param password the plain text password to check against their hashed storage
     * @return the {@link Users} entity if credentials are valid, null otherwise
     */
    public Users loginUser(String email, String password) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Users> query = session.createQuery(
                    "FROM Users WHERE email = :email", Users.class);

            query.setParameter("email", email);

            Users user = query.uniqueResult();

            if (user != null && checkPassword(password, user.getPassword())) {
                // If status is null, treat as pending for safety, but existing users were migrated to ACTIVE
                if (user.getStatus() == null) user.setStatus("PENDING");
                return user;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Saves a new OTP for the given user.
     * Automatically invalidates any previously unused OTPs before inserting the new one.
     *
     * @param user       the requesting user
     * @param otpCode    the raw OTP string
     * @param expiryTime the absolute expiration time
     */
    public boolean saveOtp(Users user, String otpCode, LocalDateTime expiryTime) {
        Session session = null;
        Transaction transaction = null;

        try {
            System.out.println("[DEBUG] saveOtp started for User ID: " + user.getId());
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            System.out.println("[DEBUG] Deleting old OTPs...");
            // Use user.id for HQL to avoid detached entity issues
            Query<?> deleteQuery = session.createQuery(
                    "DELETE FROM Otp WHERE user.id = :userId AND used = false");
            deleteQuery.setParameter("userId", user.getId());
            int deletedCount = deleteQuery.executeUpdate();
            System.out.println("[DEBUG] Deleted " + deletedCount + " unused OTPs");

            // Reload user in current session to ensure it's managed
            System.out.println("[DEBUG] Loading managed user...");
            Users managedUser = session.get(Users.class, user.getId());
            if (managedUser == null) {
                System.out.println("[ERROR] Managed user not found for ID: " + user.getId());
                throw new RuntimeException("User not found in database for ID: " + user.getId());
            }

            Otp otp = new Otp(managedUser, otpCode, expiryTime);
            System.out.println("[DEBUG] Persisting new OTP: " + otpCode);
            session.persist(otp);
            
            System.out.println("[DEBUG] Committing transaction...");
            transaction.commit();
            System.out.println("[DEBUG] OTP saved successfully");
            return true;

        } catch (Exception e) {
            System.err.println("[CRITICAL ERROR] Transaction failed in saveOtp: " + e.getMessage());
            e.printStackTrace();
            
            if (transaction != null && transaction.isActive()) {
                try {
                    System.out.println("[DEBUG] Attempting rollback...");
                    transaction.rollback();
                    System.out.println("[DEBUG] Rollback successful");
                } catch (Exception rollbackEx) {
                    System.err.println("[ERROR] Rollback failed: " + rollbackEx.getMessage());
                }
            }
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
                System.out.println("[DEBUG] Session closed");
            }
        }
    }

    /**
     * Retrieves the most recently created OTP for a user.
     *
     * @param user the user whose OTP is required
     * @return the latest {@link Otp} instance, or null if none exist
     */
    public Otp getLatestOtp(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Otp> query = session.createQuery(
                    "FROM Otp WHERE user.id = :userId ORDER BY id DESC",
                    Otp.class);

            query.setParameter("userId", user.getId());
            query.setMaxResults(1);

            List<Otp> list = query.list();

            if (!list.isEmpty()) {
                Otp otp = list.get(0);
                System.out.println("[DEBUG] getLatestOtp for User " + user.getId() + ": " + otp.getOtpCode() + " (Used: " + otp.isUsed() + ")");
                return otp;
            }
            System.out.println("[DEBUG] No OTP found for User " + user.getId());

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Marks a specific OTP as used to prevent subsequent re-use.
     *
     * @param otp the OTP record to update
     */
    public void markOtpAsUsed(Otp otp) {
        Session session = null;
        Transaction transaction = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            otp.setUsed(true);
            session.merge(otp);

            transaction.commit();

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Sends the generated OTP to the user's email address using SMTP settings
     * loaded dynamically from properties configuration files.
     *
     * @param recipientEmail the target email to send the code to
     * @param otpCode        the actual code to dispatch
     * @return true if the email was successfully sent, false otherwise
     */
    public boolean sendOtpEmail(String recipientEmail, String otpCode) {

        // Load from config.local.properties (preferred) or config.properties
        Properties config = new Properties();
        String localConfig = "config.local.properties";
        String defaultConfig = "config.properties";

        try {
            InputStream input = getClass().getClassLoader().getResourceAsStream(localConfig);
            if (input == null) {
                input = getClass().getClassLoader().getResourceAsStream(defaultConfig);
            }

            if (input != null) {
                config.load(input);
                input.close();
            } else {
                System.err.println("Configuration file not found (tried " + localConfig + " and " + defaultConfig + ")");
                return false;
            }
        } catch (IOException e) {
            System.err.println("Failed to load configuration");
            e.printStackTrace();
            return false;
        }

        String senderEmail    = config.getProperty("SMTP_EMAIL");
        String senderPassword = config.getProperty("SMTP_PASSWORD");
        String smtpHost       = config.getProperty("SMTP_HOST");
        String smtpPort       = config.getProperty("SMTP_PORT");

        // Fallback to environment variables (for production/Render)
        if (senderEmail == null || senderEmail.isBlank()) senderEmail = System.getenv("SMTP_EMAIL");
        if (senderPassword == null || senderPassword.isBlank()) senderPassword = System.getenv("SMTP_PASSWORD");
        if (smtpHost == null || smtpHost.isBlank()) smtpHost = System.getenv("SMTP_HOST");
        if (smtpPort == null || smtpPort.isBlank()) smtpPort = System.getenv("SMTP_PORT");

        // Defaults if still null
        if (smtpHost == null || smtpHost.isBlank()) smtpHost = "smtp.gmail.com";
        if (smtpPort == null || smtpPort.isBlank()) smtpPort = "587";

        if (senderEmail == null || senderEmail.isBlank() ||
                senderPassword == null || senderPassword.isBlank()) {
            System.err.println("[UserService] Error: SMTP_EMAIL or SMTP_PASSWORD not found in config or environment.");
            return false;
        }

        final String finalSenderEmail = senderEmail;
        final String finalSenderPassword = senderPassword;

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2"); // Enforce modern TLS
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.trust", smtpHost);
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        jakarta.mail.Session mailSession =
                jakarta.mail.Session.getInstance(props,
                        new Authenticator() {
                            protected PasswordAuthentication getPasswordAuthentication() {
                                return new PasswordAuthentication(finalSenderEmail, finalSenderPassword);
                            }
                        });

        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(finalSenderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Your Login OTP - StockVerdict");
            
            String htmlContent = "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 30px; background-color: #f4f7f6; border-radius: 8px;\">"
                    + "<div style=\"text-align: center; margin-bottom: 30px;\">"
                    + "<h1 style=\"color: #2c3e50; margin: 0; font-size: 28px; letter-spacing: 1px;\">StockVerdict</h1>"
                    + "<div style=\"height: 3px; background-color: #27ae60; width: 50px; margin: 10px auto;\"></div>"
                    + "</div>"
                    + "<div style=\"background-color: #ffffff; padding: 40px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);\">"
                    + "<h2 style=\"color: #333333; margin-top: 0; font-size: 22px;\">Authentication Required</h2>"
                    + "<p style=\"color: #666666; font-size: 16px; line-height: 1.6; margin-bottom: 25px;\">You are attempting to sign in to your StockVerdict account. Please use the verification code below to complete the secure login process:</p>"
                    + "<div style=\"text-align: center; margin: 35px 0;\">"
                    + "<span style=\"display: inline-block; font-size: 36px; font-weight: 700; color: #2ecc71; background-color: #eaeded; padding: 20px 40px; border-radius: 8px; letter-spacing: 6px; border: 1px solid #d5f5e3;\">" + otpCode + "</span>"
                    + "</div>"
                    + "<p style=\"color: #666666; font-size: 15px; line-height: 1.6;\">This code is valid for <strong>5 minutes</strong>. For your security, please do not share this code with anyone.</p>"
                    + "<div style=\"margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;\">"
                    + "<p style=\"color: #999999; font-size: 13px; line-height: 1.5; margin: 0;\">If you did not initiate this request, please ignore it or contact our support team immediately.</p>"
                    + "</div>"
                    + "</div>"
                    + "<div style=\"text-align: center; margin-top: 25px; color: #aaaaaa; font-size: 12px;\">"
                    + "&copy; " + java.time.Year.now().getValue() + " StockVerdict. All rights reserved."
                    + "</div>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("OTP email sent successfully to " + recipientEmail);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send OTP email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    /**
     * Checks if the supplied email address is already taken by an existing user.
     *
     * @param email the email to check
     * @return true if a user possesses the email, false otherwise
     */
    public boolean isEmailExists(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Long> query = session.createQuery(
                    "SELECT COUNT(u.id) FROM Users u WHERE u.email = :email",
                    Long.class
            );
            query.setParameter("email", email);

            Long count = query.uniqueResult();

            return count != null && count > 0;
        }
    }

    /**
     * Retrieves a user by their unique identifier.
     *
     * @param id the user ID
     * @return the {@link Users} entity if found, null otherwise
     */
    public Users findById(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Users.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Updates an existing user's information.
     * Locates the user using their email address before editing variables.
     *
     * @param updatedUser the modified user instance data
     * @return true if updated, false if the user was not found
     */
    public boolean updateUser(Users updatedUser) {
        Session session = null;
        Transaction transaction = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            // Find existing user by ID (using ID is safer than email for detached entities)
            Users existingUser = session.get(Users.class, updatedUser.getId());

            if (existingUser == null) return false;

            existingUser.setName(updatedUser.getName());
            existingUser.setRole(updatedUser.getRole());
            existingUser.setPassword(hashPassword(updatedUser.getPassword()));
            existingUser.setUpdatedAt(LocalDateTime.now());

            session.merge(existingUser);

            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Updates profile details securely without touching the password.
     */
    public boolean updateProfileDetails(Long userId, String name, String businessName, String momoCode, String bankAccountNumber, String profileImageUrl) {
        Session session = null;
        Transaction transaction = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Users existingUser = session.get(Users.class, userId);
            if (existingUser == null) return false;

            existingUser.setName(name);
            existingUser.setBusinessName(businessName);
            existingUser.setMomoCode(momoCode);
            existingUser.setBankAccountNumber(bankAccountNumber);
            if (profileImageUrl != null && !profileImageUrl.isEmpty()) {
                existingUser.setProfileImageUrl(profileImageUrl);
            }
            existingUser.setUpdatedAt(LocalDateTime.now());

            session.merge(existingUser);
            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Retrieves safe payment info for a specific trader.
     */
    public Users getTraderPaymentInfo(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Users user = session.get(Users.class, id);
            if (user != null && "TRADER".equalsIgnoreCase(user.getRole())) {
                Users safeUser = new Users();
                safeUser.setName(user.getName());
                safeUser.setEmail(user.getEmail());
                safeUser.setBusinessName(user.getBusinessName());
                safeUser.setMomoCode(user.getMomoCode());
                safeUser.setBankAccountNumber(user.getBankAccountNumber());
                safeUser.setProfileImageUrl(user.getProfileImageUrl());
                return safeUser;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Changes a user's password securely by verifying the current password first.
     *
     * @param userId          the user ID
     * @param currentPassword the plain text current password
     * @param newPassword     the plain text new password
     * @return true if updated, false if current password is wrong or user not found
     */
    public boolean changePassword(Long userId, String currentPassword, String newPassword) {
        Session session = null;
        Transaction transaction = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Users user = session.get(Users.class, userId);
            if (user == null) return false;

            if (!checkPassword(currentPassword, user.getPassword())) {
                return false;
            }

            user.setPassword(hashPassword(newPassword));
            user.setUpdatedAt(LocalDateTime.now());

            session.merge(user);
            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Deletes a user by their unique ID.
     *
     * @param userId the ID to remove from tracking
     * @return true if successfully erased, false if missing or failed
     */
    public boolean deleteUser(Long userId) {
        Session session = null;
        Transaction transaction = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Users user = session.get(Users.class, userId);
            if (user == null) return false;

            session.delete(user);
            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Retrieves all users with a specific role.
     * Often used by Admins to list all Traders.
     */
    public List<Users> getAllUsersByRole(String role) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Users> query = session.createQuery(
                    "FROM Users WHERE role = :role ORDER BY createdAt DESC",
                    Users.class);
            query.setParameter("role", role);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Counts users in the system by their account status.
     * 
     * @param status the status to count (PENDING, ACTIVE, INACTIVE)
     * @return the total count
     */
    public Long countUsersByStatus(String status) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Long> query = session.createQuery(
                    "SELECT COUNT(u.id) FROM Users u WHERE u.status = :status",
                    Long.class);
            query.setParameter("status", status);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return 0L;
        }
    }

    /**
     * Updates the status of a specific user.
     * 
     * @param userId the user to update
     * @param status the new status
     * @return true if updated successfully
     */
    public boolean updateUserStatus(Long userId, String status) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Users user = session.get(Users.class, userId);
            if (user == null) return false;

            user.setStatus(status);
            user.setUpdatedAt(LocalDateTime.now());
            session.merge(user);

            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) transaction.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) session.close();
        }
    }
}