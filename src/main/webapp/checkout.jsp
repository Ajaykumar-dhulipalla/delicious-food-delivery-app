<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tap.model.Cart" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.User" %>
<%
    // Prevent browser caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 1. Session Expiry & Auth Guard
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Empty Cart & Direct URL Protection
    Cart cart = (Cart) session.getAttribute("cart");
    if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
    }

    String defaultName = (loggedInUser.getUsername() != null) ? loggedInUser.getUsername() : "";
    String defaultPhone = (loggedInUser.getPhone() != null) ? loggedInUser.getPhone() : "";
    String defaultAddress = (loggedInUser.getAddress() != null) ? loggedInUser.getAddress() : "";
    double cartTotal = cart.getTotalAmount();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f1015;
            color: #f1f2f6;
            margin: 0;
            padding: 30px 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 980px;
            margin: 0 auto;
        }
        .top-bar {
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }
        .back-btn {
            text-decoration: none;
            color: #2ed573;
            font-weight: 700;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            padding: 10px 20px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: 0.25s ease;
        }
        .back-btn:hover {
            background: #2ed573;
            color: #000;
        }
        h2 {
            text-align: center;
            font-size: 2rem;
            color: #ffffff;
            margin-bottom: 30px;
        }
        .checkout-grid {
            display: grid;
            grid-template-columns: 1fr 1.25fr;
            gap: 25px;
        }
        .box {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.45);
        }
        .box-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #2a2e39;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        h3 {
            margin: 0;
            color: #ffa502;
            font-size: 1.25rem;
        }
        .autofill-badge {
            font-size: 0.75rem;
            font-weight: 700;
            color: #2ed573;
            background: rgba(46, 213, 115, 0.12);
            padding: 4px 10px;
            border-radius: 12px;
            border: 1px solid rgba(46, 213, 115, 0.3);
        }
        .summary-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 0.95rem;
        }

        /* Multiple Address Selectors */
        .address-tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }
        .addr-tab {
            flex: 1;
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            padding: 8px 6px;
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 700;
            cursor: pointer;
            text-align: center;
            transition: 0.2s;
        }
        .addr-tab.active {
            background: rgba(255, 165, 2, 0.15);
            border-color: #ffa502;
            color: #ffa502;
        }

        /* Autocomplete Search & Locate Me Bar */
        .autocomplete-container {
            position: relative;
            margin-bottom: 8px;
        }
        .locate-bar {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        .search-addr-input {
            flex: 1;
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 8px;
            padding: 10px 12px;
            color: #ffffff;
            font-size: 0.9rem;
            outline: none;
            transition: 0.2s;
        }
        .search-addr-input:focus {
            border-color: #ffa502;
        }
        .btn-locate {
            background: rgba(46, 213, 115, 0.12);
            border: 1px solid #2ed573;
            color: #2ed573;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 700;
            cursor: pointer;
            white-space: nowrap;
            transition: 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .btn-locate:hover {
            background: #2ed573;
            color: #000;
        }
        .suggestions-dropdown {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            right: 0;
            background: #14161d;
            border: 1px solid #2a2e39;
            border-radius: 10px;
            max-height: 220px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.7);
        }
        .suggestion-item {
            padding: 10px 14px;
            font-size: 0.86rem;
            color: #ced6e0;
            cursor: pointer;
            border-bottom: 1px solid #252834;
            display: flex;
            align-items: flex-start;
            gap: 8px;
            line-height: 1.4;
        }
        .suggestion-item:last-child {
            border-bottom: none;
        }
        .suggestion-item:hover {
            background: #252936;
            color: #ffa502;
        }
        .suggestion-item .pin-icon {
            font-size: 0.95rem;
            color: #ff4757;
            margin-top: 1px;
        }

        /* Cooking Instructions & Quick Chips */
        .chip-group {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 6px;
            margin-bottom: 8px;
        }
        .instruction-chip {
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #a4b0be;
            font-size: 0.75rem;
            padding: 4px 10px;
            border-radius: 14px;
            cursor: pointer;
            transition: 0.2s;
        }
        .instruction-chip:hover {
            border-color: #70a1ff;
            color: #70a1ff;
        }
        .instruction-chip.selected {
            background: rgba(112, 161, 255, 0.2);
            border-color: #70a1ff;
            color: #ffffff;
            font-weight: 700;
        }

        /* Delivery Tip Options */
        .tip-container {
            background: #121319;
            border: 1px solid #2a2e39;
            border-radius: 10px;
            padding: 14px;
            margin: 15px 0;
        }
        .tip-title {
            font-size: 0.85rem;
            font-weight: 700;
            color: #2ed573;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
        }
        .tip-chips {
            display: flex;
            gap: 8px;
        }
        .tip-btn {
            flex: 1;
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #ced6e0;
            padding: 8px 4px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            text-align: center;
            transition: 0.2s;
        }
        .tip-btn.active {
            background: #2ed573;
            color: #000;
            border-color: #2ed573;
        }

        .coupon-box {
            background: #121319;
            border: 1px dashed #ffa502;
            border-radius: 10px;
            padding: 14px;
            margin: 18px 0 15px 0;
        }
        .coupon-input-group {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }
        .coupon-input {
            flex: 1;
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 6px;
            padding: 9px 12px;
            color: #fff;
            text-transform: uppercase;
            font-weight: 600;
            font-size: 0.9rem;
        }
        .coupon-input:disabled {
            background: #1e212b;
            color: #747d8c;
            cursor: not-allowed;
        }
        .apply-btn {
            background: #ffa502;
            color: #000;
            border: none;
            padding: 9px 18px;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            transition: 0.2s;
        }
        .apply-btn:hover:not(:disabled) {
            background: #ffb833;
        }
        .apply-btn:disabled {
            background: #474c58;
            color: #2f3542;
            cursor: not-allowed;
        }
        #couponMsg {
            font-size: 0.82rem;
            margin-top: 8px;
            display: none;
            font-weight: 600;
        }
        .discount-row {
            display: none;
            justify-content: space-between;
            align-items: center;
            color: #2ed573;
            font-size: 0.95rem;
            font-weight: 700;
            margin-top: 8px;
        }
        .tip-row {
            display: none;
            justify-content: space-between;
            align-items: center;
            color: #ffa502;
            font-size: 0.95rem;
            font-weight: 700;
            margin-top: 8px;
        }
        .remove-coupon-btn {
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid #ff4757;
            color: #ff4757;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 8px;
            transition: 0.2s;
        }
        .remove-coupon-btn:hover {
            background: #ff4757;
            color: #fff;
        }
        .total-row {
            border-top: 2px dashed #2a2e39;
            margin-top: 15px;
            padding-top: 15px;
            display: flex;
            justify-content: space-between;
            font-size: 1.3rem;
            font-weight: 800;
            color: #ff4757;
        }
        .form-group {
            margin-bottom: 16px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 0.88rem;
            color: #a4b0be;
            font-weight: 600;
        }
        input[type="text"], input[type="tel"], textarea, select {
            width: 100%;
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 8px;
            padding: 12px;
            color: #fff;
            font-family: inherit;
            font-size: 0.95rem;
        }
        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: #2ed573;
        }
        .place-order-btn {
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            border: none;
            width: 100%;
            padding: 14px;
            border-radius: 8px;
            font-size: 1.1rem;
            font-weight: 800;
            cursor: pointer;
            transition: 0.25s ease;
            margin-top: 10px;
        }
        .place-order-btn:hover {
            transform: scale(1.02);
            box-shadow: 0 6px 18px rgba(46, 213, 115, 0.4);
        }

        /* ================= MOBILE VIEW ONLY ================= */
        @media (max-width: 768px) {
            body { padding: 14px 12px; }
            .top-bar { margin-bottom: 16px; gap: 8px; }
            .back-btn { padding: 8px 12px; font-size: 0.82rem; flex: 1; justify-content: center; }
            h2 { font-size: 1.5rem; margin-bottom: 20px; }
            .checkout-grid { grid-template-columns: 1fr; gap: 16px; }
            .box { padding: 16px; border-radius: 14px; }
            h3 { font-size: 1.15rem; }
            input[type="text"], input[type="tel"], textarea, select { padding: 11px; font-size: 1rem; }
            .place-order-btn { padding: 13px; font-size: 1rem; }
            .locate-bar { flex-direction: column; align-items: stretch; }
            .btn-locate { justify-content: center; padding: 10px 0; }
        }
    </style>
</head>
<body>
<div class="container">
        <div class="top-bar">
            <a href="cart.jsp" class="back-btn">&larr; Back to Cart</a>
            <a href="profile.jsp" class="back-btn" style="color: #ffa502;">&#128100; My Profile</a>
        </div>
        <h2>Complete Your Order</h2>

        <div class="checkout-grid">
            <!-- Left: Order Summary, Tip & Coupons -->
            <div class="box">
                <div class="box-header">
                    <h3>Order Summary</h3>
                </div>
                <%
                    for (CartItem item : cart.getItems().values()) {
                %>
                    <div class="summary-item">
                        <span><%= item.getName() %> &times; <%= item.getQuantity() %></span>
                        <span style="font-weight: 700; color: #ced6e0;">&#8377;<%= String.format("%.2f", item.getTotalPrice()) %></span>
                    </div>
                <%
                    }
                %>

                <!-- Delivery Partner Tip Selector -->
                <div class="tip-container">
                    <div class="tip-title">
                        <span>🚴 Support Delivery Partner</span>
                        <span id="tipLabelText">No Tip</span>
                    </div>
                    <div class="tip-chips">
                        <button type="button" class="tip-btn active" onclick="setTip(0, this)">None</button>
                        <button type="button" class="tip-btn" onclick="setTip(10, this)">+ ₹10</button>
                        <button type="button" class="tip-btn" onclick="setTip(20, this)">+ ₹20</button>
                        <button type="button" class="tip-btn" onclick="setTip(50, this)">+ ₹50</button>
                    </div>
                </div>

                <!-- Coupon Section -->
                <div class="coupon-box">
                    <label style="color: #ffa502; margin: 0; font-size: 0.85rem;">🎟 Apply Promo Code</label>
                    <div class="coupon-input-group">
                        <input type="text" id="couponInput" class="coupon-input" placeholder="WELCOME50 or FEAST20" autocomplete="off">
                        <button type="button" id="applyBtn" class="apply-btn" onclick="applyPromoCode()">Apply</button>
                    </div>
                    <div id="couponMsg"></div>
                </div>

                <div class="summary-item" style="margin-top: 15px;">
                    <span>Item Subtotal:</span>
                    <span style="font-weight: 700;">&#8377;<span id="subtotalVal"><%= String.format("%.2f", cartTotal) %></span></span>
                </div>

                <!-- Tip breakdown row -->
                <div id="tipRow" class="tip-row">
                    <span>Delivery Tip:</span>
                    <span>+ &#8377;<span id="tipVal">0.00</span></span>
                </div>

                <!-- Discount display with Remove button -->
                <div id="discountRow" class="discount-row">
                    <div>
                        <span>Discount (<span id="appliedCodeText"></span>):</span>
                        <button type="button" class="remove-coupon-btn" onclick="removeCoupon()">Remove ✕</button>
                    </div>
                    <span>- &#8377;<span id="discountVal">0.00</span></span>
                </div>

                <div class="total-row">
                    <span>Grand Total:</span>
                    <span>&#8377;<span id="grandTotalVal"><%= String.format("%.2f", cartTotal) %></span></span>
                </div>
            </div>

            <!-- Right: Delivery Details Form -->
            <div class="box">
                <div class="box-header">
                    <h3>Delivery Details</h3>
                    <% if (defaultAddress.length() > 0) { %>
                        <span class="autofill-badge">&#10004; Verified</span>
                    <% } %>
                </div>
                <form action="checkout" method="post" autocomplete="off" onsubmit="prepareFinalSubmission()">
                    <input type="hidden" name="appliedCouponCode" id="hiddenCouponCode" value="">
                    <input type="hidden" name="discountAmount" id="hiddenDiscountAmount" value="0.0">
                    <input type="hidden" name="tipAmount" id="hiddenTipAmount" value="0.0">
                    <input type="hidden" name="finalAmount" id="hiddenFinalAmount" value="<%= cartTotal %>">

                    <div class="form-group">
                        <label>Receiver Name</label>
                        <input type="text" name="customerName" value="<%= defaultName %>" placeholder="Your Full Name" required>
                    </div>

                    <!-- Multiple Saved Address Selectors & Geocoding Autocomplete -->
                    <div class="form-group">
                        <label>Delivery Location</label>
                        <div class="address-tabs">
                            <button type="button" class="addr-tab active" onclick="selectAddressType('home', this)">🏠 Home</button>
                            <button type="button" class="addr-tab" onclick="selectAddressType('work', this)">🏢 Work</button>
                            <button type="button" class="addr-tab" onclick="selectAddressType('other', this)">📍 Other</button>
                        </div>

                        <!-- Live Area / Pincode Search Bar with Locate Button -->
                        <div class="autocomplete-container">
                            <div class="locate-bar">
                                <input type="text" id="areaSearchInput" class="search-addr-input" placeholder="🔍 Search area / pincode (e.g. BTM, Indiranagar, 560076)..." autocomplete="off">
                                <button type="button" id="locateBtn" class="btn-locate" onclick="detectLiveLocation()">📍 Locate Me</button>
                            </div>
                            <div id="checkoutSuggestions" class="suggestions-dropdown"></div>
                        </div>

                        <textarea id="deliveryAddressInput" name="deliveryAddress" rows="3" placeholder="Enter flat/door no, street, locality" required><%= defaultAddress %></textarea>
                    </div>

                    <!-- Cooking & Delivery Notes -->
                    <div class="form-group">
                        <label>Cooking & Delivery Notes (Optional)</label>
                        <div class="chip-group">
                            <span class="instruction-chip" onclick="toggleChip(this, 'Less spicy')">🌶️ Less spicy</span>
                            <span class="instruction-chip" onclick="toggleChip(this, 'Extra napkins & cutlery')">🍴 Extra cutlery</span>
                            <span class="instruction-chip" onclick="toggleChip(this, 'Leave at door')">🚪 Leave at door</span>
                            <span class="instruction-chip" onclick="toggleChip(this, 'Avoid ringing bell')">🔕 Avoid ringing</span>
                        </div>
                        <input type="text" id="specialNotes" name="specialInstructions" placeholder="e.g. Please send extra mint chutney">
                    </div>

                    <div class="form-group">
                        <label>Contact Mobile Number</label>
                        <input type="tel" name="phone" value="<%= defaultPhone %>" placeholder="10-digit mobile number" required>
                    </div>

                    <div class="form-group">
                        <label>Payment Mode</label>
                        <select name="paymentMode">
                            <option value="UPI">UPI / GooglePay / PhonePe</option>
                            <option value="CARD">Credit / Debit Card</option>
                            <option value="COD">Cash on Delivery</option>
                        </select>
                    </div>

                    <button type="submit" class="place-order-btn">Confirm & Place Order &#10004;</button>
                </form>
            </div>
        </div>
    </div>

    <script>
    const originalSubtotal = parseFloat("<%= cartTotal %>");
    let currentDiscount = 0.0;
    let currentTip = 0.0;

    const savedHome = "<%= defaultAddress.replace("\"", "\\\"").replace("\n", " ") %>";
    const savedWork = "Tech Park, 4th Block, Koramangala / Electronic City";

    function selectAddressType(type, btn) {
        document.querySelectorAll('.addr-tab').forEach(t => t.classList.remove('active'));
        btn.classList.add('active');

        const addrBox = document.getElementById("deliveryAddressInput");
        if (type === 'home') {
            addrBox.value = savedHome || "";
            addrBox.placeholder = "Enter home address";
        } else if (type === 'work') {
            addrBox.value = savedWork;
            addrBox.placeholder = "Enter office / tech park address";
        } else {
            addrBox.value = "";
            addrBox.placeholder = "Enter custom / other address";
            addrBox.focus();
        }
    }

    /* ================= LIVE ADDRESS AUTOCOMPLETE & GPS (PHOTON API) ================= */
    const searchInput = document.getElementById("areaSearchInput");
    const suggestionsBox = document.getElementById("checkoutSuggestions");
    const addressTextarea = document.getElementById("deliveryAddressInput");
    let debounceTimer = null;

    if (searchInput) {
        searchInput.addEventListener("input", function() {
            const query = this.value.trim();
            clearTimeout(debounceTimer);

            if (query.length < 3) {
                suggestionsBox.style.display = "none";
                suggestionsBox.innerHTML = "";
                return;
            }

            debounceTimer = setTimeout(() => {
                fetchAddressSuggestions(query);
            }, 250);
        });
    }

    function fetchAddressSuggestions(query) {
        const url = 'https://photon.komoot.io/api/?q=' + encodeURIComponent(query) + '&limit=5&lat=12.9716&lon=77.5946';

        fetch(url)
            .then(res => res.json())
            .then(data => {
                suggestionsBox.innerHTML = "";
                if (!data || !data.features || data.features.length === 0) {
                    suggestionsBox.style.display = "none";
                    return;
                }

                data.features.forEach(item => {
                    const props = item.properties;
                    const parts = [
                        props.name,
                        props.street,
                        props.district,
                        props.city,
                        props.postcode,
                        props.state
                    ].filter(Boolean);

                    const fullFormattedAddress = parts.join(", ");
                    if (!fullFormattedAddress) return;

                    const row = document.createElement("div");
                    row.className = "suggestion-item";
                    row.innerHTML = '<span class="pin-icon">📍</span><span>' + fullFormattedAddress + '</span>';

                    row.addEventListener("click", () => {
                        addressTextarea.value = fullFormattedAddress;
                        searchInput.value = props.name || props.city || query;
                        suggestionsBox.style.display = "none";
                        addressTextarea.focus();
                    });

                    suggestionsBox.appendChild(row);
                });

                suggestionsBox.style.display = "block";
            })
            .catch(err => {
                console.warn("Address autocomplete error:", err);
            });
    }

    document.addEventListener("click", function(e) {
        if (searchInput && suggestionsBox) {
            if (!searchInput.contains(e.target) && !suggestionsBox.contains(e.target)) {
                suggestionsBox.style.display = "none";
            }
        }
    });

    function detectLiveLocation() {
        const locateBtn = document.getElementById("locateBtn");
        if (!navigator.geolocation) {
            alert("Geolocation is not supported by your browser.");
            return;
        }

        const originalText = locateBtn.innerHTML;
        locateBtn.innerHTML = "⏳ Locating...";
        locateBtn.disabled = true;

        navigator.geolocation.getCurrentPosition(
            position => {
                const lat = position.coords.latitude;
                const lon = position.coords.longitude;
                const revUrl = 'https://photon.komoot.io/reverse?lat=' + lat + '&lon=' + lon;

                fetch(revUrl)
                    .then(res => res.json())
                    .then(data => {
                        locateBtn.innerHTML = originalText;
                        locateBtn.disabled = false;
                        
                        if (data && data.features && data.features.length > 0) {
                            const props = data.features[0].properties;
                            const parts = [
                                props.name,
                                props.street,
                                props.district,
                                props.city,
                                props.postcode,
                                props.state
                            ].filter(Boolean);

                            const resolvedAddr = parts.join(", ");
                            addressTextarea.value = resolvedAddr;
                            if (searchInput) searchInput.value = props.name || props.district || "Current Location";
                        } else {
                            addressTextarea.value = 'Lat: ' + lat.toFixed(4) + ', Lon: ' + lon.toFixed(4);
                        }
                        addressTextarea.focus();
                    })
                    .catch(() => {
                        locateBtn.innerHTML = originalText;
                        locateBtn.disabled = false;
                        alert("Could not reverse lookup coordinates.");
                    });
            },
            error => {
                locateBtn.innerHTML = originalText;
                locateBtn.disabled = false;
                alert("Location access denied or unavailable. Please type your location.");
            },
            { enableHighAccuracy: true, timeout: 10000 }
        );
    }

    /* ================= ORDER LOGIC ================= */
    function toggleChip(chip, text) {
        const input = document.getElementById("specialNotes");
        chip.classList.toggle("selected");
        
        let existingNotes = input.value.split(", ").filter(n => n.trim().length > 0);
        if (chip.classList.contains("selected")) {
            if (!existingNotes.includes(text)) existingNotes.push(text);
        } else {
            existingNotes = existingNotes.filter(n => n !== text);
        }
        input.value = existingNotes.join(", ");
    }

    function setTip(amount, btn) {
        document.querySelectorAll('.tip-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentTip = parseFloat(amount);

        const tipRow = document.getElementById("tipRow");
        const tipVal = document.getElementById("tipVal");
        const tipLabel = document.getElementById("tipLabelText");

        if (currentTip > 0) {
            tipRow.style.display = "flex";
            tipVal.innerText = currentTip.toFixed(2);
            tipLabel.innerText = "Added ₹" + currentTip;
        } else {
            tipRow.style.display = "none";
            tipLabel.innerText = "No Tip";
        }

        recalcTotal();
    }

    function recalcTotal() {
        const grandTotal = Math.max(0, originalSubtotal - currentDiscount + currentTip);
        document.getElementById("grandTotalVal").innerText = grandTotal.toFixed(2);
        document.getElementById("hiddenTipAmount").value = currentTip.toFixed(2);
        document.getElementById("hiddenFinalAmount").value = grandTotal.toFixed(2);
    }

    function resetFormState() {
        const inputField = document.getElementById("couponInput");
        const btn = document.getElementById("applyBtn");
        const msgDiv = document.getElementById("couponMsg");
        const discountRow = document.getElementById("discountRow");

        if (inputField) {
            inputField.value = "";
            inputField.disabled = false;
        }
        if (btn) btn.disabled = false;
        if (msgDiv) {
            msgDiv.style.display = "none";
            msgDiv.innerText = "";
        }
        if (discountRow) discountRow.style.display = "none";

        currentDiscount = 0.0;
        document.getElementById("hiddenCouponCode").value = "";
        document.getElementById("hiddenDiscountAmount").value = "0.0";
        recalcTotal();
    }

    window.addEventListener("DOMContentLoaded", resetFormState);
    window.addEventListener("pageshow", resetFormState);

    function applyPromoCode() {
        const inputField = document.getElementById("couponInput");
        const btn = document.getElementById("applyBtn");
        const code = inputField.value.trim();
        const msgDiv = document.getElementById("couponMsg");

        if (!code) {
            msgDiv.style.display = "block";
            msgDiv.style.color = "#ff4757";
            msgDiv.innerText = "Please enter a promo code.";
            return;
        }

        const params = new URLSearchParams();
        params.append("couponCode", code);
        params.append("subtotal", originalSubtotal);

        fetch("applyCoupon", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: params.toString()
        })
        .then(res => res.json())
        .then(data => {
            msgDiv.style.display = "block";
            if (data.success) {
                msgDiv.style.color = "#2ed573";
                msgDiv.innerText = data.message;

                currentDiscount = parseFloat(data.discount);
                document.getElementById("discountRow").style.display = "flex";
                document.getElementById("appliedCodeText").innerText = data.code;
                document.getElementById("discountVal").innerText = currentDiscount.toFixed(2);

                document.getElementById("hiddenCouponCode").value = data.code;
                document.getElementById("hiddenDiscountAmount").value = currentDiscount.toFixed(2);

                recalcTotal();

                inputField.disabled = true;
                btn.disabled = true;
            } else {
                msgDiv.style.color = "#ff4757";
                msgDiv.innerText = data.message;
            }
        })
        .catch(err => {
            console.error(err);
            msgDiv.style.display = "block";
            msgDiv.style.color = "#ff4757";
            msgDiv.innerText = "Error applying coupon. Please try again.";
        });
    }

    function removeCoupon() {
        const inputField = document.getElementById("couponInput");
        const btn = document.getElementById("applyBtn");
        const msgDiv = document.getElementById("couponMsg");
        const discountRow = document.getElementById("discountRow");

        discountRow.style.display = "none";
        msgDiv.style.display = "block";
        msgDiv.style.color = "#ffa502";
        msgDiv.innerText = "Coupon removed.";

        inputField.value = "";
        inputField.disabled = false;
        btn.disabled = false;
        inputField.focus();

        currentDiscount = 0.0;
        document.getElementById("hiddenCouponCode").value = "";
        document.getElementById("hiddenDiscountAmount").value = "0.0";
        recalcTotal();
    }

    function prepareFinalSubmission() {
        const notes = document.getElementById("specialNotes").value.trim();
        const addrField = document.getElementById("deliveryAddressInput");
        if (notes.length > 0 && !addrField.value.includes("[Note:")) {
            addrField.value = addrField.value + " [Note: " + notes + "]";
        }
    }
    </script>
</body>
</html>