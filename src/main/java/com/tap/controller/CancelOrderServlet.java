package com.tap.controller;

import java.io.IOException;

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

@WebServlet("/cancelOrder")
public class CancelOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String orderIdStr = request.getParameter("orderId");

        if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr.trim());
                Order order = orderDao.getOrder(orderId);

                // Security check: order must belong to this user (unless admin)
                if (order != null && (order.getUserId() == currentUser.getUserId() || "admin".equalsIgnoreCase(currentUser.getRole()))) {
                    String status = order.getStatus();
                    
                    // Only allow cancellation if order hasn't progressed past Pending/Placed
                    if ("Pending".equalsIgnoreCase(status) || "Placed".equalsIgnoreCase(status)) {
                        orderDao.updateOrderStatus(orderId, "Cancelled");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("orderHistory");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("orderHistory");
    }
}