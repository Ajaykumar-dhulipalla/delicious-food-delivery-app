<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delicious - Page Error</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍔</text></svg>">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { 
            background-color: #0f1015; 
            color: #f1f2f6; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            height: 100vh; 
            text-align: center; 
            padding: 20px;
        }
        .error-card { 
            background: #1a1c23; 
            border: 1px solid #2a2e39; 
            border-radius: 16px; 
            padding: 40px 30px; 
            max-width: 480px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.5); 
        }
        .error-code { 
            font-size: 3.5rem; 
            font-weight: 800; 
            color: #ff4757; 
            margin-bottom: 10px; 
        }
        h2 { 
            font-size: 1.4rem; 
            margin-bottom: 12px; 
            color: #ffffff;
        }
        p { 
            color: #a4b0be; 
            margin-bottom: 25px; 
            font-size: 0.95rem;
            line-height: 1.5; 
        }
        .btn-home { 
            background: #ffa502; 
            color: #000; 
            font-weight: 700; 
            text-decoration: none; 
            padding: 10px 24px; 
            border-radius: 8px; 
            transition: 0.2s ease; 
            display: inline-block;
        }
        .btn-home:hover { 
            background: #e67e22; 
            color: #fff; 
        }
    </style>
</head>
<body>
    <div class="error-card">
        <div class="error-code">404 / 500</div>
        <h2>Something Went Wrong</h2>
        <p>The page you requested could not be found or a temporary server glitch occurred.</p>
        <a href="home" class="btn-home">⬅️ Return to Delicious Home</a>
    </div>
</body>
</html>