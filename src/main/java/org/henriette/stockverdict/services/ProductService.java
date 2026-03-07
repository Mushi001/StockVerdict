package org.henriette.stockverdict.services;

import org.henriette.stockverdict.models.Products;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

public class ProductService {

    // ================= ADD PRODUCT =================

    public boolean addProduct(Products product) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            product.setCreatedAt(LocalDateTime.now());
            product.setUpdatedAt(LocalDateTime.now());

            session.merge(product);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= UPDATE PRODUCT =================

    public boolean updateProduct(Products updatedProduct) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Products existing = session.get(Products.class, updatedProduct.getId());
            if (existing == null) return false;

            existing.setName(updatedProduct.getName());
            existing.setDescription(updatedProduct.getDescription());
            existing.setBarcode(updatedProduct.getBarcode());
            existing.setPurchasePrice(updatedProduct.getPurchasePrice());
            existing.setSellingPrice(updatedProduct.getSellingPrice());
            existing.setQuantityInStock(updatedProduct.getQuantityInStock());
            existing.setReorderLevel(updatedProduct.getReorderLevel());
            existing.setUpdatedAt(LocalDateTime.now());

            session.merge(existing);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= DELETE PRODUCT =================

    public boolean deleteProduct(Long productId) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Products product = session.get(Products.class, productId);
            if (product == null) return false;

            session.delete(product);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= GET PRODUCT BY ID =================

    public Products getProductById(Long productId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Products.class, productId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ================= GET ALL PRODUCTS BY USER =================

    public List<Products> getProductsByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Products> query = session.createQuery(
                    "FROM Products WHERE user = :user ORDER BY createdAt DESC",
                    Products.class);
            query.setParameter("user", user);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= GET ALL PRODUCTS =================

    public List<Products> getAllProducts() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Products> query = session.createQuery(
                    "FROM Products ORDER BY createdAt DESC",
                    Products.class);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= GET LOW STOCK PRODUCTS =================

    public List<Products> getLowStockProducts(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Products> query = session.createQuery(
                    "FROM Products WHERE user = :user AND quantityInStock <= reorderLevel ORDER BY quantityInStock ASC",
                    Products.class);
            query.setParameter("user", user);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= SEARCH PRODUCTS =================

    public List<Products> searchProducts(Users user, String keyword) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Products> query = session.createQuery(
                    "FROM Products WHERE user = :user AND " +
                            "(LOWER(name) LIKE :keyword OR LOWER(barcode) LIKE :keyword OR LOWER(description) LIKE :keyword) " +
                            "ORDER BY name ASC",
                    Products.class);
            query.setParameter("user", user);
            query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= IS BARCODE TAKEN =================

    public boolean isBarcodeExists(String barcode, Long excludeProductId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            String hql = excludeProductId != null
                    ? "SELECT COUNT(p.id) FROM Products p WHERE p.barcode = :barcode AND p.id != :excludeId"
                    : "SELECT COUNT(p.id) FROM Products p WHERE p.barcode = :barcode";

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("barcode", barcode);
            if (excludeProductId != null) query.setParameter("excludeId", excludeProductId);

            Long count = query.uniqueResult();
            return count != null && count > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}