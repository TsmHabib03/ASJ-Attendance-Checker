<?php
/**
 * Copy this file to `config/secrets.local.php` and fill in real values.
 *   cp config/secrets.example.php config/secrets.local.php
 *
 * `config/secrets.local.php` is excluded by `.gitignore` — never commit it.
 * Every value below can also be provided as an environment variable of the
 * same name, which takes precedence over this file.
 */
return [
    // Database
    'DB_HOST' => 'localhost',
    'DB_USER' => 'root',
    'DB_PASS' => '',
    'DB_NAME' => 'asj_attendease_db2',
    'DB_CHARSET' => 'utf8mb4',

    // SMTP (password-reset e-mails) — see SETUP.md
    'SMTP_HOST' => 'smtp.gmail.com',
    'SMTP_PORT' => 587,
    'SMTP_SECURE' => 'tls',
    'SMTP_USERNAME' => '',
    'SMTP_PASSWORD' => '',

    // Mail headers
    'MAIL_FROM_EMAIL' => '',
    'MAIL_FROM_NAME' => 'ASJ Attendance',
    'MAIL_REPLY_TO_EMAIL' => '',
    'MAIL_REPLY_TO_NAME' => '',

    // SMS gateway — see ANDROID_SMS_SETUP.md
    'SMS_API_URL' => '',
    'SMS_API_KEY' => '',
];
