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
import java.util.List;
import java.util.Properties;

public class UserService {

    // ================= PASSWORD =================

    private String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }

    private boolean checkPassword(String plainPassword, String hashedPassword) {
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }

    // ================= REGISTER =================

    public boolean registerUser(Users user) {
        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            user.setPassword(hashPassword(user.getPassword()));
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());

            session.persist(user);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= LOGIN =================

    public Users loginUser(String email, String password) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Users> query = session.createQuery(
                    "FROM Users WHERE email = :email", Users.class);

            query.setParameter("email", email);

            Users user = query.uniqueResult();

            if (user != null && checkPassword(password, user.getPassword())) {
                return user;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // ================= SAVE OTP =================

    public void saveOtp(Users user, String otpCode, LocalDateTime expiryTime) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Query<?> deleteQuery = session.createQuery(
                    "DELETE FROM Otp WHERE user = :user AND used = false");

            deleteQuery.setParameter("user", user);
            deleteQuery.executeUpdate();

            Otp otp = new Otp(user, otpCode, expiryTime);
            session.persist(otp);

            transaction.commit();

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }

    // ================= GET LATEST OTP =================

    public Otp getLatestOtp(Users user) {

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Otp> query = session.createQuery(
                    "FROM Otp WHERE user = :user ORDER BY expiryTime DESC",
                    Otp.class);

            query.setParameter("user", user);
            query.setMaxResults(1);

            List<Otp> list = query.list();

            if (!list.isEmpty()) {
                return list.get(0);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // ================= MARK OTP USED =================

    public void markOtpAsUsed(Otp otp) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            otp.setUsed(true);
            session.merge(otp);

            transaction.commit();

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
        }
    }

    // ================= SEND OTP EMAIL =================

    public boolean sendOtpEmail(String recipientEmail, String otpCode) {

        // Load from config.properties
        Properties config = new Properties();
        try (InputStream input = getClass().getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (input == null) {
                System.err.println("config.properties not found!");
                return false;
            }
            config.load(input);
        } catch (IOException e) {
            System.err.println("Failed to load config.properties");
            e.printStackTrace();
            return false;
        }

        final String senderEmail    = config.getProperty("SMTP_EMAIL");
        final String senderPassword = config.getProperty("SMTP_PASSWORD");
        final String smtpHost       = config.getProperty("SMTP_HOST", "smtp.gmail.com");
        final String smtpPort       = config.getProperty("SMTP_PORT", "587");

        if (senderEmail == null || senderEmail.isBlank() ||
                senderPassword == null || senderPassword.isBlank()) {
            System.err.println("OTP email not sent: missing SMTP_EMAIL / SMTP_PASSWORD in config.properties");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
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
                                return new PasswordAuthentication(senderEmail, senderPassword);
                            }
                        });

        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(senderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Your Login OTP - StockVerdict");
            message.setText(
                    "Your verification code is: " + otpCode +
                            "\n\nThis code will expire in 5 minutes." +
                            "\n\nIf you did not request this, ignore this email." +
                            "\n\n- StockVerdict Team"
            );

            Transport.send(message);
            System.out.println("OTP email sent successfully to " + recipientEmail);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send OTP email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
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

    // ================= FIND USER BY ID =================
    public Users findById(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Users.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ================= UPDATE USER =================
    public boolean updateUser(Users updatedUser) {

        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            // Find existing user by email
            Query<Users> query = session.createQuery(
                    "FROM Users WHERE email = :email", Users.class);
            query.setParameter("email", updatedUser.getEmail());

            Users existingUser = query.uniqueResult();

            if (existingUser == null) return false;

            existingUser.setName(updatedUser.getName());
            existingUser.setRole(updatedUser.getRole());
            existingUser.setPassword(hashPassword(updatedUser.getPassword()));
            existingUser.setUpdatedAt(LocalDateTime.now());

            session.update(existingUser);

            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= DELETE USER =================
    public boolean deleteUser(Long userId) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();

            Users user = session.get(Users.class, userId);
            if (user == null) return false;

            session.delete(user);
            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }
}