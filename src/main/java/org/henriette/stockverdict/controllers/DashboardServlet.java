package org.henriette.stockverdict.controllers;

import org.henriette.stockverdict.models.*;
import org.henriette.stockverdict.services.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Dashboard servlet that loads all necessary data for the traderDashboard.jsp
 * This ensures that customers, products, and suppliers are displayed correctly
 */
@WebServlet(name = "DashboardServlet", value = "/dashboard")
public class DashboardServlet extends HttpServlet {

    private ProductService productService = new ProductService();
    private SupplierService supplierService = new SupplierService();
    private CustomerService customerService = new CustomerService();
    private SaleService saleService = new SaleService();
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Users currentUser = (Users) session.getAttribute("currentUser");
        
        // Load data for the current user
        try {
            // Load products
            List<Products> productList = productService.getProductsByUser(currentUser);
            request.setAttribute("productList", productList);
            
            // Load suppliers
            List<Supplier> supplierList = supplierService.getSuppliersByUser(currentUser);
            request.setAttribute("supplierList", supplierList);
            
            // Load customers
            List<Customer> customerList = customerService.getCustomersByUser(currentUser);
            request.setAttribute("customerList", customerList);
            
            // Load sales
            List<Sales> salesList = saleService.getSalesByUser(currentUser);
            request.setAttribute("salesList", salesList);
            
            // Calculate statistics
            request.setAttribute("totalProducts", productList.size());
            request.setAttribute("totalSuppliers", supplierList.size());
            request.setAttribute("totalCustomers", customerList.size());
            request.setAttribute("totalSales", salesList.size());
            
            // Calculate revenue
            double totalRevenue = salesList.stream()
                    .mapToDouble(Sales::getTotalAmount)
                    .sum();
            request.setAttribute("totalRevenue", totalRevenue);
            
            // Calculate stock statistics
            long lowStockCount = productList.stream()
                    .filter(p -> p.getQuantityInStock() > 0 && p.getQuantityInStock() <= 5)
                    .count();
            request.setAttribute("lowStockCount", lowStockCount);
            
            long outOfStockCount = productList.stream()
                    .filter(p -> p.getQuantityInStock() == 0)
                    .count();
            request.setAttribute("outOfStockCount", outOfStockCount);
            
            // Calculate total stock value
            double totalStockValue = productList.stream()
                    .mapToDouble(p -> p.getQuantityInStock() * p.getPurchasePrice())
                    .sum();
            request.setAttribute("totalStockValue", totalStockValue);
            
            // Calculate supplier balances
            double totalOwed = supplierList.stream()
                    .mapToDouble(Supplier::getBalanceOwed)
                    .sum();
            request.setAttribute("totalOwed", totalOwed);
            
            // Handle section parameter for navigation
            String section = request.getParameter("section");
            if (section != null && !section.isEmpty()) {
                request.setAttribute("currentSection", section);
            }
            
            // Handle success and error messages
            String success = request.getParameter("success");
            if (success != null) {
                request.setAttribute("success", getSuccessMessage(success));
            }
            
            String error = request.getParameter("error");
            if (error != null) {
                request.setAttribute("error", getErrorMessage(error));
            }
            
            // Forward to the dashboard
            request.getRequestDispatcher("/traderDashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("[Dashboard] Error loading data: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Failed to load dashboard data. Please try again.");
            request.getRequestDispatcher("/traderDashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // For POST requests, just forward to GET to handle the same logic
        doGet(request, response);
    }

    private String getSuccessMessage(String successCode) {
        switch (successCode) {
            case "supplierAdded": return "Supplier added successfully!";
            case "supplierUpdated": return "Supplier updated successfully!";
            case "supplierDeleted": return "Supplier deleted successfully!";
            case "customerAdded": return "Customer added successfully!";
            case "customerUpdated": return "Customer updated successfully!";
            case "customerDeleted": return "Customer deleted successfully!";
            case "productAdded": return "Product added successfully!";
            case "productUpdated": return "Product updated successfully!";
            case "productDeleted": return "Product deleted successfully!";
            case "saleAdded": return "Sale recorded successfully!";
            case "saleUpdated": return "Sale updated successfully!";
            case "saleDeleted": return "Sale deleted successfully!";
            case "stockAdded": return "Stock added successfully!";
            case "stockDeleted": return "Stock entry deleted successfully!";
            default: return "Operation completed successfully!";
        }
    }

    private String getErrorMessage(String errorCode) {
        switch (errorCode) {
            case "supplierEmailExists": return "A supplier with this email already exists.";
            case "customerEmailExists": return "A customer with this email already exists.";
            case "invalidPrice": return "Selling Price cannot be lower than Cost Price.";
            case "barcodeExists": return "A product with this barcode already exists.";
            case "invalidProductOrSupplier": return "Invalid product or supplier selected.";
            case "invalidQuantity": return "Invalid quantity specified.";
            case "noItems": return "No items selected for sale.";
            default: return "An error occurred. Please try again.";
        }
    }
}
