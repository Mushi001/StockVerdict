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

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private final ProductService productService = new ProductService();
    private final SupplierService supplierService = new SupplierService();

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
                req.setAttribute("productList", productService.getProductsByUser(loggedInUser));
                // Inject suppliers list for dashboard dropdowns
                req.setAttribute("supplierList", supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "lowStock":
                req.setAttribute("lowStockProducts", productService.getLowStockProducts(loggedInUser));
                req.setAttribute("supplierList", supplierService.getSuppliersByUser(loggedInUser));
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "search":
                String keyword = req.getParameter("keyword");
                if (keyword == null) keyword = "";
                req.setAttribute("productList", productService.searchProducts(loggedInUser, keyword));
                req.setAttribute("supplierList", supplierService.getSuppliersByUser(loggedInUser));
                req.setAttribute("keyword", keyword);
                req.getRequestDispatcher("/traderDashboard.jsp").forward(req, resp);
                break;

            case "edit":
                Long editId = Long.parseLong(req.getParameter("id"));
                Products productToEdit = productService.getProductById(editId);
                req.setAttribute("productToEdit", productToEdit);
                req.setAttribute("supplierList", supplierService.getSuppliersByUser(loggedInUser));
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
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=barcodeExists");
                    return;
                }

                // Check price logic
                if (sellingPrice < purchasePrice) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=invalidPrice");
                    return;
                }

                Products product = new Products(
                        name, description, barcode,
                        purchasePrice, sellingPrice,
                        quantity, reorderLevel, loggedInUser, supplier
                );

                boolean success = productService.addProduct(product);
                resp.sendRedirect(req.getContextPath() + "/products?action=list&success=" +
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
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=barcodeExists");
                    return;
                }

                // Check price logic
                if (sellingPrice < purchasePrice) {
                    resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp?error=invalidPrice");
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
                resp.sendRedirect(req.getContextPath() + "/products?action=list&success=" +
                        (success ? "productUpdated" : "updateFailed"));
                break;
            }

            case "deleteProduct": {
                Long id = Long.parseLong(req.getParameter("id"));

                boolean success = productService.deleteProduct(id);
                resp.sendRedirect(req.getContextPath() + "/products?action=list&success=" +
                        (success ? "productDeleted" : "deleteFailed"));
                break;
            }

            default:
                resp.sendRedirect(req.getContextPath() + "/traderDashboard.jsp");
        }
    }
}