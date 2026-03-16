<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Send Payment — StockVerdict</title>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@500;600;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green: #00e676;
            --green-dim: #00c853;
            --bg: #040e07;
            --bg-card: rgba(4,18,9,0.85);
            --border: rgba(0,230,118,0.22);
            --text: #e4ffe4;
            --text-sub: #a8d4b0;
            --muted: #5a9a6a;
            --surface: rgba(0,20,8,0.6);
        }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow-x: hidden;
        }
        .bg-overlay {
            position: fixed; inset: 0;
            background: linear-gradient(135deg, rgba(0,10,4,0.85) 0%, rgba(0,20,8,0.7) 50%, rgba(0,10,4,0.85) 100%);
            z-index: 1;
        }
        .bg-overlay::after {
            content: ''; position: fixed; inset: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,230,118,0.015) 3px, rgba(0,230,118,0.015) 4px);
            pointer-events: none;
        }
        .card {
            position: relative; z-index: 10;
            width: 100%; max-width: 420px;
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 40px 30px;
            box-shadow: 0 0 60px rgba(0,230,118,0.08), 0 20px 40px rgba(0,0,0,0.6);
            backdrop-filter: blur(20px);
            animation: fadeUp 0.5s ease both;
        }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .logo {
            text-align: center; margin-bottom: 24px;
        }
        .logo-icon {
            width: 64px; height: 64px; border-radius: 50%;
            background: rgba(0,230,118,0.1); border: 2px solid rgba(0,230,118,0.3);
            display: flex; align-items: center; justify-content: center;
            font-size: 28px; color: var(--green); margin: 0 auto 16px;
            box-shadow: 0 0 30px rgba(0,230,118,0.2);
        }
        .title {
            text-align: center; font-family: 'Rajdhani', sans-serif;
            font-size: 28px; font-weight: 700; color: var(--text);
            margin-bottom: 8px; letter-spacing: 0.02em;
        }
        .subtitle {
            text-align: center; color: var(--text-sub); font-size: 14px;
            line-height: 1.5; margin-bottom: 32px;
        }
        .info-box {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 20px; margin-bottom: 16px;
        }
        .info-item {
            margin-bottom: 16px;
        }
        .info-item:last-child { margin-bottom: 0; }
        .info-label {
            font-family: 'Rajdhani', sans-serif; font-size: 11px; font-weight: 600;
            color: var(--muted); text-transform: uppercase; letter-spacing: 0.15em;
            margin-bottom: 4px; display: flex; align-items: center; gap: 6px;
        }
        .info-value {
            font-size: 18px; font-weight: 600; color: var(--green);
            word-break: break-all;
        }
        .copy-btn {
            background: transparent; border: 1px solid var(--border);
            color: var(--text); padding: 4px 10px; border-radius: 4px;
            font-family: 'Inter', sans-serif; font-size: 11px; cursor: pointer;
            margin-left: auto; transition: all 0.2s;
        }
        .copy-btn:hover {
            background: var(--green); color: #000; border-color: var(--green);
        }
        .info-row {
            display: flex; align-items: center;
        }
        .footer {
            text-align: center; font-size: 12px; color: var(--muted);
            margin-top: 24px; font-family: 'Rajdhani', sans-serif; letter-spacing: 0.05em;
        }
        .footer i { color: var(--green); margin-right: 4px; }
    </style>
</head>
<body>

<div class="bg-overlay"></div>

<div class="card">
    <div class="logo">
        <div class="logo-icon"><i class="fas fa-check"></i></div>
        <div class="title">Secure Payment</div>
        <div class="subtitle">
            Welcome to StockVerdict.<br>
            You are going to send money to:
        </div>
    </div>

    <c:choose>
        <c:when test="${not empty trader}">
            <div style="text-align:center; font-family:'Rajdhani',sans-serif; font-size:24px; font-weight:700; color:var(--text); margin-bottom:24px; border-bottom:1px solid var(--border); padding-bottom:16px;">
                <c:if test="${not empty trader.profileImageUrl}">
                    <img src="${pageContext.request.contextPath}/${trader.profileImageUrl}" alt="Trader Logo" style="width: 80px; height: 80px; object-fit: cover; border-radius: 50%; border: 2px solid var(--green); margin-bottom: 12px; box-shadow: 0 4px 12px rgba(0,230,118,0.2);">
                    <br>
                </c:if>
                ${not empty trader.businessName ? trader.businessName : trader.name}
            </div>

            <div class="info-box">
                <c:if test="${not empty trader.email}">
                    <div class="info-item">
                        <div class="info-label"><i class="fas fa-envelope"></i> Email Address</div>
                        <div class="info-row">
                            <div class="info-value" id="emailAdd" style="font-size:16px;">${trader.email}</div>
                            <button class="copy-btn" onclick="copyText('emailAdd', this)">Copy</button>
                        </div>
                    </div>
                </c:if>

                <c:if test="${not empty trader.momoCode}">
                    <div class="info-item" style="${not empty trader.email ? 'border-top:1px solid rgba(0,230,118,0.1); padding-top:16px;' : ''}">
                        <div class="info-label"><i class="fas fa-mobile-alt"></i> Mobile Money Number</div>
                        <div class="info-row">
                            <div class="info-value" id="momoNum">${trader.momoCode}</div>
                            <button class="copy-btn" onclick="copyText('momoNum', this)">Copy</button>
                        </div>
                    </div>
                </c:if>

                <c:if test="${not empty trader.bankAccountNumber}">
                    <div class="info-item" style="border-top:1px solid rgba(0,230,118,0.1); padding-top:16px;">
                        <div class="info-label"><i class="fas fa-university"></i> Bank Account</div>
                        <div class="info-row">
                            <div class="info-value" id="bankNum">${trader.bankAccountNumber}</div>
                            <button class="copy-btn" onclick="copyText('bankNum', this)">Copy</button>
                        </div>
                    </div>
                </c:if>
            </div>
            
            <div style="text-align:center; margin-top:24px; font-size:13px; color:var(--text-sub);">
                Please use your banking or mobile money app to complete the transfer using the details provided above.
            </div>
        </c:when>
        <c:otherwise>
            <div style="text-align:center; padding:30px 0; color:var(--red);">
                <i class="fas fa-exclamation-triangle" style="font-size:40px; margin-bottom:16px;"></i>
                <div style="font-size:18px; font-weight:600;">Trader Not Found</div>
                <div style="font-size:14px; margin-top:8px; opacity:0.8;">The payment information you are looking for is invalid or no longer exists.</div>
            </div>
        </c:otherwise>
    </c:choose>

    <div class="footer">
        <i class="fas fa-shield-alt"></i> Verified by StockVerdict
    </div>
</div>

<script>
    function copyText(elementId, btn) {
        var text = document.getElementById(elementId).innerText;
        navigator.clipboard.writeText(text).then(function() {
            var originalText = btn.innerText;
            btn.innerText = "Copied!";
            btn.style.background = "var(--green)";
            btn.style.color = "#000";
            setTimeout(function() {
                btn.innerText = originalText;
                btn.style.background = "transparent";
                btn.style.color = "var(--text)";
            }, 2000);
        });
    }
</script>

</body>
</html>
