<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Manage Restaurants | Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f1015; color: #f1f2f6; padding: 25px; min-height: 100vh; }

        .navbar {
            max-width: 1200px;
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
        .nav-btn.active { background: #ffa502; color: #000; font-weight: 700; border-color: #ffa502; }
        .btn-logout { border-color: #ff4757; color: #ff4757; }
        .btn-logout:hover { background: #ff4757; color: #fff; }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }
        h2 { font-size: 1.6rem; font-weight: 800; }

        .btn-add {
            background: #2ed573;
            color: #000;
            font-weight: 700;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            cursor: pointer;
            transition: 0.2s;
        }
        .btn-add:hover { background: #10ac84; color: #fff; }

        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th {
            background-color: #14161d;
            color: #a4b0be;
            font-size: 0.85rem;
            text-transform: uppercase;
            padding: 16px 20px;
            border-bottom: 2px solid #2a2e39;
        }
        td {
            padding: 16px 20px;
            border-bottom: 1px solid #2a2e39;
            font-size: 0.95rem;
            vertical-align: middle;
        }
        tr:hover { background-color: #21242d; }

        .action-cell {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .btn-edit {
            background: #252834;
            color: #ffa502;
            border: 1px solid #ffa502;
            padding: 6px 14px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 700;
            transition: 0.2s;
        }
        .btn-edit:hover { background: #ffa502; color: #000; }

        .btn-delete {
            background: transparent;
            color: #ff4757;
            border: 1px solid #ff4757;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 700;
            transition: 0.2s;
        }
        .btn-delete:hover { background: #ff4757; color: #fff; }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
        }
        .active-badge { background: rgba(46, 213, 115, 0.15); color: #2ed573; border: 1px solid #2ed573; }
        .inactive-badge { background: rgba(255, 71, 87, 0.15); color: #ff4757; border: 1px solid #ff4757; }

        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.7);
            justify-content: center;
            align-items: center;
            z-index: 100;
        }
        .modal-content {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 14px;
            padding: 28px;
            width: 90%;
            max-width: 520px;
        }
        .modal-title { font-size: 1.3rem; font-weight: 800; margin-bottom: 20px; color: #f1f2f6; }
        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; margin-bottom: 5px; color: #a4b0be; font-size: 0.85rem; font-weight: 600; }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border-radius: 8px;
            background: #0f1015;
            border: 1px solid #2a2e39;
            color: #f1f2f6;
            outline: none;
            font-size: 0.95rem;
        }
        .form-control:focus { border-color: #2ed573; }
        .modal-actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 20px; }
        .btn-save { background: #2ed573; color: #000; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer; }
        .btn-close { background: #0f1015; border: 1px solid #2a2e39; color: #a4b0be; padding: 10px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; }
    </style>
</head>
<body>
    <header class="navbar">
        <a href="home" class="brand">🍔 Delicious Admin</a>
        <nav class="nav-links">
            <a href="adminOrders" class="nav-btn">📋 Live Orders</a>
            <a href="adminRestaurant" class="nav-btn active">🏪 Manage Restaurants</a>
            <a href="adminMenu" class="nav-btn">🍽️ Manage Menus</a>
            <a href="home" class="nav-btn">Store Home</a>
            <a href="logout" class="nav-btn btn-logout">Logout</a>
        </nav>
    </header>

    <main class="container">
        <div class="header-section">
            <h2>🏪 Restaurant Management</h2>
            <button class="btn-add" onclick="openAddModal()">+ Add New Restaurant</button>
        </div>

        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Cuisine</th>
                        <th>Delivery</th>
                        <th>Rating</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (restaurantList != null && !restaurantList.isEmpty()) {
                            int rowNum = 1;
                            for (Restaurant r : restaurantList) {
                    %>
                            <tr>
                                <td style="font-weight: 700; color: #ffa502;">#<%= rowNum++ %></td>
                                <td><%= r.getName() %></td>
                                <td><%= r.getCuisineType() %></td>
                                <td><%= r.getDeliveryTime() %> mins</td>
                                <td>⭐ <%= r.getRating() %></td>
                                <td>
                                    <span class="status-badge <%= r.getIsActive() ? "active-badge" : "inactive-badge" %>">
                                        <%= r.getIsActive() ? "Active" : "Disabled" %>
                                    </span>
                                </td>
                                <td>
                                    <div class="action-cell">
                                        <button class="btn-edit" 
                                                onclick="openEditModal('<%= r.getRestaurantId() %>', '<%= r.getName() %>', '<%= r.getCuisineType() %>', '<%= r.getDeliveryTime() %>', '<%= r.getAddress() %>', '<%= r.getRating() %>', '<%= r.getIsActive() %>', '<%= r.getImagePath() %>')">
                                            Edit
                                        </button>
                                        <form action="adminRestaurant" method="post" style="margin: 0;" onsubmit="return confirm('Are you sure you want to delete this restaurant?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="restaurantId" value="<%= r.getRestaurantId() %>">
                                            <button type="submit" class="btn-delete">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Add/Edit Restaurant Modal -->
    <div id="restaurantModal" class="modal">
        <div class="modal-content">
            <div id="modalTitle" class="modal-title">Add Restaurant</div>
            <form action="adminRestaurant" method="post">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="restaurantId" id="restaurantId">

                <div class="form-group">
                    <label>Restaurant Name</label>
                    <input type="text" name="name" id="restName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Cuisine Type</label>
                    <input type="text" name="cuisineType" id="restCuisine" class="form-control" placeholder="e.g. North Indian, Italian" required>
                </div>
                <div class="form-group">
                    <label>Delivery Time (in minutes)</label>
                    <input type="number" name="deliveryTime" id="restDelivery" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <input type="text" name="address" id="restAddress" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Rating (e.g. 4.5)</label>
                    <input type="number" step="0.1" max="5.0" name="rating" id="restRating" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Image URL / Path</label>
                    <input type="text" name="imagePath" id="restImage" class="form-control" placeholder="e.g. images/tuscany.jpg" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="isActive" id="restStatus" class="form-control">
                        <option value="true">Active</option>
                        <option value="false">Disabled</option>
                    </select>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-close" onclick="closeModal()">Cancel</button>
                    <button type="submit" class="btn-save">Save</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openAddModal() {
            document.getElementById('modalTitle').innerText = 'Add New Restaurant';
            document.getElementById('formAction').value = 'add';
            document.getElementById('restaurantId').value = '';
            document.getElementById('restName').value = '';
            document.getElementById('restCuisine').value = '';
            document.getElementById('restDelivery').value = '';
            document.getElementById('restAddress').value = '';
            document.getElementById('restRating').value = '4.5';
            document.getElementById('restImage').value = '';
            document.getElementById('restStatus').value = 'true';
            document.getElementById('restaurantModal').style.display = 'flex';
        }

        function openEditModal(id, name, cuisine, delivery, address, rating, isActive, image) {
            document.getElementById('modalTitle').innerText = 'Edit Restaurant #' + id;
            document.getElementById('formAction').value = 'update';
            document.getElementById('restaurantId').value = id;
            document.getElementById('restName').value = name;
            document.getElementById('restCuisine').value = cuisine;
            document.getElementById('restDelivery').value = delivery;
            document.getElementById('restAddress').value = address;
            document.getElementById('restRating').value = rating;
            document.getElementById('restImage').value = image;
            document.getElementById('restStatus').value = isActive;
            document.getElementById('restaurantModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('restaurantModal').style.display = 'none';
        }
    </script>
</body>
</html>