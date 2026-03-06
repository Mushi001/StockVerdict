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

public class SaleService {

    // ================= CREATE SALE =================
    // Persists the Sale + all SaleItems + decrements stock for each product

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

    // ================= DELETE SALE =================
    // Deletes the sale + all its items + reverses stock decrements

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

    // ================= GET SALE BY ID =================

    public Sales getSaleById(Long saleId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Sales.class, saleId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ================= GET ALL SALES BY USER =================

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

    // ================= GET SALE ITEMS BY SALE =================

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

    // ================= GET SALES BY CUSTOMER =================

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

    // ================= GET SALES BY DATE RANGE =================

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

    // ================= TOTAL REVENUE BY USER =================

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

    // ================= TOTAL REVENUE BY DATE RANGE =================

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

    // ================= COUNT SALES BY USER =================

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

    // ================= TOP SELLING PRODUCTS =================

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