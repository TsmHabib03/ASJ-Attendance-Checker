<?php
/**
 * email_config.php Email Configuration for ACSCCI Attendance System
 *
 * Use environment variables or config/secrets.local.php for credentials.
 * secrets.local.php is ignored by git to avoid leaking passwords.
 */

$secrets = [];
$secretsPath = __DIR__ . '/secrets.local.php';
if (file_exists($secretsPath)) {
    $loaded = require $secretsPath;
    if (is_array($loaded)) {
        $secrets = $loaded;
    }
}

$getConfig = static function (string $key, $default = '') use ($secrets) {
    $value = getenv($key);
    if ($value === false || $value === '') {
        $value = $secrets[$key] ?? $default;
    }
    return $value;
};

// Email Configuration Settings
define('SMTP_HOST', $getConfig('SMTP_HOST', 'smtp.gmail.com'));
define('SMTP_PORT', (int)$getConfig('SMTP_PORT', 465)); // Use 587 for TLS or 465 for SSL
define('SMTP_SECURE', $getConfig('SMTP_SECURE', 'ssl')); // 'tls' or 'ssl'
define('SMTP_AUTH', true);

// SMTP Credentials
define('SMTP_USERNAME', $getConfig('SMTP_USERNAME', ''));
define('SMTP_PASSWORD', $getConfig('SMTP_PASSWORD', ''));

// Sender Information
define('MAIL_FROM_EMAIL', $getConfig('MAIL_FROM_EMAIL', SMTP_USERNAME));
define('MAIL_FROM_NAME', $getConfig('MAIL_FROM_NAME', 'ACSCCI Attendance System'));

// Reply-To Information
define('MAIL_REPLY_TO_EMAIL', $getConfig('MAIL_REPLY_TO_EMAIL', MAIL_FROM_EMAIL));
define('MAIL_REPLY_TO_NAME', $getConfig('MAIL_REPLY_TO_NAME', MAIL_FROM_NAME));

// Email Settings
define('MAIL_CHARSET', $getConfig('MAIL_CHARSET', 'UTF-8'));
define('MAIL_DEBUG', (int)$getConfig('MAIL_DEBUG', 0)); // Set to 2 for debugging SMTP connection issues, 0 for production

// Password Reset Email Settings
define('PASSWORD_RESET_SUBJECT', 'Password Reset Request - ACSCCI Attendance System');
define('PASSWORD_RESET_EXPIRY_HOURS', 1); // Token expires after 1 hour

// System URL (used in email links)
define('SYSTEM_BASE_URL', $getConfig('SYSTEM_BASE_URL', 'http://localhost/ACSCCI-Attendance-Checker')); // Update this for production

// ============================================================
// RETURN ARRAY CONFIGURATION FOR mark_attendance.php
// This ensures both constant-based and array-based email systems work
// ============================================================
return [
    // SMTP Server Settings
    'smtp_host' => SMTP_HOST,
    'smtp_port' => SMTP_PORT,
    'smtp_secure' => SMTP_SECURE, // 'tls' or 'ssl'
    'smtp_username' => SMTP_USERNAME,
    'smtp_password' => SMTP_PASSWORD,
    
    // Sender Information
    'from_email' => MAIL_FROM_EMAIL,
    'from_name' => MAIL_FROM_NAME,
    'reply_to_email' => MAIL_REPLY_TO_EMAIL,
    'reply_to_name' => MAIL_REPLY_TO_NAME,
    
    // Email Settings
    'charset' => MAIL_CHARSET,
    'debug' => MAIL_DEBUG,
    
    // Notification Settings (enable/disable emails)
    'send_on_time_in' => true,  // Send email when student scans Time IN
    'send_on_time_out' => true, // Send email when student scans Time OUT
    
    // Email Subjects
    'subject_time_in' => 'Attendance Alert: {student_name} has arrived at school',
    'subject_time_out' => 'Attendance Alert: {student_name} has left school',
    
    // School Information (for email templates)
    'school_name' => 'Academy of St. Joseph Claveria, Cagayan Inc.',
    'school_address' => 'Claveria, Cagayan, Philippines',
    'support_email' => MAIL_FROM_EMAIL,
    
    // System Settings
    'base_url' => SYSTEM_BASE_URL,
];
?>
