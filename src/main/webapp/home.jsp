<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Order" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<Restaurant> restaurantList = (List<Restaurant>) request.getAttribute("restaurantList");
    
    @SuppressWarnings("unchecked")
    Map<Integer, Integer> reviewCountMap = (Map<Integer, Integer>) request.getAttribute("reviewCountMap");

    Order activeOrder = (Order) request.getAttribute("activeOrder");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delicious - Discover Restaurants</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: #0f1015;
            color: #f1f2f6;
            min-height: 100vh;
            padding-bottom: 70px;
        }

        /* Top Navigation Bar */
        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(26, 28, 35, 0.92);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            padding: 14px 40px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.6rem;
            font-weight: 800;
            color: #ff4757;
            text-decoration: none;
            letter-spacing: -0.5px;
            transition: transform 0.2s ease;
        }

        .brand-logo:hover {
            transform: scale(1.02);
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .nav-btn {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 16px;
            border-radius: 9px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.25s ease;
            border: 1px solid transparent;
        }

        .btn-admin {
            background: rgba(255, 165, 2, 0.12);
            color: #ffa502;
            border-color: rgba(255, 165, 2, 0.4);
            font-weight: 700;
        }
        .btn-admin:hover {
            background: #ffa502;
            color: #0f1015;
            box-shadow: 0 4px 15px rgba(255, 165, 2, 0.35);
            transform: translateY(-1px);
        }

        .btn-orders {
            background: #1e212b;
            color: #ced6e0;
            border-color: #2e3342;
        }
        .btn-orders:hover {
            border-color: #ffa502;
            color: #ffa502;
            background: #252936;
            transform: translateY(-1px);
        }

        .btn-cart {
            background: rgba(46, 213, 115, 0.12);
            color: #2ed573;
            border-color: rgba(46, 213, 115, 0.45);
            font-weight: 700;
        }
        .btn-cart:hover {
            background: #2ed573;
            color: #0f1015;
            box-shadow: 0 4px 16px rgba(46, 213, 115, 0.35);
            transform: translateY(-1px);
        }

        .btn-profile {
            background: rgba(112, 161, 255, 0.1);
            color: #70a1ff;
            border-color: rgba(112, 161, 255, 0.35);
            font-weight: 700;
        }
        .btn-profile:hover {
            background: rgba(112, 161, 255, 0.2);
            border-color: #70a1ff;
            transform: translateY(-1px);
        }

        .btn-logout {
            background: rgba(255, 71, 87, 0.08);
            color: #ff6b81;
            border-color: rgba(255, 71, 87, 0.3);
            font-weight: 600;
        }
        .btn-logout:hover {
            background: #ff4757;
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(255, 71, 87, 0.35);
            transform: translateY(-1px);
        }

        .btn-login {
            background: linear-gradient(135deg, #ff4757, #ff6b81);
            color: #fff;
            font-weight: 700;
            box-shadow: 0 4px 14px rgba(255, 71, 87, 0.3);
        }
        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(255, 71, 87, 0.45);
        }

        /* Hero Section */
        .hero {
            text-align: center;
            padding: 45px 20px 10px 20px;
        }

        .hero h1 {
            font-size: 2.3rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #ffffff 40%, #ff6b81 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
        }

        .hero p {
            color: #a4b0be;
            font-size: 1rem;
            margin-bottom: 25px;
        }

        .search-container {
            max-width: 600px;
            margin: 0 auto 10px auto;
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-input {
            width: 100%;
            padding: 14px 44px 14px 22px;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 30px;
            color: #fff;
            font-size: 0.95rem;
            outline: none;
            transition: 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }
        .search-input:focus {
            border-color: #ff4757;
            box-shadow: 0 0 15px rgba(255, 71, 87, 0.25);
        }

        /* Search Clear Button */
        .search-clear-btn {
            position: absolute;
            right: 16px;
            background: #252834;
            color: #a4b0be;
            border: none;
            border-radius: 50%;
            width: 26px;
            height: 26px;
            font-size: 0.8rem;
            font-weight: 700;
            cursor: pointer;
            display: none;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }
        .search-clear-btn:hover {
            background: #ff4757;
            color: #fff;
        }

        /* ================= PRO SWIGGY/ZOMATO CUISINE CAROUSEL ================= */
        .marquee-section {
            max-width: 1200px;
            margin: 15px auto 35px auto;
            padding: 0 20px;
        }

        .marquee-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
            gap: 12px;
            flex-wrap: wrap;
        }

        .marquee-heading {
            font-size: 1.35rem;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: -0.3px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .marquee-subheading {
            font-size: 0.82rem;
            color: #ffa502;
            font-weight: 700;
            background: rgba(255, 165, 2, 0.12);
            padding: 5px 12px;
            border-radius: 20px;
            border: 1px solid rgba(255, 165, 2, 0.25);
            white-space: nowrap;
        }

        /* Outer Scroll Container */
        .marquee-container {
            width: 100%;
            overflow-x: auto;
            overflow-y: hidden;
            position: relative;
            padding: 8px 0;
            scrollbar-width: none;
            -ms-overflow-style: none;
            -webkit-overflow-scrolling: touch;
            cursor: grab;
            mask-image: linear-gradient(to right, transparent, black 3%, black 97%, transparent);
            -webkit-mask-image: linear-gradient(to right, transparent, black 3%, black 97%, transparent);
        }

        .marquee-container::-webkit-scrollbar {
            display: none;
        }

        .marquee-container:active {
            cursor: grabbing;
        }

        /* Inner Running Track */
        .marquee-track {
            display: flex;
            width: max-content;
            gap: 24px;
            animation: scrollTicker 34s linear infinite;
        }

        .marquee-track.is-paused {
            animation-play-state: paused !important;
        }

        @keyframes scrollTicker {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }

        /* Swiggy Circular Food Item Card */
        .pro-ticker-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            text-decoration: none;
            user-select: none;
            transition: transform 0.25s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        .pro-ticker-card:hover {
            transform: translateY(-5px);
        }

        .pro-img-wrapper {
            width: 82px;
            height: 82px;
            border-radius: 50%;
            position: relative;
            padding: 3px;
            background: linear-gradient(135deg, #ff4757, #ffa502);
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.45);
            transition: all 0.25s ease;
        }

        .pro-ticker-card:hover .pro-img-wrapper {
            box-shadow: 0 8px 24px rgba(255, 71, 87, 0.5);
            transform: scale(1.06);
        }

        .pro-food-img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            background: #252834;
            display: block;
            pointer-events: none;
        }

        .pro-badge-mini {
            position: absolute;
            bottom: -4px;
            left: 50%;
            transform: translateX(-50%);
            background: #ff4757;
            color: #ffffff;
            font-size: 0.62rem;
            font-weight: 800;
            padding: 2px 7px;
            border-radius: 10px;
            white-space: nowrap;
            letter-spacing: 0.3px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.5);
            text-transform: uppercase;
        }

        .pro-item-name {
            font-size: 0.88rem;
            font-weight: 700;
            color: #ced6e0;
            text-align: center;
            transition: color 0.2s;
        }

        .pro-ticker-card:hover .pro-item-name {
            color: #ff4757;
        }

        /* Restaurant Cards Grid */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px 20px 20px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
        }

        .restaurant-card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 16px;
            overflow: hidden;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            transition: transform 0.25s ease, border-color 0.25s ease, box-shadow 0.25s ease;
        }

        .restaurant-card:hover {
            transform: translateY(-6px);
            border-color: #ff4757;
            box-shadow: 0 10px 25px rgba(255, 71, 87, 0.15);
        }

        .card-img {
            width: 100%;
            height: 175px;
            object-fit: cover;
            background-color: #252834;
        }

        .card-body {
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex: 1;
        }

        .card-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: #fff;
        }

        .card-cuisine {
            font-size: 0.85rem;
            color: #a4b0be;
        }

        .card-address {
            font-size: 0.8rem;
            color: #747d8c;
            margin-bottom: auto;
        }

        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 12px;
            border-top: 1px solid #252934;
            font-size: 0.85rem;
        }

        /* Modern Rating Badge with Count */
        .rating-wrap {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .badge-rating {
            background: #2ed573;
            color: #000;
            font-weight: 800;
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 0.82rem;
            display: inline-flex;
            align-items: center;
            gap: 3px;
        }

        .rating-count-text {
            color: #a4b0be;
            font-size: 0.76rem;
            font-weight: 600;
        }

        .eta {
            color: #ffa502;
            font-weight: 700;
            font-size: 0.82rem;
        }

        #noResults {
            display: none;
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            color: #747d8c;
        }

        /* Floating Order Pill */
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

        /* Mobile View Adjustments */
        @media (max-width: 768px) {
            .navbar {
                padding: 12px 16px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .brand-logo { font-size: 1.4rem; }
            .nav-actions {
                width: 100%;
                justify-content: center;
                gap: 8px;
            }
            .nav-btn { padding: 6px 12px; font-size: 0.82rem; }
            .hero { padding: 25px 15px 10px 15px; }
            .hero h1 { font-size: 1.8rem; }
            .container { padding: 15px; }
            .grid { grid-template-columns: 1fr; gap: 20px; }
            .card-img { height: 200px; }
            .active-order-pill {
                left: 12px;
                right: 12px;
                bottom: 12px;
                border-radius: 14px;
                max-width: none;
                justify-content: space-between;
                padding: 10px 12px;
            }

            .marquee-section {
                padding: 0 16px;
                margin: 10px auto 25px auto;
            }

            .marquee-header {
                display: flex;
                flex-direction: row;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 12px;
            }

            .marquee-heading {
                font-size: 1.15rem;
                font-weight: 800;
            }

            .marquee-subheading {
                font-size: 0.75rem;
                padding: 4px 10px;
            }

            .pro-img-wrapper {
                width: 70px;
                height: 70px;
            }

            .pro-item-name {
                font-size: 0.82rem;
            }

            .marquee-track {
                gap: 18px;
            }
        }

        /* Ultra-Narrow Mobile Screen Protection (<= 380px) */
        @media (max-width: 380px) {
            .marquee-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;
            }
            .marquee-heading {
                font-size: 1.05rem;
            }
            .marquee-subheading {
                font-size: 0.7rem;
                padding: 3px 8px;
            }
        }
    </style>
</head>
<body>
    <!-- Header Navbar -->
    <header class="navbar">
        <a href="home" class="brand-logo">
            <span>🍔</span> Delicious
        </a>

        <div class="nav-actions">
            <% if (sessionUser != null) { %>
                <% if ("admin".equalsIgnoreCase(sessionUser.getRole())) { %>
                    <a href="adminOrders" class="nav-btn btn-admin">⚙️ Admin</a>
                <% } %>

                <a href="orderHistory" class="nav-btn btn-orders">📜 My Orders</a>
                <a href="cart.jsp" class="nav-btn btn-cart">🛒 Cart</a>
                <a href="profile.jsp" class="nav-btn btn-profile">👤 <%= sessionUser.getUsername() %></a>
                <a href="logout" class="nav-btn btn-logout">Logout</a>
            <% } else { %>
                <a href="login.jsp" class="nav-btn btn-login">Log In</a>
            <% } %>
        </div>
    </header>

    <!-- Hero / Title -->
    <section class="hero">
        <h1>Explore Restaurants</h1>
        <p>Order delicious dishes from your favorite local kitchens</p>
        <div class="search-container">
            <input type="text" id="searchInput" class="search-input" placeholder="🔍 Search restaurant name, cuisine, or location..." autocomplete="off" />
            <button type="button" id="clearSearchBtn" class="search-clear-btn" onclick="clearFilter()" title="Clear filter">✕</button>
        </div>
    </section>

    <!-- PRO SWIGGY / ZOMATO STYLE "WHAT'S ON YOUR MIND?" CAROUSEL STRIP -->
    <section class="marquee-section">
        <div class="marquee-header">
            <h3 class="marquee-heading">🍽 What's on your mind?</h3>
            <span class="marquee-subheading">⚡ Tap to filter</span>
        </div>

        <div class="marquee-container" id="marqueeContainer" title="Swipe or tap any cuisine to filter">
            <div class="marquee-track" id="marqueeTrack">
                <!-- SET 1 -->
                <div class="pro-ticker-card" onclick="filterByCuisine('Biryani')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=160" alt="Biryani" />
                        <span class="pro-badge-mini" style="background: #ff4757;">Hot 🔥</span>
                    </div>
                    <span class="pro-item-name">Biryani</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Pizza')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1513104890138-7c749659a591?w=160" alt="Pizza" />
                        <span class="pro-badge-mini" style="background: #2ed573; color: #000;">40% OFF</span>
                    </div>
                    <span class="pro-item-name">Pizzas</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Burger')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=160" alt="Burgers" />
                        <span class="pro-badge-mini" style="background: #ffa502; color: #000;">Fast</span>
                    </div>
                    <span class="pro-item-name">Burgers</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('North Indian')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=160" alt="North Indian" />
                        <span class="pro-badge-mini" style="background: #ff4757;">Top Rated</span>
                    </div>
                    <span class="pro-item-name">North Indian</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('South Indian')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=160" alt="South Indian" />
                        <span class="pro-badge-mini" style="background: #2ed573; color: #000;">Crispy</span>
                    </div>
                    <span class="pro-item-name">South Indian</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Dessert')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=160" alt="Desserts" />
                        <span class="pro-badge-mini" style="background: #e056fd;">Sweet</span>
                    </div>
                    <span class="pro-item-name">Desserts</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Chinese')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=160" alt="Noodles & Chinese" />
                        <span class="pro-badge-mini" style="background: #ff4757;">Spicy 🌶️</span>
                    </div>
                    <span class="pro-item-name">Chinese</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Italian')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=160" alt="Pasta" />
                        <span class="pro-badge-mini" style="background: #ffa502; color: #000;">Pasta</span>
                    </div>
                    <span class="pro-item-name">Italian</span>
                </div>

                <!-- SET 2 (Duplicate for Seamless Infinite Loop) -->
                <div class="pro-ticker-card" onclick="filterByCuisine('Biryani')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=160" alt="Biryani" />
                        <span class="pro-badge-mini" style="background: #ff4757;">Hot 🔥</span>
                    </div>
                    <span class="pro-item-name">Biryani</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Pizza')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1513104890138-7c749659a591?w=160" alt="Pizza" />
                        <span class="pro-badge-mini" style="background: #2ed573; color: #000;">40% OFF</span>
                    </div>
                    <span class="pro-item-name">Pizzas</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Burger')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=160" alt="Burgers" />
                        <span class="pro-badge-mini" style="background: #ffa502; color: #000;">Fast</span>
                    </div>
                    <span class="pro-item-name">Burgers</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('North Indian')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=160" alt="North Indian" />
                        <span class="pro-badge-mini" style="background: #ff4757;">Top Rated</span>
                    </div>
                    <span class="pro-item-name">North Indian</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('South Indian')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=160" alt="South Indian" />
                        <span class="pro-badge-mini" style="background: #2ed573; color: #000;">Crispy</span>
                    </div>
                    <span class="pro-item-name">South Indian</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Dessert')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=160" alt="Desserts" />
                        <span class="pro-badge-mini" style="background: #e056fd;">Sweet</span>
                    </div>
                    <span class="pro-item-name">Desserts</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Chinese')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=160" alt="Noodles & Chinese" />
                        <span class="pro-badge-mini" style="background: #ff4757;">Spicy 🌶️️</span>
                    </div>
                    <span class="pro-item-name">Chinese</span>
                </div>

                <div class="pro-ticker-card" onclick="filterByCuisine('Italian')">
                    <div class="pro-img-wrapper">
                        <img class="pro-food-img" src="https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=160" alt="Pasta" />
                        <span class="pro-badge-mini" style="background: #ffa502; color: #000;">Pasta</span>
                    </div>
                    <span class="pro-item-name">Italian</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Restaurants List -->
    <main class="container">
        <div class="grid" id="restaurantGrid">
            <%
                if (restaurantList != null && !restaurantList.isEmpty()) {
                    for (Restaurant r : restaurantList) {
                        if (r.getIsActive()) {
                            String img = (r.getImagePath() != null && !r.getImagePath().trim().isEmpty()) 
                                         ? r.getImagePath().trim() 
                                         : "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500";
                            
                            int count = (reviewCountMap != null && reviewCountMap.containsKey(r.getRestaurantId())) 
                                        ? reviewCountMap.get(r.getRestaurantId()) : 0;
            %>
                <a href="menu?restaurantId=<%= r.getRestaurantId() %>" class="restaurant-card"
                   data-name="<%= (r.getName() != null) ? r.getName().toLowerCase() : "" %>"
                   data-cuisine="<%= (r.getCuisineType() != null) ? r.getCuisineType().toLowerCase() : "" %>"
                   data-address="<%= (r.getAddress() != null) ? r.getAddress().toLowerCase() : "" %>">
                    <img src="<%= img %>" 
                         alt="<%= r.getName() %>" 
                         class="card-img" 
                         loading="lazy"
                         onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500';" />
                    <div class="card-body">
                        <div class="card-title"><%= r.getName() %></div>
                        <div class="card-cuisine">🍽️ <%= r.getCuisineType() %></div>
                        <div class="card-address">📍 <%= r.getAddress() %></div>
                        <div class="card-footer">
                            <div class="rating-wrap">
                                <span class="badge-rating">★ <%= String.format("%.1f", r.getRating()) %></span>
                                <span class="rating-count-text">
                                    <%= count > 0 ? ("(" + count + "+ reviews)") : "(New)" %>
                                </span>
                            </div>
                            <span class="eta">⏱️ <%= r.getDeliveryTime() %> mins</span>
                        </div>
                    </div>
                </a>
            <%
                        }
                    }
                } else {
            %>
                <div style="grid-column: 1 / -1; text-align: center; padding: 60px; color: #747d8c;">
                    <h3>No restaurants available right now.</h3>
                </div>
            <%
                }
            %>
            <div id="noResults">
                <h3>🔍 No matching restaurants or cuisines found.</h3>
            </div>
        </div>
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

    <!-- JavaScript: Live Search, Filter & Drag/Swipe Scrolling -->
    <script>
        const searchInput = document.getElementById('searchInput');
        const clearSearchBtn = document.getElementById('clearSearchBtn');
        const restaurantCards = document.querySelectorAll('.restaurant-card');
        const noResults = document.getElementById('noResults');

        function performFilter(rawQuery) {
            const query = rawQuery.trim().toLowerCase();
            let visibleCount = 0;

            if (query.length > 0) {
                clearSearchBtn.style.display = 'flex';
            } else {
                clearSearchBtn.style.display = 'none';
            }

            restaurantCards.forEach(card => {
                const name = card.getAttribute('data-name') || '';
                const cuisine = card.getAttribute('data-cuisine') || '';
                const address = card.getAttribute('data-address') || '';

                if (name.includes(query) || cuisine.includes(query) || address.includes(query)) {
                    card.style.display = 'flex';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            });

            if (visibleCount === 0 && restaurantCards.length > 0) {
                noResults.style.display = 'block';
            } else {
                noResults.style.display = 'none';
            }
        }

        searchInput.addEventListener('input', function () {
            performFilter(this.value);
        });

        function clearFilter() {
            searchInput.value = '';
            performFilter('');
            searchInput.focus();
        }

        function filterByCuisine(cuisineKeyword) {
            if (searchInput.value.trim().toLowerCase() === cuisineKeyword.trim().toLowerCase()) {
                clearFilter();
            } else {
                searchInput.value = cuisineKeyword;
                performFilter(cuisineKeyword);
                searchInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        }

        // ================= DUAL MARQUEE: AUTO-SCROLL + TOUCH/MOUSE SWIPING =================
        const container = document.getElementById('marqueeContainer');
        const track = document.getElementById('marqueeTrack');

        let isDown = false;
        let startX = 0;
        let scrollLeft = 0;
        let resumeTimer = null;

        function pauseMarquee() {
            clearTimeout(resumeTimer);
            track.classList.add('is-paused');
        }

        function queueResumeMarquee() {
            clearTimeout(resumeTimer);
            resumeTimer = setTimeout(() => {
                track.classList.remove('is-paused');
            }, 2500);
        }

        // Mouse Drag Support (Desktop)
        container.addEventListener('mousedown', (e) => {
            isDown = true;
            pauseMarquee();
            startX = e.pageX - container.offsetLeft;
            scrollLeft = container.scrollLeft;
        });

        window.addEventListener('mouseup', () => {
            if (isDown) {
                isDown = false;
                queueResumeMarquee();
            }
        });

        container.addEventListener('mousemove', (e) => {
            if (!isDown) return;
            e.preventDefault();
            const x = e.pageX - container.offsetLeft;
            const walk = (x - startX) * 1.6;
            container.scrollLeft = scrollLeft - walk;
        });

        // Touch Swipe Support (Mobile)
        container.addEventListener('touchstart', (e) => {
            pauseMarquee();
            startX = e.touches[0].pageX - container.offsetLeft;
            scrollLeft = container.scrollLeft;
        }, { passive: true });

        container.addEventListener('touchmove', (e) => {
            const x = e.touches[0].pageX - container.offsetLeft;
            const walk = (x - startX) * 1.3;
            container.scrollLeft = scrollLeft - walk;
        }, { passive: true });

        container.addEventListener('touchend', () => {
            queueResumeMarquee();
        });

        container.addEventListener('mouseenter', pauseMarquee);
        container.addEventListener('mouseleave', queueResumeMarquee);
        
    </script>
    <% if (sessionUser != null && "admin".equalsIgnoreCase(sessionUser.getRole())) { %>
    <!-- Global Admin Sound Alert for New Orders -->
    <script>
        function playGlobalOrderChime() {
            try {
                const AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (!AudioCtx) return;
                const ctx = new AudioCtx();

                if (ctx.state === 'suspended') {
                    ctx.resume();
                }

                const playNote = (freq, start, duration) => {
                    const osc = ctx.createOscillator();
                    const gain = ctx.createGain();
                    osc.type = 'triangle';
                    osc.frequency.setValueAtTime(freq, ctx.currentTime + start);
                    gain.gain.setValueAtTime(0.4, ctx.currentTime + start);
                    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + start + duration);
                    osc.connect(gain);
                    gain.connect(ctx.destination);
                    osc.start(ctx.currentTime + start);
                    osc.stop(ctx.currentTime + start + duration);
                };

                // Crisp 3-tone notification ring
                playNote(587.33, 0.0, 0.20);  // D5
                playNote(880.00, 0.15, 0.25); // A5
                playNote(1174.66, 0.35, 0.50); // D6
            } catch (e) {
                console.error("Audio error:", e);
            }
        }

        // Setup background poller
        (function() {
            const STORAGE_KEY = 'admin_latest_order_tracker';

            function checkOrders() {
                fetch('checkLatestOrder')
                    .then(response => {
                        if (!response.ok) return null;
                        return response.json();
                    })
                    .then(data => {
                        if (!data) return;
                        const currentId = data.latestOrderId;
                        const prevId = parseInt(localStorage.getItem(STORAGE_KEY) || '0');

                        // If a higher order ID is detected, trigger the sound
                        if (prevId > 0 && currentId > prevId) {
                            console.log("🔔 New Order detected: #" + currentId + "! Playing sound...");
                            playGlobalOrderChime();
                        }

                        if (currentId > 0) {
                            localStorage.setItem(STORAGE_KEY, currentId);
                        }
                    })
                    .catch(err => {
                        console.warn("Check latest order poll failed:", err);
                    });
            }

            // Run check on page load and every 3.5 seconds
            checkOrders();
            setInterval(checkOrders, 3500);
        })();
    </script>
    <% } %>
</body>
</html>