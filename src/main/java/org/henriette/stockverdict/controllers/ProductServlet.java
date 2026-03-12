package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Products;
import org.henriette.stockverdict.models.Supplier;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.ProductService;
import org.henriette.stockverdict.services.SupplierService;

import java.io.IOException;

/**
 * Servlet handling HTTP requests for Product management.
 * Provides endpoints for listing, searching, discovering low stock, adding, editing, and deleting {@link Products}.
 * Ensures all actions are performed by an authenticated user.
 */
@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private final ProductService productService = new ProductService();
    private final SupplierService supplierService = new SupplierService();

    /**
     * Handles HTTP GET requests for product-related views.
     * Actions supported:
     * <ul>
     *     <li><code>list</code>: Displays all products for the authenticated user.</li>
     *     <li><code>lowStock</code>: Filters products to show only those at or below their reorder level.</li>
     *     <li><code>search</code>: Filters products based on a keyword match.</li>
     *     <li><code>edit</code>: Prepares the dashboard to edit a specific product.</li>
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
            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }

    /**
     * Handles HTTP POST requests for product modification operations.
     * Actions supported:
     * <ul>
     *     <li><code>addProduct</code>: Creates a new product, validating barcode uniqueness and pricing logic.</li>
     *     <li><code>updateProduct</code>: Updates an existing product's details.</li>
     *     <li><code>deleteProduct</code>: Permanently removes a product from the database.</li>
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

            case "addProduct": {
                String name         = req.getParameter("name");
                String description  = req.getParameter("description");
                String barcode      = req.getParameter("barcode");
                double purchasePrice = Double.parseDouble(req.getParameter("purchasePrice"));
                double sellingPrice  = Double.parseDouble(req.getParameter("sellingPrice"));
                int quantity         = Integer.parseInt(req.getParameter("quantityInStock"));
                int reorderLevel     = Integer.parseInt(req.getParameter("reorderLevel"));
                Long supplierId      = null;
                try {
                    String supStr = req.getParameter("supplierId");
                    if (supStr != null && !supStr.isBlank()) {
                        supplierId = Long.parseLong(supStr);
                    }
                } catch (Exception e) {}
                
                Supplier supplier = null;
                if (supplierId != null) {
                    supplier = supplierService.getSupplierById(supplierId);
                }

                // Check duplicate barcode
                if (barcode != null && !barcode.isBlank() && productService.isBarcodeExists(barcode, null)) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&error=barcodeExists");
                    return;
                }

                // Check price logic
                if (sellingPrice < purchasePrice) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&error=invalidPrice");
                    return;
                }

                Products product = new Products(
                        name, description, barcode,
                        purchasePrice, sellingPrice,
                        quantity, reorderLevel, loggedInUser, supplier
                );

                boolean success = productService.addProduct(product);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&success=" +
                        (success ? "productAdded" : "addFailed"));
                break;
            }

            case "updateProduct": {
                Long id             = Long.parseLong(req.getParameter("id"));
                String name         = req.getParameter("name");
                String description  = req.getParameter("description");
                String barcode      = req.getParameter("barcode");
                double purchasePrice = Double.parseDouble(req.getParameter("purchasePrice"));
                double sellingPrice  = Double.parseDouble(req.getParameter("sellingPrice"));
                int quantity         = Integer.parseInt(req.getParameter("quantityInStock"));
                int reorderLevel     = Integer.parseInt(req.getParameter("reorderLevel"));
                Long editSupplierId  = null;
                try {
                    String supStr = req.getParameter("supplierId");
                    if (supStr != null && !supStr.isBlank()) {
                        editSupplierId = Long.parseLong(supStr);
                    }
                } catch (Exception e) {}
                
                Supplier supplier = null;
                if (editSupplierId != null) {
                    supplier = supplierService.getSupplierById(editSupplierId);
                }

                // Check duplicate barcode excluding this product
                if (barcode != null && !barcode.isBlank() && productService.isBarcodeExists(barcode, id)) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&error=barcodeExists");
                    return;
                }

                // Check price logic
                if (sellingPrice < purchasePrice) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&error=invalidPrice");
                    return;
                }

                Products updated = new Products();
                updated.setId(id);
                updated.setName(name);
                updated.setDescription(description);
                updated.setBarcode(barcode);
                updated.setPurchasePrice(purchasePrice);
                updated.setSellingPrice(sellingPrice);
                updated.setQuantityInStock(quantity);
                updated.setReorderLevel(reorderLevel);
                updated.setSupplier(supplier);

                boolean success = productService.updateProduct(updated);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&success=" +
                        (success ? "productUpdated" : "updateFailed"));
                break;
            }

            case "deleteProduct": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = productService.deleteProduct(id);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=stock&success=" +
                        (success ? "productDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}