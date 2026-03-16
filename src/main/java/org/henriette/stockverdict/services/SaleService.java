package org.henriette.stockverdict.services;

import org.henriette.stockverdict.models.Customer;
import org.henriette.stockverdict.models.Products;
import org.henriette.stockverdict.models.SaleItem;
import org.henriette.stockverdict.models.Sales;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * Service class for managing {@link Sales} entities and their corresponding items.
 * Handles sales transactions, stock deduction, and revenue reporting.
 */
public class SaleService {

    /**
     * Creates a new sale transaction.
     * Persists the Sale, all its SaleItems, decreases stock quantities for each product,
     * calculates the subtotal per item, and sets the total sale amount.
     *
     * @param sale  the sale details to persist
     * @param items the list of items included in the sale
     * @return true if the sale was successfully created, false if items were out of stock or on error
     */
    public boolean createSale(Sales sale, List<SaleItem> items) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            // Validate stock availability for every item first
            for (SaleItem item : items) {
                Products product = session.get(Products.class, item.getProduct().getId());
                if (product == null) return false;
                if (product.getQuantityInStock() < item.getQuantity()) return false;
            }

            // Persist the sale header
            sale.setSaleDate(LocalDateTime.now());
            session.persist(sale);

            // Persist each item and decrement stock
            double total = 0.0;
            for (SaleItem item : items) {
                Products product = session.get(Products.class, item.getProduct().getId());

                item.setSale(sale);
                item.setPriceAtSale(product.getSellingPrice());
                item.setSubtotal(item.getQuantity() * product.getSellingPrice());
                total += item.getSubtotal();

                // Decrement stock
                product.setQuantityInStock(product.getQuantityInStock() - item.getQuantity());
                product.setUpdatedAt(LocalDateTime.now());

                session.merge(product);
                session.persist(item);
            }

            // Update total amount on the sale
            sale.setTotalAmount(total);
            session.merge(sale);

            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Updates an existing sale transaction.
     * Reverses the previous stock impact, updates sale details/items, and applies new stock impact.
     * Simplification: This assumes a single-item sale as per the current UI dashboard limits.
     *
     * @param saleId     the ID of the sale to update
     * @param productId  the new product ID
     * @param quantity   the new quantity
     * @param payment    the new payment method
     * @param customerId the new customer ID (optional)
     * @return true if successful, false on error or insufficient stock
     */
    public boolean updateSale(Long saleId, Long productId, int quantity, String payment, Long customerId) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Sales sale = session.get(Sales.class, saleId);
            if (sale == null) return false;

            // 1. Reverse old stock
            List<SaleItem> oldItems = getSaleItemsBySale(sale);
            for (SaleItem item : oldItems) {
                Products p = session.get(Products.class, item.getProduct().getId());
                if (p != null) {
                    p.setQuantityInStock(p.getQuantityInStock() + item.getQuantity());
                    session.merge(p);
                }
            }

            // 2. Validate new stock
            Products newProduct = session.get(Products.class, productId);
            if (newProduct == null || newProduct.getQuantityInStock() < quantity) {
                transaction.rollback();
                return false;
            }

            // 3. Update Sale header
            sale.setPaymentMethod(payment);
            if (customerId != null) {
                sale.setCustomer(session.get(Customer.class, customerId));
            } else {
                sale.setCustomer(null);
            }
            
            double total = quantity * newProduct.getSellingPrice();
            sale.setTotalAmount(total);
            session.merge(sale);

            // 4. Update/Replace SaleItems (assuming single item for now)
            // Delete old items
            for (SaleItem item : oldItems) {
                session.delete(item);
            }
            
            // Create new item
            SaleItem newItem = new SaleItem();
            newItem.setSale(sale);
            newItem.setProduct(newProduct);
            newItem.setQuantity(quantity);
            newItem.setPriceAtSale(newProduct.getSellingPrice());
            newItem.setSubtotal(total);
            session.persist(newItem);

            // 5. Subtract new stock
            newProduct.setQuantityInStock(newProduct.getQuantityInStock() - quantity);
            newProduct.setUpdatedAt(LocalDateTime.now());
            session.merge(newProduct);

            transaction.commit();
            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Deletes a sale transaction.
     * Deletes the sale and all its items, and reverses the stock decrements.
     *
     * @param saleId the ID of the sale to delete
     * @return true if successfully deleted, false on error or if not found
     */
    public boolean deleteSale(Long saleId) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Sales sale = session.get(Sales.class, saleId);
            if (sale == null) return false;

            // Reverse stock for each sale item
            List<SaleItem> items = getSaleItemsBySale(sale);
            for (SaleItem item : items) {
                Products product = session.get(Products.class, item.getProduct().getId());
                if (product != null) {
                    product.setQuantityInStock(product.getQuantityInStock() + item.getQuantity());
                    product.setUpdatedAt(LocalDateTime.now());
                    session.merge(product);
                }
            }

            session.delete(sale); // cascades to SaleItems
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (session != null && session.isOpen()) {
                session.close();
            }
        }
    }

    /**
     * Retrieves a sale transaction by its ID.
     *
     * @param saleId the ID of the sale
     * @return the {@link Sales} entity if found, null otherwise
     */
    public Sales getSaleById(Long saleId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Sales.class, saleId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Retrieves all sales processed by a specific user.
     *
     * @param user the user (trader) who processed the sales
     * @return a list of {@link Sales} entities ordered chronologically by sale date descending
     */
    public List<Sales> getSalesByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Sales> query = session.createQuery(
                    "SELECT DISTINCT s FROM Sales s " +
                            "LEFT JOIN FETCH s.saleItems si " +
                            "LEFT JOIN FETCH si.product " +
                            "WHERE s.user.id = :userId ORDER BY s.saleDate DESC",
                    Sales.class);
            query.setParameter("userId", user.getId());

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all items belonging to a specific sale transaction.
     *
     * @param sale the parent {@link Sales} transaction
     * @return a list of {@link SaleItem} components
     */
    public List<SaleItem> getSaleItemsBySale(Sales sale) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<SaleItem> query = session.createQuery(
                    "FROM SaleItem WHERE sale = :sale",
                    SaleItem.class);
            query.setParameter("sale", sale);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all sales associated with a specific customer.
     *
     * @param customer the customer whose purchases are being queried
     * @return a list of {@link Sales} entities ordered chronologically by sale date descending
     */
    public List<Sales> getSalesByCustomer(Customer customer) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Sales> query = session.createQuery(
                    "FROM Sales WHERE customer = :customer ORDER BY saleDate DESC",
                    Sales.class);
            query.setParameter("customer", customer);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all sales processed by a user within a specified date range.
     *
     * @param user the user who processed the sales
     * @param from the start date (inclusive)
     * @param to   the end date (inclusive)
     * @return a list of matching {@link Sales} entities ordered chronologically by sale date descending
     */
    public List<Sales> getSalesByDateRange(Users user, LocalDateTime from, LocalDateTime to) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Sales> query = session.createQuery(
                    "FROM Sales WHERE user.id = :userId " +
                            "AND saleDate >= :from AND saleDate <= :to " +
                            "ORDER BY saleDate DESC",
                    Sales.class);
            query.setParameter("userId", user.getId());
            query.setParameter("from", from);
            query.setParameter("to", to);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Calculates the total revenue generated from all sales processed by a specific user.
     *
     * @param user the user
     * @return the total revenue
     */
    public Double getTotalRevenueByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Double> query = session.createQuery(
                    "SELECT SUM(s.totalAmount) FROM Sales s WHERE s.user.id = :userId",
                    Double.class);
            query.setParameter("userId", user.getId());

            Double result = query.uniqueResult();
            return result != null ? result : 0.0;

        } catch (Exception e) {
            e.printStackTrace();
            return 0.0;
        }
    }

    /**
     * Calculates the total revenue generated by a user within a specified date range.
     *
     * @param user the user
     * @param from the start date (inclusive)
     * @param to   the end date (inclusive)
     * @return the total revenue in the specified period
     */
    public Double getTotalRevenueByDateRange(Users user, LocalDateTime from, LocalDateTime to) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Double> query = session.createQuery(
                    "SELECT SUM(s.totalAmount) FROM Sales s WHERE s.user.id = :userId " +
                            "AND s.saleDate >= :from AND s.saleDate <= :to",
                    Double.class);
            query.setParameter("userId", user.getId());
            query.setParameter("from", from);
            query.setParameter("to", to);

            Double result = query.uniqueResult();
            return result != null ? result : 0.0;

        } catch (Exception e) {
            e.printStackTrace();
            return 0.0;
        }
    }

    /**
     * Counts the total number of distinct sale transactions processed by a user.
     *
     * @param user the user
     * @return the total count of their sales
     */
    public Long countSalesByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Long> query = session.createQuery(
                    "SELECT COUNT(s.id) FROM Sales s WHERE s.user.id = :userId",
                    Long.class);
            query.setParameter("userId", user.getId());

            return query.uniqueResult();

        } catch (Exception e) {
            e.printStackTrace();
            return 0L;
        }
    }

    /**
     * Retrieves the top-selling products by volume for a specific user.
     *
     * @param user  the user querying the top products
     * @param limit the maximum number of top products to retrieve
     * @return a list of Object arrays containing the product name and the total quantity sold
     */
    public List<Object[]> getTopSellingProducts(Users user, int limit) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Object[]> query = session.createQuery(
                    "SELECT si.product.name, SUM(si.quantity) as totalQty " +
                            "FROM SaleItem si WHERE si.sale.user.id = :userId " +
                            "GROUP BY si.product.name " +
                            "ORDER BY totalQty DESC",
                    Object[].class);
            query.setParameter("userId", user.getId());
            query.setMaxResults(limit);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves the top-selling products by volume across the entire system.
     */
    public List<Object[]> getSystemWideTopSellingProducts(int limit) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Object[]> query = session.createQuery(
                    "SELECT si.product.name, SUM(si.quantity) as totalQty " +
                            "FROM SaleItem si " +
                            "GROUP BY si.product.name " +
                            "ORDER BY totalQty DESC",
                    Object[].class);
            query.setMaxResults(limit);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves the top-performing traders by revenue.
     */
    public List<Object[]> getSystemWideTopTraders(int limit) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Object[]> query = session.createQuery(
                    "SELECT s.user.name, SUM(s.totalAmount) as revenue " +
                            "FROM Sales s " +
                            "GROUP BY s.user.name " +
                            "ORDER BY revenue DESC",
                    Object[].class);
            query.setMaxResults(limit);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Calculates the total revenue generated across the entire system.
     */
    public Double getSystemWideTotalRevenue() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Double> query = session.createQuery(
                    "SELECT SUM(s.totalAmount) FROM Sales s",
                    Double.class);
            Double result = query.uniqueResult();
            return result != null ? result : 0.0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0.0;
        }
    }
}