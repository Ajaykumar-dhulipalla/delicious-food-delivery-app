package com.tap.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.MenuDao;
import com.tap.dao.OrderDao;
import com.tap.dao.RestaurantDao;
import com.tap.daoimpl.MenuDaoImpl;
import com.tap.daoimpl.OrderDaoImpl;
import com.tap.daoimpl.RestaurantDaoImpl;
import com.tap.model.Menu;
import com.tap.model.Order;
import com.tap.model.Restaurant;
import com.tap.model.User;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private MenuDao menuDao;
    private RestaurantDao restaurantDao;
    private OrderDao orderDao;

    @Override
    public void init() {
        menuDao = new MenuDaoImpl();
        restaurantDao = new RestaurantDaoImpl();
        orderDao = new OrderDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String restaurantIdParam = request.getParameter("restaurantId");

        if (restaurantIdParam != null && !restaurantIdParam.trim().isEmpty()) {
            try {
                int restaurantId = Integer.parseInt(restaurantIdParam);

                // Fetch restaurant details
                Restaurant restaurant = restaurantDao.getRestaurant(restaurantId);

                if (restaurant != null) {
                    // Fetch dynamic average rating & review count from order_ratings
                    double liveAvgRating = restaurantDao.getAverageRating(restaurantId);
                    int reviewCount = restaurantDao.getReviewCount(restaurantId);

                    // Update the restaurant object's rating with live score
                    restaurant.setRating(liveAvgRating);
                    request.setAttribute("reviewCount", reviewCount);
                }

                // Fetch dishes for this restaurant
                List<Menu> menuList = menuDao.getAllMenusByRestaurant(restaurantId);

                request.setAttribute("restaurant", restaurant);
                request.setAttribute("menuList", menuList);
                request.setAttribute("restaurantId", restaurantId);

            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // Fetch active order for floating tracker pill if user is logged in
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user != null) {
            Order activeOrder = orderDao.getActiveOrderByUserId(user.getUserId());
            if (activeOrder != null) {
                request.setAttribute("activeOrder", activeOrder);
            }
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("menu.jsp");
        dispatcher.forward(request, response);
    }
}