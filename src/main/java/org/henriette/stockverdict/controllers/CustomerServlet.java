package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Customer;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.CustomerService;

import java.io.IOException;

/**
 * Servlet handling HTTP requests for Customer management.
 * Responsible for listing, searching, adding, updating, and deleting {@link Customer} entities.
 * Requires an authenticated user session to access its endpoints.
 */
@WebServlet("/customer")
public class CustomerServlet extends HttpServlet {

    private final CustomerService customerService = new CustomerService();

    /**
     * Handles HTTP GET requests for customer-related views.
     * Actions supported:
     * <ul>
     *     <li><code>list</code>: Displays all customers managed by the current user.</li>
     *     <li><code>search</code>: Filters customers based on a keyword.</li>
     *     <li><code>edit</code>: Prepares the dashboard to edit a specific customer.</li>
     * </ul>
     *
     * @param req  an {@link HttpServletRequest} object that contains the request the client has made of the servlet
     * @param resp an {@link HttpServletResponse} object that contains the response the servlet sends to the client
     * @throws ServletException if the request for the GET could not be handled
     * @throws IOException      if an input or output error is detected when the servlet handles the GET request
     */
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
            case "search":
            case "edit":
            default:
                resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers");
        }
    }

    /**
     * Handles HTTP POST requests for customer-related operations.
     * Actions supported:
     * <ul>
     *     <li><code>addCustomer</code>: Creates a new customer record.</li>
     *     <li><code>updateCustomer</code>: Modifies an existing customer record.</li>
     *     <li><code>deleteCustomer</code>: Removes a customer record.</li>
     * </ul>
     *
     * @param req  an {@link HttpServletRequest} object that contains the request the client has made of the servlet
     * @param resp an {@link HttpServletResponse} object that contains the response the servlet sends to the client
     * @throws ServletException if the request for the POST could not be handled
     * @throws IOException      if an input or output error is detected when the servlet handles the request
     */
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
            resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers");
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
                    resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers&error=customerEmailExists");
                    return;
                }

                Customer customer = new Customer(name, phone, email, address, loggedInUser);

                boolean success = customerService.addCustomer(customer);
                resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers&success=" +
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
                    resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers&error=customerEmailExists");
                    return;
                }

                Customer updated = new Customer();
                updated.setId(id);
                updated.setName(name);
                updated.setPhone(phone);
                updated.setEmail(email);
                updated.setAddress(address);

                boolean success = customerService.updateCustomer(updated);
                resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers&success=" +
                        (success ? "customerUpdated" : "updateFailed"));
                break;
            }

            case "deleteCustomer": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = customerService.deleteCustomer(id);
                resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers&success=" +
                        (success ? "customerDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/dashboard?section=customers");
        }
    }
}