<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tap.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    if (request.getAttribute("orderId") == null) {
        response.sendRedirect("home");
        return;
    }
    Object orderIdObj = request.getAttribute("orderId");
    Object orderAmountObj = request.getAttribute("orderAmount");
    String rawAddress = (request.getAttribute("deliveryAddress") != null) 
                        ? request.getAttribute("deliveryAddress").toString() 
                        : "Standard Address";

    String paymentMode = (request.getAttribute("paymentMode") != null) 
                        ? request.getAttribute("paymentMode").toString().trim() 
                        : "UPI";
    boolean isCOD = "COD".equalsIgnoreCase(paymentMode) || "Cash on Delivery".equalsIgnoreCase(paymentMode);

    // Parse cooking/delivery notes if present in format "... [Note: XYZ]"
    String cleanAddress = rawAddress;
    String specialNote = null;
    if (rawAddress.contains("[Note:")) {
        int noteIndex = rawAddress.indexOf("[Note:");
        cleanAddress = rawAddress.substring(0, noteIndex).trim();
        specialNote = rawAddress.substring(noteIndex + 6).replace("]", "").trim();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed #<%= orderIdObj %> - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f1015;
            color: #f1f2f6;
            padding: 40px 15px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 20px;
            padding: 36px 30px;
            max-width: 540px;
            width: 100%;
            text-align: center;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.6);
        }
        .check-badge {
            width: 72px;
            height: 72px;
            line-height: 72px;
            background: rgba(46, 213, 115, 0.15);
            color: #2ed573;
            font-size: 2.4rem;
            border-radius: 50%;
            margin: 0 auto 18px auto;
            border: 2px solid #2ed573;
            box-shadow: 0 0 20px rgba(46, 213, 115, 0.3);
        }
        h2 {
            margin-bottom: 8px;
            font-size: 1.8rem;
            color: #ffffff;
            font-weight: 800;
        }
        p {
            color: #a4b0be;
            font-size: 0.92rem;
            line-height: 1.5;
            margin-bottom: 22px;
        }
        .details-box {
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 14px;
            padding: 18px 20px;
            text-align: left;
            margin-bottom: 24px;
            font-size: 0.92rem;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
            gap: 12px;
        }
        .detail-row:last-child {
            margin-bottom: 0;
        }
        .label {
            color: #747d8c;
            font-weight: 600;
            white-space: nowrap;
        }
        .highlight {
            color: #ffa502;
            font-weight: 700;
        }
        .amount {
            color: #2ed573;
            font-weight: 800;
            font-size: 1.15rem;
        }
        
        .instruction-tag {
            background: rgba(112, 161, 255, 0.12);
            border: 1px dashed rgba(112, 161, 255, 0.4);
            color: #70a1ff;
            border-radius: 8px;
            padding: 10px 12px;
            margin-top: 10px;
            font-size: 0.85rem;
            display: flex;
            align-items: flex-start;
            gap: 8px;
        }

        .btn-group {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn-track {
            flex: 1 1 100%;
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            text-decoration: none;
            padding: 13px 20px;
            border-radius: 10px;
            font-weight: 800;
            font-size: 1rem;
            transition: 0.2s ease;
            box-shadow: 0 4px 14px rgba(46, 213, 115, 0.3);
            display: inline-block;
        }
        .btn-track:hover {
            transform: scale(1.02);
            box-shadow: 0 6px 18px rgba(46, 213, 115, 0.45);
        }
        .btn-sub {
            flex: 1;
            background: #252834;
            color: #ced6e0;
            border: 1px solid #2a2e39;
            text-decoration: none;
            padding: 11px 16px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.9rem;
            transition: 0.2s ease;
            text-align: center;
        }
        .btn-sub:hover {
            border-color: #ffa502;
            color: #ffa502;
        }

        @media (max-width: 600px) {
            body { padding: 20px 12px; }
            .card { padding: 24px 16px; border-radius: 16px; }
            .check-badge { width: 62px; height: 62px; line-height: 62px; font-size: 2rem; margin-bottom: 14px; }
            h2 { font-size: 1.5rem; }
            p { font-size: 0.85rem; margin-bottom: 16px; }
            .details-box { padding: 14px; font-size: 0.88rem; margin-bottom: 18px; }
            .btn-group { flex-direction: column; gap: 10px; }
            .btn-track, .btn-sub { width: 100%; }
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="check-badge">&#10004;</div>
        <h2>Order Confirmed!</h2>
        <p>Thank you for your order. The kitchen has received your ticket and is preparing your meal.</p>

        <div class="details-box">
            <div class="detail-row">
                <span class="label">Order Reference:</span>
                <span class="highlight">#<%= orderIdObj %></span>
            </div>
            <div class="detail-row">
                <span class="label"><%= isCOD ? "Amount to Pay on Delivery:" : "Amount Paid:" %></span>
                <span class="amount" style="<%= isCOD ? "color: #ffa502;" : "" %>">&#8377;<%= (orderAmountObj != null) ? String.format("%.2f", Double.parseDouble(orderAmountObj.toString())) : "0.00" %></span>
            </div>
            <div class="detail-row">
                <span class="label">Payment Mode:</span>
                <% if (isCOD) { %>
                    <span class="highlight">COD (<span style="color: #ffa502;">Pay Cash to Valet ⏳</span>)</span>
                <% } else { %>
                    <span class="highlight"><%= paymentMode %> (<span style="color: #2ed573;">Paid Online &#10004;</span>)</span>
                <% } %>
            </div>
            <div class="detail-row">
                <span class="label">Contact Mobile:</span>
                <span><%= request.getAttribute("phone") %></span>
            </div>
            <div class="detail-row">
                <span class="label">Delivery To:</span>
                <span style="max-width: 65%; text-align: right; color: #ffffff;"><%= cleanAddress %></span>
            </div>

            <% if (specialNote != null && !specialNote.isEmpty()) { %>
                <div class="instruction-tag">
                    <span>📝</span>
                    <div>
                        <strong>Instructions:</strong> <%= specialNote %>
                    </div>
                </div>
            <% } %>
        </div>

        <div class="btn-group">
            <a href="orderDetails?orderId=<%= orderIdObj %>" target="_self" class="btn-track">🛵 Track Order & View Receipt &rarr;</a>
            <a href="orderHistory" target="_self" class="btn-sub">&#128220; Past Orders</a>
            <a href="home" target="_self" class="btn-sub">&#127828; Explore Menu</a>
        </div>
    </div>
</body>
</html>