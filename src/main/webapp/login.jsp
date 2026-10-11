<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Delicious</title>
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
            max-width: 400px;
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
            margin-bottom: 18px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 0.85rem;
            color: #a4b0be;
            font-weight: 600;
        }
        .input-box {
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
        .input-box:focus {
            border-color: #2ed573;
        }
        .password-field {
            -webkit-text-security: disc; /* Masks text visually without triggering browser auto-login hooks */
        }
        .submit-btn {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #2ed573, #10ac84);
            color: #000;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 800;
            cursor: pointer;
            margin-top: 10px;
            transition: 0.2s ease;
            touch-action: manipulation;
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
        .success-msg {
            color: #2ed573;
            background: rgba(46, 213, 115, 0.15);
            border: 1px solid #2ed573;
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
            color: #ff4757;
            text-decoration: none;
            font-weight: 700;
        }

        @media (max-width: 480px) {
            body { padding: 20px 16px; }
            .form-card { padding: 26px 20px; border-radius: 14px; }
            h2 { font-size: 1.55rem; }
            p.sub { font-size: 0.85rem; margin-bottom: 20px; }
            .input-box { padding: 13px 14px; font-size: 1rem; }
            .submit-btn { padding: 14px; font-size: 1rem; }
        }
    </style>
</head>
<body>
    <div class="form-card">
        <h2>Welcome Back</h2>
        <p class="sub">Log in to track your food & orders</p>

        <% 
            String urlError = request.getParameter("error");
            if ("login_required".equalsIgnoreCase(urlError)) { 
        %>
            <div class="error-msg">🔒 Please log in first to proceed to checkout!</div>
        <% 
            } else if ("unauthorized".equalsIgnoreCase(urlError)) { 
        %>
            <div class="error-msg">⛔ Access denied. Admin privileges required!</div>
        <% 
            } 
        %>

        <% String error = (String) request.getAttribute("errorMessage");
           if (error != null) { %>
            <div class="error-msg"><%= error %></div>
        <% } %>

        <% String success = (String) request.getAttribute("successMessage");
           if (success != null) { %>
            <div class="success-msg"><%= success %></div>
        <% } %>

        <div id="validationError" class="error-msg" style="display: none;"></div>

        <!-- Strict non-form container -->
        <div id="authWrapper">
            <div class="form-group">
                <label>Email Address</label>
                <input type="text" 
                       id="userEmail" 
                       class="input-box" 
                       placeholder="john@example.com" 
                       autocomplete="email" 
                       inputmode="email">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" 
                       id="userPassword" 
                       class="input-box password-field" 
                       placeholder="Enter password" 
                       autocomplete="current-password">
            </div>
            
            <button type="button" id="loginBtn" class="submit-btn">Log In</button>
        </div>

        <div class="footer-link">
            Don't have an account? <a href="register.jsp">Create one</a>
        </div>
    </div>

    <!-- Hidden dynamic bridge form created only when authorized by user interaction -->
    <form id="secureBridgeForm" action="login" method="post" style="display: none;" onsubmit="return isUserAuthorizedSubmission;">
        <input type="hidden" name="email" id="bridgeEmail">
        <input type="hidden" name="password" id="bridgePassword">
    </form>

    <script>
        let isUserAuthorizedSubmission = false;
        let lastUserTapTime = 0;

        const loginBtn = document.getElementById('loginBtn');
        const emailField = document.getElementById('userEmail');
        const passwordField = document.getElementById('userPassword');
        const errorDiv = document.getElementById('validationError');
        const bridgeForm = document.getElementById('secureBridgeForm');
        const bridgeEmail = document.getElementById('bridgeEmail');
        const bridgePassword = document.getElementById('bridgePassword');

        // Register explicit human physical touch/click
        function markAuthorizedUserInteraction() {
            lastUserTapTime = Date.now();
        }

        loginBtn.addEventListener('touchstart', markAuthorizedUserInteraction, { passive: true });
        loginBtn.addEventListener('pointerdown', markAuthorizedUserInteraction);
        loginBtn.addEventListener('mousedown', markAuthorizedUserInteraction);

        function triggerLogin() {
            const timeSinceTap = Date.now() - lastUserTapTime;

            // Block automated programmatic triggers if user didn't tap the button in the last 1.5 seconds
            if (timeSinceTap > 1500) {
                console.warn("Blocked automated browser submission attempt.");
                return;
            }

            const email = emailField.value.trim();
            const password = passwordField.value.trim();

            if (!email || !password) {
                errorDiv.innerText = "Please enter both email and password.";
                errorDiv.style.display = "block";
                return;
            }

            errorDiv.style.display = "none";
            isUserAuthorizedSubmission = true;

            bridgeEmail.value = email;
            bridgePassword.value = password;

            bridgeForm.submit();
        }

        loginBtn.addEventListener('click', triggerLogin);

        // Prevent Enter key in keyboard from firing unexpected browser submissions
        emailField.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                passwordField.focus();
            }
        });

        passwordField.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                lastUserTapTime = Date.now(); // authorize enter key from desktop keyboards
                triggerLogin();
            }
        });
    </script>
</body>
</html>