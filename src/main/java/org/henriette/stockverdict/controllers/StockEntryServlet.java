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

@WebServlet("/stockEntry")
public class StockEntryServlet extends HttpServlet {

    private final StockEntryService stockEntryService = new StockEntryService();
    private final ProductService    productService    = new ProductService();
    private final SupplierService   supplierService   = new SupplierService();

    // ================= DO GET =================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        Users loggedInUser = (Users) req.getSession().getAttribute("user");

        if (loggedInUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (action == null) action = "list";

        switch (action) {

            case "list":
                req.setAttribute("stockEntries", stockEntryService.getStockEntriesByUser(loggedInUser));
                req.setAttribute("products",     productService.getProductsByUser(loggedInUser));
                req.setAttribute("suppliers",    supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "byProduct":
                Long productId = Long.parseLong(req.getParameter("productId"));
                Products product = productService.getProductById(productId);
                if (product != null) {
                    req.setAttribute("stockEntries", stockEntryService.getStockEntriesByProduct(product));
                    req.setAttribute("filterProduct", product);
                }
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "bySupplier":
                Long supplierId = Long.parseLong(req.getParameter("supplierId"));
                Supplier supplier = supplierService.getSupplierById(supplierId);
                if (supplier != null) {
                    req.setAttribute("stockEntries", stockEntryService.getStockEntriesBySupplier(supplier));
                    req.setAttribute("filterSupplier", supplier);
                }
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
        Users loggedInUser = (Users) req.getSession().getAttribute("user");

        if (loggedInUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
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
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=invalidProductOrSupplier");
                    return;
                }

                if (quantityAdded <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=invalidQuantity");
                    return;
                }

                StockEntry entry = new StockEntry(quantityAdded, purchasePrice, product, supplier, loggedInUser);

                boolean success = stockEntryService.addStockEntry(entry);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "stockAdded" : "addFailed"));
                break;
            }

            case "deleteStockEntry": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = stockEntryService.deleteStockEntry(id);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "stockDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}