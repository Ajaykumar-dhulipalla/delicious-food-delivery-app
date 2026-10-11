package com.tap.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.MenuDao;
import com.tap.dao.OrderDao;
import com.tap.dao.OrderItemDao;
import com.tap.daoimpl.MenuDaoImpl;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.daoimpl.OrderItemDaoImpl;
import com.tap.model.Cart;
import com.tap.model.CartItem;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.OrderItem;
import com.tap.model.User;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private OrderItemDao orderItemDao;
    private MenuDao menuDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        orderItemDao = new OrderItemDaoImpl();
        menuDao = new MenuDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // 1. Session Expiry & Auth Guard
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Empty Cart Guard: Prevent accessing checkout without items
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
            response.sendRedirect("cart.jsp");
            return;
        }

        // 3. Clear leftover coupon state so checkout loads fresh
        session.removeAttribute("appliedCoupon");
        session.removeAttribute("discountAmount");
        session.removeAttribute("discountedGrandTotal");

        response.sendRedirect("checkout.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 1. Guard check: Redirect to login if unauthenticated or session expired
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Cart cart = (Cart) session.getAttribute("cart");

        if (cart != null && !cart.getItems().isEmpty()) {

            // 2. Pre-checkout Stock & Availability Database Verification
            for (CartItem item : cart.getItems().values()) {
                Menu liveMenu = menuDao.getMenu(item.getItemId());
                if (liveMenu == null || !liveMenu.getIsAvailable()) {
                    String dishName = (liveMenu != null) ? liveMenu.getItemName() : item.getName();
                    session.setAttribute("cartError", "Sorry! \"" + dishName + "\" just went out of stock and is no longer available.");
                    response.sendRedirect("cart.jsp");
                    return;
                }
            }

            String address = request.getParameter("deliveryAddress");
            String specialInstructions = request.getParameter("specialInstructions");
            String phone = request.getParameter("phone");
            String paymentMode = request.getParameter("paymentMode");

            // Combine address with special notes if present
            if (specialInstructions != null && !specialInstructions.trim().isEmpty()) {
                if (address != null && !address.contains("[Note:")) {
                    address = address.trim() + " [Note: " + specialInstructions.trim() + "]";
                }
            }

            // 3. Read final amount safely from form submission (includes discounts + tips)
            String finalAmountStr = request.getParameter("finalAmount");
            double totalAmount;

            if (finalAmountStr != null && !finalAmountStr.trim().isEmpty()) {
                try {
                    totalAmount = Double.parseDouble(finalAmountStr);
                } catch (NumberFormatException e) {
                    totalAmount = cart.getTotalAmount();
                }
            } else {
                totalAmount = cart.getTotalAmount();
            }

            int userId = user.getUserId();
            int restaurantId = cart.getItems().values().iterator().next().getRestaurantId();

            // 4. Persist the main Order record with the exact address and total
            Order order = new Order();
            order.setUserId(userId);
            order.setRestaurantId(restaurantId);
            order.setTotalAmount(totalAmount);
            order.setStatus("Placed");
            order.setPaymentMode(paymentMode);
            order.setAddress(address);

            int orderId = orderDao.addOrder(order);

            // 5. Persist individual order items
            if (orderId > 0) {
                for (CartItem item : cart.getItems().values()) {
                    OrderItem orderItem = new OrderItem();
                    orderItem.setOrderId(orderId);
                    orderItem.setMenuId(item.getItemId());
                    orderItem.setTotalAmount(item.getTotalPrice());

                    orderItemDao.addOrderItem(orderItem);
                }
            }

            // 6. Set attributes for confirmation screen
            request.setAttribute("orderId", orderId);
            request.setAttribute("orderAmount", totalAmount);
            request.setAttribute("deliveryAddress", address);
            request.setAttribute("phone", phone);
            request.setAttribute("paymentMode", paymentMode);

            // 7. Clear cart and session attributes
            session.removeAttribute("cart");
            session.removeAttribute("appliedCoupon");
            session.removeAttribute("discountAmount");
            session.removeAttribute("discountedGrandTotal");

            // 8. Forward to confirmation
            request.getRequestDispatcher("orderConfirmation.jsp").forward(request, response);
        } else {
            response.sendRedirect("cart.jsp");
        }
    }
}