<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.Order" %>
<%
    Cart cartObj = (Cart) session.getAttribute("cart");
    int totalCartQuantity = 0;
    if (cartObj != null && cartObj.getItems() != null) {
        for (CartItem cItem : cartObj.getItems().values()) {
            totalCartQuantity += cItem.getQuantity();
        }
    }
    User currentUser = (User) session.getAttribute("user");
    Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");
    Integer reviewCount = (Integer) request.getAttribute("reviewCount");
    if (reviewCount == null) reviewCount = 0;
    Order activeOrder = (Order) request.getAttribute("activeOrder");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= (restaurant != null) ? restaurant.getName() + " - Menu" : "Menu - Delicious" %></title>
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
            padding-bottom: 80px;
        }
        .navbar {
            max-width: 1250px;
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
        .admin-link {
            background: #ffa502;
            color: #000;
            font-weight: 800;
            border-color: #ffa502;
        }
        .admin-link:hover {
            background: #eccc68;
            color: #000;
        }
        .cart-link {
            background: #2ed573;
            color: #000;
            font-weight: 700;
            border-color: #2ed573;
        }
        .cart-link:hover {
            background: #10ac84;
            color: #fff;
        }
        .cart-badge {
            background: #000;
            color: #2ed573;
            font-size: 0.75rem;
            font-weight: 800;
            padding: 2px 7px;
            border-radius: 10px;
            margin-left: 4px;
        }
        .user-greeting {
            color: #70a1ff;
            font-weight: 700;
            font-size: 0.95rem;
            padding: 0 4px;
        }
        .logout-btn {
            border-color: #ff4757 !important;
            color: #ff4757 !important;
        }
        .logout-btn:hover {
            background: #ff4757 !important;
            color: #ffffff !important;
        }
        .login-btn {
            border-color: #2ed573 !important;
            color: #2ed573 !important;
        }

        /* Restaurant Info Header Banner */
        .restaurant-header {
            max-width: 1250px;
            margin: 0 auto 25px auto;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 16px;
            padding: 24px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }
        .restaurant-details h1 {
            margin: 0 0 6px 0;
            font-size: 2rem;
            font-weight: 800;
            text-align: left;
            letter-spacing: -0.5px;
        }
        .restaurant-details h1::after { display: none; }
        .res-cuisine {
            color: #a4b0be;
            font-size: 0.95rem;
            margin-bottom: 4px;
        }
        .res-address {
            color: #747d8c;
            font-size: 0.85rem;
        }
        .restaurant-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }
        .rating-box {
            background: #252834;
            border: 1px solid #2ed573;
            padding: 10px 16px;
            border-radius: 12px;
            text-align: center;
        }
        .rating-stars {
            color: #2ed573;
            font-weight: 800;
            font-size: 1.25rem;
        }
        .rating-count {
            color: #a4b0be;
            font-size: 0.75rem;
            margin-top: 2px;
        }
        .delivery-eta-box {
            background: #252834;
            border: 1px solid #2a2e39;
            padding: 10px 16px;
            border-radius: 12px;
            text-align: center;
        }
        .eta-val {
            font-weight: 800;
            font-size: 1.15rem;
            color: #ffa502;
        }
        .eta-lbl {
            color: #a4b0be;
            font-size: 0.75rem;
            margin-top: 2px;
        }

        /* Filter & Search Bar Section */
        .controls-container {
            max-width: 1250px;
            margin: 0 auto 30px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }
        .search-box {
            position: relative;
            flex: 1;
            min-width: 260px;
            max-width: 480px;
        }
        .search-input {
            width: 100%;
            padding: 12px 18px 12px 42px;
            font-size: 0.95rem;
            border-radius: 30px;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            color: #ffffff;
            outline: none;
            transition: 0.25s ease;
        }
        .search-input:focus {
            border-color: #ff4757;
            box-shadow: 0 0 10px rgba(255, 71, 87, 0.35);
        }
        .search-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #747d8c;
            font-size: 1rem;
            pointer-events: none;
        }
        .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filter-btn {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            transition: 0.2s ease;
        }
        .filter-btn:hover {
            border-color: #ffa502;
            color: #ffa502;
        }
        .filter-btn.active {
            background: #ffa502;
            color: #000;
            border-color: #ffa502;
        }
        .sort-select {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 600;
            outline: none;
            cursor: pointer;
        }
        .sort-select:focus {
            border-color: #2ed573;
        }

        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); 
            gap: 25px; 
            max-width: 1250px; 
            margin: 0 auto; 
        }
        .card { 
            background: #1a1c23; 
            border: 1px solid #2a2e39; 
            border-radius: 16px; 
            overflow: hidden; 
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45); 
            display: flex; 
            flex-direction: column; 
            transition: transform 0.25s ease, box-shadow 0.25s ease, border-color 0.25s ease;
            position: relative;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 14px 28px rgba(0, 0, 0, 0.65);
            border-color: #ff4757;
        }
        
        /* Out-of-Stock Card Treatment */
        .card.out-of-stock {
            opacity: 0.55;
            filter: grayscale(0.5);
            border-color: #2a2e39 !important;
        }
        .card.out-of-stock:hover {
            transform: none !important;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45) !important;
            border-color: #2a2e39 !important;
        }
        .card-img-wrapper {
            position: relative;
            width: 100%;
        }
        .card img { 
            width: 100%; 
            height: 190px; 
            object-fit: cover; 
            display: block; 
            background-color: #252834;
        }

        /* Out of Stock Overlay Badge */
        .out-of-stock-overlay {
            position: absolute;
            top: 10px;
            left: 10px;
            background: rgba(255, 71, 87, 0.92);
            color: #ffffff;
            font-size: 0.72rem;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 20px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
            z-index: 2;
        }

        .card-body { 
            padding: 18px; 
            display: flex; 
            flex-direction: column; 
            flex-grow: 1; 
            justify-content: space-between; 
        }
        .item-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 8px;
            margin-bottom: 6px;
        }
        .item-name { 
            font-size: 1.15rem; 
            font-weight: 700; 
            color: #ffffff; 
        }
        .diet-badge {
            font-size: 0.7rem;
            font-weight: 800;
            padding: 3px 8px;
            border-radius: 6px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
        }
        .badge-veg {
            background: rgba(46, 213, 115, 0.15);
            border: 1px solid #2ed573;
            color: #2ed573;
        }
        .badge-nonveg {
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid #ff4757;
            color: #ff4757;
        }
        .item-desc { 
            font-size: 0.85rem; 
            color: #a4b0be; 
            line-height: 1.4; 
            margin-bottom: 12px;
            min-height: 38px;
        }
        .item-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #2a2e39;
            padding-top: 14px;
            margin-top: auto;
        }
        .item-price {
            font-size: 1.2rem;
            font-weight: 800;
            color: #ffa502;
        }
        .initial-add-btn {
            background: linear-gradient(135deg, #ff4757, #ff6b81);
            color: #fff;
            border: none;
            padding: 8px 18px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            transition: 0.2s ease;
        }
        .initial-add-btn:hover {
            transform: scale(1.04);
            box-shadow: 0 4px 12px rgba(255, 71, 87, 0.4);
        }
        
        /* Disabled Out-of-Stock Action Button */
        .btn-disabled {
            background: #252834;
            color: #ff4757;
            border: 1px solid rgba(255, 71, 87, 0.35);
            padding: 8px 14px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.82rem;
            cursor: not-allowed;
            pointer-events: none;
        }
        .counter-widget {
            display: inline-flex;
            align-items: center;
            background: #0f1015;
            border: 1px solid #2ed573;
            border-radius: 8px;
            overflow: hidden;
        }
        .counter-btn {
            background: transparent;
            color: #2ed573;
            border: none;
            padding: 6px 12px;
            font-size: 1rem;
            font-weight: 800;
            cursor: pointer;
            transition: 0.15s ease;
        }
        .counter-btn:hover {
            background: #2ed573;
            color: #000;
        }
        .counter-qty {
            font-weight: 800;
            color: #ffffff;
            padding: 0 10px;
            font-size: 0.95rem;
            min-width: 20px;
            text-align: center;
        }
        #noMenuResults {
            display: none;
            text-align: center;
            grid-column: 1 / -1;
            padding: 60px 20px;
            color: #747d8c;
            font-size: 1.1rem;
        }

        /* ================= FLOATING ACTIVE ORDER PILL ================= */
        .active-order-pill {
            position: fixed;
            bottom: 20px;
            right: 24px;
            z-index: 999;
            background: linear-gradient(135deg, #1e222d, #141720);
            border: 1px solid #2ed573;
            border-radius: 50px;
            padding: 10px 18px 10px 14px;
            display: flex;
            align-items: center;
            gap: 14px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.7), 0 0 16px rgba(46, 213, 115, 0.25);
            animation: slideUp 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            max-width: 440px;
        }
        @keyframes slideUp {
            from { transform: translateY(80px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .pill-icon-wrapper {
            position: relative;
            width: 38px;
            height: 38px;
            background: #252a37;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            flex-shrink: 0;
        }
        .pill-live-dot {
            position: absolute;
            top: 0;
            right: 0;
            width: 10px;
            height: 10px;
            background: #2ed573;
            border: 2px solid #141720;
            border-radius: 50%;
            box-shadow: 0 0 8px #2ed573;
            animation: pillPulse 1.5s infinite;
        }
        @keyframes pillPulse {
            0% { transform: scale(0.95); opacity: 1; }
            50% { transform: scale(1.3); opacity: 0.5; }
            100% { transform: scale(0.95); opacity: 1; }
        }
        .pill-content {
            display: flex;
            flex-direction: column;
            gap: 2px;
            overflow: hidden;
        }
        .pill-title {
            font-size: 0.88rem;
            font-weight: 700;
            color: #ffffff;
            white-space: nowrap;
        }
        .pill-subtitle {
            font-size: 0.75rem;
            color: #2ed573;
            font-weight: 600;
        }
        .pill-action-btn {
            background: #2ed573;
            color: #000;
            text-decoration: none;
            padding: 7px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 800;
            white-space: nowrap;
            transition: background 0.2s ease, transform 0.2s ease;
        }
        .pill-action-btn:hover {
            background: #26af5f;
            transform: scale(1.04);
        }

        /* ================= MOBILE OPTIMIZATIONS ================= */
        @media (max-width: 768px) {
            body { padding: 12px; }
            .navbar {
                padding: 12px 15px;
                margin-bottom: 20px;
                flex-direction: column;
                align-items: stretch;
            }
            .brand { justify-content: center; font-size: 1.35rem; }
            .nav-links { justify-content: center; gap: 8px; }
            .nav-btn { padding: 6px 10px; font-size: 0.82rem; }
            .user-greeting { font-size: 0.85rem; width: 100%; text-align: center; }
            .restaurant-header {
                padding: 18px;
                flex-direction: column;
                align-items: flex-start;
            }
            .restaurant-details h1 { font-size: 1.6rem; }
            .controls-container {
                flex-direction: column;
                align-items: stretch;
                gap: 12px;
                margin-bottom: 20px;
            }
            .search-box { max-width: 100%; min-width: 100%; }
            .filter-group { justify-content: space-between; width: 100%; }
            .filter-btn { padding: 7px 12px; font-size: 0.8rem; flex: 1; text-align: center; }
            .sort-select { width: 100%; margin-top: 4px; }
            .grid { grid-template-columns: 1fr; gap: 16px; }
            .card {
                flex-direction: row-reverse;
                align-items: center;
                padding: 14px;
                border-radius: 14px;
            }
            .card:hover { transform: none; }
            .card-img-wrapper {
                width: 125px;
                min-width: 125px;
                position: relative;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            .card img {
                width: 120px;
                height: 120px;
                border-radius: 12px;
            }
            .out-of-stock-overlay {
                top: 4px;
                left: 4px;
                font-size: 0.62rem;
                padding: 3px 6px;
            }
            .card-body {
                padding: 0 12px 0 0;
                justify-content: flex-start;
                min-width: 0;
            }
            .item-header {
                flex-direction: column-reverse;
                gap: 5px;
            }
            .item-name { font-size: 1.05rem; line-height: 1.3; }
            .item-desc {
                font-size: 0.78rem;
                min-height: unset;
                margin-bottom: 8px;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }
            .item-bottom {
                border-top: none;
                padding-top: 4px;
                margin-top: 4px;
            }
            .item-price { font-size: 1.1rem; }
            .mobile-action-container {
                position: absolute;
                bottom: -8px;
                z-index: 2;
            }
            .initial-add-btn {
                padding: 6px 14px;
                font-size: 0.82rem;
                box-shadow: 0 4px 10px rgba(0,0,0,0.5);
            }
            .counter-widget { box-shadow: 0 4px 10px rgba(0,0,0,0.5); }
            .counter-btn { padding: 4px 8px; }
            .counter-qty { padding: 0 6px; font-size: 0.85rem; }
            .desktop-action { display: none !important; }
            .active-order-pill {
                left: 12px;
                right: 12px;
                bottom: 12px;
                border-radius: 14px;
                max-width: none;
                justify-content: space-between;
                padding: 10px 12px;
            }
        }
        @media (min-width: 769px) {
            .mobile-action-container { display: none !important; }
        }
    </style>
</head>
<body>
    <!-- Top Navigation Bar -->
    <header class="navbar">
        <a href="home" class="brand">&#127828; Delicious</a>
        <nav class="nav-links">
            <% if (currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole())) { %>
                <a href="adminOrders" class="nav-btn admin-link">&#9881; Admin Panel</a>
            <% } %>

            <a href="home" class="nav-btn">&#127968; Restaurants</a>
            <a href="orderHistory" class="nav-btn">&#128220; My Orders</a>
            <a href="cart.jsp" class="nav-btn cart-link">
                &#128722; Cart
                <span class="cart-badge" id="navCartBadge" style="<%= totalCartQuantity > 0 ? "" : "display:none;" %>">
                    <%= totalCartQuantity %>
                </span>
            </a>
            <% if (currentUser != null) { %>
                <span class="user-greeting">&#128100; Hi, <%= currentUser.getUsername() %></span>
                <a href="logout" class="nav-btn logout-btn">Logout</a>
            <% } else { %>
                <a href="login.jsp" class="nav-btn login-btn">Login</a>
                <a href="register.jsp" class="nav-btn">Sign Up</a>
            <% } %>
        </nav>
    </header>

    <!-- Restaurant Header Banner with Community Rating -->
    <% if (restaurant != null) { %>
        <section class="restaurant-header">
            <div class="restaurant-details">
                <h1><%= restaurant.getName() %></h1>
                <div class="res-cuisine">&#127869; <%= restaurant.getCuisineType() %></div>
                <div class="res-address">&#128205; <%= restaurant.getAddress() %></div>
            </div>
            <div class="restaurant-meta">
                <div class="rating-box">
                    <div class="rating-stars">&#9733; <%= restaurant.getRating() %></div>
                    <div class="rating-count">
                        <%= reviewCount > 0 ? reviewCount + "+ reviews" : "New on Delicious" %>
                    </div>
                </div>
                <div class="delivery-eta-box">
                    <div class="eta-val">&#9201; <%= restaurant.getDeliveryTime() %> mins</div>
                    <div class="eta-lbl">Delivery Time</div>
                </div>
            </div>
        </section>
    <% } else { %>
        <h1 style="text-align: center; margin-bottom: 25px;">Menu Items</h1>
    <% } %>

    <!-- Live Search & Diet Filter Controls -->
    <div class="controls-container">
        <div class="search-box">
            <span class="search-icon">&#128269;</span>
            <input type="text" id="dishSearch" class="search-input" placeholder="Search dishes by name or ingredients..." onkeyup="filterMenu()">
        </div>

        <div class="filter-group">
            <button type="button" class="filter-btn active" onclick="setDietFilter('all', this)">All</button>
            <button type="button" class="filter-btn" onclick="setDietFilter('veg', this)">&#128994; Veg</button>
            <button type="button" class="filter-btn" onclick="setDietFilter('non-veg', this)">&#128308; Non-Veg</button>
            
            <select id="sortSelect" class="sort-select" onchange="sortMenuItems()">
                <option value="default">Sort by: Default</option>
                <option value="low-high">Price: Low to High</option>
                <option value="high-low">Price: High to Low</option>
            </select>
        </div>
    </div>

    <main class="grid" id="menuGrid">
        <%
            List<Menu> menuList = (List<Menu>) request.getAttribute("menuList");
            if (menuList != null && !menuList.isEmpty()) {
                for (Menu item : menuList) {
                    CartItem cartItem = (cartObj != null && cartObj.getItems() != null) ? cartObj.getItems().get(item.getMenuId()) : null;
                    int itemQty = (cartItem != null) ? cartItem.getQuantity() : 0;

                    String itemName = (item.getItemName() != null) ? item.getItemName() : "";
                    String itemDesc = (item.getDescription() != null) ? item.getDescription() : "";
                    boolean inStock = item.getIsAvailable();

                    // Detect Veg vs Non-Veg
                    String textCheck = (itemName + " " + itemDesc).toLowerCase();
                    boolean isPaneer = textCheck.contains("paneer");
                    boolean isNonVeg = !isPaneer && (textCheck.contains("chicken") || textCheck.contains("mutton") 
                                    || textCheck.contains("fish") || textCheck.contains("prawn") 
                                    || textCheck.contains("egg") || textCheck.contains("meat") 
                                    || textCheck.contains("non-veg") || textCheck.contains("non veg")
                                    || textCheck.contains("pepperoni") || textCheck.contains("bacon")
                                    || textCheck.contains("kebab") || textCheck.contains("tikka"));
                    String dietType = isNonVeg ? "non-veg" : "veg";

                    // Dish-Specific Fallback Selector
                    String fallbackImage;
                    if (textCheck.contains("biryani")) {
                        fallbackImage = "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("kebab") || textCheck.contains("tandoori")) {
                        fallbackImage = "https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("pizza") || textCheck.contains("margherita")) {
                        fallbackImage = "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("burger")) {
                        fallbackImage = "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("pasta") || textCheck.contains("spaghetti") || textCheck.contains("penne")) {
                        fallbackImage = "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("dosa") || textCheck.contains("idli") || textCheck.contains("vada")) {
                        fallbackImage = "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("noodle") || textCheck.contains("chowmein")) {
                        fallbackImage = "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("momo") || textCheck.contains("dimsum")) {
                        fallbackImage = "https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("fish") || textCheck.contains("prawn") || textCheck.contains("seafood")) {
                        fallbackImage = "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("cake") || textCheck.contains("ice cream") || textCheck.contains("pastry") || textCheck.contains("dessert")) {
                        fallbackImage = "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&auto=format&fit=crop&q=80";
                    } else if (textCheck.contains("paneer")) {
                        fallbackImage = "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80";
                    } else if (isNonVeg) {
                        fallbackImage = "https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&auto=format&fit=crop&q=80";
                    } else {
                        fallbackImage = "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80";
                    }

                    String rawImage = (item.getImagePath() != null && !item.getImagePath().trim().isEmpty()) 
                                        ? item.getImagePath().trim() 
                                        : fallbackImage;
                    
                    String escapedName = itemName.replace("'", "\\'");
        %>
                    <article class="card menu-item-card <%= inStock ? "" : "out-of-stock" %>" 
                             data-price="<%= item.getPrice() %>" 
                             data-diet="<%= dietType %>"
                             data-name="<%= itemName.toLowerCase() %>"
                             data-desc="<%= itemDesc.toLowerCase() %>">
                             
                        <div class="card-img-wrapper">
                            <% if (!inStock) { %>
                                <span class="out-of-stock-overlay">&#10006; Out of Stock</span>
                            <% } %>

                            <img src="<%= rawImage %>" 
                                 alt="<%= itemName %>" 
                                 loading="lazy"
                                 onerror="this.onerror=null; this.src='<%= fallbackImage %>';">
                            
                            <!-- Mobile Action Container -->
                            <div class="mobile-action-container" id="mobile-action-<%= item.getMenuId() %>">
                                <% if (!inStock) { %>
                                    <button type="button" class="btn-disabled">Unavailable</button>
                                <% } else if (itemQty == 0) { %>
                                    <button type="button" class="initial-add-btn" 
                                            onclick="handleCartAction('<%= item.getMenuId() %>', '<%= item.getRestaurantId() %>', '<%= escapedName %>', <%= item.getPrice() %>, 'add', 1)">+ Add</button>
                                <% } else { %>
                                    <div class="counter-widget">
                                        <button type="button" class="counter-btn" 
                                                onclick="handleCartAction('<%= item.getMenuId() %>', '<%= item.getRestaurantId() %>', '<%= escapedName %>', <%= item.getPrice() %>, '<%= itemQty > 1 ? "update" : "delete" %>', <%= itemQty - 1 %>)">-</button>
                                        <span class="counter-qty" id="mobile-qty-<%= item.getMenuId() %>"><%= itemQty %></span>
                                        <button type="button" class="counter-btn" 
                                                onclick="handleCartAction('<%= item.getMenuId() %>', '<%= item.getRestaurantId() %>', '<%= escapedName %>', <%= item.getPrice() %>, 'update', <%= itemQty + 1 %>)">+</button>
                                    </div>
                                <% } %>
                            </div>
                        </div>

                        <div class="card-body">
                            <div>
                                <div class="item-header">
                                    <div class="item-name"><%= itemName %></div>
                                    <span class="diet-badge <%= isNonVeg ? "badge-nonveg" : "badge-veg" %>">
                                        <%= isNonVeg ? "&#128308; Non-Veg" : "&#128994; Veg" %>
                                    </span>
                                </div>
                                <div class="item-desc"><%= itemDesc %></div>
                            </div>
                            <div class="item-bottom">
                                <span class="item-price">&#8377;<%= String.format("%.2f", item.getPrice()) %></span>

                                <!-- Desktop Action Container -->
                                <div class="desktop-action" id="desktop-action-<%= item.getMenuId() %>">
                                    <% if (!inStock) { %>
                                        <button type="button" class="btn-disabled">✕ Out of Stock</button>
                                    <% } else if (itemQty == 0) { %>
                                        <button type="button" class="initial-add-btn" 
                                                onclick="handleCartAction('<%= item.getMenuId() %>', '<%= item.getRestaurantId() %>', '<%= escapedName %>', <%= item.getPrice() %>, 'add', 1)">+ Add</button>
                                    <% } else { %>
                                        <div class="counter-widget">
                                            <button type="button" class="counter-btn" 
                                                    onclick="handleCartAction('<%= item.getMenuId() %>', '<%= item.getRestaurantId() %>', '<%= escapedName %>', <%= item.getPrice() %>, '<%= itemQty > 1 ? "update" : "delete" %>', <%= itemQty - 1 %>)">-</button>
                                            <span class="counter-qty" id="desktop-qty-<%= item.getMenuId() %>"><%= itemQty %></span>
                                            <button type="button" class="counter-btn" 
                                                    onclick="handleCartAction('<%= item.getMenuId() %>', '<%= item.getRestaurantId() %>', '<%= escapedName %>', <%= item.getPrice() %>, 'update', <%= itemQty + 1 %>)">+</button>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </article>
        <%
                }
            } else {
        %>
            <p style="text-align: center; width: 100%; color: #747d8c; grid-column: 1 / -1; padding: 40px;">No menu items available for this restaurant.</p>
        <%
            }
        %>
        <div id="noMenuResults">&#128269; No dishes match your search or filter criteria.</div>
    </main>

    <!-- FLOATING ACTIVE ORDER TRACKER PILL -->
    <% if (activeOrder != null) { 
        String activeStatus = (activeOrder.getStatus() != null) ? activeOrder.getStatus().trim() : "Placed";
        String statusEmoji = "⏳";
        String statusText = "Order Placed & Confirmed";

        if ("Preparing".equalsIgnoreCase(activeStatus)) {
            statusEmoji = "👨‍🍳";
            statusText = "Chef is preparing your food";
        } else if ("Out for Delivery".equalsIgnoreCase(activeStatus) || "On the Way".equalsIgnoreCase(activeStatus)) {
            statusEmoji = "🛵";
            statusText = "Valet is heading to your door";
        }
    %>
        <aside class="active-order-pill" aria-label="Active order status tracker">
            <div class="pill-icon-wrapper">
                <span><%= statusEmoji %></span>
                <span class="pill-live-dot"></span>
            </div>
            <div class="pill-content">
                <div class="pill-title">Order #<%= activeOrder.getOrderId() %></div>
                <div class="pill-subtitle"><%= statusText %></div>
            </div>
            <a href="orderDetails?orderId=<%= activeOrder.getOrderId() %>" class="pill-action-btn">
                Track Live &rarr;
            </a>
        </aside>
    <% } %>

    <!-- AJAX Dynamic Cart & Search Scripts -->
    <script>
        function handleCartAction(itemId, restaurantId, name, price, action, quantity) {
            const params = new URLSearchParams();
            params.append('action', action);
            params.append('itemId', itemId);
            params.append('restaurantId', restaurantId);
            params.append('name', name);
            params.append('price', price);
            params.append('quantity', quantity);

            fetch('cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            })
            .then(() => {
                const escapedName = name.replace(/'/g, "\\'");
                const mobileContainer = document.getElementById('mobile-action-' + itemId);
                const desktopContainer = document.getElementById('desktop-action-' + itemId);

                let delta = 0;
                if (action === 'add') {
                    delta = 1;
                } else if (action === 'delete') {
                    delta = -1;
                } else {
                    const currentElem = document.getElementById('desktop-qty-' + itemId) || document.getElementById('mobile-qty-' + itemId);
                    const oldQty = currentElem ? parseInt(currentElem.innerText) : 0;
                    delta = quantity - oldQty;
                }

                if (quantity <= 0 || action === 'delete') {
                    const addBtnHtml = '<button type="button" class="initial-add-btn" onclick="handleCartAction(\'' + itemId + '\', \'' + restaurantId + '\', \'' + escapedName + '\', ' + price + ', \'add\', 1)">+ Add</button>';
                    if (mobileContainer) mobileContainer.innerHTML = addBtnHtml;
                    if (desktopContainer) desktopContainer.innerHTML = addBtnHtml;
                } else {
                    const decAction = (quantity > 1) ? 'update' : 'delete';
                    const decQty = quantity - 1;
                    const incQty = quantity + 1;

                    const counterWidgetHtml = 
                        '<div class="counter-widget">' +
                            '<button type="button" class="counter-btn" onclick="handleCartAction(\'' + itemId + '\', \'' + restaurantId + '\', \'' + escapedName + '\', ' + price + ', \'' + decAction + '\', ' + decQty + ')">-</button>' +
                            '<span class="counter-qty" id="desktop-qty-' + itemId + '">' + quantity + '</span>' +
                            '<button type="button" class="counter-btn" onclick="handleCartAction(\'' + itemId + '\', \'' + restaurantId + '\', \'' + escapedName + '\', ' + price + ', \'update\', ' + incQty + ')">+</button>' +
                        '</div>';

                    if (mobileContainer) {
                        mobileContainer.innerHTML = 
                            '<div class="counter-widget">' +
                                '<button type="button" class="counter-btn" onclick="handleCartAction(\'' + itemId + '\', \'' + restaurantId + '\', \'' + escapedName + '\', ' + price + ', \'' + decAction + '\', ' + decQty + ')">-</button>' +
                                '<span class="counter-qty" id="mobile-qty-' + itemId + '">' + quantity + '</span>' +
                                '<button type="button" class="counter-btn" onclick="handleCartAction(\'' + itemId + '\', \'' + restaurantId + '\', \'' + escapedName + '\', ' + price + ', \'update\', ' + incQty + ')">+</button>' +
                            '</div>';
                    }
                    if (desktopContainer) {
                        desktopContainer.innerHTML = counterWidgetHtml;
                    }
                }

                updateTopCartBadge(delta);
            })
            .catch(err => console.error("Cart update error:", err));
        }

        function updateTopCartBadge(delta) {
            const badge = document.getElementById('navCartBadge');
            if (badge) {
                let current = parseInt(badge.innerText) || 0;
                let next = current + delta;
                if (next > 0) {
                    badge.innerText = next;
                    badge.style.display = 'inline-block';
                } else {
                    badge.innerText = '0';
                    badge.style.display = 'none';
                }
            }
        }

        let currentDiet = 'all';

        function setDietFilter(diet, btnElement) {
            currentDiet = diet;
            document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
            btnElement.classList.add('active');
            filterMenu();
        }

        function filterMenu() {
            const query = document.getElementById('dishSearch').value.toLowerCase().trim();
            const cards = document.querySelectorAll('.menu-item-card');
            let visibleCount = 0;

            cards.forEach(card => {
                const name = card.getAttribute('data-name') || '';
                const desc = card.getAttribute('data-desc') || '';
                const cardDiet = card.getAttribute('data-diet') || 'veg';

                const matchesSearch = query === '' || name.includes(query) || desc.includes(query);
                const matchesDiet = (currentDiet === 'all') || (cardDiet === currentDiet);

                if (matchesSearch && matchesDiet) {
                    card.style.display = 'flex';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            });

            const noResults = document.getElementById('noMenuResults');
            if (noResults) {
                noResults.style.display = (visibleCount === 0 && cards.length > 0) ? 'block' : 'none';
            }
        }

        function sortMenuItems() {
            const sortMode = document.getElementById('sortSelect').value;
            const grid = document.getElementById('menuGrid');
            const cards = Array.from(grid.querySelectorAll('.menu-item-card'));

            if (sortMode === 'low-high') {
                cards.sort((a, b) => parseFloat(a.dataset.price) - parseFloat(b.dataset.price));
            } else if (sortMode === 'high-low') {
                cards.sort((a, b) => parseFloat(b.dataset.price) - parseFloat(a.dataset.price));
            }

            cards.forEach(card => grid.appendChild(card));
            filterMenu();
        }
    </script>
</body>
</html>