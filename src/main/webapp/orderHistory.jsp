<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.model.Order" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Rating" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Order> orderList = (List<Order>) request.getAttribute("orderList");

    @SuppressWarnings("unchecked")
    Map<Integer, List<Menu>> orderMenusMap = (Map<Integer, List<Menu>>) request.getAttribute("orderMenusMap");

    @SuppressWarnings("unchecked")
    Map<Integer, Rating> ratingsMap = (Map<Integer, Rating>) request.getAttribute("ratingsMap");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f1015; color: #f1f2f6; padding: 25px; min-height: 100vh; }

        .navbar {
            max-width: 1180px;
            margin: 0 auto 25px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1c23;
            padding: 16px 28px;
            border-radius: 14px;
            border: 1px solid #2a2e39;
            flex-wrap: wrap;
            gap: 12px;
        }
        .brand { font-size: 1.5rem; font-weight: 800; color: #ff4757; text-decoration: none; }
        .nav-links { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
        .nav-btn {
            text-decoration: none;
            color: #ced6e0;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            background: #252834;
            border: 1px solid #2a2e39;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .nav-btn:hover { color: #ffa502; border-color: #ffa502; }

        /* Styled Profile Pill (matching home.jsp, cart.jsp, profile.jsp) */
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

        .btn-logout { border-color: #ff4757; color: #ff4757; }
        .btn-logout:hover { background: #ff4757; color: #fff; }

        .container {
            max-width: 1180px;
            margin: 0 auto;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        h2 { font-size: 1.6rem; font-weight: 800; margin-bottom: 25px; }

        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th {
            background-color: #14161d;
            color: #a4b0be;
            font-size: 0.85rem;
            text-transform: uppercase;
            padding: 16px 14px;
            border-bottom: 2px solid #2a2e39;
        }
        td {
            padding: 16px 14px;
            border-bottom: 1px solid #2a2e39;
            font-size: 0.95rem;
            vertical-align: middle;
        }
        tr:hover { background-color: #21242d; }

        .order-id { font-weight: 800; color: #ffa502; }
        .price { color: #2ed573; font-weight: 800; }
        
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 700;
            white-space: nowrap;
        }
        .badge-placed { background: rgba(46, 213, 115, 0.15); color: #2ed573; border: 1px solid #2ed573; }
        .badge-preparing { background: rgba(255, 165, 2, 0.15); color: #ffa502; border: 1px solid #ffa502; }
        .badge-onway { background: rgba(112, 161, 255, 0.15); color: #70a1ff; border: 1px solid #70a1ff; }
        .badge-delivered { background: rgba(46, 213, 115, 0.25); color: #2ed573; border: 1px solid #2ed573; font-weight: 800; }
        .badge-cancelled { background: rgba(255, 71, 87, 0.15); color: #ff4757; border: 1px solid #ff4757; }

        .items-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
            max-width: 260px;
        }
        .dish-entry {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #14161d;
            padding: 6px 10px;
            border-radius: 8px;
            border: 1px solid #252834;
        }
        .dish-thumb {
            width: 40px;
            height: 40px;
            border-radius: 6px;
            object-fit: cover;
            border: 1px solid #2a2e39;
            background: #0f1015;
            flex-shrink: 0;
        }
        .thumb-fallback {
            width: 40px;
            height: 40px;
            border-radius: 6px;
            background: #252834;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            border: 1px solid #2a2e39;
            flex-shrink: 0;
        }
        .dish-name {
            font-size: 0.9rem;
            font-weight: 600;
            color: #f1f2f6;
            line-height: 1.3;
            word-break: break-word;
        }

        .action-cell {
            display: flex;
            flex-direction: column;
            gap: 6px;
            min-width: 170px;
        }
        .btn-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 6px;
        }
        .btn-track {
            background: linear-gradient(135deg, #70a1ff, #1e90ff);
            color: #000;
            text-decoration: none;
            padding: 7px 10px;
            border-radius: 6px;
            font-weight: 800;
            font-size: 0.82rem;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            transition: 0.2s;
        }
        .btn-track:hover {
            transform: scale(1.03);
            box-shadow: 0 4px 12px rgba(112, 161, 255, 0.4);
        }

        .btn-rate {
            background: rgba(255, 165, 2, 0.15);
            border: 1px solid #ffa502;
            color: #ffa502;
            text-decoration: none;
            padding: 7px 10px;
            border-radius: 6px;
            font-weight: 800;
            font-size: 0.82rem;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            transition: 0.2s;
        }
        .btn-rate:hover {
            background: #ffa502;
            color: #000;
            box-shadow: 0 4px 12px rgba(255, 165, 2, 0.4);
        }

        /* Already Rated Badge Indicator */
        .badge-rated {
            background: rgba(46, 213, 115, 0.1);
            border: 1px solid rgba(46, 213, 115, 0.3);
            color: #2ed573;
            padding: 6px 10px;
            border-radius: 6px;
            font-weight: 800;
            font-size: 0.8rem;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }

        .btn-view {
            background: #252834;
            color: #f1f2f6;
            text-decoration: none;
            padding: 7px 10px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.82rem;
            border: 1px solid #2a2e39;
            transition: 0.2s;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }
        .btn-view:hover { background: #343a40; color: #ffa502; }

        .btn-reorder {
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            text-decoration: none;
            padding: 7px 10px;
            border-radius: 6px;
            font-weight: 800;
            font-size: 0.82rem;
            border: none;
            transition: 0.2s ease;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }
        .btn-reorder:hover {
            transform: scale(1.03);
            box-shadow: 0 4px 12px rgba(46, 213, 115, 0.4);
        }

        .cancel-form {
            margin: 0;
            width: 100%;
        }
        .btn-cancel {
            width: 100%;
            background: transparent;
            color: #ff4757;
            border: 1px solid #ff4757;
            padding: 6px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 0.8rem;
            cursor: pointer;
            transition: 0.2s;
            text-align: center;
        }
        .btn-cancel:hover { background: #ff4757; color: #fff; }

        .empty-history {
            text-align: center;
            padding: 60px 20px;
        }
        .empty-icon {
            font-size: 3.8rem;
            margin-bottom: 18px;
            display: inline-block;
            filter: drop-shadow(0 4px 12px rgba(255, 165, 2, 0.25));
        }
        .empty-history h3 {
            color: #f1f2f6;
            font-size: 1.4rem;
            margin: 0 0 10px 0;
            font-weight: 700;
        }
        .empty-history p {
            color: #a4b0be;
            font-size: 1rem;
            max-width: 440px;
            margin: 0 auto 28px auto;
            line-height: 1.5;
        }
        .explore-btn {
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            text-decoration: none;
            padding: 13px 30px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 800;
            transition: 0.25s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 14px rgba(46, 213, 115, 0.35);
        }
        .explore-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(46, 213, 115, 0.5);
            color: #000;
        }

        .mobile-label { display: none; }

        @media (max-width: 768px) {
            body { padding: 12px; }
            .navbar {
                padding: 12px 16px;
                flex-direction: column;
                align-items: stretch;
                margin-bottom: 16px;
                gap: 12px;
            }
            .brand { justify-content: center; text-align: center; }
            .nav-links { justify-content: center; flex-wrap: wrap; gap: 8px; }
            .nav-btn { padding: 6px 12px; font-size: 0.82rem; }

            .container {
                padding: 16px;
                border-radius: 14px;
            }
            h2 { font-size: 1.35rem; margin-bottom: 16px; text-align: center; }

            table thead { display: none; }
            table, tbody, tr, td {
                display: block;
                width: 100%;
            }
            tr {
                background: #14161d;
                border: 1px solid #2a2e39;
                border-radius: 12px;
                margin-bottom: 16px;
                padding: 14px 16px;
            }
            tr:hover { background-color: #14161d; }
            td {
                border-bottom: 1px dashed #222530;
                padding: 10px 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-size: 0.9rem;
            }
            td:last-child {
                border-bottom: none;
                padding-top: 14px;
                display: block;
            }
            .mobile-label {
                display: inline-block;
                color: #a4b0be;
                font-weight: 600;
                font-size: 0.82rem;
                text-transform: uppercase;
            }
            .items-list {
                max-width: 65%;
                align-items: flex-end;
            }
            .dish-entry {
                width: 100%;
                justify-content: flex-end;
            }
            .dish-name {
                text-align: right;
                font-size: 0.85rem;
            }
            .action-cell {
                display: flex;
                flex-direction: column;
                gap: 8px;
                width: 100%;
                min-width: unset;
            }
            .btn-row {
                grid-template-columns: 1fr;
                gap: 8px;
            }
            .btn-track, .btn-rate, .badge-rated, .btn-reorder, .btn-view, .btn-cancel {
                width: 100%;
                text-align: center;
                justify-content: center;
                padding: 11px 0;
                font-size: 0.9rem;
            }
        }
    </style>
</head>
<body>
    <header class="navbar">
        <a href="home" class="brand">&#127828; Delicious</a>
        <nav class="nav-links">
            <a href="home" class="nav-btn">&#127968; Home</a>
            <a href="cart.jsp" class="nav-btn">&#128722; Cart</a>
            <a href="profile.jsp" class="nav-btn btn-profile">👤 <%= currentUser.getUsername() %></a>
            <a href="logout" class="nav-btn btn-logout">Logout</a>
        </nav>
    </header>

    <main class="container">
        <h2>&#128221; My Order History</h2>

        <% if (orderList != null && !orderList.isEmpty()) { %>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Items & Dishes</th>
                            <th>Date</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th style="text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Order o : orderList) {
                                String status = (o.getStatus() != null) ? o.getStatus().trim() : "Placed";
                                
                                String badgeClass = "badge-placed";
                                boolean isDelivered = "Delivered".equalsIgnoreCase(status);
                                boolean isCancelled = "Cancelled".equalsIgnoreCase(status);
                                boolean isOngoing = "Placed".equalsIgnoreCase(status) 
                                                 || "Preparing".equalsIgnoreCase(status) 
                                                 || "Out for Delivery".equalsIgnoreCase(status) 
                                                 || "On the Way".equalsIgnoreCase(status);

                                if ("Preparing".equalsIgnoreCase(status)) {
                                    badgeClass = "badge-preparing";
                                } else if ("Out for Delivery".equalsIgnoreCase(status) || "On the Way".equalsIgnoreCase(status)) {
                                    badgeClass = "badge-onway";
                                } else if (isDelivered) {
                                    badgeClass = "badge-delivered";
                                } else if (isCancelled) {
                                    badgeClass = "badge-cancelled";
                                }

                                List<Menu> dishes = (orderMenusMap != null) ? orderMenusMap.get(o.getOrderId()) : null;
                                Rating existingRating = (ratingsMap != null) ? ratingsMap.get(o.getOrderId()) : null;
                        %>
                                <tr>
                                    <td>
                                        <span class="mobile-label">Order ID</span>
                                        <span class="order-id">#<%= o.getOrderId() %></span>
                                    </td>
                                    <td>
                                        <span class="mobile-label">Dishes</span>
                                        <div class="items-list">
                                            <% 
                                                if (dishes != null && !dishes.isEmpty()) {
                                                    for (Menu m : dishes) {
                                                        String img = m.getImagePath();
                                            %>
                                                        <div class="dish-entry">
                                                            <% if (img != null && !img.trim().isEmpty()) { %>
                                                                <img src="<%= img %>" alt="<%= m.getItemName() %>" class="dish-thumb" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                                <div class="thumb-fallback" style="display: none;">🍽️</div>
                                                            <% } else { %>
                                                                <div class="thumb-fallback">🍽️</div>
                                                            <% } %>
                                                            <span class="dish-name"><%= m.getItemName() %></span>
                                                        </div>
                                            <% 
                                                    }
                                                } else {
                                            %>
                                                <span style="color: #747d8c; font-size: 0.85rem;">No items info</span>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="mobile-label">Date</span>
                                        <span style="color: #a4b0be; font-size: 0.88rem;"><%= o.getOrderDate() %></span>
                                    </td>
                                    <td>
                                        <span class="mobile-label">Total</span>
                                        <span class="price">&#8377;<%= String.format("%.2f", o.getTotalAmount()) %></span>
                                    </td>
                                    <td>
                                        <span class="mobile-label">Status</span>
                                        <span class="status-badge <%= badgeClass %>"><%= status %></span>
                                    </td>
                                    <td>
                                        <div class="action-cell">
                                            <!-- Dynamic Primary Action -->
                                            <% if (isOngoing) { %>
                                                <a href="orderDetails?orderId=<%= o.getOrderId() %>" class="btn-track">🗺️ Track Live &rarr;</a>
                                            <% } else if (isDelivered) { %>
                                                <% if (existingRating != null) { %>
                                                    <div class="badge-rated" title="Rating submitted">
                                                        <span>✔ Rated</span>
                                                        <span style="color: #ffa502; margin-left: 2px;">
                                                            <% for (int s = 0; s < existingRating.getRating(); s++) { %>★<% } %>
                                                        </span>
                                                    </div>
                                                <% } else { %>
                                                    <a href="orderDetails?orderId=<%= o.getOrderId() %>#ratingBox" class="btn-rate">⭐ Rate Meal</a>
                                                <% } %>
                                            <% } %>

                                            <div class="btn-row">
                                                <!-- Reorder -->
                                                <a href="orderHistory?action=reorder&orderId=<%= o.getOrderId() %>" class="btn-reorder">&#128260; Reorder</a>

                                                <!-- Receipt -->
                                                <a href="orderDetails?orderId=<%= o.getOrderId() %>" class="btn-view">&#128438; Receipt</a>
                                            </div>
                                            
                                            <!-- Cancel Order (Only if Placed) -->
                                            <% if ("Placed".equalsIgnoreCase(status)) { %>
                                                <form action="orderHistory" method="get" class="cancel-form" onsubmit="return confirm('Are you sure you want to cancel this order?');">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                                    <button type="submit" class="btn-cancel">&#10006; Cancel Order</button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div class="empty-history">
                <div class="empty-icon">&#128220;</div>
                <h3>No Orders Placed Yet</h3>
                <p>You haven't ordered any delicious meals so far. Discover top-rated dishes and place your first order today!</p>
                <a href="home" class="explore-btn">&#127828; Order Food Now</a>
            </div>
        <% } %>
    </main>
</body>
</html>