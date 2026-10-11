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

import com.tap.dao.MenuDao;
import com.tap.dao.OrderDao;
import com.tap.dao.OrderItemDao;
import com.tap.dao.RestaurantDao;
import com.tap.daoimpl.MenuDaoImpl;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.daoimpl.OrderItemDaoImpl;
import com.tap.daoimpl.RestaurantDaoImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.Restaurant;
import com.tap.model.User;

@WebServlet("/orderDetails")
public class OrderDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private OrderDao orderDao;
    private OrderItemDao orderItemDao;
    private MenuDao menuDao;
    private RestaurantDao restaurantDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        orderItemDao = new OrderItemDaoImpl();
        menuDao = new MenuDaoImpl();
        restaurantDao = new RestaurantDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String orderIdParam = request.getParameter("orderId");
        
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                
                // Fetch primary order details
                Order order = orderDao.getOrder(orderId);
                
                // Fetch associated item records
                List<OrderItem> itemList = orderItemDao.getOrderItemsByOrder(orderId);
                
                // Map menuId to dish name
                Map<Integer, String> itemNames = new HashMap<>();
                if (itemList != null) {
                    for (OrderItem item : itemList) {
                        Menu menu = menuDao.getMenu(item.getMenuId());
                        if (menu != null && menu.getItemName() != null) {
                            itemNames.put(item.getMenuId(), menu.getItemName());
                        } else {
                            itemNames.put(item.getMenuId(), "Item #" + item.getMenuId());
                        }
                    }
                }
                
                // Fetch Restaurant to get its exact delivery time
                Restaurant restaurant = null;
                if (order != null) {
                    try {
                        restaurant = restaurantDao.getRestaurant(order.getRestaurantId());
                    } catch (Exception e) {
                        System.err.println("--> [OrderDetailsServlet] Could not fetch restaurant: " + e.getMessage());
                    }
                }
                
                request.setAttribute("order", order);
                request.setAttribute("itemList", itemList);
                request.setAttribute("itemNames", itemNames);
                request.setAttribute("restaurant", restaurant);
                
                request.getRequestDispatcher("orderDetails.jsp").forward(request, response);
                return;
            } catch (NumberFormatException e) {
                System.err.println("--> [OrderDetailsServlet] Invalid order ID format: " + orderIdParam);
            } catch (Exception e) {
                System.err.println("--> [OrderDetailsServlet] Error fetching order receipt: " + e.getMessage());
            }
        }
        
        response.sendRedirect("orderHistory");
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

        String action = request.getParameter("action");
        String orderIdParam = request.getParameter("orderId");

        if ("cancelOrder".equalsIgnoreCase(action) && orderIdParam != null) {
            try {
                int orderId = Integer.parseInt(orderIdParam.trim());
                Order order = orderDao.getOrder(orderId);

                // Security check: Only allow cancellation if order belongs to user and is still 'Placed'
                if (order != null && order.getUserId() == currentUser.getUserId()) {
                    if ("Placed".equalsIgnoreCase(order.getStatus())) {
                        orderDao.updateOrderStatus(orderId, "Cancelled");
                    }
                }
                response.sendRedirect("orderDetails?orderId=" + orderId);
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        doGet(request, response);
    }
}