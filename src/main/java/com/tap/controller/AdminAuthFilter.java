package com.tap.controller;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.model.User;

@WebFilter("/*")
public class AdminAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 1. Prevent direct browser access to raw JSP files (force them through Servlets)
        if (uri.endsWith("adminOrders.jsp") || uri.endsWith("adminRestaurants.jsp") || uri.endsWith("adminMenu.jsp")) {
            response.sendRedirect(request.getContextPath() + "/adminOrders");
            return;
        }

        if (uri.endsWith("home.jsp")) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 2. Protect Admin Servlets & Endpoints
        if (uri.contains("/adminOrders") || uri.contains("/adminRestaurant") || uri.contains("/adminMenu")) {
            if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
                return;
            }
        }

        // 3. Protect Customer Checkout, Profile, and Orders
        if (uri.contains("/checkout") || uri.contains("/orderHistory") || uri.endsWith("checkout.jsp") || uri.endsWith("profile.jsp")) {
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=login_required");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}