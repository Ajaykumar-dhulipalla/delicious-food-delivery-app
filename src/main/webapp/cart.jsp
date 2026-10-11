<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Order" %>
<%@ page import="com.tap.daoimpl.OrderDaoImpl" %>
<%
    User currentUser = (User) session.getAttribute("user");
    
    // Check for active ongoing order
    Order activeOrder = (Order) request.getAttribute("activeOrder");
    if (activeOrder == null && currentUser != null) {
        try {
            OrderDaoImpl orderDao = new OrderDaoImpl();
            activeOrder = orderDao.getActiveOrderByUserId(currentUser.getUserId());
        } catch (Exception e) {
            // Ignore if unavailable
        }
    }

    // Flash session messages (e.g. out of stock redirect from CheckoutServlet)
    String cartError = (String) session.getAttribute("cartError");
    if (cartError != null) {
        session.removeAttribute("cartError");
    }

    String cartSuccess = (String) session.getAttribute("cartSuccess");
    if (cartSuccess != null) {
        session.removeAttribute("cartSuccess");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f1015;
            color: #f1f2f6;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .navbar {
            max-width: 1000px;
            margin: 0 auto 25px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1c23;
            padding: 15px 25px;
            border-radius: 14px;
            border: 1px solid #2a2e39;
            flex-wrap: wrap;
            gap: 15px;
        }
        .brand {
            font-size: 1.4rem;
            font-weight: 800;
            color: #ff4757;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .nav-links {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }
        .nav-btn {
            text-decoration: none;
            color: #ced6e0;
            font-weight: 600;
            font-size: 0.95rem;
            padding: 8px 16px;
            border-radius: 8px;
            background: #0f1015;
            border: 1px solid #2a2e39;
            transition: 0.25s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .nav-btn:hover {
            color: #2ed573;
            border-color: #2ed573;
        }

        /* Styled Profile Pill (matching home.jsp) */
        .btn-profile {
            background: rgba(112, 161, 255, 0.1);
            color: #70a1ff !important;
            border-color: rgba(112, 161, 255, 0.35);
            font-weight: 700;
        }
        .btn-profile:hover {
            background: rgba(112, 161, 255, 0.2);
            border-color: #70a1ff !important;
            transform: translateY(-1px);
        }

        .logout-btn {
            border-color: #ff4757 !important;
            color: #ff4757 !important;
        }
        .logout-btn:hover {
            background: #ff4757 !important;
            color: #ffffff !important;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }

        /* Stock & Status Alert Banners */
        .alert-banner {
            padding: 14px 18px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.95rem;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }
        .alert-error {
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid #ff4757;
            color: #ff4757;
        }
        .alert-success {
            background: rgba(46, 213, 115, 0.15);
            border: 1px solid #2ed573;
            color: #2ed573;
        }

        .cart-card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.45);
        }
        .cart-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        .cart-table th {
            border-bottom: 1px solid #2a2e39;
            padding: 12px;
            color: #a4b0be;
            font-size: 0.9rem;
            text-transform: uppercase;
        }
        .cart-table td {
            padding: 16px 12px;
            border-bottom: 1px solid #252934;
            vertical-align: middle;
        }
        .item-name {
            font-weight: 700;
            color: #ffffff;
            font-size: 1.05rem;
        }
        .qty-controls {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .qty-btn {
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            width: 30px;
            height: 30px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .qty-btn:hover {
            border-color: #2ed573;
            color: #2ed573;
        }
        .qty-text {
            font-weight: 700;
            min-width: 25px;
            text-align: center;
        }
        .remove-btn {
            background: transparent;
            border: 1px solid #ff4757;
            color: #ff4757;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 600;
        }
        .remove-btn:hover {
            background: #ff4757;
            color: #fff;
        }
        .cart-footer {
            margin-top: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            border-top: 2px dashed #2a2e39;
            padding-top: 20px;
        }
        .grand-total {
            font-size: 1.4rem;
            font-weight: 800;
            color: #ffffff;
        }
        .grand-total span {
            color: #ffa502;
        }
        .checkout-btn {
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            text-decoration: none;
            padding: 14px 28px;
            border-radius: 8px;
            font-size: 1.05rem;
            font-weight: 800;
            transition: 0.25s ease;
            display: inline-block;
        }
        .checkout-btn:hover {
            transform: scale(1.02);
            box-shadow: 0 6px 18px rgba(46, 213, 115, 0.4);
        }
        .empty-cart {
            text-align: center;
            padding: 60px 20px;
        }
        .empty-cart-icon {
            font-size: 3.8rem;
            margin-bottom: 18px;
            display: inline-block;
            filter: drop-shadow(0 4px 12px rgba(255, 71, 87, 0.25));
        }
        .empty-cart h3 {
            color: #f1f2f6;
            font-size: 1.4rem;
            margin: 0 0 10px 0;
            font-weight: 700;
        }
        .empty-cart p {
            color: #a4b0be;
            font-size: 1rem;
            max-width: 420px;
            margin: 0 auto 28px auto;
            line-height: 1.5;
        }
        .explore-btn {
            background: linear-gradient(135deg, #ff4757, #ff6b81);
            color: #ffffff;
            text-decoration: none;
            padding: 13px 30px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 700;
            transition: 0.25s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 14px rgba(255, 71, 87, 0.35);
        }
        .explore-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 71, 87, 0.5);
            color: #ffffff;
        }

        /* Floating Live Order Tracker Pill */
        .order-pill {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: #1a1c23;
            border: 2px solid #2ed573;
            border-radius: 35px;
            padding: 12px 22px;
            display: flex;
            align-items: center;
            gap: 15px;
            box-shadow: 0 10px 28px rgba(0, 0, 0, 0.6);
            z-index: 999;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .order-pill:hover {
            transform: translateY(-3px);
            box-shadow: 0 14px 32px rgba(46, 213, 115, 0.25);
        }
        .pill-status-dot {
            width: 10px;
            height: 10px;
            background: #2ed573;
            border-radius: 50%;
            animation: pulse-dot 1.4s infinite;
        }
        @keyframes pulse-dot {
            0% { transform: scale(0.9); opacity: 1; }
            50% { transform: scale(1.4); opacity: 0.4; }
            100% { transform: scale(0.9); opacity: 1; }
        }
        .pill-content {
            display: flex;
            flex-direction: column;
        }
        .pill-title {
            font-size: 0.88rem;
            font-weight: 800;
            color: #ffffff;
        }
        .pill-desc {
            font-size: 0.78rem;
            color: #a4b0be;
        }
        .pill-btn {
            background: #2ed573;
            color: #000;
            text-decoration: none;
            font-weight: 800;
            font-size: 0.8rem;
            padding: 6px 14px;
            border-radius: 20px;
            transition: 0.2s;
            white-space: nowrap;
        }
        .pill-btn:hover {
            background: #26af5f;
        }

        /* Mobile View Adjustments */
        @media (max-width: 768px) {
            body {
                padding: 12px;
                padding-bottom: 90px;
            }
            .navbar {
                padding: 12px 15px;
                flex-direction: column;
                align-items: stretch;
                margin-bottom: 15px;
            }
            .brand {
                justify-content: center;
            }
            .nav-links {
                justify-content: center;
                gap: 8px;
            }
            .nav-btn {
                padding: 6px 10px;
                font-size: 0.82rem;
            }
            .cart-card {
                padding: 16px;
            }
            .cart-table thead {
                display: none;
            }
            .cart-table, .cart-table tbody, .cart-table tr, .cart-table td {
                display: block;
                width: 100%;
            }
            .cart-table tr {
                border-bottom: 1px solid #2a2e39;
                padding: 14px 0;
            }
            .cart-table tr:last-child {
                border-bottom: none;
            }
            .cart-table td {
                border-bottom: none;
                padding: 6px 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .cart-table td.item-name {
                font-size: 1.15rem;
                margin-bottom: 6px;
            }
            .cart-footer {
                flex-direction: column;
                align-items: stretch;
                text-align: center;
                gap: 15px;
            }
            .checkout-btn {
                width: 100%;
                text-align: center;
                padding: 14px 0;
            }
            .order-pill {
                left: 15px;
                right: 15px;
                bottom: 15px;
                justify-content: space-between;
                padding: 10px 16px;
            }
        }
    </style>
</head>
<body>
    <header class="navbar">
        <a href="home" class="brand">&#127828; Delicious</a>
        <nav class="nav-links">
            <a href="home" class="nav-btn">&#127968; Restaurants</a>
            <a href="orderHistory" class="nav-btn">&#128220; My Orders</a>
            <%
                if (currentUser != null) {
            %>
                <a href="profile.jsp" class="nav-btn btn-profile">👤 <%= currentUser.getUsername() %></a>
                <a href="logout" class="nav-btn logout-btn">Logout</a>
            <%
                } else {
            %>
                <a href="login.jsp" class="nav-btn" style="border-color: #2ed573; color: #2ed573;">Login</a>
                <a href="register.jsp" class="nav-btn">Sign Up</a>
            <%
                }
            %>
        </nav>
    </header>

    <div class="container">
        <!-- Stock / Validation Error Alert -->
        <% if (cartError != null) { %>
            <div class="alert-banner alert-error">
                <span>⚠️</span>
                <span><%= cartError %></span>
            </div>
        <% } %>

        <!-- Cart Success Alert -->
        <% if (cartSuccess != null) { %>
            <div class="alert-banner alert-success">
                <span>✔</span>
                <span><%= cartSuccess %></span>
            </div>
        <% } %>

        <div class="cart-card">
            <%
                Cart cart = (Cart) session.getAttribute("cart");
                if (cart != null && !cart.getItems().isEmpty()) {
            %>
                <table class="cart-table">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Unit Price</th>
                            <th style="text-align: center;">Quantity</th>
                            <th>Subtotal</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (CartItem item : cart.getItems().values()) {
                        %>
                            <tr>
                                <td class="item-name"><%= item.getName() %></td>
                                <td style="color: #ced6e0;"><span>Price:</span> &#8377;<%= item.getPrice() %></td>
                                <td>
                                    <span>Quantity:</span>
                                    <div class="qty-controls">
                                        <!-- Decrease -->
                                        <form action="cart" method="post" style="margin: 0;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="itemId" value="<%= item.getItemId() %>">
                                            <input type="hidden" name="quantity" value="<%= item.getQuantity() - 1 %>">
                                            <button type="submit" class="qty-btn">-</button>
                                        </form>
                                        <span class="qty-text"><%= item.getQuantity() %></span>
                                        <!-- Increase -->
                                        <form action="cart" method="post" style="margin: 0;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="itemId" value="<%= item.getItemId() %>">
                                            <input type="hidden" name="quantity" value="<%= item.getQuantity() + 1 %>">
                                            <button type="submit" class="qty-btn">+</button>
                                        </form>
                                    </div>
                                </td>
                                <td style="color: #ffa502; font-weight: 700;"><span>Subtotal:</span> &#8377;<%= item.getTotalPrice() %></td>
                                <td>
                                    <form action="cart" method="post" style="margin: 0; width: 100%; display: flex; justify-content: flex-end;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="itemId" value="<%= item.getItemId() %>">
                                        <button type="submit" class="remove-btn">Remove</button>
                                    </form>
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>

                <div class="cart-footer">
                    <div class="grand-total">
                        Total Amount: <span>&#8377;<%= cart.getTotalAmount() %></span>
                    </div>
                    <a href="checkout" class="checkout-btn">Proceed to Checkout &rarr;</a>
                </div>
            <%
                } else {
            %>
                <div class="empty-cart">
                    <div class="empty-cart-icon">&#128722;</div>
                    <h3>Your Basket is Empty</h3>
                    <p>Looks like you haven't added any dishes yet. Discover top restaurants and add something delicious!</p>
                    <a href="home" class="explore-btn">&#127828; Explore Restaurants</a>
                </div>
            <%
                }
            %>
        </div>
    </div>

    <!-- Floating Live Order Tracker Pill -->
    <% if (activeOrder != null) { %>
        <div class="order-pill">
            <span class="pill-status-dot"></span>
            <div class="pill-content">
                <span class="pill-title">Order #<%= activeOrder.getOrderId() %></span>
                <span class="pill-desc">Status: <strong style="color: #2ed573;"><%= activeOrder.getStatus() %></strong></span>
            </div>
            <a href="orderDetails?orderId=<%= activeOrder.getOrderId() %>" class="pill-btn">Track Live &rarr;</a>
        </div>
    <% } %>

</body>
</html>