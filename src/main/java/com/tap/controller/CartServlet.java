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
import com.tap.daoimpl.MenuDaoImpl;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.model.Cart;
import com.tap.model.CartItem;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.User;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private MenuDao menuDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        menuDao = new MenuDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Fetch active order for floating tracker pill
        if (user != null) {
            try {
                Order activeOrder = orderDao.getActiveOrderByUserId(user.getUserId());
                request.setAttribute("activeOrder", activeOrder);
            } catch (Exception e) {
                System.err.println("--> [CartServlet] Could not fetch active order: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");

        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }

        String action = request.getParameter("action");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"))
                || "fetch".equalsIgnoreCase(request.getHeader("Sec-Fetch-Mode"));

        try {
            if ("add".equals(action)) {
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                int restaurantId = Integer.parseInt(request.getParameter("restaurantId"));
                String name = request.getParameter("name");
                double price = Double.parseDouble(request.getParameter("price"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));

                // Backend Stock Guard: Check if the dish is currently available
                Menu menuItem = menuDao.getMenu(itemId);
                if (menuItem != null && !menuItem.getIsAvailable()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("Sorry, \"" + name + "\" is currently out of stock.");
                    return;
                }

                CartItem item = new CartItem(itemId, restaurantId, name, price, quantity);
                cart.addItem(item);

            } else if ("update".equals(action)) {
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));

                // If incrementing quantity, ensure the item is still available
                if (quantity > 0) {
                    Menu menuItem = menuDao.getMenu(itemId);
                    if (menuItem != null && !menuItem.getIsAvailable()) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("This item has just gone out of stock.");
                        return;
                    }
                    cart.updateItem(itemId, quantity);
                } else {
                    cart.removeItem(itemId);
                }

            } else if ("delete".equals(action)) {
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                cart.removeItem(itemId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        // Return clean HTTP 200 OK for AJAX requests (from menu.jsp fetch)
        if (isAjax) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        String referer = request.getHeader("referer");
        if (referer != null && !referer.isEmpty() && !referer.contains("cart")) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("cart");
        }
    }
}