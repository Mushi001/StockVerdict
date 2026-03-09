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
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

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
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
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
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

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
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
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
                    "FROM Sales WHERE user = :user ORDER BY saleDate DESC",
                    Sales.class);
            query.setParameter("user", user);

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
                    "FROM Sales WHERE user = :user " +
                            "AND saleDate >= :from AND saleDate <= :to " +
                            "ORDER BY saleDate DESC",
                    Sales.class);
            query.setParameter("user", user);
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
                    "SELECT SUM(s.totalAmount) FROM Sales s WHERE s.user = :user",
                    Double.class);
            query.setParameter("user", user);

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
                    "SELECT SUM(s.totalAmount) FROM Sales s WHERE s.user = :user " +
                            "AND s.saleDate >= :from AND s.saleDate <= :to",
                    Double.class);
            query.setParameter("user", user);
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
                    "SELECT COUNT(s.id) FROM Sales s WHERE s.user = :user",
                    Long.class);
            query.setParameter("user", user);

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
                            "FROM SaleItem si WHERE si.sale.user = :user " +
                            "GROUP BY si.product.name " +
                            "ORDER BY totalQty DESC",
                    Object[].class);
            query.setParameter("user", user);
            query.setMaxResults(limit);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}