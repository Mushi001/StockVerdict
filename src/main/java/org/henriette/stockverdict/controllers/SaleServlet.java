package org.henriette.stockverdict.controllers;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.henriette.stockverdict.models.Customer;
import org.henriette.stockverdict.models.Products;
import org.henriette.stockverdict.models.SaleItem;
import org.henriette.stockverdict.models.Sales;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.services.CustomerService;
import org.henriette.stockverdict.services.ProductService;
import org.henriette.stockverdict.services.SaleService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/sales")

public class SaleServlet extends HttpServlet {

    private final SaleService     saleService     = new SaleService();
    private final ProductService  productService  = new ProductService();
    private final CustomerService customerService = new CustomerService();

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
                req.setAttribute("sales",     saleService.getSalesByUser(loggedInUser));
                req.setAttribute("products",  productService.getProductsByUser(loggedInUser));
                req.setAttribute("customers", customerService.getCustomersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "view":
                Long saleId = Long.parseLong(req.getParameter("id"));
                Sales sale  = saleService.getSaleById(saleId);
                if (sale != null) {
                    req.setAttribute("sale",      sale);
                    req.setAttribute("saleItems", saleService.getSaleItemsBySale(sale));
                }
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "byCustomer":
                Long customerId  = Long.parseLong(req.getParameter("customerId"));
                Customer customer = customerService.getCustomerById(customerId);
                if (customer != null) {
                    req.setAttribute("sales",          saleService.getSalesByCustomer(customer));
                    req.setAttribute("filterCustomer", customer);
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

            case "createSale": {
                // --- Customer (optional) ---
                String customerIdParam = req.getParameter("customerId");
                Customer customer = null;
                if (customerIdParam != null && !customerIdParam.isBlank()) {
                    customer = customerService.getCustomerById(Long.parseLong(customerIdParam));
                }

                String paymentMethod = req.getParameter("paymentMethod");

                // --- Build sale items from parallel arrays ---
                // Form sends: productId[], quantity[]
                String[] productIds = req.getParameterValues("productId");
                String[] quantities = req.getParameterValues("quantity");

                if (productIds == null || productIds.length == 0) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=noItemsInSale");
                    return;
                }

                List<SaleItem> items = new ArrayList<>();
                for (int i = 0; i < productIds.length; i++) {
                    Long productId = Long.parseLong(productIds[i]);
                    int qty        = Integer.parseInt(quantities[i]);

                    if (qty <= 0) continue;

                    Products product = productService.getProductById(productId);
                    if (product == null) continue;

                    // Check stock before building the list
                    if (product.getQuantityInStock() < qty) {
                        resp.sendRedirect(req.getContextPath() +
                                "/traderDashboard.jsp?error=insufficientStock&product=" +
                                product.getName());
                        return;
                    }

                    SaleItem item = new SaleItem();
                    item.setProduct(product);
                    item.setQuantity(qty);
                    item.setPriceAtSale(product.getSellingPrice());
                    item.setSubtotal(qty * product.getSellingPrice());
                    items.add(item);
                }

                if (items.isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=noValidItems");
                    return;
                }

                Sales sale = new Sales(0.0, paymentMethod, loggedInUser, customer);

                boolean success = saleService.createSale(sale, items);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "saleCreated" : "saleFailed"));
                break;
            }

            case "deleteSale": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = saleService.deleteSale(id);
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?success=" +
                        (success ? "saleDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}