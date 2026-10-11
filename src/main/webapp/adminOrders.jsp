<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.model.Order" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Rating" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"admin".equalsIgnoreCase(sessionUser.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Order> orderList = (List<Order>) request.getAttribute("orderList");

    @SuppressWarnings("unchecked")
    Map<Integer, String> orderItemSummaries = (Map<Integer, String>) request.getAttribute("orderItemSummaries");

    @SuppressWarnings("unchecked")
    Map<Integer, Rating> ratingsMap = (Map<Integer, Rating>) request.getAttribute("ratingsMap");

    @SuppressWarnings("unchecked")
    List<Map.Entry<String, Integer>> topDishesList = (List<Map.Entry<String, Integer>>) request.getAttribute("topDishesList");

    double totalRevenue = 0.0;
    int totalOrdersCount = 0;
    int activeOrdersCount = 0;
    int deliveredOrdersCount = 0;
    int placedOrdersCount = 0;
    int preparingOrdersCount = 0;
    int outForDeliveryCount = 0;
    int cancelledCount = 0;

    int latestOrderId = 0;
    boolean isLatestPlaced = false;

    if (orderList != null && !orderList.isEmpty()) {
        totalOrdersCount = orderList.size();

        Order newestOrder = orderList.get(0);
        latestOrderId = newestOrder.getOrderId();
        if ("Placed".equalsIgnoreCase(newestOrder.getStatus())) {
            isLatestPlaced = true;
        }

        for (Order ord : orderList) {
            String st = (ord.getStatus() != null) ? ord.getStatus().trim() : "Placed";
            if (!"Cancelled".equalsIgnoreCase(st)) {
                totalRevenue += ord.getTotalAmount();
            }
            if ("Placed".equalsIgnoreCase(st)) {
                placedOrdersCount++;
                activeOrdersCount++;
            } else if ("Preparing".equalsIgnoreCase(st)) {
                preparingOrdersCount++;
                activeOrdersCount++;
            } else if ("Out for Delivery".equalsIgnoreCase(st) || "On the Way".equalsIgnoreCase(st)) {
                outForDeliveryCount++;
                activeOrdersCount++;
            } else if ("Delivered".equalsIgnoreCase(st)) {
                deliveredOrdersCount++;
            } else if ("Cancelled".equalsIgnoreCase(st)) {
                cancelledCount++;
            }
        }
    }

    double aov = (totalOrdersCount - cancelledCount > 0) ? (totalRevenue / (totalOrdersCount - cancelledCount)) : 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Live Orders Dashboard | Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f1015; color: #f1f2f6; padding: 25px 15px; min-height: 100vh; }

        .navbar {
            max-width: 1340px;
            margin: 0 auto 25px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1c23;
            padding: 15px 30px;
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
            font-size: 0.9rem;
        }
        .nav-btn:hover { color: #ffa502; border-color: #ffa502; }
        .nav-btn.active { background: #ffa502; color: #000; font-weight: 700; border-color: #ffa502; }
        .btn-logout { border-color: #ff4757; color: #ff4757; }
        .btn-logout:hover { background: #ff4757; color: #fff; }

        .dashboard-wrapper { max-width: 1340px; margin: 0 auto; }

        /* Top Grid with 4 Metrics + Top Selling Widget */
        .analytics-top-container {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 18px;
            margin-bottom: 25px;
        }
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
        }
        .metric-card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 14px;
            padding: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
            transition: transform 0.2s ease, border-color 0.2s ease;
        }
        .metric-card:hover {
            transform: translateY(-2px);
            border-color: #3d4351;
        }
        .metric-info h4 {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #a4b0be;
            margin-bottom: 6px;
        }
        .metric-info .metric-value {
            font-size: 1.55rem;
            font-weight: 800;
            color: #ffffff;
        }
        .metric-subtext {
            font-size: 0.75rem;
            color: #747d8c;
            margin-top: 4px;
        }
        .metric-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }
        .icon-revenue { background: rgba(46, 213, 115, 0.15); color: #2ed573; border: 1px solid rgba(46, 213, 115, 0.3); }
        .icon-orders  { background: rgba(112, 161, 255, 0.15); color: #70a1ff; border: 1px solid rgba(112, 161, 255, 0.3); }
        .icon-active  { background: rgba(255, 165, 2, 0.15); color: #ffa502; border: 1px solid rgba(255, 165, 2, 0.3); }
        .icon-done    { background: rgba(46, 213, 115, 0.25); color: #2ed573; border: 1px solid #2ed573; }

        /* Top Selling Dishes Widget */
        .top-dishes-card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 14px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
        }
        .top-dishes-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }
        .top-dishes-header h4 {
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #ffa502;
            font-weight: 800;
        }
        .top-dish-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .top-dish-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #14161d;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid #252834;
            font-size: 0.85rem;
        }
        .dish-rank {
            font-weight: 800;
            color: #ffa502;
            margin-right: 8px;
        }
        .dish-title {
            color: #ffffff;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 180px;
        }
        .dish-sales-badge {
            background: rgba(46, 213, 115, 0.15);
            color: #2ed573;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 800;
        }

        .container {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 18px;
            padding: 26px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }
        h2 { font-size: 1.5rem; font-weight: 800; }
        .header-right { display: flex; align-items: center; gap: 12px; }
        .live-indicator {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.82rem;
            color: #2ed573;
            background: rgba(46, 213, 115, 0.12);
            padding: 5px 12px;
            border-radius: 20px;
            border: 1px solid rgba(46, 213, 115, 0.3);
            font-weight: 700;
        }
        .pulse-dot {
            width: 8px;
            height: 8px;
            background: #2ed573;
            border-radius: 50%;
            animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 1; }
            50% { transform: scale(1.4); opacity: 0.4; }
            100% { transform: scale(0.95); opacity: 1; }
        }

        .btn-audio-toggle {
            background: #252834;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.82rem;
            cursor: pointer;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: 0.2s;
        }
        .btn-audio-toggle.active {
            color: #ffa502;
            border-color: #ffa502;
            background: rgba(255, 165, 2, 0.12);
        }

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            margin-bottom: 22px;
            flex-wrap: wrap;
        }
        .filter-pills { display: flex; gap: 8px; flex-wrap: wrap; }
        .pill-btn {
            background: #14161d;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            padding: 7px 14px;
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 700;
            cursor: pointer;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .pill-btn:hover { color: #ffa502; border-color: #ffa502; }
        .pill-btn.active { background: #ffa502; color: #0f1015; border-color: #ffa502; }
        .pill-badge {
            background: rgba(255, 255, 255, 0.15);
            padding: 2px 7px;
            border-radius: 10px;
            font-size: 0.72rem;
            font-weight: 800;
        }
        .pill-btn.active .pill-badge { background: #000; color: #ffa502; }

        .search-box-wrapper { position: relative; min-width: 280px; flex: 1; max-width: 420px; }
        .search-input {
            width: 100%;
            background: #14161d;
            border: 1px solid #2a2e39;
            border-radius: 20px;
            padding: 8px 16px 8px 36px;
            font-size: 0.85rem;
            color: #fff;
            outline: none;
            transition: 0.2s;
        }
        .search-input:focus { border-color: #2ed573; box-shadow: 0 0 10px rgba(46, 213, 115, 0.2); }
        .search-icon-svg {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #747d8c;
            font-size: 0.85rem;
            pointer-events: none;
        }

        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th {
            background-color: #14161d;
            color: #a4b0be;
            font-size: 0.82rem;
            text-transform: uppercase;
            padding: 14px 12px;
            border-bottom: 2px solid #2a2e39;
            white-space: nowrap;
        }
        td {
            padding: 14px 12px;
            border-bottom: 1px solid #2a2e39;
            font-size: 0.92rem;
            vertical-align: middle;
        }
        tr:hover { background-color: #21242d; }

        .items-summary-text {
            color: #f1f2f6;
            font-weight: 600;
            font-size: 0.88rem;
            line-height: 1.4;
            max-width: 260px;
            word-break: break-word;
        }

        .admin-review-box {
            margin-top: 8px;
            padding: 8px 10px;
            background: rgba(255, 165, 2, 0.08);
            border: 1px solid rgba(255, 165, 2, 0.25);
            border-radius: 8px;
            font-size: 0.76rem;
            line-height: 1.35;
            max-width: 260px;
        }
        .review-stars { color: #ffa502; font-weight: 800; display: flex; align-items: center; gap: 4px; }
        .review-tags { color: #2ed573; font-size: 0.72rem; font-weight: 700; margin-top: 3px; }
        .review-comment { color: #ced6e0; font-style: italic; margin-top: 3px; word-break: break-word; }

        .quick-action-btn {
            border: none;
            padding: 8px 12px;
            border-radius: 8px;
            font-weight: 800;
            font-size: 0.82rem;
            cursor: pointer;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
        }
        .btn-preparing { background: #ffa502; color: #000; }
        .btn-preparing:hover { background: #ffb833; transform: scale(1.03); }

        .btn-dispatch { background: #70a1ff; color: #000; }
        .btn-dispatch:hover { background: #8bb4ff; transform: scale(1.03); }

        .btn-deliver { background: #2ed573; color: #000; }
        .btn-deliver:hover { background: #26af5f; transform: scale(1.03); }

        .status-select {
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #f1f2f6;
            padding: 6px 8px;
            border-radius: 6px;
            outline: none;
            font-size: 0.8rem;
            cursor: pointer;
        }
        .status-select:focus { border-color: #2ed573; }

        .btn-update {
            background: #252834;
            color: #ced6e0;
            border: 1px solid #3d4351;
            padding: 6px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 0.78rem;
            cursor: pointer;
            transition: 0.2s;
        }
        .btn-update:hover { border-color: #2ed573; color: #2ed573; }

        .btn-receipt {
            background: #252834;
            color: #70a1ff;
            border: 1px solid #2a2e39;
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.82rem;
            font-weight: 600;
            display: inline-block;
            transition: 0.2s;
            white-space: nowrap;
        }
        .btn-receipt:hover { border-color: #70a1ff; background: #2f3542; }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 700;
            white-space: nowrap;
        }
        .badge-placed { background: rgba(46, 213, 115, 0.15); color: #2ed573; border: 1px solid #2ed573; }
        .badge-preparing { background: rgba(255, 165, 2, 0.15); color: #ffa502; border: 1px solid #ffa502; }
        .badge-onway { background: rgba(112, 161, 255, 0.15); color: #70a1ff; border: 1px solid #70a1ff; }
        .badge-delivered { background: rgba(46, 213, 115, 0.25); color: #2ed573; font-weight: 800; border: 1px solid #2ed573; }
        .badge-cancelled { background: rgba(255, 71, 87, 0.15); color: #ff4757; border: 1px solid #ff4757; }

        #noTableMatch {
            display: none;
            text-align: center;
            padding: 40px;
            color: #747d8c;
            font-size: 0.95rem;
        }

        @media (max-width: 980px) {
            .analytics-top-container { grid-template-columns: 1fr; }
        }
        @media (max-width: 600px) {
            .metrics-grid { grid-template-columns: 1fr; }
            .toolbar { flex-direction: column; align-items: stretch; }
            .search-box-wrapper { max-width: 100%; }
        }
    </style>
</head>
<body>
    <header class="navbar">
        <a href="home" class="brand">🍔 Delicious Admin</a>
        <nav class="nav-links">
            <a href="adminOrders" class="nav-btn active">📋 Live Orders</a>
            <a href="adminRestaurant" class="nav-btn">🏪 Manage Restaurants</a>
            <a href="adminMenu" class="nav-btn">🍽️ Manage Menus</a>
            <a href="home" class="nav-btn">Store Home</a>
            <a href="logout" class="nav-btn btn-logout">Logout</a>
        </nav>
    </header>

    <div class="dashboard-wrapper">
        <!-- Top Analytics: Metrics Grid & Top Dishes Widget -->
        <div class="analytics-top-container">
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-info">
                        <h4>Total Revenue</h4>
                        <div class="metric-value" style="color: #2ed573;">₹<%= String.format("%.2f", totalRevenue) %></div>
                        <div class="metric-subtext">Avg Order: ₹<%= String.format("%.2f", aov) %></div>
                    </div>
                    <div class="metric-icon icon-revenue">💰</div>
                </div>

                <div class="metric-card">
                    <div class="metric-info">
                        <h4>Total Orders</h4>
                        <div class="metric-value" style="color: #70a1ff;"><%= totalOrdersCount %></div>
                        <div class="metric-subtext"><%= cancelledCount %> Cancelled</div>
                    </div>
                    <div class="metric-icon icon-orders">📦</div>
                </div>

                <div class="metric-card">
                    <div class="metric-info">
                        <h4>Active Orders</h4>
                        <div class="metric-value" style="color: #ffa502;"><%= activeOrdersCount %></div>
                        <div class="metric-subtext"><%= placedOrdersCount %> New / <%= preparingOrdersCount %> Kitchen</div>
                    </div>
                    <div class="metric-icon icon-active">🛵</div>
                </div>

                <div class="metric-card">
                    <div class="metric-info">
                        <h4>Delivered</h4>
                        <div class="metric-value" style="color: #2ed573;"><%= deliveredOrdersCount %></div>
                        <div class="metric-subtext">Successfully fulfilled</div>
                    </div>
                    <div class="metric-icon icon-done">✅</div>
                </div>
            </div>

            <!-- Top 3 Best-Selling Dishes Widget -->
            <div class="top-dishes-card">
                <div class="top-dishes-header">
                    <h4>🔥 Top 3 Best Sellers</h4>
                    <span style="font-size: 0.72rem; color: #a4b0be; font-weight: 700;">By Volume</span>
                </div>
                <div class="top-dish-list">
                    <%
                        if (topDishesList != null && !topDishesList.isEmpty()) {
                            int rank = 1;
                            for (Map.Entry<String, Integer> entry : topDishesList) {
                    %>
                                <div class="top-dish-item">
                                    <div style="display: flex; align-items: center; min-width: 0;">
                                        <span class="dish-rank">#<%= rank++ %></span>
                                        <span class="dish-title" title="<%= entry.getKey() %>"><%= entry.getKey() %></span>
                                    </div>
                                    <span class="dish-sales-badge"><%= entry.getValue() %> sold</span>
                                </div>
                    <%
                            }
                        } else {
                    %>
                        <div style="color: #747d8c; font-size: 0.82rem; text-align: center; padding: 20px 0;">
                            No sales data available yet.
                        </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>

        <main class="container">
            <div class="header-section">
                <div>
                    <h2>📋 Live Customer Orders</h2>
                    <small style="color: #747d8c;">Real-time management for kitchen & valet dispatch</small>
                </div>
                <div class="header-right">
                    <button type="button" id="audioToggleBtn" class="btn-audio-toggle active" onclick="toggleKitchenAudio()">
                        🔔 Audio Alert: ON
                    </button>
                    <div class="live-indicator">
                        <span class="pulse-dot"></span>
                        <span>Live Feed Active</span>
                    </div>
                </div>
            </div>

            <div class="toolbar">
                <div class="filter-pills">
                    <button type="button" class="pill-btn active" data-filter="all" onclick="applyStatusFilter('all', this)">
                        All <span class="pill-badge"><%= totalOrdersCount %></span>
                    </button>
                    <button type="button" class="pill-btn" data-filter="placed" onclick="applyStatusFilter('placed', this)">
                        ⏳ Placed <span class="pill-badge" style="color: #2ed573;"><%= placedOrdersCount %></span>
                    </button>
                    <button type="button" class="pill-btn" data-filter="preparing" onclick="applyStatusFilter('preparing', this)">
                        👨‍🍳 Preparing <span class="pill-badge" style="color: #ffa502;"><%= preparingOrdersCount %></span>
                    </button>
                    <button type="button" class="pill-btn" data-filter="out for delivery" onclick="applyStatusFilter('out for delivery', this)">
                        🛵 Out for Delivery <span class="pill-badge" style="color: #70a1ff;"><%= outForDeliveryCount %></span>
                    </button>
                    <button type="button" class="pill-btn" data-filter="delivered" onclick="applyStatusFilter('delivered', this)">
                        ✅ Delivered <span class="pill-badge"><%= deliveredOrdersCount %></span>
                    </button>
                    <button type="button" class="pill-btn" data-filter="cancelled" onclick="applyStatusFilter('cancelled', this)">
                        ✖ Cancelled <span class="pill-badge" style="color: #ff4757;"><%= cancelledCount %></span>
                    </button>
                </div>

                <div class="search-box-wrapper">
                    <span class="search-icon-svg">🔍</span>
                    <input type="text" id="orderSearchInput" class="search-input" placeholder="Search Order #ID, Dish Name, User #ID, UPI..." onkeyup="filterOrderRows()">
                </div>
            </div>

            <div class="table-responsive">
                <table id="ordersTable">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Items Ordered</th>
                            <th>User ID</th>
                            <th>Total Paid</th>
                            <th>Payment</th>
                            <th>Order Date</th>
                            <th>Current Status</th>
                            <th>1-Click Next Step</th>
                            <th>Manual Change</th>
                            <th>Tracker / Receipt</th>
                        </tr>
                    </thead>
                    <tbody id="ordersTableBody">
                        <%
                            if (orderList != null && !orderList.isEmpty()) {
                                for (Order ord : orderList) {
                                    String st = (ord.getStatus() != null) ? ord.getStatus().trim() : "Placed";
                                    String badgeClass = "badge-placed";
                                    if ("Preparing".equalsIgnoreCase(st)) badgeClass = "badge-preparing";
                                    else if ("Out for Delivery".equalsIgnoreCase(st) || "On the Way".equalsIgnoreCase(st)) badgeClass = "badge-onway";
                                    else if ("Delivered".equalsIgnoreCase(st)) badgeClass = "badge-delivered";
                                    else if ("Cancelled".equalsIgnoreCase(st)) badgeClass = "badge-cancelled";

                                    String summary = (orderItemSummaries != null && orderItemSummaries.containsKey(ord.getOrderId()))
                                                     ? orderItemSummaries.get(ord.getOrderId())
                                                     : "Items unavailable";

                                    Rating userRating = (ratingsMap != null) ? ratingsMap.get(ord.getOrderId()) : null;
                                    String searchFeedback = "";
                                    if (userRating != null) {
                                        searchFeedback = (userRating.getTags() != null ? userRating.getTags() : "") + " " +
                                                         (userRating.getComment() != null ? userRating.getComment() : "");
                                    }
                        %>
                                <tr class="order-row" 
                                    id="order-row-<%= ord.getOrderId() %>" 
                                    data-status="<%= st.toLowerCase() %>" 
                                    data-search="order #<%= ord.getOrderId() %> user #<%= ord.getUserId() %> <%= ord.getPaymentMode() != null ? ord.getPaymentMode().toLowerCase() : "" %> <%= summary.toLowerCase() %> <%= searchFeedback.toLowerCase() %>">
                                    <td style="font-weight: 700; color: #ffa502;">#<%= ord.getOrderId() %></td>
                                    <td>
                                        <div class="items-summary-text"><%= summary %></div>

                                        <% if (userRating != null) { %>
                                            <div class="admin-review-box">
                                                <div class="review-stars">
                                                    <% for (int s = 0; s < userRating.getRating(); s++) { %>⭐<% } %>
                                                    <span style="color: #a4b0be; font-size: 0.72rem; margin-left: 2px;">(<%= userRating.getRating() %>/5)</span>
                                                </div>
                                                <% if (userRating.getTags() != null && !userRating.getTags().trim().isEmpty()) { %>
                                                    <div class="review-tags"><%= userRating.getTags() %></div>
                                                <% } %>
                                                <% if (userRating.getComment() != null && !userRating.getComment().trim().isEmpty()) { %>
                                                    <div class="review-comment">"<%= userRating.getComment() %>"</div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </td>
                                    <td>User #<%= ord.getUserId() %></td>
                                    <td style="font-weight: 700; color: #2ed573;">₹<%= String.format("%.2f", ord.getTotalAmount()) %></td>
                                    <td><%= ord.getPaymentMode() != null ? ord.getPaymentMode() : "UPI" %></td>
                                    <td style="color: #a4b0be; font-size: 0.82rem;"><%= ord.getOrderDate() %></td>
                                    <td>
                                        <span class="status-badge <%= badgeClass %>"><%= st %></span>
                                    </td>

                                    <td>
                                        <% if ("Placed".equalsIgnoreCase(st)) { %>
                                            <form action="adminOrders" method="post" class="status-form" style="margin: 0;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="<%= ord.getOrderId() %>">
                                                <input type="hidden" name="status" value="Preparing">
                                                <button type="submit" class="quick-action-btn btn-preparing">
                                                    👨‍🍳 Start Preparing &rarr;
                                                </button>
                                            </form>
                                        <% } else if ("Preparing".equalsIgnoreCase(st)) { %>
                                            <form action="adminOrders" method="post" class="status-form" style="margin: 0;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="<%= ord.getOrderId() %>">
                                                <input type="hidden" name="status" value="Out for Delivery">
                                                <button type="submit" class="quick-action-btn btn-dispatch">
                                                    🛵 Dispatch Rider &rarr;
                                                </button>
                                            </form>
                                        <% } else if ("Out for Delivery".equalsIgnoreCase(st) || "On the Way".equalsIgnoreCase(st)) { %>
                                            <form action="adminOrders" method="post" class="status-form" style="margin: 0;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="<%= ord.getOrderId() %>">
                                                <input type="hidden" name="status" value="Delivered">
                                                <button type="submit" class="quick-action-btn btn-deliver">
                                                    ✅ Mark Delivered &rarr;
                                                </button>
                                            </form>
                                        <% } else if ("Delivered".equalsIgnoreCase(st)) { %>
                                            <span style="color: #2ed573; font-size: 0.85rem; font-weight: 700;">Completed ✔</span>
                                        <% } else { %>
                                            <span style="color: #ff4757; font-size: 0.85rem; font-weight: 700;">Cancelled ✖</span>
                                        <% } %>
                                    </td>

                                    <td>
                                        <form action="adminOrders" method="post" class="status-form" style="display: flex; gap: 6px; align-items: center; margin: 0;">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="orderId" value="<%= ord.getOrderId() %>">
                                            <select name="status" class="status-select">
                                                <option value="Placed" <%= "Placed".equalsIgnoreCase(st) ? "selected" : "" %>>Placed</option>
                                                <option value="Preparing" <%= "Preparing".equalsIgnoreCase(st) ? "selected" : "" %>>Preparing</option>
                                                <option value="Out for Delivery" <%= ("Out for Delivery".equalsIgnoreCase(st) || "On the Way".equalsIgnoreCase(st)) ? "selected" : "" %>>Out for Delivery</option>
                                                <option value="Delivered" <%= "Delivered".equalsIgnoreCase(st) ? "selected" : "" %>>Delivered</option>
                                                <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(st) ? "selected" : "" %>>Cancelled</option>
                                            </select>
                                            <button type="submit" class="btn-update">Save</button>
                                        </form>
                                    </td>

                                    <td>
                                        <a href="orderDetails?orderId=<%= ord.getOrderId() %>" class="btn-receipt" target="_blank">
                                            🗺️ Track Map &rarr;
                                        </a>
                                    </td>
                                </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="10" style="text-align: center; padding: 40px; color: #747d8c;">
                                    No customer orders found yet.
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <div id="noTableMatch">🔍 No orders match the selected filter or search term.</div>
            </div>
        </main>
    </div>

    <script>
        let currentStatusFilter = sessionStorage.getItem('adminActiveFilter') || 'all';

        function applyStatusFilter(status, btnElement) {
            currentStatusFilter = status.toLowerCase();
            sessionStorage.setItem('adminActiveFilter', currentStatusFilter);

            document.querySelectorAll('.pill-btn').forEach(btn => btn.classList.remove('active'));
            if (btnElement) {
                btnElement.classList.add('active');
            }
            filterOrderRows();
        }

        function restoreActiveFilterUI() {
            const savedFilter = sessionStorage.getItem('adminActiveFilter') || 'all';
            currentStatusFilter = savedFilter;
            const targetBtn = document.querySelector(`.pill-btn[data-filter="${savedFilter}"]`);
            if (targetBtn) {
                document.querySelectorAll('.pill-btn').forEach(btn => btn.classList.remove('active'));
                targetBtn.classList.add('active');
            }
            filterOrderRows();
        }

        function filterOrderRows() {
            const query = document.getElementById('orderSearchInput').value.trim().toLowerCase();
            const rows = document.querySelectorAll('.order-row');
            let visibleCount = 0;

            rows.forEach(row => {
                const rowStatus = row.getAttribute('data-status') || '';
                const searchData = row.getAttribute('data-search') || '';

                const matchesSearch = (query === '' || searchData.includes(query));
                let matchesStatus = (currentStatusFilter === 'all');
                
                if (!matchesStatus) {
                    if (currentStatusFilter === 'out for delivery') {
                        matchesStatus = (rowStatus === 'out for delivery' || rowStatus === 'on the way');
                    } else {
                        matchesStatus = (rowStatus === currentStatusFilter);
                    }
                }

                if (matchesSearch && matchesStatus) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            const noMatchDiv = document.getElementById('noTableMatch');
            if (noMatchDiv) {
                noMatchDiv.style.display = (visibleCount === 0 && rows.length > 0) ? 'block' : 'none';
            }
        }

        let isAudioEnabled = (localStorage.getItem('adminAudioAlert') !== 'false');

        function updateAudioBtnUI() {
            const btn = document.getElementById('audioToggleBtn');
            if (btn) {
                if (isAudioEnabled) {
                    btn.className = 'btn-audio-toggle active';
                    btn.innerHTML = '🔔 Audio Alert: ON';
                } else {
                    btn.className = 'btn-audio-toggle';
                    btn.innerHTML = '🔕 Audio Alert: OFF';
                }
            }
        }
        updateAudioBtnUI();

        function toggleKitchenAudio() {
            isAudioEnabled = !isAudioEnabled;
            localStorage.setItem('adminAudioAlert', isAudioEnabled.toString());
            updateAudioBtnUI();
            if (isAudioEnabled) {
                playKitchenBell();
            }
        }

        function playKitchenBell() {
            try {
                const AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (!AudioCtx) return;
                const ctx = new AudioCtx();

                const osc1 = ctx.createOscillator();
                const gain1 = ctx.createGain();
                osc1.type = 'sine';
                osc1.frequency.setValueAtTime(587.33, ctx.currentTime);
                gain1.gain.setValueAtTime(0.25, ctx.currentTime);
                gain1.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.6);
                osc1.connect(gain1);
                gain1.connect(ctx.destination);
                osc1.start();
                osc1.stop(ctx.currentTime + 0.6);

                const osc2 = ctx.createOscillator();
                const gain2 = ctx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(880.00, ctx.currentTime + 0.15);
                gain2.gain.setValueAtTime(0.3, ctx.currentTime + 0.15);
                gain2.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.8);
                osc2.connect(gain2);
                gain2.connect(ctx.destination);
                osc2.start(ctx.currentTime + 0.15);
                osc2.stop(ctx.currentTime + 0.8);
            } catch (e) {
                console.warn('Audio Context interaction required:', e);
            }
        }

        const currentLatestOrderId = <%= latestOrderId %>;
        const isLatestPlaced = <%= isLatestPlaced %>;

        window.addEventListener('DOMContentLoaded', () => {
            restoreActiveFilterUI();

            const lastSeenOrderId = parseInt(localStorage.getItem('lastSeenAdminOrderId') || '0');

            if (currentLatestOrderId > lastSeenOrderId && isLatestPlaced && isAudioEnabled) {
                setTimeout(() => {
                    playKitchenBell();
                }, 600);
            }

            if (currentLatestOrderId > 0) {
                localStorage.setItem('lastSeenAdminOrderId', currentLatestOrderId.toString());
            }

            const savedScroll = sessionStorage.getItem("adminScrollPos");
            if (savedScroll !== null) {
                window.scrollTo({
                    top: parseInt(savedScroll),
                    behavior: 'instant'
                });
                sessionStorage.removeItem("adminScrollPos");
            }
        });

        document.querySelectorAll(".status-form").forEach(form => {
            form.addEventListener("submit", function () {
                sessionStorage.setItem("adminScrollPos", window.scrollY.toString());
            });
        });

        setTimeout(function() {
            sessionStorage.setItem("adminScrollPos", window.scrollY.toString());
            window.location.reload();
        }, 20000);
    </script>
</body>
</html>