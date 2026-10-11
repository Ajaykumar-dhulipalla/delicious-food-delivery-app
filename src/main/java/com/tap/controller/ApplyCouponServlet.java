package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.CouponDAO;
import com.tap.dao.OrderDao;
import com.tap.daoimpl.CouponDAOImpl;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.model.Coupon;
import com.tap.model.User;

@WebServlet("/applyCoupon")
public class ApplyCouponServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CouponDAO couponDAO;
    private OrderDao orderDao;

    @Override
    public void init() {
        couponDAO = new CouponDAOImpl();
        orderDao = new OrderDaoImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 1. Ensure user is logged in
        if (user == null) {
            out.print("{\"success\": false, \"message\": \"Please login to apply promo codes.\"}");
            return;
        }

        String code = request.getParameter("couponCode");
        String subtotalStr = request.getParameter("subtotal");

        if (code == null || code.trim().isEmpty() || subtotalStr == null) {
            out.print("{\"success\": false, \"message\": \"Please enter a valid coupon code.\"}");
            return;
        }

        double subtotal;
        try {
            subtotal = Double.parseDouble(subtotalStr);
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"Invalid order subtotal.\"}");
            return;
        }

        // 2. Retrieve coupon from database
        Coupon coupon = couponDAO.getCouponByCode(code.trim());

        if (coupon == null) {
            out.print("{\"success\": false, \"message\": \"Invalid or expired promo code.\"}");
            return;
        }

        // 3. First-order only restriction for WELCOME50
        if (coupon.getCode().equalsIgnoreCase("WELCOME50")) {
            int pastOrders = orderDao.getOrderCountByUserId(user.getUserId());
            if (pastOrders > 0) {
                out.print("{\"success\": false, \"message\": \"WELCOME50 is only valid on your first order!\"}");
                return;
            }
        }

        // 4. Validate minimum order requirement (now ₹160 from DB)
        if (subtotal < coupon.getMinOrderAmount()) {
            out.printf("{\"success\": false, \"message\": \"Minimum order value for %s is ₹%.2f.\"}%n", 
                    coupon.getCode(), coupon.getMinOrderAmount());
            return;
        }

        // 5. Calculate discount and final amount
        double discount = (subtotal * coupon.getDiscountPercent()) / 100.0;
        if (discount > coupon.getMaxDiscount()) {
            discount = coupon.getMaxDiscount();
        }

        double finalTotal = subtotal - discount;

        // 6. Return response JSON without storing in persistent session
        out.printf("{\"success\": true, \"message\": \"Coupon %s applied! Saved ₹%.2f\", \"discount\": %.2f, \"finalTotal\": %.2f, \"code\": \"%s\"}%n",
                coupon.getCode(), discount, discount, finalTotal, coupon.getCode());
    }
}