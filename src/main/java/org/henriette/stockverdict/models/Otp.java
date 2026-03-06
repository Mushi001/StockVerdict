package org.henriette.stockverdict.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_otps")
public class Otp {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;

    @Column(nullable = false)
    private String otpCode;

    @Column(nullable = false)
    private LocalDateTime expiryTime;

    @Column(nullable = false)
    private boolean used = false;

    public Otp() {}

    public Otp(Users user, String otpCode, LocalDateTime expiryTime) {
        this.user = user;
        this.otpCode = otpCode;
        this.expiryTime = expiryTime;
        this.used = false;
    }

    public Otp(boolean used, LocalDateTime expiryTime, String otpCode, Users user, Long id) {
        this.used = used;
        this.expiryTime = expiryTime;
        this.otpCode = otpCode;
        this.user = user;
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public Users getUser() {
        return user;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public LocalDateTime getExpiryTime() {
        return expiryTime;
    }

    public boolean isUsed() {
        return used;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setUser(Users user) {
        this.user = user;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public void setExpiryTime(LocalDateTime expiryTime) {
        this.expiryTime = expiryTime;
    }

    public void setUsed(boolean used) {
        this.used = used;
    }
}