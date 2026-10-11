package com.tap.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.dao.UserDao;
import com.tap.daoimpl.UserDaoImpl;
import com.tap.model.User;

@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDaoImpl();
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

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Verify current password matches active account session
        if (currentPassword == null || !currentPassword.equals(currentUser.getPassword())) {
            session.setAttribute("pwdError", "Current password does not match!");
            response.sendRedirect("profile.jsp");
            return;
        }

        // 2. Validate new password and confirmation match
        if (newPassword == null || newPassword.trim().isEmpty() || !newPassword.equals(confirmPassword)) {
            session.setAttribute("pwdError", "New password and confirmation do not match!");
            response.sendRedirect("profile.jsp");
            return;
        }

        // 3. Update password on model and save via userDao.updateUser()
        currentUser.setPassword(newPassword);
        int rowsUpdated = userDao.updateUser(currentUser);

        if (rowsUpdated > 0) {
            session.setAttribute("user", currentUser);
            session.setAttribute("pwdSuccess", "Password updated successfully!");
        } else {
            session.setAttribute("pwdError", "Failed to update password. Please try again.");
        }

        response.sendRedirect("profile.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("profile.jsp");
    }
}