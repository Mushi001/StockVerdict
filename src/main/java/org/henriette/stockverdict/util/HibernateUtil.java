package org.henriette.stockverdict.util;

import org.henriette.stockverdict.models.*;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
// import other entities if you have them
// import org.henriette.stockverdict.models.Product;
// import org.henriette.stockverdict.models.Order;

/**
 * Utility class for managing the Hibernate {@link SessionFactory}.
 * Handles the initialization of Hibernate, loading the <code>hibernate.cfg.xml</code> configuration,
 * and registering all entity classes. Provides global access to the SessionFactory.
 */
public class HibernateUtil {

    private static final SessionFactory sessionFactory;

    static {
        try {
            // Create Configuration object
            Configuration configuration = new Configuration();
            configuration.configure("hibernate.cfg.xml"); // Load settings from hibernate.cfg.xml

            // ======= Environment Variable Overrides =======
            String dbUrl = System.getenv("DB_URL");
            String dbUser = System.getenv("DB_USER");
            if (dbUser == null) dbUser = System.getenv("DB_USERNAME"); // Fallback for your .env format
            String dbPassword = System.getenv("DB_PASSWORD");

            if (dbUrl != null && !dbUrl.isEmpty()) {
                configuration.setProperty("hibernate.connection.url", dbUrl);
                System.out.println("[Hibernate] Using DB_URL from environment.");
            }
            if (dbUser != null && !dbUser.isEmpty()) {
                configuration.setProperty("hibernate.connection.username", dbUser);
            }
            if (dbPassword != null && !dbPassword.isEmpty()) {
                configuration.setProperty("hibernate.connection.password", dbPassword);
            }

            if (dbUrl == null) {
                System.err.println("[Hibernate] WARNING: DB_URL environment variable is missing!");
            }

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

    /**
     * Retrieves the globally configured Hibernate {@link SessionFactory}.
     *
     * @return the active SessionFactory instance
     */
    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }

    /**
     * Closes the SessionFactory and releases all resources it holds.
     * Should be called when the application is shutting down.
     */
    public static void shutdown() {
        getSessionFactory().close();
    }
}