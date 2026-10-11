package com.tap.model;

public class Coupon {
    private int couponId;
    private String code;
    private double discountPercent;
    private double maxDiscount;
    private double minOrderAmount;
    private boolean isActive;

    public Coupon() {}

    public Coupon(int couponId, String code, double discountPercent, double maxDiscount, double minOrderAmount, boolean isActive) {
        this.couponId = couponId;
        this.code = code;
        this.discountPercent = discountPercent;
        this.maxDiscount = maxDiscount;
        this.minOrderAmount = minOrderAmount;
        this.isActive = isActive;
    }

    public int getCouponId() { return couponId; }
    public void setCouponId(int couponId) { this.couponId = couponId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public double getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(double discountPercent) { this.discountPercent = discountPercent; }

    public double getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(double maxDiscount) { this.maxDiscount = maxDiscount; }

    public double getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(double minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}