package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Customer;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.CustomerService;

import java.io.IOException;

@WebServlet("/customer")
public class CustomerServlet extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    // ================= DO GET =================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        Users loggedInUser = (Users) req.getSession().getAttribute("currentUser");

        if (loggedInUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (action == null) action = "list";

        switch (action) {

            case "list":
                req.setAttribute("customers", customerService.getCustomersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "search":
                String keyword = req.getParameter("keyword");
                if (keyword == null) keyword = "";
                req.setAttribute("customers", customerService.searchCustomers(loggedInUser, keyword));
                req.setAttribute("keyword", keyword);
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "edit":
                Long editId = Long.parseLong(req.getParameter("id"));
                Customer customerToEdit = customerService.getCustomerById(editId);
                req.setAttribute("customerToEdit", customerToEdit);
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }

    // ================= DO POST =================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        Users loggedInUser = (Users) req.getSession().getAttribute("currentUser");

        if (loggedInUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
            return;
        }

        switch (action) {

            case "addCustomer": {
                String name    = req.getParameter("name");
                String phone   = req.getParameter("phone");
                String email   = req.getParameter("email");
                String address = req.getParameter("address");

                // Check duplicate email
                if (email != null && !email.isBlank() && customerService.isEmailExists(email, null)) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=customerEmailExists");
                    return;
                }

                Customer customer = new Customer(name, phone, email, address, loggedInUser);

                boolean success = customerService.addCustomer(customer);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "customerAdded" : "addFailed"));
                break;
            }

            case "updateCustomer": {
                Long id        = Long.parseLong(req.getParameter("id"));
                String name    = req.getParameter("name");
                String phone   = req.getParameter("phone");
                String email   = req.getParameter("email");
                String address = req.getParameter("address");

                // Check duplicate email excluding this customer
                if (email != null && !email.isBlank() && customerService.isEmailExists(email, id)) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=customerEmailExists");
                    return;
                }

                Customer updated = new Customer();
                updated.setId(id);
                updated.setName(name);
                updated.setPhone(phone);
                updated.setEmail(email);
                updated.setAddress(address);

                boolean success = customerService.updateCustomer(updated);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "customerUpdated" : "updateFailed"));
                break;
            }

            case "deleteCustomer": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = customerService.deleteCustomer(id);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "customerDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}