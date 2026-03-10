package org.henriette.stockverdict.services;

import org.henriette.stockverdict.models.Products;
import org.henriette.stockverdict.models.StockEntry;
import org.henriette.stockverdict.models.Supplier;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * Service class for managing {@link StockEntry} entities.
 * Handles adding new stock, maintaining stock levels, and supply queries.
 */
public class StockEntryService {

    /**
     * Records a new stock entry into the inventory.
     * Increases the product's available quantity and updates its current purchase price.
     *
     * @param entry the stock entry details to persist
     * @return true if the stock entry was successful, false otherwise
     */
    public boolean addStockEntry(StockEntry entry) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            entry.setDateAdded(LocalDateTime.now());

            // Increase product stock quantity
            Products product = session.get(Products.class, entry.getProduct().getId());
            if (product == null) return false;

            product.setQuantityInStock(product.getQuantityInStock() + entry.getQuantityAdded());
            product.setUpdatedAt(LocalDateTime.now());

            // Also update product purchase price to latest
            product.setPurchasePrice(entry.getPurchasePrice());

            session.merge(product);
            session.persist(entry);

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
     * Deletes an existing stock entry and reverses the corresponding stock increase.
     * Ensures that the product's quantity doesn't drop below zero.
     *
     * @param entryId the ID of the stock entry to remove
     * @return true if successfully deleted, false on error or if not found
     */
    public boolean deleteStockEntry(Long entryId) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            StockEntry entry = session.get(StockEntry.class, entryId);
            if (entry == null) return false;

            // Reverse the stock quantity
            Products product = session.get(Products.class, entry.getProduct().getId());
            if (product != null) {
                int newQty = product.getQuantityInStock() - entry.getQuantityAdded();
                product.setQuantityInStock(Math.max(newQty, 0)); // never go below 0
                product.setUpdatedAt(LocalDateTime.now());
                session.merge(product);
            }

            session.delete(entry);
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
     * Retrieves a stock entry by its unique identifier.
     *
     * @param entryId the ID of the stock entry
     * @return the {@link StockEntry} entity if found, null otherwise
     */
    public StockEntry getStockEntryById(Long entryId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(StockEntry.class, entryId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Retrieves all stock entries created by a specific user.
     *
     * @param user the user who created the entries
     * @return a list of {@link StockEntry} ordered chronologically descending
     */
    public List<StockEntry> getStockEntriesByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<StockEntry> query = session.createQuery(
                    "FROM StockEntry WHERE user.id = :userId ORDER BY dateAdded DESC",
                    StockEntry.class);
            query.setParameter("userId", user.getId());

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all stock entries for a specific product.
     *
     * @param product the product whose stock history is requested
     * @return a list of {@link StockEntry} ordered chronologically descending
     */
    public List<StockEntry> getStockEntriesByProduct(Products product) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<StockEntry> query = session.createQuery(
                    "FROM StockEntry WHERE product = :product ORDER BY dateAdded DESC",
                    StockEntry.class);
            query.setParameter("product", product);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all stock entries fulfilled by a specific supplier.
     *
     * @param supplier the supplier whose entries are requested
     * @return a list of {@link StockEntry} ordered chronologically descending
     */
    public List<StockEntry> getStockEntriesBySupplier(Supplier supplier) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<StockEntry> query = session.createQuery(
                    "FROM StockEntry WHERE supplier = :supplier ORDER BY dateAdded DESC",
                    StockEntry.class);
            query.setParameter("supplier", supplier);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all stock entries created by a user within a specified date range.
     *
     * @param user the user who created the entries
     * @param from the starting date for the query (inclusive)
     * @param to   the ending date for the query (inclusive)
     * @return a list of matching {@link StockEntry} ordered chronologically descending
     */
    public List<StockEntry> getStockEntriesByDateRange(Users user, LocalDateTime from, LocalDateTime to) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<StockEntry> query = session.createQuery(
                    "FROM StockEntry WHERE user.id = :userId " +
                            "AND dateAdded >= :from AND dateAdded <= :to " +
                            "ORDER BY dateAdded DESC",
                    StockEntry.class);
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
     * Calculates the total financial value of all stock added by a user.
     * Useful for dashboard summaries to show the total investment in stock.
     *
     * @param user the managing user
     * @return the sum of quantityAdded * purchasePrice for all entries
     */
    public Double getTotalStockValueByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Double> query = session.createQuery(
                    "SELECT SUM(se.quantityAdded * se.purchasePrice) " +
                            "FROM StockEntry se WHERE se.user.id = :userId",
                    Double.class);
            query.setParameter("userId", user.getId());

            Double result = query.uniqueResult();
            return result != null ? result : 0.0;

        } catch (Exception e) {
            e.printStackTrace();
            return 0.0;
        }
    }
}