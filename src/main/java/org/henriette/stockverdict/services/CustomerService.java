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

public class CustomerService {

    // ================= ADD CUSTOMER =================

    public boolean addCustomer(Customer customer) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            customer.setCreatedAt(LocalDateTime.now());
            customer.setUpdatedAt(LocalDateTime.now());

            session.persist(customer);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= UPDATE CUSTOMER =================

    public boolean updateCustomer(Customer updatedCustomer) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

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
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= DELETE CUSTOMER =================

    public boolean deleteCustomer(Long customerId) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            transaction = session.beginTransaction();

            Customer customer = session.get(Customer.class, customerId);
            if (customer == null) return false;

            session.delete(customer);
            transaction.commit();

            return true;

        } catch (Exception e) {
            if (transaction != null) transaction.rollback();
            e.printStackTrace();
            return false;
        }
    }

    // ================= GET CUSTOMER BY ID =================

    public Customer getCustomerById(Long customerId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            return session.get(Customer.class, customerId);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ================= GET ALL CUSTOMERS BY USER =================

    public List<Customer> getCustomersByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Customer> query = session.createQuery(
                    "FROM Customer WHERE user = :user ORDER BY name ASC",
                    Customer.class);
            query.setParameter("user", user);

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= GET ALL CUSTOMERS =================

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

    // ================= SEARCH CUSTOMERS =================

    public List<Customer> searchCustomers(Users user, String keyword) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Customer> query = session.createQuery(
                    "FROM Customer WHERE user = :user AND " +
                            "(LOWER(name) LIKE :keyword OR LOWER(email) LIKE :keyword OR LOWER(phone) LIKE :keyword) " +
                            "ORDER BY name ASC",
                    Customer.class);
            query.setParameter("user", user);
            query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");

            return query.list();

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ================= IS EMAIL EXISTS =================

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

    // ================= COUNT CUSTOMERS BY USER =================

    public Long countCustomersByUser(Users user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {

            Query<Long> query = session.createQuery(
                    "SELECT COUNT(c.id) FROM Customer c WHERE c.user = :user",
                    Long.class);
            query.setParameter("user", user);

            return query.uniqueResult();

        } catch (Exception e) {
            e.printStackTrace();
            return 0L;
        }
    }
}