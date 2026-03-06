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

    @ManyToOne
    @JoinColumn(name = "user_id")
    private Users user;

    @OneToMany(mappedBy = "supplier")
    private List<StockEntry> stockEntries;

    // Constructors
    public Supplier() {}

    public Supplier(String name, String phone, String email, String address, Users user) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.address = address;
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

    public Users getUser() { return user; }
    public void setUser(Users user) { this.user = user; }

    public List<StockEntry> getStockEntries() { return stockEntries; }
    public void setStockEntries(List<StockEntry> stockEntries) { this.stockEntries = stockEntries; }
}