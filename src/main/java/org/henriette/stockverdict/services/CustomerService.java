package org.henriette.stockverdict.services;

import org.henriette.stockverdict.models.Customer;
import org.henriette.stockverdict.models.Users;
import org.henriette.stockverdict.util.HibernateUtil;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * Service class for managing {@link Customer} entities.
 * Provides CRUD operations and custom queries for customer management.
 */
public class CustomerService {

    /**
     * Adds a new customer to the database.
     * Sets the creation and update timestamps before persisting.
     *
     * @param customer the customer entity to add
     * @return true if the customer was successfully added, false otherwise
     */
    public boolean addCustomer(Customer customer) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            customer.setCreatedAt(LocalDateTime.now());
            customer.setUpdatedAt(LocalDateTime.now());

            session.persist(customer);
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
     * Updates an existing customer's details.
     *
     * @param updatedCustomer the customer entity containing updated information
     * @return true if the customer was successfully updated, false if not found or on error
     */
    public boolean updateCustomer(Customer updatedCustomer) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Customer existing = session.get(Customer.class, updatedCustomer.getId());
            if (existing == null) return false;

            existing.setName(updatedCustomer.getName());
            existing.setPhone(updatedCustomer.getPhone());
            existing.setEmail(updatedCustomer.getEmail());
            existing.setAddress(updatedCustomer.getAddress());
            existing.setUpdatedAt(LocalDateTime.now());

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
     * Deletes a customer by their unique identifier.
     *
     * @param customerId the ID of the customer to delete
     * @return true if the customer was successfully deleted, false if not found or on error
     */
    public boolean deleteCustomer(Long customerId) {
        Session session = null;
        Transaction transaction = null;
        try {
            session = HibernateUtil.getSessionFactory().openSession();
            transaction = session.beginTransaction();

            Customer customer = session.get(Customer.class, customerId);
            if (customer == null) return false;

            session.delete(customer);
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
     * Retrieves a customer by their unique identifier.
     *
     * @param customerId the ID of the customer
     * @return the {@link Customer} entity if found, null otherwise
     */
    public Customer getCustomerById(Long customerId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Customer.class, customerId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Retrieves all customers managed by a specific user.
     *
     * @param user the managing {@link Users}
     * @return a list of {@link Customer} entities ordered by name
     */
    public List<Customer> getCustomersByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Customer> query = session.createQuery(
                    "FROM Customer WHERE user.id = :userId ORDER BY name ASC",
                    Customer.class);
            query.setParameter("userId", user.getId());

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Retrieves all customers in the system.
     *
     * @return a list of all {@link Customer} entities ordered by name
     */
    public List<Customer> getAllCustomers() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Customer> query = session.createQuery(
                    "FROM Customer ORDER BY name ASC",
                    Customer.class);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Searches for customers managed by a specific user using a keyword.
     * The search matches against the customer's name, email, or phone.
     *
     * @param user    the managing {@link Users}
     * @param keyword the search term
     * @return a list of matching {@link Customer} entities
     */
    public List<Customer> searchCustomers(Users user, String keyword) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Customer> query = session.createQuery(
                    "FROM Customer WHERE user.id = :userId AND " +
                            "(LOWER(name) LIKE :keyword OR LOWER(email) LIKE :keyword OR LOWER(phone) LIKE :keyword) " +
                            "ORDER BY name ASC",
                    Customer.class);
            query.setParameter("userId", user.getId());
            query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    /**
     * Checks if an email address is already in use by another customer.
     *
     * @param email             the email address to check
     * @param excludeCustomerId an optional customer ID to exclude from the check (useful during updates)
     * @return true if the email is taken, false otherwise
     */
    public boolean isEmailExists(String email, Long excludeCustomerId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            String hql = excludeCustomerId != null
                    ? "SELECT COUNT(c.id) FROM Customer c WHERE c.email = :email AND c.id != :excludeId"
                    : "SELECT COUNT(c.id) FROM Customer c WHERE c.email = :email";

            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("email", email);
            if (excludeCustomerId != null) query.setParameter("excludeId", excludeCustomerId);

            Long count = query.uniqueResult();
            return count != null && count > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Counts the total number of customers managed by a specific user.
     *
     * @param user the managing {@link Users}
     * @return the count of customers
     */
    public Long countCustomersByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Long> query = session.createQuery(
                    "SELECT COUNT(c.id) FROM Customer c WHERE c.user.id = :userId",
                    Long.class);
            query.setParameter("userId", user.getId());

            return query.uniqueResult();

        } catch (Exception e) {
            e.printStackTrace();
            return 0L;
        }
    }
}