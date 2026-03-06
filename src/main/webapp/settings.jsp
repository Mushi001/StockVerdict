<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:if test="${empty sessionScope.currentUser}">
    <c:redirect url="${pageContext.request.contextPath}/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Settings</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/verdictlogo.png"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #00e676; --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.15);
            --bg:         #040e07; --bg-card:    rgba(4,18,9,0.95);
            --bg-sidebar: #020a04;
            --border:     rgba(0,230,118,0.15); --border-hi: rgba(0,230,118,0.4);
            --text:       #e4ffe4; --text-sub:   #a8d4b0;
            --muted:      #5a9a6a; --surface:    rgba(0,20,8,0.6);
            --red:        #ff5252;
        }
        [data-theme="light"] {
            --green:      #00a84a; --green-dim:  #007a35;
            --green-glow: rgba(0,168,74,0.12);
            --bg:         #f0faf2; --bg-card:    #ffffff;
            --bg-sidebar: #e8f5ec;
            --border:     rgba(0,150,60,0.18); --border-hi: rgba(0,150,60,0.45);
            --text:       #0a2e12; --text-sub:   #2d6e3e;
            --muted:      #4a8a5a; --surface:    rgba(210,240,218,0.7);
        }

        body { font-family:'Inter',sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; transition:background 0.3s,color 0.3s; }

        .sidebar { width:230px; flex-shrink:0; background:var(--bg-sidebar); border-right:1px solid var(--border); display:flex; flex-direction:column; position:fixed; top:0; left:0; bottom:0; z-index:50; }
        .sidebar-top { padding:20px 18px 16px; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:10px; }
        .sidebar-logo { width:32px; height:32px; border-radius:50%; object-fit:contain; border:1px solid var(--border-hi); }
        .sidebar-brand { font-family:'Rajdhani',sans-serif; font-size:16px; font-weight:700; color:var(--green); letter-spacing:0.07em; text-transform:uppercase; }
        .sidebar-user { padding:14px 18px; border-bottom:1px solid var(--border); }
        .sidebar-user-name { font-family:'Rajdhani',sans-serif; font-size:13px; font-weight:600; color:var(--text); }
        .sidebar-user-role { font-size:10px; color:var(--muted); text-transform:uppercase; letter-spacing:0.1em; margin-top:2px; }
        .sidebar-nav { flex:1; padding:10px 0; }
        .nav-label { padding:8px 18px 3px; font-family:'Rajdhani',sans-serif; font-size:9px; letter-spacing:0.26em; text-transform:uppercase; color:var(--muted); }
        .nav-item { display:flex; align-items:center; gap:10px; padding:9px 18px; color:var(--muted); text-decoration:none; font-size:13px; cursor:pointer; border:none; background:none; width:100%; text-align:left; border-left:3px solid transparent; transition:color 0.2s,background 0.2s; }
        .nav-item:hover { color:var(--text); background:var(--green-glow); }
        .nav-item.active { color:var(--green); border-left-color:var(--green); background:var(--green-glow); }
        .nav-item.danger { color:var(--red); }
        .nav-item.danger:hover { background:rgba(255,82,82,0.08); }
        .nav-icon { font-size:15px; width:18px; text-align:center; }
        .sidebar-bottom { padding:12px 0; border-top:1px solid var(--border); }

        .main { margin-left:230px; flex:1; min-height:100vh; }
        .topbar { height:54px; background:var(--bg-card); border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; padding:0 26px; position:sticky; top:0; z-index:40; }
        .topbar-title { font-family:'Rajdhani',sans-serif; font-size:15px; font-weight:600; color:var(--text); letter-spacing:0.06em; text-transform:uppercase; }
        .topbar-right { display:flex; align-items:center; gap:10px; }
        .btn-theme { width:32px; height:32px; background:var(--surface); border:1px solid var(--border); color:var(--muted); cursor:pointer; font-size:14px; display:flex; align-items:center; justify-content:center; transition:border-color 0.2s,color 0.2s; }
        .btn-theme:hover { border-color:var(--green); color:var(--green); }

        .content { padding:28px; max-width:860px; }
        .page-hdr { margin-bottom:28px; padding-bottom:18px; border-bottom:1px solid var(--border); }
        .page-eyebrow { font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.26em; text-transform:uppercase; color:var(--green); margin-bottom:4px; }
        .page-title { font-family:'Rajdhani',sans-serif; font-size:28px; font-weight:700; color:var(--text); }
        .page-sub { font-size:13px; color:var(--muted); margin-top:5px; }

        .settings-grid { display:flex; flex-direction:column; gap:20px; }
        .settings-card { background:var(--surface); border:1px solid var(--border); padding:24px; }
        .card-title { font-family:'Rajdhani',sans-serif; font-size:14px; font-weight:700; color:var(--text); letter-spacing:0.08em; text-transform:uppercase; margin-bottom:18px; display:flex; align-items:center; gap:8px; }

        .alert { padding:10px 14px; margin-bottom:20px; font-size:13px; border-left:3px solid; }
        .alert-success { background:rgba(0,230,118,0.08); border-color:var(--green); color:var(--green); }
        .alert-error   { background:rgba(255,82,82,0.08); border-color:var(--red); color:#ff8a8a; }

        .profile-row { display:flex; align-items:center; gap:20px; }
        .avatar { width:64px; height:64px; border-radius:50%; background:var(--green-glow); border:2px solid var(--border-hi); display:flex; align-items:center; justify-content:center; font-family:'Rajdhani',sans-serif; font-size:24px; font-weight:700; color:var(--green); flex-shrink:0; text-transform:uppercase; }
        .profile-info-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px 24px; flex:1; }
        .info-label { font-size:10px; color:var(--muted); text-transform:uppercase; letter-spacing:0.14em; margin-bottom:3px; font-family:'Rajdhani',sans-serif; }
        .info-value { font-size:14px; color:var(--text); font-weight:500; }
        .info-value.green { color:var(--green); }
        .badge { display:inline-block; padding:2px 10px; font-family:'Rajdhani',sans-serif; font-size:10px; font-weight:600; letter-spacing:0.12em; text-transform:uppercase; border:1px solid rgba(0,230,118,0.3); color:var(--green); background:var(--green-glow); }

        .theme-options { display:flex; gap:12px; }
        .theme-btn { flex:1; padding:14px 16px; cursor:pointer; border:2px solid var(--border); background:var(--surface); text-align:center; transition:all 0.2s; }
        .theme-btn:hover { border-color:var(--border-hi); }
        .theme-btn.selected { border-color:var(--green); background:var(--green-glow); }
        .theme-btn-icon { font-size:24px; display:block; margin-bottom:6px; }
        .theme-btn-label { font-family:'Rajdhani',sans-serif; font-size:13px; font-weight:600; letter-spacing:0.1em; text-transform:uppercase; color:var(--text); }
        .theme-btn-desc { font-size:11px; color:var(--muted); margin-top:3px; }

        .field { margin-bottom:14px; }
        .field label { display:block; font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); margin-bottom:6px; }
        .field input { width:100%; background:var(--bg); border:1px solid var(--border); color:var(--text); font-family:'Inter',sans-serif; font-size:13px; padding:10px 13px; outline:none; border-radius:0; transition:border-color 0.2s,box-shadow 0.2s; }
        .field input:focus { border-color:var(--green); box-shadow:0 0 0 1px var(--green-glow); }
        .field input::placeholder { color:rgba(90,154,106,0.4); }
        .field-row { display:flex; gap:14px; }
        .field-row .field { flex:1; }
        .field-hint { font-size:11px; color:var(--muted); margin-top:4px; }

        .strength-bar { height:3px; background:var(--border); margin-top:6px; border-radius:2px; overflow:hidden; }
        .strength-fill { height:100%; width:0; transition:width 0.3s,background 0.3s; border-radius:2px; }

        .btn-primary { padding:10px 22px; background:var(--green); color:#020e05; border:none; cursor:pointer; font-family:'Rajdhani',sans-serif; font-size:12px; font-weight:700; letter-spacing:0.16em; text-transform:uppercase; box-shadow:0 4px 14px var(--green-glow); transition:background 0.2s,transform 0.1s; }
        .btn-primary:hover { background:var(--green-dim); }
        .btn-danger-outline { padding:10px 22px; background:transparent; border:1px solid var(--red); color:var(--red); cursor:pointer; font-family:'Rajdhani',sans-serif; font-size:12px; font-weight:700; letter-spacing:0.16em; text-transform:uppercase; transition:background 0.2s; }
        .btn-danger-outline:hover { background:rgba(255,82,82,0.1); }

        .danger-zone { border-color:rgba(255,82,82,0.25) !important; }
        .danger-zone .card-title { color:var(--red); }
        .danger-item { display:flex; align-items:center; justify-content:space-between; padding:14px 0; border-bottom:1px solid var(--border); gap:20px; }
        .danger-item:last-child { border-bottom:none; padding-bottom:0; }
        .danger-item-title { font-size:14px; color:var(--text); font-weight:500; margin-bottom:3px; }
        .danger-item-desc { font-size:12px; color:var(--muted); }

        .modal-overlay { display:none; position:fixed; inset:0; z-index:500; background:rgba(2,8,4,0.82); backdrop-filter:blur(4px); align-items:center; justify-content:center; padding:20px; }
        .modal-overlay.open { display:flex; }
        .modal { background:var(--bg-card); border:1px solid var(--border-hi); width:100%; max-width:420px; box-shadow:0 0 50px var(--green-glow); animation:modalIn 0.22s ease both; }
        @keyframes modalIn { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
        .modal-hdr { display:flex; align-items:center; justify-content:space-between; padding:16px 20px 12px; border-bottom:1px solid var(--border); }
        .modal-eyebrow { font-family:'Rajdhani',sans-serif; font-size:9px; letter-spacing:0.26em; text-transform:uppercase; color:var(--green); margin-bottom:2px; }
        .modal-title   { font-family:'Rajdhani',sans-serif; font-size:17px; font-weight:700; color:var(--text); }
        .modal-close   { background:none; border:none; cursor:pointer; color:var(--muted); font-size:17px; padding:4px 8px; transition:color 0.2s; }
        .modal-close:hover { color:var(--text); }
        .modal-body { padding:20px; }
        .modal-footer { display:flex; gap:10px; justify-content:flex-end; padding:14px 20px; border-top:1px solid var(--border); }
        .confirm-icon { text-align:center; font-size:36px; margin-bottom:10px; }
        .confirm-msg  { text-align:center; color:var(--muted); font-size:13px; line-height:1.6; margin-bottom:6px; }
        .confirm-name { text-align:center; font-family:'Rajdhani',sans-serif; font-size:14px; color:var(--green); font-weight:600; margin-bottom:16px; }
        .btn-cancel { padding:9px 18px; background:transparent; border:1px solid var(--border); color:var(--muted); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; transition:border-color 0.2s,color 0.2s; }
        .btn-cancel:hover { border-color:var(--border-hi); color:var(--text); }
        .btn-danger { padding:9px 18px; background:rgba(255,82,82,0.1); border:1px solid var(--red); color:var(--red); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; text-decoration:none; display:inline-flex; align-items:center; }
        .btn-danger:hover { background:rgba(255,82,82,0.2); }

        @media(max-width:768px) {
            .sidebar { transform:translateX(-100%); }
            .main { margin-left:0; }
            .profile-row { flex-direction:column; }
            .profile-info-grid { grid-template-columns:1fr; }
            .theme-options { flex-direction:column; }
            .field-row { flex-direction:column; gap:0; }
        }
    </style>
</head>
<body>

<aside class="sidebar">
    <div class="sidebar-top">
        <img src="${pageContext.request.contextPath}/images/verdictlogo.png" class="sidebar-logo" alt="Logo"/>
        <span class="sidebar-brand">StockVerdict</span>
    </div>
    <div class="sidebar-user">
        <div class="sidebar-user-name">${sessionScope.currentUser.name}</div>
        <div class="sidebar-user-role">${sessionScope.currentUser.role}</div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section-label">Main</div>
        <a class="nav-item active" onclick="showSection('dashboard', this)">
            <span class="nav-icon"><i class="fa-solid fa-house"></i></span> Dashboard
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/sales.jsp">
            <span class="nav-icon"><i class="fa-solid fa-chart-line"></i></span> Sales
        </a>
        <div class="nav-section-label">Inventory</div>
        <a class="nav-item" onclick="showSection('stock', this)">
            <span class="nav-icon"><i class="fa-solid fa-boxes-stacked"></i></span> Stock Management
        </a>
        <a class="nav-item" onclick="showSection('suppliers', this)">
            <span class="nav-icon"><i class="fa-solid fa-handshake"></i></span> Suppliers
        </a>
        <div class="nav-section-label">Account</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/settings.jsp">
            <span class="nav-icon"><i class="fa-solid fa-gear"></i></span> Settings
        </a>
        <button class="nav-item danger" onclick="openLogoutModal()">
            <span class="nav-icon"><i class="fa-solid fa-right-from-bracket"></i></span> Logout
        </button>
    </nav>
    <div class="sidebar-bottom">
        <button class="nav-item danger" onclick="openLogoutModal()"><span class="nav-icon">🚪</span> Logout</button>
    </div>
</aside>

<div class="main">
    <div class="topbar">
        <span class="topbar-title">Settings</span>
        <div class="topbar-right">
            <button class="btn-theme" id="themeToggle" onclick="toggleTheme()">🌙</button>
        </div>
    </div>

    <div class="content">
        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                <c:choose>
                    <c:when test="${param.success == 'passwordChanged'}">✓ Password changed successfully.</c:when>
                    <c:otherwise>✓ Settings updated successfully.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">
                <c:choose>
                    <c:when test="${param.error == 'wrongPassword'}">⚠ Current password is incorrect.</c:when>
                    <c:when test="${param.error == 'passwordMismatch'}">⚠ New passwords do not match.</c:when>
                    <c:otherwise>⚠ An error occurred. Please try again.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <div class="page-hdr">
            <div class="page-eyebrow">Account</div>
            <div class="page-title">Settings</div>
            <div class="page-sub">Manage your profile, security, and preferences</div>
        </div>

        <div class="settings-grid">

            <div class="settings-card">
                <div class="card-title">👤 Profile Information</div>
                <div class="profile-row">
                    <div class="avatar">${sessionScope.currentUser.name.substring(0,1)}</div>
                    <div class="profile-info-grid">
                        <div><div class="info-label">Full Name</div><div class="info-value">${sessionScope.currentUser.name}</div></div>
                        <div><div class="info-label">Email Address</div><div class="info-value green">${sessionScope.currentUser.email}</div></div>
                        <div><div class="info-label">Role</div><div class="info-value"><span class="badge">${sessionScope.currentUser.role}</span></div></div>
                        <div><div class="info-label">Account Status</div><div class="info-value"><span class="badge">Active</span></div></div>
                    </div>
                </div>
            </div>

            <div class="settings-card">
                <div class="card-title">🎨 Appearance</div>
                <div style="font-size:12px;color:var(--muted);margin-bottom:14px;">Choose your display theme. Your preference is saved automatically.</div>
                <div class="theme-options">
                    <div class="theme-btn" id="btn-dark" onclick="applyTheme('dark')">
                        <span class="theme-btn-icon">🌙</span>
                        <div class="theme-btn-label">Dark Mode</div>
                        <div class="theme-btn-desc">Easy on the eyes, great for low light</div>
                    </div>
                    <div class="theme-btn" id="btn-light" onclick="applyTheme('light')">
                        <span class="theme-btn-icon">☀️</span>
                        <div class="theme-btn-label">Light Mode</div>
                        <div class="theme-btn-desc">Clean and bright for daytime use</div>
                    </div>
                </div>
            </div>

            <div class="settings-card">
                <div class="card-title">🔒 Change Password</div>
                <form action="${pageContext.request.contextPath}/user" method="post">
                    <input type="hidden" name="action" value="changePassword"/>
                    <div class="field">
                        <label>Current Password</label>
                        <input type="password" name="currentPassword" placeholder="Enter your current password" required/>
                    </div>
                    <div class="field-row">
                        <div class="field">
                            <label>New Password</label>
                            <input type="password" name="newPassword" id="newPass" placeholder="Min. 8 characters" required oninput="checkStrength(this.value)"/>
                            <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                            <div class="field-hint" id="strengthLabel">Enter a new password</div>
                        </div>
                        <div class="field">
                            <label>Confirm New Password</label>
                            <input type="password" name="confirmPassword" id="confirmPass" placeholder="Re-enter new password" required oninput="checkMatch()"/>
                            <div class="field-hint" id="matchLabel"></div>
                        </div>
                    </div>
                    <button type="submit" class="btn-primary">Update Password</button>
                </form>
            </div>

            <div class="settings-card danger-zone">
                <div class="card-title">⚠️ Danger Zone</div>
                <div class="danger-item">
                    <div>
                        <div class="danger-item-title">Log Out</div>
                        <div class="danger-item-desc">End your current session and return to the login page.</div>
                    </div>
                    <button class="btn-danger-outline" onclick="openLogoutModal()">🚪 Logout</button>
                </div>
                <div class="danger-item">
                    <div>
                        <div class="danger-item-title">Delete Account</div>
                        <div class="danger-item-desc">Permanently remove your account and all associated data. This cannot be undone.</div>
                    </div>
                    <button class="btn-danger-outline" onclick="alert('Contact your administrator to delete your account.')">Delete Account</button>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- LOGOUT MODAL -->
<div class="modal-overlay" id="logoutModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm</div><div class="modal-title">Log Out</div></div>
            <button class="modal-close" onclick="closeLogoutModal()">✕</button>
        </div>
        <div class="modal-body">
            <div class="confirm-icon">🚪</div>
            <div class="confirm-msg">Are you sure you want to log out of StockVerdict?</div>
            <div class="confirm-name">You will be returned to the login page.</div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="closeLogoutModal()">Stay Logged In</button>
            <a href="${pageContext.request.contextPath}/user?action=logout" class="btn-danger">Yes, Log Out</a>
        </div>
    </div>
</div>

<script>
    const THEME_KEY = 'sv_theme';
    function applyTheme(t) {
        document.documentElement.setAttribute('data-theme', t);
        const btn = document.getElementById('themeToggle');
        if (btn) btn.textContent = t === 'light' ? '🌙' : '☀️';
        localStorage.setItem(THEME_KEY, t);
        document.getElementById('btn-dark').classList.toggle('selected', t === 'dark');
        document.getElementById('btn-light').classList.toggle('selected', t === 'light');
    }
    function toggleTheme() {
        applyTheme((document.documentElement.getAttribute('data-theme') || 'dark') === 'dark' ? 'light' : 'dark');
    }
    applyTheme(localStorage.getItem(THEME_KEY) || 'dark');

    function openLogoutModal()  { document.getElementById('logoutModal').classList.add('open'); document.body.style.overflow='hidden'; }
    function closeLogoutModal() { document.getElementById('logoutModal').classList.remove('open'); document.body.style.overflow=''; }
    document.getElementById('logoutModal').addEventListener('click', function(e) { if(e.target===this) closeLogoutModal(); });

    function checkStrength(val) {
        const fill=document.getElementById('strengthFill'), label=document.getElementById('strengthLabel');
        let s=0;
        if(val.length>=8)s++; if(/[A-Z]/.test(val))s++; if(/[0-9]/.test(val))s++; if(/[^A-Za-z0-9]/.test(val))s++;
        const lvl=[{w:'0%',c:'transparent',t:''},{w:'25%',c:'#ff5252',t:'Weak'},{w:'50%',c:'#ffb300',t:'Fair'},{w:'75%',c:'#00c853',t:'Good'},{w:'100%',c:'#00e676',t:'Strong'}];
        const l=lvl[Math.min(s,4)]; fill.style.width=l.w; fill.style.background=l.c; label.textContent=l.t; label.style.color=l.c;
    }
    function checkMatch() {
        const np=document.getElementById('newPass').value, cp=document.getElementById('confirmPass').value, lbl=document.getElementById('matchLabel');
        if(!cp){lbl.textContent='';return;}
        if(np===cp){lbl.textContent='✓ Passwords match';lbl.style.color='var(--green)';}
        else{lbl.textContent='✗ Do not match';lbl.style.color='var(--red)';}
    }
    setTimeout(() => {
        document.querySelectorAll('.alert').forEach(el => { el.style.transition='opacity 0.5s'; el.style.opacity='0'; setTimeout(()=>el.remove(),500); });
    }, 5000);
</script>
</body>
</html>