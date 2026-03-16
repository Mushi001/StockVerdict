package org.henriette.stockverdict.controllers;

import org.henriette.stockverdict.models.Otp;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.UUID;
import java.nio.file.Paths;

/**
 * Servlet handling HTTP requests for User authentication and management.
 * Manages registration, login, OTP verification, profile updates, logout, and deletion.
 * Validates Google reCAPTCHA during registration.
 */
@WebServlet(name = "UserServlet", value = "/user")
@jakarta.servlet.annotation.MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 10,      // 10 MB
        maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
public class UserServlet extends HttpServlet {

    private UserService userService = new UserService();
    private String recaptchaSecretKey;

    /**
     * Initializes the servlet.
     * Loads the configuration properties to retrieve the Google reCAPTCHA secret key.
     * Tries <code>config.local.properties</code> first, then falls back to <code>config.properties</code>.
     *
     * @throws ServletException if configuration files cannot be loaded
     */
    @Override
    public void init() throws ServletException {
        Properties config = new Properties();
        String localConfig = "config.local.properties";
        String defaultConfig = "config.properties";

        try {
            // Try local first
            InputStream input = getClass().getClassLoader().getResourceAsStream(localConfig);
            if (input == null) {
                // Fallback to default
                input = getClass().getClassLoader().getResourceAsStream(defaultConfig);
            }

            if (input == null) {
                throw new ServletException("Configuration file not found (tried " + localConfig + " and " + defaultConfig + ")");
            }

            config.load(input);
            recaptchaSecretKey = config.getProperty("RECAPTCHA_SECRET_KEY");
            input.close();
        } catch (IOException e) {
            throw new ServletException("Failed to load configuration", e);
        }
    }

    /**
     * Handles HTTP POST requests, primarily for form submissions involving sensitive data.
     * Actions supported: <code>register</code>, <code>login</code>, <code>verifyOtp</code>, <code>update</code>.
     *
     * @param request  the {@link HttpServletRequest} containing the form data and action parameter
     * @param response the {@link HttpServletResponse} used for forwarding or redirection
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            handleRegister(request, response);
        } else if ("login".equals(action)) {
            handleLogin(request, response);
        } else if ("verifyOtp".equals(action)) {
            handleVerifyOtp(request, response);
        } else if ("update".equals(action)) {
            handleUpdate(request, response);
        } else if ("changePassword".equals(action)) {
            handleChangePassword(request, response);
        } else if ("updateProfile".equals(action)) {
            handleUpdateProfile(request, response);
        }
    }

    /**
     * Handles HTTP GET requests.
     * Actions supported: <code>logout</code>, <code>delete</code>.
     *
     * @param request  the {@link HttpServletRequest} containing the action parameter
     * @param response the {@link HttpServletResponse} used for redirection
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            handleLogout(request, response);
        } else if ("delete".equals(action)) {
            handleDelete(request, response);
        }
    }

    /**
     * Processes a user registration request.
     * Validates that the email doesn't already exist and that the reCAPTCHA challenge was successful.
     * Upon success, redirects the user to the login page.
     *
     * @param request  the HTTP request containing registration form data
     * @param response the HTTP response
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name     = request.getParameter("name");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        // String role = request.getParameter("role"); // Disable role selection from request

        if (userService.isEmailExists(email)) {
            request.setAttribute("error", "Email already exists");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        String gRecaptchaResponse = request.getParameter("g-recaptcha-response");
        if (gRecaptchaResponse == null || gRecaptchaResponse.isEmpty() || !verifyRecaptcha(gRecaptchaResponse)) {
            request.setAttribute("error", "Captcha verification failed. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        Users user = new Users(name, email, password, "TRADER"); // Enforce TRADER role
        user.setStatus("PENDING"); // Enforce PENDING status
        if (userService.registerUser(user)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?success=registered");
        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    /**
     * Verifies a Google reCAPTCHA v2 token with the Google API.
     *
     * @param gRecaptchaResponse the token submitted by the frontend client
     * @return true if Google confirms the verification was successful, false otherwise
     */
    private boolean verifyRecaptcha(String gRecaptchaResponse) {
        try {
            String url    = "https://www.google.com/recaptcha/api/siteverify";
            String params = "secret=" + recaptchaSecretKey + "&response=" + gRecaptchaResponse;

            java.net.URL obj = new java.net.URL(url);
            java.net.HttpURLConnection con = (java.net.HttpURLConnection) obj.openConnection();
            con.setRequestMethod("POST");
            con.setDoOutput(true);
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            con.setRequestProperty("Content-Length", String.valueOf(params.length()));
            con.setConnectTimeout(5000);
            con.setReadTimeout(5000);

            try (java.io.OutputStream os = con.getOutputStream()) {
                os.write(params.getBytes("UTF-8"));
            }

            java.io.BufferedReader in = new java.io.BufferedReader(
                    new java.io.InputStreamReader(con.getInputStream())
            );
            String inputLine;
            StringBuilder responseBuilder = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                responseBuilder.append(inputLine);
            }
            in.close();

            System.out.println("Google reCAPTCHA Response: " + responseBuilder);

            com.google.gson.JsonObject json = new com.google.gson.JsonParser()
                    .parse(responseBuilder.toString()).getAsJsonObject();
            return json.get("success").getAsBoolean();

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Processes a user login request.
     * Validates credentials against the database. If successful, generates a 6-digit OTP,
     * stores it in the database with an expiration time, sends it via email, and redirects
     * the user to the OTP verification page.
     *
     * @param request  the HTTP request containing login credentials
     * @param response the HTTP response
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("[DEBUG] Login attempt for email: " + email);
        Users user = userService.loginUser(email, password);

        if (user != null) {
            String status = user.getStatus();
            String role = user.getRole();
            
            // Treat null status as ACTIVE for legacy accounts
            if (status == null) {
                status = "ACTIVE";
            }
            
            System.out.println("[DEBUG] Login: " + email + " | Role: " + role + " | Status: " + status);

            if ("PENDING".equalsIgnoreCase(status)) {
                System.out.println("[DEBUG] Access Denied: User " + email + " is PENDING");
                request.setAttribute("error", "Your account is awaiting administrative approval.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            if ("INACTIVE".equalsIgnoreCase(status)) {
                System.out.println("[DEBUG] Access Denied: User " + email + " is INACTIVE");
                request.setAttribute("error", "Your account has been deactivated. Please contact support.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            String otpCode = String.valueOf((int)(Math.random() * 900000) + 100000);
            java.time.LocalDateTime expiry = java.time.LocalDateTime.now().plusMinutes(5);

            if (userService.saveOtp(user, otpCode, expiry)) {
                boolean emailSent = userService.sendOtpEmail(user.getEmail(), otpCode);

                if (!emailSent) {
                    request.setAttribute("error", "Unable to send OTP email right now. Please configure SMTP settings.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession();
                session.setAttribute("pendingUserId", user.getId());
                System.out.println("[DEBUG] Redirecing to verifyOtp.jsp for user ID: " + user.getId() + " | Session ID: " + session.getId());
                response.sendRedirect(request.getContextPath() + "/verifyOtp.jsp");
            } else {
                System.out.println("[ERROR] Failed to save OTP for user: " + email);
                request.setAttribute("error", "System error: Failed to generate and save verification code.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } else {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    /**
     * Verifies the OTP submitted by the user during the two-factor authentication process.
     * Confirms the OTP matches the database record and has not expired or been previously used.
     * Upon success, creates the authenticated user session (<code>currentUser</code>) and redirects
     * to the appropriate dashboard based on their role.
     *
     * @param request  the HTTP request containing the OTP code
     * @param response the HTTP response
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
     */
    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String enteredOtp = request.getParameter("otp");
        if (enteredOtp != null) enteredOtp = enteredOtp.trim();
        System.out.println("[DEBUG] Entered OTP (trimmed): '" + enteredOtp + "'");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUserId") == null) {
            System.out.println("[OTP] Session invalid - redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Long userId = (Long) session.getAttribute("pendingUserId");
        System.out.println("[OTP] UserId: " + userId);

        Users user = userService.findById(userId);
        if (user == null) {
            System.out.println("[OTP] User not found");
            request.setAttribute("error", "User not found. Please login again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        Otp otp = userService.getLatestOtp(user);

        if (otp == null || otp.isUsed()) {
            System.out.println("[OTP] OTP is null or already used");
            request.setAttribute("error", "Invalid OTP.");
            request.getRequestDispatcher("/verifyOtp.jsp").forward(request, response);
            return;
        }

        if (java.time.LocalDateTime.now().isAfter(otp.getExpiryTime())) {
            System.out.println("[OTP] OTP expired");
            request.setAttribute("error", "OTP expired. Please login again.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!otp.getOtpCode().equals(enteredOtp)) {
            System.out.println("[DEBUG] OTP MISMATCH - Expected: '" + otp.getOtpCode() + "', Got: '" + enteredOtp + "'");
            request.setAttribute("error", "Incorrect OTP.");
            request.getRequestDispatcher("/verifyOtp.jsp").forward(request, response);
            return;
        }

        // ===== OTP VERIFIED SUCCESSFULLY =====
        System.out.println("[OTP] ✓ SUCCESS - User " + userId + " verified");

        userService.markOtpAsUsed(otp);

        session.removeAttribute("pendingUserId");

        // KEY FIX: must be "currentUser" to match ${sessionScope.currentUser} used in all JSPs
        session.setAttribute("currentUser", user);
        session.setAttribute("userId", user.getId());

        String dashboardPage;
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            dashboardPage = "/admin/dashboard"; // Redirect to AdminServlet
        } else {
            dashboardPage = "/dashboard";
        }

        System.out.println("[OTP] Redirecting to: " + request.getContextPath() + dashboardPage);
        response.sendRedirect(request.getContextPath() + dashboardPage);
    }

    /**
     * Processes a profile update request from the authenticated user.
     * Modifies the user's name, password, or role.
     *
     * @param request  the HTTP request containing the updated profile data
     * @param response the HTTP response
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name     = request.getParameter("name");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        String role     = request.getParameter("role");

        Users user = new Users(name, email, password, role);
        user.setUpdatedAt(java.time.LocalDateTime.now());

        // FIX: Must set ID from current session user
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            Users currentUser = (Users) session.getAttribute("currentUser");
            user.setId(currentUser.getId());
        }

        if (user.getId() != null && userService.updateUser(user)) {
            request.setAttribute("success", "User updated successfully");
        } else {
            request.setAttribute("error", "Update failed");
        }
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    /**
     * Processes a profile and payment details update request, including profile picture upload.
     */
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String businessName = request.getParameter("businessName");
        String momoCode = request.getParameter("momoCode");
        String bankAccountNumber = request.getParameter("bankAccountNumber");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Users currentUser = (Users) session.getAttribute("currentUser");
        String profileImageUrl = null;

        // Process file upload
        try {
            Part filePart = request.getPart("profileImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String ext = fileName.substring(fileName.lastIndexOf("."));
                String uniqueName = UUID.randomUUID().toString() + ext;
                
                String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "profiles";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                
                filePart.write(uploadPath + File.separator + uniqueName);
                profileImageUrl = "assets/profiles/" + uniqueName;
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Not fatal if file upload fails, continue with text fields
        }

        if (userService.updateProfileDetails(currentUser.getId(), name, businessName, momoCode, bankAccountNumber, profileImageUrl)) {
            // Update session object
            currentUser.setName(name);
            currentUser.setBusinessName(businessName);
            currentUser.setMomoCode(momoCode);
            currentUser.setBankAccountNumber(bankAccountNumber);
            if (profileImageUrl != null) currentUser.setProfileImageUrl(profileImageUrl);
            session.setAttribute("currentUser", currentUser);
            
            response.sendRedirect(request.getContextPath() + "/traderDashboard.jsp?section=settings&success=profile_updated");
        } else {
            request.setAttribute("error", "Failed to update profile details");
            request.getRequestDispatcher("/traderDashboard.jsp?section=settings").forward(request, response);
        }
    }

    /**
     * Processes a password change request from the authenticated user.
     */
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Users currentUser = (Users) session.getAttribute("currentUser");

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("/traderDashboard.jsp?section=settings").forward(request, response);
            return;
        }

        if (userService.changePassword(currentUser.getId(), currentPassword, newPassword)) {
            response.sendRedirect(request.getContextPath() + "/traderDashboard.jsp?section=settings&success=password_changed");
        } else {
            request.setAttribute("error", "Invalid current password");
            request.getRequestDispatcher("/traderDashboard.jsp?section=settings").forward(request, response);
        }
    }

    /**
     * Logs out the current user by invalidating their HTTP session.
     * Redirects them back to the login page.
     *
     * @param request  the HTTP request
     * @param response the HTTP response
     * @throws IOException if an I/O error occurs during redirection
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp?success=loggedout");
    }

    /**
     * Deletes a user account from the system.
     * This action is typically restricted to Administrators from the admin dashboard.
     *
     * @param request  the HTTP request containing the ID of the user to delete
     * @param response the HTTP response
     * @throws IOException if an I/O error occurs during redirection
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            Long userId = Long.parseLong(idParam);
            if (userService.deleteUser(userId)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=delete_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=invalid_id");
        }
    }
}
