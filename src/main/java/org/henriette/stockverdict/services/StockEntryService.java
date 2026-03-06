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

public class StockEntryService {

    // ================= ADD STOCK ENTRY =================
    // Creates a stock entry AND increases the product's quantityInStock

    public boolean addStockEntry(StockEntry entry) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

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
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= DELETE STOCK ENTRY =================
    // Deletes the entry AND reverses the stock quantity increase

    public boolean deleteStockEntry(Long entryId) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

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
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= GET ENTRY BY ID =================

    public StockEntry getStockEntryById(Long entryId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(StockEntry.class, entryId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ================= GET ALL ENTRIES BY USER =================

    public List<StockEntry> getStockEntriesByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<StockEntry> query = session.createQuery(
                    "FROM StockEntry WHERE user = :user ORDER BY dateAdded DESC",
                    StockEntry.class);
            query.setParameter("user", user);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= GET ENTRIES BY PRODUCT =================

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

    // ================= GET ENTRIES BY SUPPLIER =================

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

    // ================= GET ENTRIES BY DATE RANGE =================

    public List<StockEntry> getStockEntriesByDateRange(Users user, LocalDateTime from, LocalDateTime to) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<StockEntry> query = session.createQuery(
                    "FROM StockEntry WHERE user = :user " +
                            "AND dateAdded >= :from AND dateAdded <= :to " +
                            "ORDER BY dateAdded DESC",
                    StockEntry.class);
            query.setParameter("user", user);
            query.setParameter("from", from);
            query.setParameter("to", to);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= TOTAL STOCK VALUE BY USER =================
    // Sum of (quantityAdded * purchasePrice) — useful for dashboard

    public Double getTotalStockValueByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Double> query = session.createQuery(
                    "SELECT SUM(se.quantityAdded * se.purchasePrice) " +
                            "FROM StockEntry se WHERE se.user = :user",
                    Double.class);
            query.setParameter("user", user);

            Double result = query.uniqueResult();
            return result != null ? result : 0.0;

        } catch (Exception e) {
            e.printStackTrace();
            return 0.0;
        }
    }
}