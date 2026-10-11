<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"admin".equalsIgnoreCase(sessionUser.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Restaurant> restaurantList = (List<Restaurant>) request.getAttribute("restaurantList");

    @SuppressWarnings("unchecked")
    List<Menu> menuList = (List<Menu>) request.getAttribute("menuList");

    Integer selectedRestaurantId = (Integer) request.getAttribute("selectedRestaurantId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Menu Items - Delicious Admin</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f1015; color: #f1f2f6; padding: 25px; min-height: 100vh; }
        
        .navbar {
            max-width: 1250px;
            margin: 0 auto 30px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1a1c23;
            padding: 15px 30px;
            border-radius: 14px;
            border: 1px solid #2a2e39;
        }
        .brand { font-size: 1.5rem; font-weight: 800; color: #ff4757; text-decoration: none; }
        .nav-links { display: flex; gap: 12px; align-items: center; }
        .nav-btn {
            text-decoration: none;
            color: #ced6e0;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            background: #252834;
            border: 1px solid #2a2e39;
            transition: 0.2s;
        }
        .nav-btn:hover { color: #ffa502; border-color: #ffa502; }
        .btn-active { background: #ffa502; color: #000; font-weight: 700; border-color: #ffa502; }
        .btn-active:hover { background: #eccc68; color: #000; }
        .btn-logout { border-color: #ff4757; color: #ff4757; }
        .btn-logout:hover { background: #ff4757; color: #fff; }

        .container { max-width: 1250px; margin: 0 auto; }
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 25px;
        }
        .title { font-size: 1.8rem; font-weight: 800; }
        
        .rest-selector {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            color: #ffa502;
            font-size: 1rem;
            font-weight: 700;
            padding: 10px 18px;
            border-radius: 10px;
            outline: none;
            cursor: pointer;
        }

        /* Form Card */
        .add-card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 30px;
        }
        .add-card h3 { color: #2ed573; margin-bottom: 15px; }
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
            align-items: center;
        }
        .form-input {
            width: 100%;
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #fff;
            padding: 10px 14px;
            border-radius: 8px;
            outline: none;
        }
        .form-input:focus { border-color: #2ed573; }
        .btn-add {
            background: #2ed573;
            color: #000;
            border: none;
            padding: 10px 20px;
            font-weight: 700;
            border-radius: 8px;
            cursor: pointer;
            transition: 0.2s;
            height: 100%;
        }
        .btn-add:hover { background: #10ac84; color: #fff; }

        /* Table */
        .table-wrap {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 14px;
            overflow-x: auto;
        }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background: #14161d; color: #a4b0be; padding: 14px 16px; font-size: 0.85rem; text-transform: uppercase; }
        td { padding: 14px 16px; border-top: 1px solid #2a2e39; vertical-align: middle; }
        .item-thumb { width: 50px; height: 50px; border-radius: 8px; object-fit: cover; background: #252834; }
        
        .stock-select {
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #f1f2f6;
            padding: 8px 12px;
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 700;
            outline: none;
            cursor: pointer;
        }
        .stock-select.is-in-stock { color: #2ed573; border-color: rgba(46, 213, 115, 0.4); }
        .stock-select.is-out-stock { color: #ff4757; border-color: rgba(255, 71, 87, 0.4); }

        .btn-update {
            background: #ffa502;
            border: none;
            color: #000;
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 800;
            font-size: 0.85rem;
            cursor: pointer;
            transition: 0.2s;
        }
        .btn-update:hover { background: #eccc68; transform: scale(1.03); }

        .btn-delete {
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid #ff4757;
            color: #ff4757;
            padding: 8px 14px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 0.85rem;
            cursor: pointer;
            transition: 0.2s;
        }
        .btn-delete:hover { background: #ff4757; color: #fff; }
    </style>
</head>
<body>

    <header class="navbar">
        <a href="home" class="brand">🍔 Delicious Admin</a>
        <nav class="nav-links">
            <a href="adminOrders" class="nav-btn">📋 Live Orders</a>
            <a href="adminRestaurant" class="nav-btn">🏪 Manage Restaurants</a>
            <a href="adminMenu" class="nav-btn btn-active">🍽️ Manage Menus</a>
            <a href="home" class="nav-btn">Store Home</a>
            <a href="logout" class="nav-btn btn-logout">Logout</a>
        </nav>
    </header>

    <main class="container">
        <div class="header-section">
            <h2 class="title">Menu Management</h2>
            
            <form action="adminMenu" method="get" id="restForm">
                <select name="restaurantId" class="rest-selector" onchange="document.getElementById('restForm').submit()">
                    <% if (restaurantList != null) {
                        for (Restaurant r : restaurantList) { %>
                            <option value="<%= r.getRestaurantId() %>" <%= (selectedRestaurantId != null && selectedRestaurantId == r.getRestaurantId()) ? "selected" : "" %>>
                                <%= r.getName() %> (<%= r.getCuisineType() %>)
                            </option>
                    <%  }
                    } %>
                </select>
            </form>
        </div>

        <!-- Add Dish Form -->
        <section class="add-card">
            <h3>+ Add New Dish to this Restaurant</h3>
            <form action="adminMenu" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="restaurantId" value="<%= selectedRestaurantId %>">
                <div class="form-row">
                    <input type="text" name="itemName" class="form-input" placeholder="Dish Name (e.g. Garlic Bread)" required>
                    <input type="number" step="0.5" name="price" class="form-input" placeholder="Price (₹)" required>
                    <input type="text" name="imagePath" class="form-input" placeholder="Image URL">
                    <input type="text" name="description" class="form-input" placeholder="Short description / ingredients">
                    <select name="isAvailable" class="form-input">
                        <option value="true" selected>● In Stock</option>
                        <option value="false">✕ Out of Stock</option>
                    </select>
                    <button type="submit" class="btn-add">Add Dish</button>
                </div>
            </form>
        </section>

        <!-- Menu Table -->
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Item Name</th>
                        <th>Price (₹)</th>
                        <th>Description</th>
                        <th>Stock Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (menuList != null && !menuList.isEmpty()) {
                        for (Menu m : menuList) { 
                            boolean isAvailable = m.getIsAvailable();
                    %>
                            <tr>
                                <td>
                                    <img src="<%= (m.getImagePath() != null && !m.getImagePath().trim().isEmpty()) ? m.getImagePath() : "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100" %>" 
                                         alt="<%= m.getItemName() %>" class="item-thumb" 
                                         onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100'">
                                </td>
                                
                                <td>
                                    <input type="text" form="form-menu-<%= m.getMenuId() %>" name="itemName" value="<%= m.getItemName() %>" class="form-input" style="font-weight:700;" required>
                                </td>
                                <td>
                                    <input type="number" step="0.5" form="form-menu-<%= m.getMenuId() %>" name="price" value="<%= m.getPrice() %>" class="form-input" style="width:100px;" required>
                                </td>
                                <td>
                                    <input type="text" form="form-menu-<%= m.getMenuId() %>" name="description" value="<%= (m.getDescription() != null) ? m.getDescription() : "" %>" class="form-input">
                                </td>
                                <td>
                                    <!-- Stock Status Selector (Updates upon Save) -->
                                    <select name="isAvailable" form="form-menu-<%= m.getMenuId() %>" class="stock-select <%= isAvailable ? "is-in-stock" : "is-out-stock" %>" onchange="this.className = 'stock-select ' + (this.value === 'true' ? 'is-in-stock' : 'is-out-stock');">
                                        <option value="true" <%= isAvailable ? "selected" : "" %>>● In Stock</option>
                                        <option value="false" <%= !isAvailable ? "selected" : "" %>>✕ Out of Stock</option>
                                    </select>
                                </td>
                                
                                <td>
                                    <div style="display: flex; gap: 8px; align-items: center;">
                                        <!-- Update Form -->
                                        <form id="form-menu-<%= m.getMenuId() %>" action="adminMenu" method="post" style="margin: 0;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="menuId" value="<%= m.getMenuId() %>">
                                            <input type="hidden" name="restaurantId" value="<%= selectedRestaurantId %>">
                                            <input type="hidden" name="imagePath" value="<%= (m.getImagePath() != null) ? m.getImagePath() : "" %>">
                                            <button type="submit" class="btn-update">Save</button>
                                        </form>

                                        <!-- Delete Form -->
                                        <form action="adminMenu" method="post" onsubmit="return confirm('Delete this dish?');" style="margin: 0;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="menuId" value="<%= m.getMenuId() %>">
                                            <input type="hidden" name="restaurantId" value="<%= selectedRestaurantId %>">
                                            <button type="submit" class="btn-delete">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="6" style="text-align:center; padding:40px; color:#747d8c;">
                                No menu items found for this restaurant. Add one above!
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

</body>
</html>