package com.tap.dao;

import com.tap.model.Coupon;

public interface CouponDAO {
    Coupon getCouponByCode(String code);
}