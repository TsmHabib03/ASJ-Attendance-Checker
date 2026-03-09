<?php
/**
 * Local secrets file for ACSCCI Attendance System. secrets.local.php
 *
 * This file is intended to hold real credentials on a local or production
 * server. Do NOT commit real secrets to the repository. Instead, copy
 * `config/secrets.example.php` to `config/secrets.local.php` and fill in
 * the real values. The repository `.gitignore` excludes `config/secrets.local.php`.
 */

// Example structure. Replace the placeholder values below with real ones.
return [
    // Database
    'DB_HOST' => 'localhost',
    'DB_USER' => 'root',
    'DB_PASS' => 'muning0328',
    'DB_NAME' => 'asj_attendease_db2',

    // Email (SMTP)
    'SMTP_HOST' => 'smtp.gmail.com',
    'SMTP_PORT' => 465,
    'SMTP_SECURE' => 'ssl',
    'SMTP_USERNAME' => 'asjclaveriaattendance@gmail.com',
    'SMTP_PASSWORD' => 'otnrczhculmiojop',
    'MAIL_FROM_EMAIL' => 'asjclaveriaattendance@gmail.com',
    'MAIL_FROM_NAME' => 'ACSCCI Attendance System',
    'MAIL_REPLY_TO_EMAIL' => 'asjclaveriaattendance@gmail.com',
    'MAIL_REPLY_TO_NAME' => 'ACSCCI Attendance System',
    // SMS gateway (for Android SMS gateway or external API)
    // Set these when using the 'custom' provider in config/sms_config.php
    // Example: 'SMS_API_URL' => 'http://192.168.1.5:8080/v1/sms',
    'SMS_API_URL' => '',
    'SMS_API_KEY' => '',
];
