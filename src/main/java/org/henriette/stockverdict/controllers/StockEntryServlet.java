package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Products;
import org.henriette.stockverdict.models.StockEntry;
import org.henriette.stockverdict.models.Supplier;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.ProductService;
import org.henriette.stockverdict.services.StockEntryService;
import org.henriette.stockverdict.services.SupplierService;

import java.io.IOException;

/**
 * Servlet handling HTTP requests for Stock Entries.
 * Allows authenticated users to view stock history, filter by product or supplier,
 * and add or delete stock entries.
 */
@WebServlet("/stockEntry")
public class StockEntryServlet extends HttpServlet {

    private final StockEntryService stockEntryService = new StockEntryService();
    private final ProductService    productService    = new ProductService();
    private final SupplierService   supplierService   = new SupplierService();

    /**
     * Handles HTTP GET requests for viewing stock entries.
     * Actions supported:
     * <ul>
     *     <li><code>list</code>: Displays all stock entries managed by the current user.</li>
     *     <li><code>byProduct</code>: Filters stock entries by a specific product.</li>
     *     <li><code>bySupplier</code>: Filters stock entries by a specific supplier.</li>
     * </ul>
     *
     * @param req  the {@link HttpServletRequest} containing the query parameters
     * @param resp the {@link HttpServletResponse} used to forward to the dashboard
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
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
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                break;

            case "byProduct":
                Long productId = Long.parseLong(req.getParameter("productId"));
                Products product = productService.getProductById(productId);
                if (product != null) {
                    req.setAttribute("stockEntries", stockEntryService.getStockEntriesByProduct(product));
                    req.setAttribute("filterProduct", product);
                }
                req.getRequestDispatcher("/dashboard").forward(req, resp);
                break;

            case "bySupplier":
                Long supplierId = Long.parseLong(req.getParameter("supplierId"));
                Supplier supplier = supplierService.getSupplierById(supplierId);
                if (supplier != null) {
                    req.setAttribute("stockEntries", stockEntryService.getStockEntriesBySupplier(supplier));
                    req.setAttribute("filterSupplier", supplier);
                }
                req.getRequestDispatcher("/dashboard").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    /**
     * Handles HTTP POST requests for modifying stock entries.
     * Actions supported:
     * <ul>
     *     <li><code>addStockEntry</code>: Creates a new stock entry and increments the product's quantity.</li>
     *     <li><code>deleteStockEntry</code>: Removes a stock entry and reverses the product's quantity increment,
     *         ensuring the quantity doesn't fall below zero.</li>
     * </ul>
     *
     * @param req  the {@link HttpServletRequest} containing the form data
     * @param resp the {@link HttpServletResponse} used to redirect upon completion
     * @throws ServletException if the request could not be handled
     * @throws IOException      if an I/O error occurs
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
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        switch (action) {

            case "addStockEntry": {
                Long productId    = Long.parseLong(req.getParameter("productId"));
                Long supplierId   = Long.parseLong(req.getParameter("supplierId"));
                int quantityAdded = Integer.parseInt(req.getParameter("quantityAdded"));
                double purchasePrice = Double.parseDouble(req.getParameter("purchasePrice"));

                Products product  = productService.getProductById(productId);
                Supplier supplier = supplierService.getSupplierById(supplierId);

                if (product == null || supplier == null) {
                    resp.sendRedirect(req.getContextPath() + "/dashboard?error=invalidProductOrSupplier");
                    return;
                }

                if (quantityAdded <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/dashboard?error=invalidQuantity");
                    return;
                }

                StockEntry entry = new StockEntry(quantityAdded, purchasePrice, product, supplier, loggedInUser);

                boolean success = stockEntryService.addStockEntry(entry);
                resp.sendRedirect(req.getContextPath() + "/dashboard?success=" +
                        (success ? "stockAdded" : "addFailed"));
                break;
            }

            case "deleteStockEntry": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = stockEntryService.deleteStockEntry(id);
                resp.sendRedirect(req.getContextPath() + "/dashboard?success=" +
                        (success ? "stockDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
}