package org.henriette.stockverdict.services;

import org.henriette.stockverdict.models.Supplier;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.util.Collections;
import java.util.List;

/**
 * Service class for managing {@link Supplier} entities.
 * Handles the creation, updates, and querying of product suppliers.
 */
public class SupplierService {

    /**
     * Adds a new supplier to the system.
     * Handles re-attaching any detached user entities to the current Hibernate session.
     *
     * @param supplier the supplier details to persist
     * @return true if successfully added, false otherwise
     */
    public boolean addSupplier(Supplier supplier) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();
            
            // Reload user in current session to ensure it's managed
            if (supplier.getUser() != null && supplier.getUser().getId() != null) {
                Users managedUser = session.get(Users.class, supplier.getUser().getId());
                supplier.setUser(managedUser);
            }
            
            session.persist(supplier);
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
     * Updates an existing supplier's details.
     *
     * @param updatedSupplier the supplier instance containing the updated information
     * @return true if successfully updated, false on error or if the supplier wasn't found
     */
    public boolean updateSupplier(Supplier updatedSupplier) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Supplier existing = session.get(Supplier.class, updatedSupplier.getId());
            if (existing == null) return false;

            existing.setName(updatedSupplier.getName());
            existing.setPhone(updatedSupplier.getPhone());
            existing.setEmail(updatedSupplier.getEmail());
            existing.setAddress(updatedSupplier.getAddress());
            existing.setContactPerson(updatedSupplier.getContactPerson());
            existing.setBalanceOwed(updatedSupplier.getBalanceOwed());
            existing.setNotes(updatedSupplier.getNotes());

            session.merge(existing);
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
     * Deletes a supplier by their unique identifier.
     *
     * @param supplierId the ID of the supplier to remove
     * @return true if successfully deleted, false on error or if the supplier wasn't found
     */
    public boolean deleteSupplier(Long supplierId) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Supplier supplier = session.get(Supplier.class, supplierId);
            if (supplier == null) return false;

            session.delete(supplier);
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
     * Retrieves a supplier by its unique identifier.
     *
     * @param supplierId the ID of the supplier
     * @return the {@link Supplier} entity if found, null otherwise
     */
    public Supplier getSupplierById(Long supplierId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Supplier.class, supplierId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Retrieves all suppliers managed by a specific user.
     *
     * @param user the manager user
     * @return a list of {@link Supplier} ordered alphabetically by name
     */
    public List<Supplier> getSuppliersByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Supplier> query = session.createQuery(
                    "FROM Supplier WHERE user.id = :userId ORDER BY name ASC",
                    Supplier.class);
            query.setParameter("userId", user.getId());

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all suppliers across the entire system.
     *
     * @return a list of all {@link Supplier} ordered alphabetically by name
     */
    public List<Supplier> getAllSuppliers() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Supplier> query = session.createQuery(
                    "FROM Supplier ORDER BY name ASC",
                    Supplier.class);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Searches for suppliers managed by a specific user using a keyword.
     * The search matches against the supplier's name, email, or phone.
     *
     * @param user    the user managing the suppliers
     * @param keyword the search term
     * @return a list of matching {@link Supplier} entities
     */
    public List<Supplier> searchSuppliers(Users user, String keyword) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Supplier> query = session.createQuery(
                    "FROM Supplier WHERE user.id = :userId AND " +
                            "(LOWER(name) LIKE :keyword OR LOWER(email) LIKE :keyword OR LOWER(phone) LIKE :keyword) " +
                            "ORDER BY name ASC",
                    Supplier.class);
            query.setParameter("userId", user.getId());
            query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Checks if an email address is already in use by another supplier for the same user.
     *
     * @param email             the email address to check
     * @param userId            the ID of the user owning the supplier
     * @param excludeSupplierId an optional supplier ID to exclude from the check
     * @return true if the email is taken by another supplier managed by this user, false otherwise
     */
    public boolean isEmailExists(String email, Long userId, Long excludeSupplierId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            String hql = excludeSupplierId != null
                    ? "SELECT COUNT(s.id) FROM Supplier s WHERE s.email = :email AND s.user.id = :userId AND s.id != :excludeId"
                    : "SELECT COUNT(s.id) FROM Supplier s WHERE s.email = :email AND s.user.id = :userId";

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("email", email);
            query.setParameter("userId", userId);
            if (excludeSupplierId != null) query.setParameter("excludeId", excludeSupplierId);

            Long count = query.uniqueResult();
            return count != null && count > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}