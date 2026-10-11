<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sign Up - Delicious</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f1015;
            color: #f1f2f6;
            margin: 0;
            padding: 40px 20px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .form-card {
            background: #1a1c23;
            border: 1px solid #2a2e39;
            border-radius: 16px;
            padding: 35px;
            max-width: 440px;
            width: 100%;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        h2 {
            margin: 0 0 10px 0;
            font-size: 1.8rem;
            color: #ffffff;
            text-align: center;
        }
        p.sub {
            color: #a4b0be;
            font-size: 0.9rem;
            text-align: center;
            margin-bottom: 25px;
        }
        .form-group {
            margin-bottom: 16px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 0.85rem;
            color: #a4b0be;
            font-weight: 600;
        }
        input, textarea {
            width: 100%;
            padding: 12px;
            background: #0f1015;
            border: 1px solid #2a2e39;
            border-radius: 8px;
            color: #ffffff;
            font-size: 0.95rem;
            outline: none;
            transition: 0.2s ease;
        }
        input:focus, textarea:focus {
            border-color: #ff4757;
        }
        .submit-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #ff4757, #ff6b81);
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            margin-top: 10px;
            transition: 0.2s ease;
        }
        .submit-btn:hover {
            transform: scale(1.02);
        }
        .error-msg {
            color: #ff4757;
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid #ff4757;
            padding: 10px;
            border-radius: 8px;
            font-size: 0.85rem;
            margin-bottom: 15px;
            text-align: center;
        }
        .footer-link {
            text-align: center;
            font-size: 0.85rem;
            color: #a4b0be;
            margin-top: 20px;
        }
        .footer-link a {
            color: #2ed573;
            text-decoration: none;
            font-weight: 700;
        }
    </style>
</head>
<body>
    <div class="form-card">
        <h2>Create Account</h2>
        <p class="sub">Join Delicious for fresh meals delivered fast</p>

        <% String error = (String) request.getAttribute("errorMessage");
           if (error != null) { %>
            <div class="error-msg"><%= error %></div>
        <% } %>

        <form action="register" method="post">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required placeholder="john_doe">
            </div>
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" required placeholder="john@example.com">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter password">
            </div>
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" name="phone" required placeholder="9876543210">
            </div>
            <div class="form-group">
                <label>Default Delivery Address</label>
                <textarea name="address" rows="2" required placeholder="123 Food Street, City"></textarea>
            </div>
            <button type="submit" class="submit-btn">Register</button>
        </form>

        <div class="footer-link">
            Already have an account? <a href="login.jsp">Sign In</a>
        </div>
    </div>
</body>
</html>