package com.tap.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.OrderDao;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.model.Order;
import com.tap.model.User;

@WebServlet("/checkLatestOrder")
public class AdminNotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDao orderDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Allow only logged-in administrators
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"latestOrderId\": 0}");
            return;
        }

        int latestOrderId = 0;

        try {
            // Use your project's OrderDaoImpl to get the orders
            List<Order> orders = orderDao.getAllOrders();
            if (orders != null && !orders.isEmpty()) {
                for (Order o : orders) {
                    if (o.getOrderId() > latestOrderId) {
                        latestOrderId = o.getOrderId();
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[checkLatestOrder] Error fetching latest order: " + e.getMessage());
        }

        response.getWriter().write("{\"latestOrderId\":" + latestOrderId + "}");
    }
}