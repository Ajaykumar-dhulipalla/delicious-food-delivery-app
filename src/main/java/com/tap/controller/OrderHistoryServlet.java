package com.tap.controller;

import java.io.IOException;
import java.util.ArrayList;
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
import com.tap.model.Cart;
import com.tap.model.CartItem;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Rating;
import com.tap.model.User;

@WebServlet("/orderHistory")
public class OrderHistoryServlet extends HttpServlet {
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

        HttpSession session = request.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Guard check: Redirect to login if user is not authenticated
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = user.getUserId();
        String action = request.getParameter("action");
        String orderIdStr = request.getParameter("orderId");

        // 1. Handle Reorder action
        if ("reorder".equalsIgnoreCase(action) && orderIdStr != null && !orderIdStr.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr.trim());
                List<OrderItem> items = orderItemDao.getOrderItemsByOrder(orderId);

                Cart cart = (Cart) session.getAttribute("cart");
                if (cart == null) {
                    cart = new Cart();
                    session.setAttribute("cart", cart);
                }

                if (items != null) {
                    for (OrderItem orderItem : items) {
                        Menu menu = menuDao.getMenu(orderItem.getMenuId());
                        if (menu != null) {
                            int qty = 1;
                            if (menu.getPrice() > 0) {
                                qty = Math.max(1, (int) Math.round(orderItem.getTotalAmount() / menu.getPrice()));
                            }
                            CartItem cartItem = new CartItem(
                                menu.getMenuId(),
                                menu.getRestaurantId(),
                                menu.getItemName(),
                                menu.getPrice(),
                                qty
                            );
                            cart.addItem(cartItem);
                        }
                    }
                }
                response.sendRedirect("cart.jsp");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 2. Handle Cancellation action
        if ("cancel".equalsIgnoreCase(action) && orderIdStr != null && !orderIdStr.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr.trim());
                orderDao.updateOrderStatus(orderId, "Cancelled");
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect("orderHistory");
            return;
        }

        // 3. Fetch user's orders and dish items
        List<Order> orderList = orderDao.getOrdersByUser(userId);
        
        // Map: orderId -> List of Menu items
        Map<Integer, List<Menu>> orderMenusMap = new HashMap<>();

        if (orderList != null) {
            for (Order o : orderList) {
                List<OrderItem> oItems = orderItemDao.getOrderItemsByOrder(o.getOrderId());
                List<Menu> menusForThisOrder = new ArrayList<>();
                if (oItems != null) {
                    for (OrderItem oi : oItems) {
                        Menu m = menuDao.getMenu(oi.getMenuId());
                        if (m != null) {
                            menusForThisOrder.add(m);
                        }
                    }
                }
                orderMenusMap.put(o.getOrderId(), menusForThisOrder);
            }
        }

        // 4. Fetch ratings lookup map
        Map<Integer, Rating> ratingsMap = new HashMap<>();
        try {
            ratingsMap = ratingDao.getAllRatingsMap();
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("orderList", orderList);
        request.setAttribute("orderMenusMap", orderMenusMap);
        request.setAttribute("ratingsMap", ratingsMap);

        request.getRequestDispatcher("orderHistory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}