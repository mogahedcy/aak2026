<?php
require_once 'includes/config.php';
require_once 'includes/functions.php';

// التحقق من تسجيل الدخول
if (isLoggedIn()) {
    redirect('pages/dashboard.php');
}

// معالجة تسجيل الدخول
$error = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = clean($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    
    if (empty($username) || empty($password)) {
        $error = 'يرجى إدخال اسم المستخدم وكلمة المرور';
    } else {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND is_active = true");
        $stmt->execute([$username]);
        $user = $stmt->fetch();
        
        if ($user && password_verify($password, $user['password'])) {
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['username'];
            $_SESSION['full_name'] = $user['full_name'];
            $_SESSION['role'] = $user['role'];
            
            logActivity($user['id'], 'تسجيل دخول', 'تسجيل دخول ناجح');
            redirect('pages/dashboard.php');
        } else {
            $error = 'اسم المستخدم أو كلمة المرور غير صحيحة';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل الدخول - <?php echo SITE_NAME; ?></title>
    <link rel="stylesheet" href="public/css/style.css">
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="login-header">
                <h1><?php echo SITE_NAME; ?></h1>
                <p><?php echo SITE_LOCATION . ' • ' . SITE_YEAR; ?></p>
            </div>
            
            <?php if ($error): ?>
                <div class="alert alert-error"><?php echo $error; ?></div>
            <?php endif; ?>
            
            <form method="POST">
                <div class="form-group">
                    <label>اسم المستخدم</label>
                    <input type="text" name="username" class="form-control" required autofocus>
                </div>
                
                <div class="form-group">
                    <label>كلمة المرور</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                
                <button type="submit" class="btn btn-primary">تسجيل الدخول</button>
            </form>
            
            <div style="margin-top: 20px; text-align: center; color: #666; font-size: 12px;">
                <p>المستخدم الافتراضي: admin</p>
                <p>كلمة المرور: admin123</p>
            </div>
        </div>
    </div>
    
    <!-- شاشة التحميل -->
    <div id="loading-screen">
        <div class="loading-content">
            <div class="spinner"></div>
            <div class="loading-text">
                جاري تسجيل الدخول<span class="loading-dots"></span>
            </div>
            <div class="progress-container">
                <div class="progress-label">يرجى الانتظار</div>
                <div class="progress-bar-wrapper">
                    <div class="progress-bar" id="progress-bar"></div>
                </div>
                <div class="progress-percentage" id="progress-percentage">0%</div>
            </div>
        </div>
    </div>
    
    <script>
        // عرض شاشة التحميل عند تسجيل الدخول
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('form');
            
            if (form) {
                form.addEventListener('submit', function(e) {
                    const loadingScreen = document.getElementById('loading-screen');
                    if (loadingScreen) {
                        loadingScreen.classList.add('active');
                        startProgressBar();
                    }
                });
            }
        });
        
        // دالة لتشغيل شريط التقدم
        function startProgressBar() {
            const progressBar = document.getElementById('progress-bar');
            const progressPercentage = document.getElementById('progress-percentage');
            let progress = 0;
            
            // المرحلة الأولى: من 0% إلى 30% (سريع)
            const interval1 = setInterval(() => {
                if (progress < 30) {
                    progress += Math.random() * 3 + 2;
                    if (progress > 30) progress = 30;
                    updateProgress(progress);
                } else {
                    clearInterval(interval1);
                    startSecondPhase();
                }
            }, 100);
            
            // المرحلة الثانية: من 30% إلى 70% (متوسط)
            function startSecondPhase() {
                const interval2 = setInterval(() => {
                    if (progress < 70) {
                        progress += Math.random() * 2 + 1;
                        if (progress > 70) progress = 70;
                        updateProgress(progress);
                    } else {
                        clearInterval(interval2);
                        startThirdPhase();
                    }
                }, 150);
            }
            
            // المرحلة الثالثة: من 70% إلى 90% (بطيء)
            function startThirdPhase() {
                const interval3 = setInterval(() => {
                    if (progress < 90) {
                        progress += Math.random() * 1 + 0.5;
                        if (progress > 90) progress = 90;
                        updateProgress(progress);
                    } else {
                        clearInterval(interval3);
                        // البقاء على 90% حتى يتم التحميل الفعلي
                    }
                }, 200);
            }
            
            function updateProgress(value) {
                progressBar.style.width = value + '%';
                progressPercentage.textContent = Math.round(value) + '%';
            }
        }
    </script>
</body>
</html>
