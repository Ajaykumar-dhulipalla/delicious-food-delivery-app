package com.tap.controller;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.OrderDao;
import com.tap.dao.RatingDao;
import com.tap.dao.RestaurantDao;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.daoimpl.RatingDaoImpl;
import com.tap.daoimpl.RestaurantDaoImpl;
import com.tap.model.Order;
import com.tap.model.Rating;
import com.tap.model.User;

@WebServlet("/submitRating")
public class SubmitRatingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private RatingDao ratingDao;
    private OrderDao orderDao;
    private RestaurantDao restaurantDao;

    @Override
    public void init() {
        ratingDao = new RatingDaoImpl();
        orderDao = new OrderDaoImpl();
        restaurantDao = new RestaurantDaoImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 1. Guard check: Require authentication
        if (user == null) {
            out.print("{\"success\": false, \"message\": \"User not authenticated.\"}");
            out.flush();
            return;
        }

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            int ratingVal = Integer.parseInt(request.getParameter("rating"));
            String tags = request.getParameter("tags");
            String comment = request.getParameter("comment");

            if (tags == null) tags = "";
            if (comment == null) comment = "";

            // 2. Check if this order was already rated to prevent duplicate inserts
            Rating existingRating = ratingDao.getRatingByOrderId(orderId);
            if (existingRating != null) {
                out.print("{\"success\": false, \"message\": \"This order has already been rated.\"}");
                out.flush();
                return;
            }

            // 3. Persist new rating to MySQL
            Rating rating = new Rating(orderId, user.getUserId(), ratingVal, tags.trim(), comment.trim());
            boolean isSaved = ratingDao.addRating(rating);

            if (isSaved) {
                // 4. Recalculate and synchronize restaurant's average rating
                try {
                    Order order = orderDao.getOrder(orderId);
                    if (order != null && order.getRestaurantId() > 0) {
                        restaurantDao.syncRestaurantAverageRating(order.getRestaurantId());
                    }
                } catch (Exception syncEx) {
                    System.err.println("--> [SubmitRatingServlet] Could not sync restaurant rating: " + syncEx.getMessage());
                }

                out.print("{\"success\": true, \"message\": \"Rating submitted successfully!\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Database error saving rating.\"}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"Invalid input data format.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
        out.flush();
    }
}