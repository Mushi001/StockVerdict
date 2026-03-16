package org.henriette.stockverdict.controllers;

import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.SaleService;
import org.henriette.stockverdict.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminServlet", value = "/admin/*")
public class AdminServlet extends HttpServlet {

    private UserService userService = new UserService();
    private SaleService saleService = new SaleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || "/dashboard".equals(pathInfo)) {
            handleDashboard(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if ("/approveTrader".equals(pathInfo)) {
            updateStatus(request, response, "ACTIVE");
        } else if ("/deactivateTrader".equals(pathInfo)) {
            updateStatus(request, response, "INACTIVE");
        } else if ("/activateTrader".equals(pathInfo)) {
            updateStatus(request, response, "ACTIVE");
        } else if ("/deleteTrader".equals(pathInfo)) {
            deleteTrader(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Security Check
        HttpSession session = request.getSession(false);
        Users currentUser = (session != null) ? (Users) session.getAttribute("currentUser") : null;
        if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
            return;
        }

        // 1. Stat Cards
        request.setAttribute("totalTraders", userService.getAllUsersByRole("TRADER").size());
        request.setAttribute("pendingTraders", userService.countUsersByStatus("PENDING"));
        request.setAttribute("inactiveTraders", userService.countUsersByStatus("INACTIVE"));
        request.setAttribute("monthlySales", saleService.getSystemWideTotalRevenue());

        // 2. Top Products (List<Object[]>) -> Map for JSP
        List<Object[]> rawTopProducts = saleService.getSystemWideTopSellingProducts(5);
        List<Map<String, Object>> topProducts = new ArrayList<>();
        for (Object[] row : rawTopProducts) {
            Map<String, Object> p = new HashMap<>();
            p.put("name", row[0]);
            p.put("category", "General"); // Category not aggregated in this query, defaulting
            p.put("unitsSold", row[1]);
            topProducts.add(p);
        }
        request.setAttribute("topProducts", topProducts);

        // 3. Top Traders (List<Object[]>) -> Map for JSP
        List<Object[]> rawTopTraders = saleService.getSystemWideTopTraders(5);
        List<Map<String, Object>> topTradersList = new ArrayList<>();
        for (Object[] row : rawTopTraders) {
            Map<String, Object> t = new HashMap<>();
            t.put("fullName", row[0]);
            t.put("totalSales", row[1]);
            topTradersList.add(t);
        }
        request.setAttribute("topTraders", topTradersList);

        // 4. Traders List
        List<Users> users = userService.getAllUsersByRole("TRADER");
        List<Map<String, Object>> traders = new ArrayList<>();
        for (Users u : users) {
             Map<String, Object> tm = new HashMap<>();
             tm.put("id", u.getId());
             tm.put("fullName", u.getName());
             tm.put("email", u.getEmail());
             tm.put("joinDate", u.getCreatedAt() != null ? u.getCreatedAt().toLocalDate().toString() : "N/A");
             String s = u.getStatus();
             if (s == null) s = "PENDING";
             tm.put("status", s.toLowerCase());
             traders.add(tm);
         }
        request.setAttribute("traders", traders);

        request.getRequestDispatcher("/adminDashboard.jsp").forward(request, response);
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response, String status) throws IOException {
        String idParam = request.getParameter("traderId");
        if (idParam != null) {
            Long userId = Long.parseLong(idParam);
            if (userService.updateUserStatus(userId, status)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?success=status_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=update_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=invalid_id");
        }
    }

    private void deleteTrader(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("traderId");
        if (idParam != null) {
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
