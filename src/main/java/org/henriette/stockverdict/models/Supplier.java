package org.henriette.stockverdict.models;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "suppliers")
public class Supplier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String phone;
    private String email;
    private String address;

    private String contactPerson;
    private double balanceOwed;
    private String notes;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private Users user;

    @OneToMany(mappedBy = "supplier")
    private List<StockEntry> stockEntries;

    @OneToMany(mappedBy = "supplier", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Products> products;

    // Constructors
    public Supplier() {}

    public Supplier(String name, String phone, String email, String address, String contactPerson, double balanceOwed, String notes, Users user) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.contactPerson = contactPerson;
        this.balanceOwed = balanceOwed;
        this.notes = notes;
        this.user = user;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }

    public double getBalanceOwed() { return balanceOwed; }
    public void setBalanceOwed(double balanceOwed) { this.balanceOwed = balanceOwed; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Users getUser() { return user; }
    public void setUser(Users user) { this.user = user; }

    public List<StockEntry> getStockEntries() { return stockEntries; }
    public void setStockEntries(List<StockEntry> stockEntries) { this.stockEntries = stockEntries; }

    public List<Products> getProducts() { return products; }
    public void setProducts(List<Products> products) { this.products = products; }
}