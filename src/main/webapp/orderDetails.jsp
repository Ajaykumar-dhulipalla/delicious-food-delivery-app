<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.tap.model.Order" %>
<%@ page import="com.tap.model.OrderItem" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.Rating" %>
<%@ page import="com.tap.daoimpl.RatingDaoImpl" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("orderHistory");
        return;
    }

    Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");

    @SuppressWarnings("unchecked")
    List<OrderItem> itemList = (List<OrderItem>) request.getAttribute("itemList");
    @SuppressWarnings("unchecked")
    Map<Integer, String> itemNames = (Map<Integer, String>) request.getAttribute("itemNames");

    String currentStatus = (order.getStatus() != null) ? order.getStatus().trim() : "Placed";
    boolean isCancelled = "Cancelled".equalsIgnoreCase(currentStatus);
    boolean isDelivered = "Delivered".equalsIgnoreCase(currentStatus);
    boolean isPlaced = "Placed".equalsIgnoreCase(currentStatus);

    String paymentMode = (order.getPaymentMode() != null) ? order.getPaymentMode().trim() : "UPI";
    boolean isCOD = "COD".equalsIgnoreCase(paymentMode) || "Cash on Delivery".equalsIgnoreCase(paymentMode);

    // Retrieve existing rating from MySQL if the order is delivered
    Rating existingRating = null;
    if (isDelivered) {
        try {
            RatingDaoImpl ratingDao = new RatingDaoImpl();
            existingRating = ratingDao.getRatingByOrderId(order.getOrderId());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    int currentStep = 0;
    if ("Preparing".equalsIgnoreCase(currentStatus)) {
        currentStep = 1;
    } else if ("Out for Delivery".equalsIgnoreCase(currentStatus) || "On the Way".equalsIgnoreCase(currentStatus)) {
        currentStep = 2;
    } else if (isDelivered) {
        currentStep = 3;
    }
    
    int progressWidth = (currentStep == 0) ? 0 : (currentStep == 1 ? 33 : (currentStep == 2 ? 66 : 100));

    // Calculate subtotal from items to determine any promo discount
    double itemsSubtotal = 0.0;
    if (itemList != null) {
        for (OrderItem it : itemList) {
            itemsSubtotal += it.getTotalAmount();
        }
    }
    double totalPaid = order.getTotalAmount();
    double discountApplied = Math.max(0.0, itemsSubtotal - totalPaid);

    // Format Order Date
    String formattedReceiptDate = "Just now";
    if (order.getOrderDate() != null) {
        try {
            SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat displayFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
            Date parsedDate = dbFormat.parse(order.getOrderDate().toString());
            formattedReceiptDate = displayFormat.format(parsedDate);
        } catch (Exception e) {
            formattedReceiptDate = order.getOrderDate().toString();
        }
    }

    // Dynamic ETA based on restaurant delivery time
    int baseDeliveryTime = (restaurant != null && restaurant.getDeliveryTime() > 0) ? restaurant.getDeliveryTime() : 30;
    int remainingMinutes = baseDeliveryTime;

    if ("Preparing".equalsIgnoreCase(currentStatus)) {
        remainingMinutes = Math.max(10, (int) Math.round(baseDeliveryTime * 0.65));
    } else if ("Out for Delivery".equalsIgnoreCase(currentStatus) || "On the Way".equalsIgnoreCase(currentStatus)) {
        remainingMinutes = Math.max(5, (int) Math.round(baseDeliveryTime * 0.30));
    } else if (isDelivered) {
        remainingMinutes = 0;
    }

    // Resolve order-specific address (fallback to profile address if empty)
    String displayDeliveryAddress = (order.getAddress() != null && !order.getAddress().trim().isEmpty())
                                    ? order.getAddress()
                                    : ((currentUser.getAddress() != null) ? currentUser.getAddress() : "Standard Address");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Order #<%= order.getOrderId() %> - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    
    <!-- Leaflet.js Assets -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f1015;
            color: #f1f2f6;
            padding: 30px 15px;
            min-height: 100vh;
        }
        .container {
            max-width: 840px;
            margin: 0 auto;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.6);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px dashed #2a2e39;
            padding-bottom: 18px;
            margin-bottom: 22px;
        }
        .brand {
            font-size: 1.6rem;
            font-weight: 800;
            color: #ff4757;
        }
        .badge {
            font-weight: 800;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.82rem;
            display: inline-block;
        }
        .badge-placed { background: rgba(46, 213, 115, 0.15); color: #2ed573; border: 1px solid #2ed573; }
        .badge-cancelled { background: rgba(255, 71, 87, 0.15); color: #ff4757; border: 1px solid #ff4757; }

        /* Toast Banner */
        #statusUpdateToast {
            display: none;
            position: fixed;
            top: 24px;
            left: 50%;
            transform: translateX(-50%);
            background: #10ac84;
            color: #ffffff;
            padding: 12px 26px;
            border-radius: 30px;
            font-weight: 700;
            font-size: 0.95rem;
            box-shadow: 0 8px 24px rgba(16, 172, 132, 0.45);
            z-index: 9999;
            transition: opacity 0.4s ease, transform 0.4s ease;
        }

        /* ETA Banner */
        .eta-banner {
            background: linear-gradient(135deg, rgba(255, 165, 2, 0.12), rgba(255, 71, 87, 0.08));
            border: 1px solid rgba(255, 165, 2, 0.35);
            border-radius: 14px;
            padding: 16px 20px;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            flex-wrap: wrap;
        }
        .eta-banner.delivered-banner {
            background: rgba(46, 213, 115, 0.12);
            border-color: rgba(46, 213, 115, 0.4);
        }
        .eta-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .eta-icon {
            font-size: 2.2rem;
            filter: drop-shadow(0 2px 8px rgba(255, 165, 2, 0.35));
        }
        .eta-title {
            font-size: 1.15rem;
            font-weight: 800;
            color: #ffffff;
        }
        .eta-subtitle {
            font-size: 0.85rem;
            color: #a4b0be;
            margin-top: 3px;
        }
        .eta-badge {
            background: #ffa502;
            color: #000;
            font-weight: 800;
            font-size: 0.95rem;
            padding: 7px 14px;
            border-radius: 20px;
            white-space: nowrap;
        }
        .eta-badge.badge-done {
            background: #2ed573;
            color: #000;
        }

        /* Post-Delivery Rating */
        .rating-box {
            background: linear-gradient(135deg, #151821, #1e222d);
            border: 1px solid #2ed573;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            text-align: center;
            box-shadow: 0 6px 24px rgba(46, 213, 115, 0.15);
        }
        .rating-title {
            font-size: 1.25rem;
            font-weight: 800;
            color: #ffffff;
            margin-bottom: 6px;
        }
        .rating-subtitle {
            font-size: 0.88rem;
            color: #a4b0be;
            margin-bottom: 16px;
        }
        .stars-container {
            display: inline-flex;
            gap: 10px;
            margin-bottom: 14px;
        }
        .star-item {
            font-size: 2rem;
            color: #2a2e39;
            cursor: pointer;
            transition: transform 0.2s, color 0.2s;
        }
        .star-item:hover, .star-item.active {
            color: #ffa502;
            transform: scale(1.15);
            text-shadow: 0 0 12px rgba(255, 165, 2, 0.6);
        }
        .star-status-text {
            font-size: 0.9rem;
            font-weight: 700;
            color: #ffa502;
            height: 20px;
            margin-bottom: 12px;
        }
        .compliment-tags {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 8px;
            margin-bottom: 16px;
        }
        .comp-tag {
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #a4b0be;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            cursor: pointer;
            transition: 0.2s;
        }
        .comp-tag:hover {
            border-color: #2ed573;
            color: #2ed573;
        }
        .comp-tag.selected {
            background: rgba(46, 213, 115, 0.15);
            border-color: #2ed573;
            color: #2ed573;
            font-weight: 700;
        }
        .review-input-group {
            max-width: 520px;
            margin: 0 auto;
            display: flex;
            gap: 8px;
        }
        .review-input {
            flex: 1;
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 8px;
            padding: 10px 14px;
            color: #ffffff;
            font-size: 0.9rem;
            outline: none;
        }
        .review-input:focus { border-color: #2ed573; }
        .review-submit-btn {
            background: #2ed573;
            color: #000;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 800;
            font-size: 0.9rem;
            cursor: pointer;
            transition: 0.2s;
        }
        .review-submit-btn:hover { background: #26af5f; }
        .review-thankyou {
            padding: 15px;
            background: rgba(46, 213, 115, 0.12);
            border-radius: 10px;
            color: #2ed573;
            font-weight: 700;
            font-size: 1rem;
        }

        /* Map Section */
        .map-wrapper {
            margin-bottom: 24px;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid #2a2e39;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.6);
            position: relative;
            background: #000000;
        }
        .map-header {
            background: #14161d;
            padding: 12px 18px;
            border-bottom: 1px solid #2a2e39;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.85rem;
            font-weight: 700;
            color: #ced6e0;
        }
        .map-live-pulse {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #2ed573;
        }
        .pulse-dot {
            width: 9px;
            height: 9px;
            background: #2ed573;
            border-radius: 50%;
            box-shadow: 0 0 10px #2ed573;
            animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 1; }
            50% { transform: scale(1.4); opacity: 0.4; }
            100% { transform: scale(0.95); opacity: 1; }
        }
        #deliveryMap {
            width: 100%;
            height: 340px;
            min-height: 340px;
            background: #050505 !important;
            display: block;
            position: relative;
            z-index: 1;
        }

        /* Pure Dark Black Map Tiles */
        .leaflet-tile-pane {
            filter: invert(100%) hue-rotate(180deg) brightness(85%) contrast(145%) !important;
        }

        /* Block attribution link clicks from opening new tabs */
        .leaflet-control-attribution, 
        .leaflet-control-container a {
            display: none !important;
            pointer-events: none !important;
        }

        .custom-map-icon {
            background: transparent !important;
            border: none !important;
        }

        /* Map Tooltips */
        .map-badge-tooltip {
            background: #111317 !important;
            border: 1px solid #2ed573 !important;
            color: #ffffff !important;
            font-family: inherit !important;
            font-size: 0.8rem !important;
            font-weight: 700 !important;
            padding: 6px 12px !important;
            border-radius: 8px !important;
            box-shadow: 0 4px 16px rgba(0,0,0,0.85) !important;
            white-space: nowrap !important;
            pointer-events: none !important;
        }
        .map-badge-tooltip::before {
            border-top-color: #2ed573 !important;
        }

        /* Status Tracker */
        .tracker-card {
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 12px;
            padding: 22px 14px;
            margin-bottom: 24px;
        }
        .tracker-title {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #747d8c;
            margin-bottom: 18px;
            font-weight: 700;
            text-align: center;
        }
        .tracker-steps {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            max-width: 580px;
            margin: 0 auto;
        }
        .tracker-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 2;
            flex: 1;
        }
        .step-circle {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 0.85rem;
            background: #1a1c23;
            border: 2px solid #2a2e39;
            color: #747d8c;
            transition: all 0.3s ease;
        }
        .step-label {
            margin-top: 8px;
            font-size: 0.75rem;
            font-weight: 600;
            color: #747d8c;
            text-align: center;
        }
        .tracker-step.completed .step-circle {
            background: #2ed573;
            border-color: #2ed573;
            color: #000;
            box-shadow: 0 0 12px rgba(46, 213, 115, 0.4);
        }
        .tracker-step.completed .step-label { color: #f1f2f6; }
        .tracker-step.active .step-circle {
            background: #ffa502;
            border-color: #ffa502;
            color: #000;
            box-shadow: 0 0 12px rgba(255, 165, 2, 0.4);
        }
        .tracker-step.active .step-label {
            color: #ffa502;
            font-weight: 700;
        }
        .tracker-line {
            position: absolute;
            top: 17px;
            left: 12%;
            right: 12%;
            height: 3px;
            background: #2a2e39;
            z-index: 1;
        }
        .tracker-line-progress {
            height: 100%;
            background: #2ed573;
            transition: width 0.3s ease;
        }
        .tracker-cancelled {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            padding: 12px;
            background: rgba(255, 71, 87, 0.12);
            border: 1px solid rgba(255, 71, 87, 0.3);
            border-radius: 8px;
            color: #ff6b81;
            font-weight: 600;
            font-size: 0.9rem;
        }

        /* Customer & Order Metadata */
        .meta-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            background: #0f1015;
            padding: 18px;
            border-radius: 10px;
            border: 1px solid #2a2e39;
            margin-bottom: 24px;
            font-size: 0.9rem;
        }
        .meta-item {
            color: #a4b0be;
            line-height: 1.5;
        }
        .meta-item strong { color: #ffffff; }

        /* Itemized Table */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0 20px 0;
        }
        th {
            text-align: left;
            color: #a4b0be;
            font-size: 0.85rem;
            border-bottom: 2px solid #2a2e39;
            padding: 12px 8px;
            text-transform: uppercase;
        }
        td {
            padding: 14px 8px;
            border-bottom: 1px solid #252934;
            color: #f1f2f6;
            vertical-align: middle;
            font-size: 0.95rem;
        }
        .text-right { text-align: right; }

        /* Calculation Section */
        .calc-section {
            width: 60%;
            margin-left: auto;
            border-top: 1px solid #2a2e39;
            padding-top: 12px;
            font-size: 0.95rem;
            margin-bottom: 20px;
        }
        .calc-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            color: #a4b0be;
        }
        .calc-row strong { color: #f1f2f6; }

        .total-box {
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 10px;
            padding: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 1.2rem;
            font-weight: 800;
        }
        .total-box span {
            color: #2ed573;
            font-size: 1.35rem;
        }

        .actions {
            margin-top: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
        }
        .actions-right {
            display: flex;
            gap: 12px;
            align-items: center;
        }
        .btn {
            text-align: center;
            padding: 12px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 700;
            font-size: 0.95rem;
            transition: 0.2s ease;
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        .btn-back {
            background: #252834;
            border: 1px solid #2a2e39;
            color: #ced6e0;
        }
        .btn-back:hover {
            border-color: #ffa502;
            color: #ffa502;
        }
        .btn-print {
            background: #2ed573;
            color: #000;
        }
        .btn-print:hover { background: #26af5f; }

        .btn-cancel {
            background: rgba(255, 71, 87, 0.15);
            color: #ff4757;
            border: 1px solid #ff4757;
        }
        .btn-cancel:hover {
            background: #ff4757;
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(255, 71, 87, 0.4);
        }

        /* Mobile View */
        @media (max-width: 640px) {
            body { padding: 15px 10px; }
            .container { padding: 20px 14px; border-radius: 14px; }
            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
                padding-bottom: 14px;
            }
            .brand { font-size: 1.4rem; }
            .eta-banner {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            .eta-badge {
                width: 100%;
                text-align: center;
            }
            #deliveryMap { height: 260px; min-height: 260px; }
            .tracker-card { padding: 16px 8px; margin-bottom: 18px; }
            .step-circle { width: 28px; height: 28px; font-size: 0.75rem; }
            .step-label { font-size: 0.65rem; margin-top: 6px; }
            .tracker-line { top: 14px; left: 10%; right: 10%; }
            .meta-grid { grid-template-columns: 1fr; gap: 12px; padding: 14px; }
            .meta-grid > div:last-child {
                text-align: left !important;
                border-top: 1px dashed #2a2e39;
                padding-top: 10px;
            }
            .review-input-group { flex-direction: column; }
            th, td { padding: 10px 4px; font-size: 0.85rem; }
            .calc-section { width: 100%; margin-left: 0; }
            .total-box { padding: 14px; font-size: 1.05rem; }
            .total-box span { font-size: 1.2rem; }
            .actions { flex-direction: column; gap: 10px; margin-top: 18px; }
            .actions-right { flex-direction: column; width: 100%; gap: 10px; }
            .btn { width: 100%; }
        }

        /* Print Media Styles */
        @media print {
            body { background: #ffffff !important; color: #000000 !important; padding: 0; }
            .container {
                border: none !important;
                box-shadow: none !important;
                margin: 0 auto;
                max-width: 100% !important;
                background: #ffffff !important;
                color: #000000 !important;
                padding: 15px 0;
            }
            .brand { color: #000000 !important; }
            .actions, .tracker-card, .eta-banner, .map-wrapper, .rating-box, #statusUpdateToast { display: none !important; }
            .meta-grid, .total-box {
                background: #f8f9fa !important;
                border: 1px solid #ddd !important;
                color: #000000 !important;
            }
            .meta-item, th, .calc-row { color: #555555 !important; }
            .meta-item strong, td, .calc-row strong, .total-box span { color: #000000 !important; }
        }
    </style>
</head>
<body>

    <!-- Toast Notification Banner -->
    <div id="statusUpdateToast">
        🔔 Status Update: <span id="toastStatusText"></span>
    </div>

    <!-- Hidden element: safely provides address to JS without syntax errors -->
    <div id="hiddenSafeAddress" style="display: none;"><%= displayDeliveryAddress %></div>

    <div class="container">
        <!-- Header -->
        <div class="header">
            <div>
                <div class="brand">&#127828; Delicious</div>
                <small style="color: #a4b0be;"><%= (restaurant != null) ? restaurant.getName() + " &bull; " : "" %>Official Tax Invoice & Live Tracker</small>
            </div>
            <div>
                <span class="badge <%= isCancelled ? "badge-cancelled" : "badge-placed" %>">
                    <%= currentStatus %>
                </span>
            </div>
        </div>

        <!-- Dynamic ETA Countdown Banner -->
        <% if (!isCancelled) { %>
            <div class="eta-banner <%= isDelivered ? "delivered-banner" : "" %>">
                <div class="eta-left">
                    <div class="eta-icon"><%= isDelivered ? "🎉" : (currentStep == 2 ? "🛵" : "⏳") %></div>
                    <div>
                        <div class="eta-title">
                            <%= isDelivered ? "Order Delivered!" : (currentStep == 2 ? "Valet is on the way!" : (currentStep == 1 ? "Chef is preparing your food" : "Order Placed & Confirmed")) %>
                        </div>
                        <div class="eta-subtitle">
                            <%= isDelivered ? "Hope you enjoy your delicious meal!" : "Estimated arrival at your door" %>
                        </div>
                    </div>
                </div>
                <div class="eta-badge <%= isDelivered ? "badge-done" : "" %>" id="etaCountdownBadge">
                    <%= isDelivered ? "Delivered" : "Arriving in ~" + remainingMinutes + " mins" %>
                </div>
            </div>
        <% } %>

        <!-- POST-DELIVERY RATING WIDGET (Delivered only) -->
        <% if (isDelivered) { %>
            <div class="rating-box" id="ratingBox">
                <% if (existingRating != null) { %>
                    <div class="review-thankyou">
                        <div style="font-size: 1.4rem; margin-bottom: 6px;">
                            <% for (int s = 0; s < existingRating.getRating(); s++) { %>⭐<% } %>
                        </div>
                        <div>🎉 <strong>Thank you!</strong> Your rating has been recorded in our system.</div>
                        <% if (existingRating.getTags() != null && !existingRating.getTags().isEmpty()) { %>
                            <div style="font-size: 0.85rem; color: #a4b0be; margin-top: 6px;">
                                Badges: <span style="color: #2ed573;"><%= existingRating.getTags() %></span>
                            </div>
                        <% } %>
                        <% if (existingRating.getComment() != null && !existingRating.getComment().isEmpty()) { %>
                            <div style="font-size: 0.88rem; color: #ced6e0; margin-top: 4px; font-style: italic;">
                                "<%= existingRating.getComment() %>"
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div id="ratingFormContent">
                        <div class="rating-title">⭐ How was your meal from Delicious?</div>
                        <div class="rating-subtitle">Rate your delivery experience to help us improve!</div>

                        <div class="stars-container" id="starsContainer">
                            <span class="star-item active" data-val="1" onclick="setRating(1)">★</span>
                            <span class="star-item active" data-val="2" onclick="setRating(2)">★</span>
                            <span class="star-item active" data-val="3" onclick="setRating(3)">★</span>
                            <span class="star-item active" data-val="4" onclick="setRating(4)">★</span>
                            <span class="star-item active" data-val="5" onclick="setRating(5)">★</span>
                        </div>
                        <div class="star-status-text" id="starStatusText">⭐⭐⭐⭐⭐ Loved it!</div>

                        <div class="compliment-tags">
                            <span class="comp-tag selected" onclick="toggleTag(this)">⚡ Lightning Fast</span>
                            <span class="comp-tag selected" onclick="toggleTag(this)">🔥 Piping Hot</span>
                            <span class="comp-tag" onclick="toggleTag(this)">👌 Great Packaging</span>
                            <span class="comp-tag" onclick="toggleTag(this)">😋 Super Tasty</span>
                        </div>

                        <div class="review-input-group">
                            <input type="text" id="reviewComment" class="review-input" placeholder="Leave a quick note for the chef... (optional)">
                            <button type="button" id="submitRatingBtn" class="review-submit-btn" onclick="submitReview()">Submit Rating &#10004;</button>
                        </div>
                    </div>

                    <div class="review-thankyou" id="ratingThankYou" style="display: none;">
                        🎉 Thank you for your feedback! Your rating has been permanently recorded.
                    </div>
                <% } %>
            </div>
        <% } %>

        <!-- Live Visual Delivery Map -->
        <% if (!isCancelled) { %>
            <div class="map-wrapper">
                <div class="map-header">
                    <div class="map-live-pulse">
                        <span class="pulse-dot"></span>
                        <span>LIVE DELIVERY TRACKING</span>
                    </div>
                    <span id="mapLiveStatusText"><%= (currentStep == 2) ? "⚡ Valet Approaching Doorstep" : "⚡ Kitchen & Courier Sync" %></span>
                </div>
                <div id="deliveryMap"></div>
            </div>
        <% } %>

        <!-- Visual Order Status Progress Bar -->
        <div class="tracker-card">
            <% if (isCancelled) { %>
                <div class="tracker-cancelled">
                    <span style="font-size: 1.2rem;">&#10008;</span>
                    This order has been cancelled and will not be prepared or delivered.
                </div>
            <% } else { %>
                <div class="tracker-title">Order Status Steps</div>
                <div class="tracker-steps">
                    <div class="tracker-line">
                        <div class="tracker-line-progress" style="width: <%= progressWidth %>%;"></div>
                    </div>
                    
                    <div class="tracker-step <%= currentStep >= 0 ? (currentStep == 0 ? "active" : "completed") : "" %>">
                        <div class="step-circle">&#10003;</div>
                        <div class="step-label">Placed</div>
                    </div>

                    <div class="tracker-step <%= currentStep > 1 ? "completed" : (currentStep == 1 ? "active" : "") %>">
                        <div class="step-circle"><%= currentStep > 1 ? "&#10003;" : "2" %></div>
                        <div class="step-label">Preparing</div>
                    </div>

                    <div class="tracker-step <%= currentStep > 2 ? "completed" : (currentStep == 2 ? "active" : "") %>">
                        <div class="step-circle"><%= currentStep > 2 ? "&#10003;" : "3" %></div>
                        <div class="step-label">On the Way</div>
                    </div>

                    <div class="tracker-step <%= currentStep == 3 ? "completed" : "" %>">
                        <div class="step-circle"><%= currentStep == 3 ? "&#10003;" : "4" %></div>
                        <div class="step-label">Delivered</div>
                    </div>
                </div>
            <% } %>
        </div>

        <!-- Customer & Order Meta Information -->
        <div class="meta-grid">
            <div>
                <div class="meta-item">Order ID: <strong>#<%= order.getOrderId() %></strong></div>
                <div class="meta-item">Restaurant: <strong><%= (restaurant != null) ? restaurant.getName() : "Delicious Partner" %></strong></div>
                <div class="meta-item">Customer: <strong><%= currentUser.getUsername() %></strong></div>
                <div class="meta-item">Contact: <strong><%= currentUser.getPhone() != null ? currentUser.getPhone() : "N/A" %></strong></div>
            </div>
            <div style="text-align: right;">
                <div class="meta-item">Date: <strong><%= formattedReceiptDate %></strong></div>
                <div class="meta-item">Payment: 
                    <strong><%= paymentMode %> 
                        <% if (isCOD && !isDelivered) { %>
                            (<span style="color: #ffa502;">Pay on Delivery ⏳</span>)
                        <% } else if (isCOD && isDelivered) { %>
                            (<span style="color: #2ed573;">Collected in Cash &#10004;</span>)
                        <% } else { %>
                            (<span style="color: #2ed573;">Paid Online &#10004;</span>)
                        <% } %>
                    </strong>
                </div>
                <div class="meta-item" style="word-break: break-word;">
                    Delivery: <strong><%= displayDeliveryAddress %></strong>
                </div>
            </div>
        </div>

        <!-- Itemized Order Table -->
        <table>
            <thead>
                <tr>
                    <th>Item Description</th>
                    <th style="text-align: right;">Item Total</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (itemList != null && !itemList.isEmpty()) {
                        for (OrderItem it : itemList) {
                            String dishName = (itemNames != null && itemNames.containsKey(it.getMenuId())) 
                                              ? itemNames.get(it.getMenuId()) 
                                              : ("Menu Item #" + it.getMenuId());
                %>
                    <tr>
                        <td>
                            <strong><%= dishName %></strong>
                            <div style="font-size: 0.8rem; color: #a4b0be;">Item Code: #<%= it.getMenuId() %></div>
                        </td>
                        <td class="text-right" style="font-weight: 700; color: #ffa502;">
                            &#8377;<%= String.format("%.2f", it.getTotalAmount()) %>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="2" style="text-align: center; color: #747d8c; padding: 20px;">
                            No item records found for this order.
                        </td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <!-- Subtotal / Discount Summary -->
        <div class="calc-section">
            <div class="calc-row">
                <span>Items Subtotal:</span>
                <strong>&#8377;<%= String.format("%.2f", itemsSubtotal > 0 ? itemsSubtotal : totalPaid) %></strong>
            </div>

            <% if (discountApplied > 0) { %>
            <div class="calc-row" style="color: #2ed573;">
                <span>Promo Discount:</span>
                <strong>- &#8377;<%= String.format("%.2f", discountApplied) %></strong>
            </div>
            <% } %>
        </div>

        <div class="total-box">
            <div><%= (isCOD && !isDelivered) ? "Amount to Pay in Cash" : "Grand Total Paid" %></div>
            <div><span>&#8377;<%= String.format("%.2f", totalPaid) %></span></div>
        </div>

        <!-- Action Buttons -->
        <div class="actions">
            <a href="orderHistory" target="_self" class="btn btn-back">&larr; Back to Orders</a>
            <div class="actions-right">
                <% if (isPlaced) { %>
                    <form action="orderDetails" method="post" onsubmit="return confirm('Are you sure you want to cancel this order?');" style="margin: 0;">
                        <input type="hidden" name="action" value="cancelOrder">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                        <button type="submit" class="btn btn-cancel">&#10008; Cancel Order</button>
                    </form>
                <% } %>
                <button onclick="window.print()" class="btn btn-print">&#128438; Print / Save PDF</button>
            </div>
        </div>
    </div>

    <!-- Live Leaflet Map Script -->
    <% if (!isCancelled) { %>
    <script>
        window.addEventListener("load", function () {
            if (typeof L === 'undefined') {
                console.error("Leaflet library failed to load.");
                return;
            }

            const mapContainer = document.getElementById('deliveryMap');
            if (!mapContainer) return;

            // Stop click bubbling on the entire map container
            L.DomEvent.disableClickPropagation(mapContainer);

            // Safe address retrieval
            const safeAddrEl = document.getElementById("hiddenSafeAddress");
            let customerAddressText = safeAddrEl ? safeAddrEl.innerText.trim() : "Your Doorstep";
            let shortAddressText = customerAddressText.length > 32 
                ? customerAddressText.substring(0, 30) + "..." 
                : customerAddressText;

            // Coordinates for Restaurant and Customer (Bengaluru)
            const restaurantLoc = [12.9716, 77.5946];
            const customerLoc   = [12.9850, 77.6250];

            // 1. Initialize Map
            const map = L.map('deliveryMap', {
                center: [12.9783, 77.6098],
                zoom: 13,
                zoomControl: false,
                attributionControl: false,
                tap: false
            });

            // 2. OpenStreetMap Standard Free Tiles
            L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19
            }).addTo(map);

            setTimeout(function() {
                map.invalidateSize();
            }, 250);

            // Custom Icon Generator
            function createIcon(emoji) {
                return L.divIcon({
                    html: '<div style="background: #111317; border: 2px solid #2ed573; border-radius: 50%; width: 38px; height: 38px; display: flex; align-items: center; justify-content: center; font-size: 20px; box-shadow: 0 4px 14px rgba(0,0,0,0.9);">' + emoji + '</div>',
                    className: 'custom-map-icon',
                    iconSize: [38, 38],
                    iconAnchor: [19, 19],
                    popupAnchor: [0, -20]
                });
            }

            // 3. Markers with Floating Badges
            const restName = "<%= (restaurant != null) ? restaurant.getName() : "Delicious Partner Kitchen" %>";
            
            L.marker(restaurantLoc, { icon: createIcon('🏪') })
                .addTo(map)
                .bindTooltip("<b>" + restName + "</b>", {
                    permanent: true,
                    direction: 'top',
                    className: 'map-badge-tooltip',
                    offset: [0, -18]
                });

            L.marker(customerLoc, { icon: createIcon('📍') })
                .addTo(map)
                .bindTooltip("<b>📍 " + shortAddressText + "</b>", {
                    permanent: true,
                    direction: 'top',
                    className: 'map-badge-tooltip',
                    offset: [0, -18]
                });

            // 4. Delivery Route Path
            const routePath = [
                restaurantLoc,
                [12.9740, 77.6010],
                [12.9780, 77.6120],
                [12.9810, 77.6180],
                customerLoc
            ];

            const routeLine = L.polyline(routePath, {
                color: '#2ed573',
                weight: 5,
                dashArray: '8, 8',
                opacity: 0.95
            }).addTo(map);

            map.fitBounds(routeLine.getBounds(), { padding: [55, 55] });

            function getPointAtRatio(ratio) {
                if (ratio <= 0) return routePath[0];
                if (ratio >= 1) return routePath[routePath.length - 1];

                const totalSegments = routePath.length - 1;
                const scaled = ratio * totalSegments;
                const idx = Math.floor(scaled);
                const subRatio = scaled - idx;

                const p1 = routePath[idx];
                const p2 = routePath[Math.min(idx + 1, totalSegments)];

                return [
                    p1[0] + (p2[0] - p1[0]) * subRatio,
                    p1[1] + (p2[1] - p1[1]) * subRatio
                ];
            }

            // 5. Dynamic Rider Movement based on Order Status
            <% if (isDelivered) { %>
                L.marker(customerLoc, { icon: createIcon('🛵') })
                    .addTo(map)
                    .bindTooltip("<b>🎉 Food Delivered</b>", {
                        permanent: true,
                        direction: 'bottom',
                        className: 'map-badge-tooltip',
                        offset: [0, 18]
                    });
            <% } else { %>
                const orderId = "<%= order.getOrderId() %>";
                const step = <%= currentStep %>;
                let currentMinutes = <%= remainingMinutes %>;

                let minBound = 0.05;
                let maxBound = 0.25;

                if (step === 2) {
                    minBound = 0.65;
                    maxBound = 0.95;
                } else if (step === 1) {
                    minBound = 0.15;
                    maxBound = 0.35;
                } else {
                    minBound = 0.05;
                    maxBound = 0.15;
                }

                const storageRatioKey = 'rider_ratio_' + orderId + '_' + step;
                let savedRatio = parseFloat(sessionStorage.getItem(storageRatioKey));
                let riderRatio = (!isNaN(savedRatio) && savedRatio >= minBound && savedRatio <= maxBound) 
                    ? savedRatio 
                    : minBound;

                const courierMarker = L.marker(getPointAtRatio(riderRatio), { icon: createIcon('🛵') })
                    .addTo(map);

                function updateRiderTooltip(mins) {
                    let label = (step === 2) ? "🛵 Approaching Doorstep" : "🛵 Valet on Route";
                    courierMarker.bindTooltip("<b>" + label + " &bull; ~" + mins + "m</b>", {
                        permanent: true,
                        direction: 'bottom',
                        className: 'map-badge-tooltip',
                        offset: [0, 18]
                    }).openTooltip();
                }

                updateRiderTooltip(currentMinutes);

                setInterval(function () {
                    riderRatio += 0.008;
                    if (riderRatio > maxBound) {
                        riderRatio = minBound;
                    }
                    sessionStorage.setItem(storageRatioKey, riderRatio.toFixed(4));
                    courierMarker.setLatLng(getPointAtRatio(riderRatio));
                }, 800);

                const etaElement = document.getElementById("etaCountdownBadge");
                if (currentMinutes > 1) {
                    setInterval(function () {
                        currentMinutes = Math.max(1, currentMinutes - 1);
                        if (etaElement) {
                            etaElement.innerText = "Arriving in ~" + currentMinutes + " mins";
                        }
                        updateRiderTooltip(currentMinutes);
                    }, 60000);
                }
            <% } %>
        });
    </script>
    <% } %>

    <!-- Rating Logic -->
    <script>
        let selectedStars = 5;
        const ratingTexts = {
            1: "⭐ Terrible experience",
            2: "⭐⭐ Below average",
            3: "⭐⭐⭐ Good, but can improve",
            4: "⭐⭐⭐⭐ Really good food!",
            5: "⭐⭐⭐⭐⭐ Loved it!"
        };

        function setRating(val) {
            selectedStars = val;
            const stars = document.querySelectorAll("#starsContainer .star-item");
            stars.forEach(s => {
                const sVal = parseInt(s.getAttribute("data-val"));
                if (sVal <= val) {
                    s.classList.add("active");
                } else {
                    s.classList.remove("active");
                }
            });
            document.getElementById("starStatusText").innerText = ratingTexts[val] || "";
        }

        function toggleTag(el) {
            el.classList.toggle("selected");
        }

        function submitReview() {
            const btn = document.getElementById("submitRatingBtn");
            if (btn) {
                btn.disabled = true;
                btn.innerText = "Saving...";
            }

            const orderId = "<%= order.getOrderId() %>";
            const stars = selectedStars;
            const comment = document.getElementById("reviewComment") ? document.getElementById("reviewComment").value.trim() : "";
            
            const tags = Array.from(document.querySelectorAll('.comp-tag.selected'))
                              .map(t => t.innerText.trim())
                              .join(", ");

            const params = new URLSearchParams();
            params.append("orderId", orderId);
            params.append("rating", stars);
            params.append("tags", tags);
            params.append("comment", comment);

            fetch("submitRating", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    const formContent = document.getElementById("ratingFormContent");
                    const thankYou = document.getElementById("ratingThankYou");
                    if (formContent && thankYou) {
                        formContent.style.display = "none";
                        thankYou.style.display = "block";
                    }
                } else {
                    alert(data.message || "Failed to submit rating.");
                    if (btn) {
                        btn.disabled = false;
                        btn.innerText = "Submit Rating ✔";
                    }
                }
            })
            .catch(err => {
                console.error("Error submitting rating:", err);
                alert("Something went wrong while saving your rating.");
                if (btn) {
                    btn.disabled = false;
                    btn.innerText = "Submit Rating ✔";
                }
            });
        }
    </script>

    <!-- Audio Chime & In-Place Polling (No New Tab Spawning) -->
    <script>
        const orderId = "<%= order.getOrderId() %>";
        const currentServerStatus = "<%= currentStatus %>";

        function playCustomerChime() {
            try {
                const AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (!AudioCtx) return;
                const ctx = new AudioCtx();

                const playTone = (freq, delay, duration) => {
                    const osc = ctx.createOscillator();
                    const gain = ctx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(freq, ctx.currentTime + delay);
                    gain.gain.setValueAtTime(0.25, ctx.currentTime + delay);
                    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + duration);
                    osc.connect(gain);
                    gain.connect(ctx.destination);
                    osc.start(ctx.currentTime + delay);
                    osc.stop(ctx.currentTime + delay + duration);
                };

                playTone(523.25, 0, 0.3);       // C5
                playTone(659.25, 0.15, 0.3);    // E5
                playTone(783.99, 0.30, 0.5);    // G5
            } catch (e) {
                console.warn("Audio Context playback prevented:", e);
            }
        }

        window.addEventListener('DOMContentLoaded', () => {
            const storageKey = 'cust_order_status_' + orderId;
            const previousStatus = sessionStorage.getItem(storageKey);

            if (previousStatus && previousStatus !== currentServerStatus) {
                playCustomerChime();

                const toast = document.getElementById('statusUpdateToast');
                const toastText = document.getElementById('toastStatusText');
                if (toast && toastText) {
                    toastText.innerText = currentServerStatus;
                    toast.style.display = 'block';
                    setTimeout(() => {
                        toast.style.opacity = '0';
                        setTimeout(() => { toast.style.display = 'none'; }, 400);
                    }, 4000);
                }
            }

            sessionStorage.setItem(storageKey, currentServerStatus);
        });

        // Use location.replace so the reload strictly stays in the current window
        <% if (!isDelivered && !isCancelled) { %>
            setTimeout(function() {
                window.location.replace("orderDetails?orderId=" + orderId);
            }, 8000);
        <% } else { %>
            sessionStorage.removeItem('cust_order_status_' + orderId);
        <% } %>
    </script>
</body>
</html>