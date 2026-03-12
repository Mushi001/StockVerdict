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

/**
 * Servlet handling HTTP requests for Sales transactions.
 * Manages processing new sales, viewing sale receipts, listing all sales,
 * and deleting past sales. Actions are restricted to authenticated users.
 */
@WebServlet("/sales")
public class SaleServlet extends HttpServlet {

    private final SaleService     saleService     = new SaleService();
    private final ProductService  productService  = new ProductService();
    private final CustomerService customerService = new CustomerService();

    /**
     * Handles HTTP GET requests to display sales information.
     * Actions supported:
     * <ul>
     *     <li><code>list</code>: Displays all sales history for the current user.</li>
     *     <li><code>view</code>: Shows detailed items for a specific sale transaction.</li>
     *     <li><code>byCustomer</code>: Filters sales history for a specific customer.</li>
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
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
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

    /**
     * Handles HTTP POST requests for creating and deleting sales.
     * Actions supported:
     * <ul>
     *     <li><code>createSale</code>: Processes a shopping cart of items, creating a new Sale,
     *         deducting stock, and linking an optional customer.</li>
     *     <li><code>deleteSale</code>: Removes a sale record and reverses the associated stock deduction.</li>
     * </ul>
     *
     * @param req  the {@link HttpServletRequest} containing formData (e.g., arrays of productIds/quantities)
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
            resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
            return;
        }

        switch (action) {

            case "createSale": {
                try {
                    // --- Customer (optional) ---
                    String customerIdParam = req.getParameter("customerId");
                    Customer customer = null;
                    if (customerIdParam != null && !customerIdParam.isBlank()) {
                        if (customerIdParam.equals("NEW")) {
                            String newName = req.getParameter("newCustomerName");
                            String newPhone = req.getParameter("newCustomerPhone");
                            if (newName != null && !newName.isBlank()) {
                                customer = new Customer(newName, newPhone, "", "", loggedInUser);
                                customerService.addCustomer(customer);
                            }
                        } else {
                            customer = customerService.getCustomerById(Long.parseLong(customerIdParam));
                        }
                    }

                    String paymentMethod = req.getParameter("paymentMethod");

                    // --- Build sale items from parallel arrays ---
                    String[] productIds = req.getParameterValues("productId");
                    String[] quantities = req.getParameterValues("quantity");

                    if (productIds == null || productIds.length == 0 || productIds[0].isBlank()) {
                        resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&error=noItems");
                        return;
                    }

                    List<SaleItem> items = new ArrayList<>();
                    for (int i = 0; i < productIds.length; i++) {
                        if (productIds[i] == null || productIds[i].isBlank()) continue;
                        
                        Long productId = Long.parseLong(productIds[i]);
                        int qty        = Integer.parseInt(quantities[i]);

                        if (qty <= 0) continue;

                        Products product = productService.getProductById(productId);
                        if (product == null) continue;

                        // Check stock
                        if (product.getQuantityInStock() < qty) {
                            resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&error=insufficientStock&product=" + product.getName());
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
                        resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&error=noValidItems");
                        return;
                    }

                    Sales sale = new Sales(0.0, paymentMethod, loggedInUser, customer);
                    boolean success = saleService.createSale(sale, items);
                    
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&success=" + (success ? "added" : "error"));
                } catch (Exception e) {
                    e.printStackTrace();
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&error=systemError");
                }
                break;
            }

            case "updateSale": {
                try {
                    Long saleId = Long.parseLong(req.getParameter("saleId"));
                    Long productId = Long.parseLong(req.getParameter("productId"));
                    int quantity = Integer.parseInt(req.getParameter("quantity"));
                    String payment = req.getParameter("paymentMethod");
                    String customerIdParam = req.getParameter("customerId");
                    Long customerId = (customerIdParam != null && !customerIdParam.isBlank()) ? Long.parseLong(customerIdParam) : null;

                    boolean success = saleService.updateSale(saleId, productId, quantity, payment, customerId);
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&success=" + (success ? "updated" : "updateFailed"));
                } catch (Exception e) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&error=updateError");
                }
                break;
            }

            case "deleteSale": {
                try {
                    Long id = Long.parseLong(req.getParameter("saleId")); // FIXED: parameter name was 'id' in java but 'saleId' in jsp
                    boolean success = saleService.deleteSale(id);
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&success=" + (success ? "deleted" : "deleteFailed"));
                } catch (Exception e) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?section=sales&error=deleteError");
                }
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}
