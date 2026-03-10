package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Supplier;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.SupplierService;

import java.io.IOException;

/**
 * Servlet handling HTTP requests for Supplier management.
 * Responsible for listing, searching, adding, updating, and deleting {@link Supplier} entities.
 * Requires an authenticated user session.
 */
@WebServlet("/supplier")
public class SupplierServlet extends HttpServlet {

    private final SupplierService supplierService = new SupplierService();

    /**
     * Handles HTTP GET requests for supplier-related views.
     * Actions supported:
     * <ul>
     *     <li><code>list</code>: Displays all suppliers for the authenticated user.</li>
     *     <li><code>search</code>: Filters suppliers based on a keyword match.</li>
     *     <li><code>edit</code>: Prepares the dashboard to edit a specific supplier.</li>
     * </ul>
     *
     * @param req  the {@link HttpServletRequest} object containing the client's request
     * @param resp the {@link HttpServletResponse} object containing the servlet's response
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an input/output error occurs
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
                req.setAttribute("supplierList", supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "search":
                String keyword = req.getParameter("keyword");
                if (keyword == null) keyword = "";
                req.setAttribute("supplierList", supplierService.searchSuppliers(loggedInUser, keyword));
                req.setAttribute("keyword", keyword);
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "edit":
                Long editId = Long.parseLong(req.getParameter("id"));
                Supplier supplierToEdit = supplierService.getSupplierById(editId);
                req.setAttribute("supplierToEdit", supplierToEdit);
                req.setAttribute("supplierList", supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }

    /**
     * Handles HTTP POST requests for supplier modification operations.
     * Actions supported:
     * <ul>
     *     <li><code>addSupplier</code>: Creates a new supplier, validating email uniqueness.</li>
     *     <li><code>updateSupplier</code>: Updates an existing supplier's details.</li>
     *     <li><code>deleteSupplier</code>: Permanently removes a supplier from the database.</li>
     * </ul>
     *
     * @param req  the {@link HttpServletRequest} object containing the client's form data
     * @param resp the {@link HttpServletResponse} object to send redirects back to the client
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an input/output error occurs
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
            resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
            return;
        }

        switch (action) {

            case "addSupplier": {
                String name          = req.getParameter("name");
                String phone         = req.getParameter("phone");
                String email         = req.getParameter("email");
                String address       = req.getParameter("address");
                String contactPerson = req.getParameter("contactPerson");
                String notes         = req.getParameter("notes");
                double balanceOwed   = 0.0;
                try {
                    String balStr = req.getParameter("balanceOwed");
                    if (balStr != null && !balStr.isBlank()) {
                        balanceOwed = Double.parseDouble(balStr);
                    }
                } catch (Exception e) {}

                System.out.println("[Supplier] Adding supplier: " + name);

                // Check duplicate email
                if (email != null && !email.isBlank() && supplierService.isEmailExists(email, loggedInUser.getId(), null)) {
                    System.out.println("[Supplier] Email already exists for this user: " + email);
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=supplierEmailExists");
                    return;
                }

                Supplier supplier = new Supplier(name, phone, email, address, contactPerson, balanceOwed, notes, loggedInUser);

                boolean success = supplierService.addSupplier(supplier);
                System.out.println("[Supplier] Add success: " + success);

                // Redirect with success message
                resp.sendRedirect(req.getContextPath() + "/supplier?action=list&success=" + (success ? "supplierAdded" : "addFailed"));
                break;
            }

            case "updateSupplier": {
                Long id              = Long.parseLong(req.getParameter("supplierId"));
                String name          = req.getParameter("name");
                String phone         = req.getParameter("phone");
                String email         = req.getParameter("email");
                String address       = req.getParameter("address");
                String contactPerson = req.getParameter("contactPerson");
                String notes         = req.getParameter("notes");
                double balanceOwed   = 0.0;
                try {
                    String balStr = req.getParameter("balanceOwed");
                    if (balStr != null && !balStr.isBlank()) {
                        balanceOwed = Double.parseDouble(balStr);
                    }
                } catch (Exception e) {}

                System.out.println("[Supplier] Updating supplier: " + id);

                // Check duplicate email excluding this supplier
                if (email != null && !email.isBlank() && supplierService.isEmailExists(email, loggedInUser.getId(), id)) {
                    System.out.println("[Supplier] Email already exists for this user: " + email);
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=supplierEmailExists");
                    return;
                }

                Supplier updated = new Supplier();
                updated.setId(id);
                updated.setName(name);
                updated.setPhone(phone);
                updated.setEmail(email);
                updated.setAddress(address);
                updated.setContactPerson(contactPerson);
                updated.setBalanceOwed(balanceOwed);
                updated.setNotes(notes);

                boolean success = supplierService.updateSupplier(updated);
                System.out.println("[Supplier] Update success: " + success);

                // Redirect with success message
                resp.sendRedirect(req.getContextPath() + "/supplier?action=list&success=" + (success ? "supplierUpdated" : "updateFailed"));
                break;
            }

            case "deleteSupplier": {
                Long id = Long.parseLong(req.getParameter("supplierId"));

                System.out.println("[Supplier] Deleting supplier: " + id);

                boolean success = supplierService.deleteSupplier(id);
                System.out.println("[Supplier] Delete success: " + success);

                // Redirect with success message
                resp.sendRedirect(req.getContextPath() + "/supplier?action=list&success=" + (success ? "supplierDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}