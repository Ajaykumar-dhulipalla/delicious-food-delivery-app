package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.tap.dao.CouponDAO;
import com.tap.model.Coupon;
import com.tap.util.DBConnection;

public class CouponDAOImpl implements CouponDAO {

    @Override
    public Coupon getCouponByCode(String code) {
        Coupon coupon = null;
        String query = "SELECT * FROM coupons WHERE UPPER(code) = UPPER(?) AND isActive = 1";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, code.trim());

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                coupon = new Coupon(
                    rs.getInt("couponId"),
                    rs.getString("code"),
                    rs.getDouble("discountPercent"),
                    rs.getDouble("maxDiscount"),
                    rs.getDouble("minOrderAmount"),
                    rs.getBoolean("isActive")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return coupon;
    }
}