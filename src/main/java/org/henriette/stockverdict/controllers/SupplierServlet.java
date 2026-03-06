package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Supplier;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.SupplierService;

import java.io.IOException;

@WebServlet("/supplier")
public class SupplierServlet extends HttpServlet {

    private final SupplierService supplierService = new SupplierService();

    // ================= DO GET =================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        Users loggedInUser = (Users) req.getSession().getAttribute("user");

        if (loggedInUser == null) {
            resp.sendRedirect("/login.jsp");
            return;
        }

        if (action == null) action = "list";

        switch (action) {

            case "list":
                req.setAttribute("suppliers", supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/suppliers.jsp").forward(req, resp);
                break;

            case "search":
                String keyword = req.getParameter("keyword");
                if (keyword == null) keyword = "";
                req.setAttribute("suppliers", supplierService.searchSuppliers(loggedInUser, keyword));
                req.setAttribute("keyword", keyword);
                req.getRequestDispatcher("/suppliers.jsp").forward(req, resp);
                break;

            case "edit":
                Long editId = Long.parseLong(req.getParameter("id"));
                Supplier supplierToEdit = supplierService.getSupplierById(editId);
                req.setAttribute("supplierToEdit", supplierToEdit);
                req.setAttribute("suppliers", supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/suppliers.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect("/suppliers.jsp");
        }
    }

    // ================= DO POST =================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        Users loggedInUser = (Users) req.getSession().getAttribute("user");

        if (loggedInUser == null) {
            resp.sendRedirect("/login.jsp");
            return;
        }

        if (action == null) {
            resp.sendRedirect("/suppliers.jsp");
            return;
        }

        switch (action) {

            case "addSupplier": {
                String name    = req.getParameter("name");
                String phone   = req.getParameter("phone");
                String email   = req.getParameter("email");
                String address = req.getParameter("address");

                System.out.println("[Supplier] Adding supplier: " + name);

                // Check duplicate email
                if (email != null && !email.isBlank() && supplierService.isEmailExists(email, null)) {
                    System.out.println("[Supplier] Email already exists: " + email);
                    resp.sendRedirect("/suppliers.jsp?error=supplierEmailExists");
                    return;
                }

                Supplier supplier = new Supplier(name, phone, email, address, loggedInUser);

                boolean success = supplierService.addSupplier(supplier);
                System.out.println("[Supplier] Add success: " + success);

                // Redirect with success message
                resp.sendRedirect("/suppliers.jsp?success=" + (success ? "supplierAdded" : "addFailed"));
                break;
            }

            case "updateSupplier": {
                Long id        = Long.parseLong(req.getParameter("id"));
                String name    = req.getParameter("name");
                String phone   = req.getParameter("phone");
                String email   = req.getParameter("email");
                String address = req.getParameter("address");

                System.out.println("[Supplier] Updating supplier: " + id);

                // Check duplicate email excluding this supplier
                if (email != null && !email.isBlank() && supplierService.isEmailExists(email, id)) {
                    System.out.println("[Supplier] Email already exists: " + email);
                    resp.sendRedirect("/suppliers.jsp?error=supplierEmailExists");
                    return;
                }

                Supplier updated = new Supplier();
                updated.setId(id);
                updated.setName(name);
                updated.setPhone(phone);
                updated.setEmail(email);
                updated.setAddress(address);

                boolean success = supplierService.updateSupplier(updated);
                System.out.println("[Supplier] Update success: " + success);

                // Redirect with success message
                resp.sendRedirect("/suppliers.jsp?success=" + (success ? "supplierUpdated" : "updateFailed"));
                break;
            }

            case "deleteSupplier": {
                Long id = Long.parseLong(req.getParameter("id"));

                System.out.println("[Supplier] Deleting supplier: " + id);

                boolean success = supplierService.deleteSupplier(id);
                System.out.println("[Supplier] Delete success: " + success);

                // Redirect with success message
                resp.sendRedirect("/suppliers.jsp?success=" + (success ? "supplierDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect("/suppliers.jsp");
        }
    }
}