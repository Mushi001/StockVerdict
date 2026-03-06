package org.henriette.stockverdict.models;

import jakarta.persistence.*;

@Entity
@Table(name = "sale_items")
public class SaleItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer quantity;
    private Double priceAtSale;
    private Double subtotal;

    @ManyToOne
    @JoinColumn(name = "sale_id")
    private Sales sale;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Products product;

    // Constructors
    public SaleItem() {}

    public SaleItem(Integer quantity, Double priceAtSale, Sales sale, Products product) {
        this.quantity = quantity;
        this.priceAtSale = priceAtSale;
        this.subtotal = quantity * priceAtSale;
        this.sale = sale;
        this.product = product;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public Double getPriceAtSale() { return priceAtSale; }
    public void setPriceAtSale(Double priceAtSale) { this.priceAtSale = priceAtSale; }

    public Double getSubtotal() { return subtotal; }
    public void setSubtotal(Double subtotal) { this.subtotal = subtotal; }

    public Sales getSale() { return sale; }
    public void setSale(Sales sale) { this.sale = sale; }

    public Products getProduct() { return product; }
    public void setProduct(Products product) { this.product = product; }
}