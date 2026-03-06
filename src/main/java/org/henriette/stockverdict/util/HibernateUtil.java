package org.henriette.stockverdict.util;

import org.henriette.stockverdict.models.*;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
// import other entities if you have them
// import org.henriette.stockverdict.models.Product;
// import org.henriette.stockverdict.models.Order;

public class HibernateUtil {

    private static final SessionFactory sessionFactory;

    static {
        try {
            // Create Configuration object
            Configuration configuration = new Configuration();
            configuration.configure("hibernate.cfg.xml"); // Load settings from hibernate.cfg.xml

            // ======= Register all annotated entity classes =======
            configuration.addAnnotatedClass(Users.class);
            configuration.addAnnotatedClass(Customer.class);
            configuration.addAnnotatedClass(Products.class);
            configuration.addAnnotatedClass(SaleItem.class);
            configuration.addAnnotatedClass(Sales.class);
            configuration.addAnnotatedClass(StockEntry.class);
            configuration.addAnnotatedClass(Supplier.class);
            configuration.addAnnotatedClass(Otp.class);

            // Build the SessionFactory
            sessionFactory = configuration.buildSessionFactory();

        } catch (Throwable ex) {
            System.err.println("Initial SessionFactory creation failed." + ex);
            throw new ExceptionInInitializerError(ex);
        }
    }

    // Public method to access SessionFactory
    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }

    // Optional: close the SessionFactory
    public static void shutdown() {
        getSessionFactory().close();
    }
}