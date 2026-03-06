<%--
  Created by IntelliJ IDEA.
  User: HP
  Date: 05/03/2026
  Time: 14:25
  To change this template use File | Settings | File Templates.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Inventory Management</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/verdictlogo.png"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #00e676;
            --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.18);
            --bg:         #040e07;
            --bg-card:    rgba(4,18,9,0.95);
            --border:     rgba(0,230,118,0.15);
            --border-hi:  rgba(0,230,118,0.4);
            --text:       #e4ffe4;
            --text-sub:   #a8d4b0;
            --muted:      #5a9a6a;
            --surface:    rgba(0,20,8,0.6);
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
        }

        /* Navigation Bar */
        .navbar {
            background: var(--bg-card);
            border-bottom: 1px solid var(--border);
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .navbar-left {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .navbar-logo {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: contain;
            border: 1px solid var(--border-hi);
        }

        .navbar-brand {
            font-family: 'Rajdhani', sans-serif;
            font-size: 22px;
            font-weight: 700;
            color: var(--green);
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .nav-link {
            color: var(--text);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 4px;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .nav-link:hover {
            background: var(--green-glow);
            color: var(--green);
        }

        .btn-logout {
            background: rgba(255, 82, 82, 0.1);
            border: 1px solid rgba(255, 82, 82, 0.3);
            color: #ff8a8a;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-family: 'Rajdhani', sans-serif;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-logout:hover {
            background: rgba(255, 82, 82, 0.2);
        }

        /* Main Content */
        .main {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 32px;
        }

        .hero {
            text-align: center;
            max-width: 700px;
            animation: fadeInUp 0.8s ease both;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .hero-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 48px;
            font-weight: 700;
            color: var(--green);
            margin-bottom: 16px;
            letter-spacing: 0.04em;
            line-height: 1.2;
        }

        .hero-subtitle {
            font-size: 16px;
            color: var(--text-sub);
            margin-bottom: 32px;
            line-height: 1.6;
        }

        .hero-accent {
            display: inline-block;
            width: 80px;
            height: 3px;
            background: linear-gradient(90deg, var(--green), transparent);
            margin-bottom: 24px;
            border-radius: 2px;
        }

        .cta-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 48px;
        }

        .btn-primary {
            background: var(--green);
            color: #020e05;
            padding: 14px 36px;
            border: none;
            border-radius: 4px;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 16px rgba(0, 230, 118, 0.3);
        }

        .btn-primary:hover {
            background: var(--green-dim);
            box-shadow: 0 6px 24px rgba(0, 230, 118, 0.4);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: transparent;
            border: 1px solid var(--border-hi);
            color: var(--text);
            padding: 14px 36px;
            border-radius: 4px;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            border-color: var(--green);
            color: var(--green);
            background: var(--green-glow);
        }

        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 24px;
            margin-top: 48px;
            padding-top: 48px;
            border-top: 1px solid var(--border);
        }

        .feature {
            text-align: left;
            background: var(--surface);
            padding: 24px;
            border: 1px solid var(--border);
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .feature:hover {
            border-color: var(--green);
            background: var(--green-glow);
        }

        .feature-icon {
            font-size: 32px;
            margin-bottom: 12px;
            color: var(--green);
        }

        .feature-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 8px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        .feature-desc {
            font-size: 12px;
            color: var(--muted);
            line-height: 1.6;
        }

        .user-info {
            text-align: center;
            padding: 24px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 4px;
            margin-top: 32px;
        }

        .user-greeting {
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            color: var(--muted);
            margin-bottom: 8px;
            letter-spacing: 0.1em;
            text-transform: uppercase;
        }

        .user-name {
            font-family: 'Rajdhani', sans-serif;
            font-size: 24px;
            font-weight: 700;
            color: var(--green);
            margin-bottom: 16px;
        }

        .user-role {
            display: inline-block;
            padding: 4px 12px;
            background: rgba(0, 230, 118, 0.15);
            border: 1px solid rgba(0, 230, 118, 0.3);
            color: var(--green);
            font-family: 'Rajdhani', sans-serif;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            border-radius: 2px;
        }

        @media (max-width: 768px) {
            .navbar {
                padding: 12px 16px;
                flex-wrap: wrap;
                gap: 12px;
            }

            .navbar-brand {
                font-size: 18px;
            }

            .hero-title {
                font-size: 36px;
            }

            .cta-buttons {
                flex-direction: column;
            }

            .btn-primary, .btn-secondary {
                width: 100%;
                justify-content: center;
            }

            .features {
                grid-template-columns: 1fr;
            }

            .main {
                padding: 40px 16px;
            }
        }
    </style>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar">
    <div class="navbar-left">
        <img src="${pageContext.request.contextPath}/images/verdictlogo.png" alt="Logo" class="navbar-logo"/>
        <div class="navbar-brand">StockVerdict</div>
    </div>
    <div class="navbar-right">
        <c:choose>
            <c:when test="${not empty sessionScope.user}">
                <span class="nav-link" style="cursor: default; background: transparent;">
                    <i class="fas fa-user"></i> ${sessionScope.user.name}
                </span>
                <a href="/traderDashboard.jsp" class="nav-link">
                    <i class="fas fa-chart-line"></i> Dashboard
                </a>
                <a href="/user?action=logout" class="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </c:when>
            <c:otherwise>
                <a href="/login.jsp" class="nav-link">Login</a>
                <a href="/register.jsp" class="btn-primary">Register</a>
            </c:otherwise>
        </c:choose>
    </div>
</nav>

<!-- Main Content -->
<main class="main">
    <div class="hero">
        <div class="hero-accent"></div>
        <h1 class="hero-title">Inventory Management Simplified</h1>
        <p class="hero-subtitle">
            StockVerdict is your complete inventory and supplier management solution. Track products, manage suppliers,
            and monitor sales all in one place.
        </p>

        <c:choose>
            <c:when test="${empty sessionScope.user}">
                <div class="cta-buttons">
                    <a href="/register.jsp" class="btn-primary">
                        <i class="fas fa-plus-circle"></i> Get Started
                    </a>
                    <a href="/login.jsp" class="btn-secondary">
                        <i class="fas fa-sign-in-alt"></i> Sign In
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="cta-buttons">
                    <a href="/traderDashboard.jsp" class="btn-primary">
                        <i class="fas fa-dashboard"></i> Go to Dashboard
                    </a>
                    <a href="/" class="btn-secondary">
                        <i class="fas fa-refresh"></i> Refresh
                    </a>
                </div>

                <div class="user-info">
                    <div class="user-greeting">Logged in as</div>
                    <div class="user-name">${sessionScope.user.name}</div>
                    <span class="user-role">${sessionScope.user.role}</span>
                </div>
            </c:otherwise>
        </c:choose>

        <div class="features">
            <div class="feature">
                <div class="feature-icon"><i class="fas fa-boxes"></i></div>
                <div class="feature-title">Product Management</div>
                <div class="feature-desc">Add, update, and manage your inventory with real-time stock tracking.</div>
            </div>
            <div class="feature">
                <div class="feature-icon"><i class="fas fa-handshake"></i></div>
                <div class="feature-title">Supplier Network</div>
                <div class="feature-desc">Build relationships with suppliers and track balances effortlessly.</div>
            </div>
            <div class="feature">
                <div class="feature-icon"><i class="fas fa-chart-bar"></i></div>
                <div class="feature-title">Sales Tracking</div>
                <div class="feature-desc">Monitor sales performance and revenue in comprehensive reports.</div>
            </div>
            <div class="feature">
                <div class="feature-icon"><i class="fas fa-lock"></i></div>
                <div class="feature-title">Secure & Private</div>
                <div class="feature-desc">Your data is encrypted and protected with enterprise-grade security.</div>
            </div>
        </div>
    </div>
</main>

</body>
</html>

