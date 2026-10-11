package com.tap.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.OrderDao;
import com.tap.dao.RestaurantDao;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.daoimpl.RestaurantDaoImpl;
import com.tap.model.Order;
import com.tap.model.Restaurant;
import com.tap.model.User;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private RestaurantDao restaurantDao;
    private OrderDao orderDao;

    @Override
    public void init() {
        restaurantDao = new RestaurantDaoImpl();
        orderDao = new OrderDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 1. Fetch active order for bottom floating tracker pill
        if (user != null) {
            try {
                Order activeOrder = orderDao.getActiveOrderByUserId(user.getUserId());
                request.setAttribute("activeOrder", activeOrder);
            } catch (Exception e) {
                System.err.println("--> [HomeServlet] Could not fetch active order: " + e.getMessage());
            }
        }

        // 2. Fetch all restaurants and aggregate live review counts
        List<Restaurant> restaurantList = restaurantDao.getAllRestaurants();
        Map<Integer, Integer> reviewCountMap = new HashMap<>();

        if (restaurantList != null) {
            for (Restaurant r : restaurantList) {
                try {
                    int count = restaurantDao.getReviewCount(r.getRestaurantId());
                    reviewCountMap.put(r.getRestaurantId(), count);
                } catch (Exception e) {
                    reviewCountMap.put(r.getRestaurantId(), 0);
                }
            }
        }

        request.setAttribute("restaurantList", restaurantList);
        request.setAttribute("reviewCountMap", reviewCountMap);

        request.getRequestDispatcher("home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}