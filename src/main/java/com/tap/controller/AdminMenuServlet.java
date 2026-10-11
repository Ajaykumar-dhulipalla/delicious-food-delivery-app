package com.tap.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.MenuDao;
import com.tap.dao.RestaurantDao;
import com.tap.daoimpl.MenuDaoImpl;
import com.tap.daoimpl.RestaurantDaoImpl;
import com.tap.model.Menu;
import com.tap.model.Restaurant;
import com.tap.model.User;

@WebServlet("/adminMenu")
public class AdminMenuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private MenuDao menuDao;
    private RestaurantDao restaurantDao;

    @Override
    public void init() {
        menuDao = new MenuDaoImpl();
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

        String restIdParam = request.getParameter("restaurantId");
        int selectedRestaurantId = 0;

        if (restIdParam != null && !restIdParam.trim().isEmpty()) {
            try {
                selectedRestaurantId = Integer.parseInt(restIdParam.trim());
            } catch (NumberFormatException e) {
                selectedRestaurantId = 0;
            }
        } else if (restaurantList != null && !restaurantList.isEmpty()) {
            selectedRestaurantId = restaurantList.get(0).getRestaurantId();
        }

        List<Menu> menuList = null;
        if (selectedRestaurantId > 0) {
            menuList = menuDao.getAllMenusByRestaurant(selectedRestaurantId);
        }

        request.setAttribute("selectedRestaurantId", selectedRestaurantId);
        request.setAttribute("menuList", menuList);
        request.getRequestDispatcher("adminMenu.jsp").forward(request, response);
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
        int restaurantId = 0;

        try {
            restaurantId = Integer.parseInt(request.getParameter("restaurantId"));

            if ("toggleAvailability".equalsIgnoreCase(action)) {
                int menuId = Integer.parseInt(request.getParameter("menuId"));
                Menu item = menuDao.getMenu(menuId);
                if (item != null) {
                    item.setIsAvailable(!item.getIsAvailable());
                    menuDao.updateMenu(item);
                }

            } else if ("add".equalsIgnoreCase(action)) {
                Menu item = new Menu();
                item.setRestaurantId(restaurantId);
                item.setItemName(request.getParameter("itemName"));
                item.setDescription(request.getParameter("description"));
                item.setPrice(Double.parseDouble(request.getParameter("price")));
                item.setIsAvailable("true".equalsIgnoreCase(request.getParameter("isAvailable")));
                item.setImagePath(request.getParameter("imagePath"));

                menuDao.addMenu(item);

            } else if ("update".equalsIgnoreCase(action)) {
                int menuId = Integer.parseInt(request.getParameter("menuId"));
                Menu item = menuDao.getMenu(menuId);

                if (item != null) {
                    item.setItemName(request.getParameter("itemName"));
                    item.setDescription(request.getParameter("description"));
                    item.setPrice(Double.parseDouble(request.getParameter("price")));
                    item.setIsAvailable("true".equalsIgnoreCase(request.getParameter("isAvailable")));
                    item.setImagePath(request.getParameter("imagePath"));

                    menuDao.updateMenu(item);
                }

            } else if ("delete".equalsIgnoreCase(action)) {
                int menuId = Integer.parseInt(request.getParameter("menuId"));
                menuDao.deleteMenu(menuId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("adminMenu?restaurantId=" + restaurantId);
    }
}