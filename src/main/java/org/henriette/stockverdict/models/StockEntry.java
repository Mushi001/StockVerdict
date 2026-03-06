package org.henriette.stockverdict.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stock_entries")
public class StockEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer quantityAdded;
    private Double purchasePrice;
    private LocalDateTime dateAdded;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Products product;

    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private Users user;

    // Constructors
    public StockEntry() {
        this.dateAdded = LocalDateTime.now();
    }

    public StockEntry(Integer quantityAdded, Double purchasePrice, Products product, Supplier supplier, Users user) {
        this.quantityAdded = quantityAdded;
        this.purchasePrice = purchasePrice;
        this.product = product;
        this.supplier = supplier;
        this.user = user;
        this.dateAdded = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getQuantityAdded() { return quantityAdded; }
    public void setQuantityAdded(Integer quantityAdded) { this.quantityAdded = quantityAdded; }

    public Double getPurchasePrice() { return purchasePrice; }
    public void setPurchasePrice(Double purchasePrice) { this.purchasePrice = purchasePrice; }

    public LocalDateTime getDateAdded() { return dateAdded; }
    public void setDateAdded(LocalDateTime dateAdded) { this.dateAdded = dateAdded; }

    public Products getProduct() { return product; }
    public void setProduct(Products product) { this.product = product; }

    public Supplier getSupplier() { return supplier; }
    public void setSupplier(Supplier supplier) { this.supplier = supplier; }

    public Users getUser() { return user; }
    public void setUser(Users user) { this.user = user; }
}
