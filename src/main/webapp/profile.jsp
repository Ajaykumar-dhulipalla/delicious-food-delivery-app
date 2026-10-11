<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tap.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    String pwdSuccess = (String) session.getAttribute("pwdSuccess");
    String pwdError = (String) session.getAttribute("pwdError");
    session.removeAttribute("pwdSuccess");
    session.removeAttribute("pwdError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body {
            background-color: #0f1015;
            color: #f1f2f6;
            margin: 0;
            padding: 25px 15px;
            min-height: 100vh;
        }

        /* Top Navigation Bar */
        .navbar {
            max-width: 780px;
            margin: 0 auto 25px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1c23;
            padding: 14px 28px;
            border-radius: 14px;
            border: 1px solid #2a2e39;
            flex-wrap: wrap;
            gap: 12px;
        }
        .brand {
            font-size: 1.5rem;
            font-weight: 800;
            color: #ff4757;
            text-decoration: none;
            letter-spacing: -0.5px;
        }
        .nav-links {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }
        .nav-btn {
            text-decoration: none;
            color: #ced6e0;
            font-weight: 600;
            padding: 7px 14px;
            border-radius: 8px;
            background: #252834;
            border: 1px solid #2a2e39;
            transition: 0.2s;
            font-size: 0.88rem;
        }
        .nav-btn:hover { color: #ffa502; border-color: #ffa502; }
        .btn-logout { border-color: #ff4757; color: #ff4757; }
        .btn-logout:hover { background: #ff4757; color: #fff; }

        .container {
            max-width: 780px;
            margin: 0 auto;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.55);
        }

        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            font-weight: 600;
            margin-bottom: 22px;
            text-align: center;
            font-size: 0.92rem;
        }
        .alert-success { background: rgba(46, 213, 115, 0.15); border: 1px solid #2ed573; color: #2ed573; }
        .alert-error { background: rgba(255, 71, 87, 0.15); border: 1px solid #ff4757; color: #ff4757; }

        .profile-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 24px;
            border-bottom: 1px solid #2a2e39;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }
        .profile-user {
            display: flex;
            align-items: center;
            gap: 18px;
        }
        .avatar {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff4757, #ff6b81);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            font-weight: 800;
            text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(255, 71, 87, 0.3);
        }
        .profile-name {
            font-size: 1.45rem;
            font-weight: 800;
            color: #f1f2f6;
        }
        .profile-role {
            color: #2ed573;
            font-size: 0.82rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            margin-top: 4px;
        }
        .header-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .btn-edit {
            background: #14161d;
            border: 1px solid #ffa502;
            color: #ffa502;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 700;
            font-size: 0.85rem;
            transition: 0.2s;
        }
        .btn-edit:hover {
            background: #ffa502;
            color: #000;
        }
        .btn-pwd {
            background: #14161d;
            border: 1px solid #70a1ff;
            color: #70a1ff;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 700;
            font-size: 0.85rem;
            transition: 0.2s;
        }
        .btn-pwd:hover {
            background: #70a1ff;
            color: #000;
        }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
            margin-bottom: 26px;
        }
        .info-card {
            background: #14161d;
            border: 1px solid #2a2e39;
            border-radius: 12px;
            padding: 16px 18px;
        }
        .info-label {
            color: #747d8c;
            font-size: 0.78rem;
            text-transform: uppercase;
            font-weight: 700;
            margin-bottom: 6px;
            letter-spacing: 0.5px;
        }
        .info-value {
            font-size: 0.98rem;
            color: #f1f2f6;
            font-weight: 600;
            word-break: break-all;
        }
        .full-width {
            grid-column: 1 / -1;
        }

        .actions {
            display: flex;
            gap: 15px;
            margin-top: 10px;
        }
        .btn {
            flex: 1;
            text-align: center;
            padding: 12px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 700;
            font-size: 0.92rem;
            transition: 0.2s ease;
        }
        .btn-orders {
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            border: none;
        }
        .btn-orders:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 14px rgba(46, 213, 115, 0.4);
        }
        .btn-home {
            background: #14161d;
            border: 1px solid #2a2e39;
            color: #ced6e0;
        }
        .btn-home:hover {
            border-color: #ffa502;
            color: #ffa502;
        }

        /* Modal styling */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.75);
            backdrop-filter: blur(4px);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal-content {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 16px;
            padding: 28px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.7);
        }
        .modal-title {
            font-size: 1.3rem;
            font-weight: 800;
            margin-bottom: 20px;
            color: #f1f2f6;
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: #a4b0be;
            font-size: 0.85rem;
            font-weight: 600;
        }
        .form-control {
            width: 100%;
            padding: 11px 14px;
            border-radius: 8px;
            background: #14161d;
            border: 1px solid #2a2e39;
            color: #f1f2f6;
            outline: none;
            font-size: 0.95rem;
            transition: 0.2s;
        }
        .form-control:focus {
            border-color: #2ed573;
            box-shadow: 0 0 10px rgba(46, 213, 115, 0.2);
        }

        /* Autocomplete & GPS Locate Bar for Modal */
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
            background: #14161d;
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
            max-height: 180px;
            overflow-y: auto;
            z-index: 1001;
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

        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 22px;
        }
        .btn-save {
            background: #2ed573;
            color: #000;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
        }
        .btn-save:hover { background: #26af5f; }
        .btn-save-pwd {
            background: #70a1ff;
            color: #000;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
        }
        .btn-save-pwd:hover { background: #538df8; }
        .btn-close {
            background: #14161d;
            border: 1px solid #2a2e39;
            color: #a4b0be;
            padding: 10px 16px;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-close:hover { color: #fff; border-color: #4b5263; }

        @media (max-width: 768px) {
            body { padding: 12px; }
            .navbar {
                padding: 12px 16px;
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
                margin-bottom: 16px;
            }
            .brand { text-align: center; }
            .nav-links { justify-content: center; gap: 8px; }
            .container { padding: 20px 16px; border-radius: 14px; }
            .profile-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }
            .header-actions { width: 100%; display: flex; gap: 8px; }
            .btn-edit, .btn-pwd { flex: 1; text-align: center; padding: 10px 0; }
            .info-grid { grid-template-columns: 1fr; gap: 12px; }
            .actions { flex-direction: column; gap: 10px; }
            .modal-content { padding: 22px 16px; width: 95%; }
            .modal-actions { flex-direction: column; gap: 8px; }
            .btn-save, .btn-save-pwd, .btn-close { width: 100%; text-align: center; padding: 12px 0; }
            .locate-bar { flex-direction: column; align-items: stretch; }
            .btn-locate { justify-content: center; padding: 10px 0; }
        }
    </style>
</head>
<body>
    <header class="navbar">
        <a href="home" class="brand">&#127828; Delicious</a>
        <nav class="nav-links">
            <a href="home" class="nav-btn">&#127968; Home</a>
            <a href="orderHistory" class="nav-btn">&#128221; My Orders</a>
            <a href="cart.jsp" class="nav-btn">&#128722; Cart</a>
            <a href="logout" class="nav-btn btn-logout">Logout</a>
        </nav>
    </header>

    <main class="container">
        <!-- Status alerts -->
        <% if ("1".equals(success)) { %>
            <div class="alert alert-success">&#10004; Profile updated successfully!</div>
        <% } else if ("1".equals(error)) { %>
            <div class="alert alert-error">&#10008; Failed to update profile. Please try again.</div>
        <% } %>

        <% if (pwdSuccess != null) { %>
            <div class="alert alert-success">&#10004; <%= pwdSuccess %></div>
        <% } else if (pwdError != null) { %>
            <div class="alert alert-error">&#10008; <%= pwdError %></div>
        <% } %>

        <div class="profile-header">
            <div class="profile-user">
                <div class="avatar">
                    <%= (user.getUsername() != null && !user.getUsername().isEmpty()) ? user.getUsername().substring(0, 1) : "U" %>
                </div>
                <div>
                    <div class="profile-name"><%= user.getUsername() %></div>
                    <div class="profile-role"><%= "admin".equalsIgnoreCase(user.getRole()) ? "Platform Administrator" : "Registered Customer" %></div>
                </div>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-edit" onclick="openModal('editModal')">&#9998; Edit Profile</button>
                <button type="button" class="btn-pwd" onclick="openModal('pwdModal')">&#128273; Change Password</button>
            </div>
        </div>

        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Customer ID</div>
                <div class="info-value"><%= String.format("#USR-%03d", user.getUserId()) %></div>
            </div>

            <div class="info-card">
                <div class="info-label">Email Address</div>
                <div class="info-value"><%= user.getEmail() %></div>
            </div>

            <div class="info-card">
                <div class="info-label">Phone Number</div>
                <div class="info-value"><%= (user.getPhone() != null && !user.getPhone().isEmpty()) ? user.getPhone() : "Not provided" %></div>
            </div>

            <div class="info-card">
                <div class="info-label">Account Status</div>
                <div class="info-value" style="color: #2ed573;">Active &#10004;</div>
            </div>

            <div class="info-card full-width">
                <div class="info-label">Saved Delivery Address</div>
                <div class="info-value"><%= (user.getAddress() != null && !user.getAddress().isEmpty()) ? user.getAddress() : "No default address saved." %></div>
            </div>
        </div>

        <div class="actions">
            <a href="orderHistory" class="btn btn-orders">View Order History &rarr;</a>
            <a href="home" class="btn btn-home">Browse Restaurants</a>
        </div>
    </main>

    <!-- Edit Profile Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-title">&#9998; Edit Profile Details</div>
            <form action="updateProfile" method="post">
                <div class="form-group">
                    <label>Full Name / Username</label>
                    <input type="text" name="username" class="form-control" value="<%= user.getUsername() %>" required>
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" class="form-control" value="<%= (user.getPhone() != null) ? user.getPhone() : "" %>" required>
                </div>

                <!-- Geocoding Autocomplete & GPS Locate Bar -->
                <div class="form-group">
                    <label>Delivery Address</label>
                    <div class="autocomplete-container">
                        <div class="locate-bar">
                            <input type="text" id="profileAreaSearch" class="search-addr-input" placeholder="🔍 Search area / pincode (e.g. BTM, Indiranagar, 560076)..." autocomplete="off">
                            <button type="button" id="profileLocateBtn" class="btn-locate" onclick="detectProfileLiveLocation()">📍 Locate Me</button>
                        </div>
                        <div id="profileSuggestions" class="suggestions-dropdown"></div>
                    </div>
                    <textarea id="profileAddressField" name="address" rows="3" class="form-control" placeholder="Enter full address, street, flat no." required><%= (user.getAddress() != null) ? user.getAddress() : "" %></textarea>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-close" onclick="closeModal('editModal')">Cancel</button>
                    <button type="submit" class="btn-save">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div id="pwdModal" class="modal">
        <div class="modal-content">
            <div class="modal-title">&#128273; Change Password</div>
            <form action="changePassword" method="post">
                <div class="form-group">
                    <label>Current Password</label>
                    <input type="password" name="currentPassword" class="form-control" placeholder="Enter current password" required>
                </div>
                <div class="form-group">
                    <label>New Password</label>
                    <input type="password" name="newPassword" class="form-control" placeholder="Enter new password (min. 4 chars)" required>
                </div>
                <div class="form-group">
                    <label>Confirm New Password</label>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Re-enter new password" required>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-close" onclick="closeModal('pwdModal')">Cancel</button>
                    <button type="submit" class="btn-save-pwd">Update Password</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal(id) {
            document.getElementById(id).style.display = 'flex';
        }
        function closeModal(id) {
            document.getElementById(id).style.display = 'none';
        }
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        };

        /* ================= LIVE ADDRESS AUTOCOMPLETE & GPS (PROFILE - PHOTON API) ================= */
        const profileSearchInput = document.getElementById("profileAreaSearch");
        const profileSuggestionsBox = document.getElementById("profileSuggestions");
        const profileAddressField = document.getElementById("profileAddressField");
        let profileDebounceTimer = null;

        if (profileSearchInput) {
            profileSearchInput.addEventListener("input", function() {
                const query = this.value.trim();
                clearTimeout(profileDebounceTimer);

                if (query.length < 3) {
                    profileSuggestionsBox.style.display = "none";
                    profileSuggestionsBox.innerHTML = "";
                    return;
                }

                profileDebounceTimer = setTimeout(() => {
                    fetchProfileAddressSuggestions(query);
                }, 250);
            });
        }

        function fetchProfileAddressSuggestions(query) {
            const url = 'https://photon.komoot.io/api/?q=' + encodeURIComponent(query) + '&limit=5&lat=12.9716&lon=77.5946';

            fetch(url)
                .then(res => res.json())
                .then(data => {
                    profileSuggestionsBox.innerHTML = "";
                    if (!data || !data.features || data.features.length === 0) {
                        profileSuggestionsBox.style.display = "none";
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
                            profileAddressField.value = fullFormattedAddress;
                            profileSearchInput.value = props.name || props.city || query;
                            profileSuggestionsBox.style.display = "none";
                            profileAddressField.focus();
                        });

                        profileSuggestionsBox.appendChild(row);
                    });

                    profileSuggestionsBox.style.display = "block";
                })
                .catch(err => {
                    console.warn("Profile address autocomplete error:", err);
                });
        }

        document.addEventListener("click", function(e) {
            if (profileSearchInput && profileSuggestionsBox) {
                if (!profileSearchInput.contains(e.target) && !profileSuggestionsBox.contains(e.target)) {
                    profileSuggestionsBox.style.display = "none";
                }
            }
        });

        function detectProfileLiveLocation() {
            const locateBtn = document.getElementById("profileLocateBtn");
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
                                profileAddressField.value = resolvedAddr;
                                if (profileSearchInput) profileSearchInput.value = props.name || props.district || "Current Location";
                            } else {
                                profileAddressField.value = 'Lat: ' + lat.toFixed(4) + ', Lon: ' + lon.toFixed(4);
                            }
                            profileAddressField.focus();
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
    </script>
</body>
</html>