package org.henriette.stockverdict.controllers;

import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Servlet handling public QR Code payment links.
 */
@WebServlet(name = "PaymentServlet", value = "/pay")
public class PaymentServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String traderIdStr = request.getParameter("traderId");

        if (traderIdStr != null && !traderIdStr.isEmpty()) {
            try {
                Long traderId = Long.parseLong(traderIdStr);
                Users trader = userService.getTraderPaymentInfo(traderId);

                if (trader != null) {
                    request.setAttribute("trader", trader);
                    request.getRequestDispatcher("/paymentInfo.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                // Invalid ID format
            }
        }

        // If something goes wrong, redirect to home
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}
