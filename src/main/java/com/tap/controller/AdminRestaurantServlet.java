package com.tap.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.RestaurantDao;
import com.tap.daoimpl.RestaurantDaoImpl;
import com.tap.model.Restaurant;
import com.tap.model.User;

@WebServlet("/adminRestaurant")
public class AdminRestaurantServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private RestaurantDao restaurantDao;

    @Override
    public void init() {
        restaurantDao = new RestaurantDaoImpl();
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

        List<Restaurant> restaurantList = restaurantDao.getAllRestaurants();
        request.setAttribute("restaurantList", restaurantList);
        request.getRequestDispatcher("adminRestaurants.jsp").forward(request, response);
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

        try {
            if ("add".equalsIgnoreCase(action)) {
                Restaurant r = new Restaurant();
                r.setName(request.getParameter("name"));
                r.setCuisineType(request.getParameter("cuisineType"));
                r.setDeliveryTime(Integer.parseInt(request.getParameter("deliveryTime")));
                r.setAddress(request.getParameter("address"));
                r.setRating(Double.parseDouble(request.getParameter("rating")));
                r.setIsActive("true".equalsIgnoreCase(request.getParameter("isActive")));
                r.setImagePath(request.getParameter("imagePath"));
                r.setAdminUserId(user.getUserId());

                restaurantDao.addRestaurant(r);

            } else if ("update".equalsIgnoreCase(action)) {
                int restaurantId = Integer.parseInt(request.getParameter("restaurantId"));
                Restaurant r = restaurantDao.getRestaurant(restaurantId);

                if (r != null) {
                    r.setName(request.getParameter("name"));
                    r.setCuisineType(request.getParameter("cuisineType"));
                    r.setDeliveryTime(Integer.parseInt(request.getParameter("deliveryTime")));
                    r.setAddress(request.getParameter("address"));
                    r.setRating(Double.parseDouble(request.getParameter("rating")));
                    r.setIsActive("true".equalsIgnoreCase(request.getParameter("isActive")));
                    r.setImagePath(request.getParameter("imagePath"));
                    
                    // Keep the existing owner ID intact
                    if (r.getAdminUserId() == 0) {
                        r.setAdminUserId(user.getUserId());
                    }

                    restaurantDao.updateRestaurant(r);
                }
            } else if ("delete".equalsIgnoreCase(action)) {
                int restaurantId = Integer.parseInt(request.getParameter("restaurantId"));
                restaurantDao.deleteRestaurant(restaurantId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("adminRestaurant");
    }
}