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

/**
 * Service class for managing {@link Products} entities.
 * Handles product creation, updates, and custom queries such as low stock detection.
 */
public class ProductService {

    /**
     * Adds a new product to the database.
     * Sets the creation and update timestamps before persisting.
     *
     * @param product the product entity to add
     * @return true if the product was successfully added, false otherwise
     */
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

    /**
     * Updates an existing product's details.
     *
     * @param updatedProduct the product entity containing the updated information
     * @return true if the product was successfully updated, false if not found or on error
     */
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

    /**
     * Deletes a product by its unique identifier.
     *
     * @param productId the ID of the product to delete
     * @return true if the product was successfully deleted, false if not found or on error
     */
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

    /**
     * Retrieves a product by its unique identifier.
     *
     * @param productId the ID of the product
     * @return the {@link Products} entity if found, null otherwise
     */
    public Products getProductById(Long productId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Products.class, productId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Retrieves all products managed by a specific user.
     *
     * @param user the managing {@link Users}
     * @return a list of {@link Products} entities ordered by creation date descending
     */
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

    /**
     * Retrieves all products in the system.
     *
     * @return a list of all {@link Products} entities ordered by creation date descending
     */
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

    /**
     * Retrieves products managed by a user that are below or equal to their reorder level.
     *
     * @param user the managing {@link Users}
     * @return a list of low-stock {@link Products} entities
     */
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

    /**
     * Searches for products managed by a specific user using a keyword.
     * The search matches against either the product name, barcode, or description.
     *
     * @param user    the managing {@link Users}
     * @param keyword the search term
     * @return a list of matching {@link Products} entities
     */
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

    /**
     * Checks if a barcode is already associated with another product.
     *
     * @param barcode          the barcode to check
     * @param excludeProductId an optional product ID to exclude from the check
     * @return true if the barcode belongs to another product, false otherwise
     */
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