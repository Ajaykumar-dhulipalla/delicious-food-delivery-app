package com.tap.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.MenuDao;
import com.tap.dao.OrderDao;
import com.tap.dao.OrderItemDao;
import com.tap.dao.RatingDao;
import com.tap.daoimpl.MenuDaoImpl;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.daoimpl.OrderItemDaoImpl;
import com.tap.daoimpl.RatingDaoImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Rating;
import com.tap.model.User;

@WebServlet("/adminOrders")
public class AdminOrdersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private OrderItemDao orderItemDao;
    private MenuDao menuDao;
    private RatingDao ratingDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        orderItemDao = new OrderItemDaoImpl();
        menuDao = new MenuDaoImpl();
        ratingDao = new RatingDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        List<Order> orderList = orderDao.getAllOrders();
        Map<Integer, String> menuNameCache = new HashMap<>();
        Map<Integer, String> orderItemSummaries = new HashMap<>();
        Map<String, Integer> dishOrderCounts = new HashMap<>();

        if (orderList != null) {
            for (Order ord : orderList) {
                try {
                    List<OrderItem> items = orderItemDao.getOrderItemsByOrder(ord.getOrderId());
                    if (items != null && !items.isEmpty()) {
                        StringBuilder sb = new StringBuilder();
                        for (int i = 0; i < items.size(); i++) {
                            OrderItem it = items.get(i);
                            int menuId = it.getMenuId();

                            String dishName = menuNameCache.get(menuId);
                            if (dishName == null) {
                                Menu m = menuDao.getMenu(menuId);
                                dishName = (m != null && m.getItemName() != null) ? m.getItemName() : ("Dish #" + menuId);
                                menuNameCache.put(menuId, dishName);
                            }

                            // Calculate quantity from item total or default 1
                            int qty = 1;
                            try {
                                Menu m = menuDao.getMenu(menuId);
                                if (m != null && m.getPrice() > 0) {
                                    qty = Math.max(1, (int) Math.round(it.getTotalAmount() / m.getPrice()));
                                }
                            } catch (Exception ignored) {}

                            // Track sales frequency (skip cancelled orders from sales rank)
                            if (!"Cancelled".equalsIgnoreCase(ord.getStatus())) {
                                dishOrderCounts.put(dishName, dishOrderCounts.getOrDefault(dishName, 0) + qty);
                            }

                            sb.append(dishName);
                            if (i < items.size() - 1) {
                                sb.append(", ");
                            }
                        }
                        orderItemSummaries.put(ord.getOrderId(), sb.toString());
                    } else {
                        orderItemSummaries.put(ord.getOrderId(), "No items listed");
                    }
                } catch (Exception e) {
                    orderItemSummaries.put(ord.getOrderId(), "Items unavailable");
                }
            }
        }

        // Sort Top 3 Dishes by order count
        List<Map.Entry<String, Integer>> topDishesList = new ArrayList<>(dishOrderCounts.entrySet());
        topDishesList.sort((a, b) -> b.getValue().compareTo(a.getValue()));
        if (topDishesList.size() > 3) {
            topDishesList = topDishesList.subList(0, 3);
        }

        // Fetch customer ratings
        Map<Integer, Rating> ratingsMap = new HashMap<>();
        try {
            ratingsMap = ratingDao.getAllRatingsMap();
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("orderList", orderList);
        request.setAttribute("orderItemSummaries", orderItemSummaries);
        request.setAttribute("ratingsMap", ratingsMap);
        request.setAttribute("topDishesList", topDishesList);

        request.getRequestDispatcher("adminOrders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");

        if ("updateStatus".equalsIgnoreCase(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String newStatus = request.getParameter("status");

                if (newStatus != null && !newStatus.trim().isEmpty()) {
                    orderDao.updateOrderStatus(orderId, newStatus.trim());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("adminOrders");
    }
}