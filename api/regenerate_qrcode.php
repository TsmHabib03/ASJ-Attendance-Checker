<?php
/**
 * API Endpoint: Regenerate QR Code for Student
 * Allows admin to manually regenerate QR code for existing student
 */

// Start session only if none exists (avoid "session_start(): Ignoring session_start()" notices)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Prevent PHP notices/warnings from being output and breaking JSON responses
@ini_set('display_errors', '0');
require_once '../admin/config.php';
require_once '../includes/qrcode_helper.php';
require_once __DIR__ . '/../includes/auth_middleware.php';

header('Content-Type: application/json');

// Enforce admin role — return JSON if unauthenticated/unauthorized
if (!isAuthenticated()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Authentication required']);
    exit;
}
if (!hasRole([ROLE_ADMIN])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Admin role required']);
    exit;
}

// Check request method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit;
}

// Get student ID from request (accept JSON body or form POST)
$rawInput = file_get_contents('php://input');
$input = null;
if (!empty($rawInput)) {
    $input = json_decode($rawInput, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        // Not JSON — ignore and fallback to POST
        $input = null;
    }
}

$studentId = 0;
if (is_array($input) && isset($input['student_id'])) {
    $studentId = intval($input['student_id']);
} elseif (isset($_POST['student_id'])) {
    $studentId = intval($_POST['student_id']);
} elseif (isset($_REQUEST['student_id'])) {
    $studentId = intval($_REQUEST['student_id']);
}

if ($studentId <= 0) {
    error_log('regenerate_qrcode: invalid or missing student_id; rawInput=' . substr($rawInput ?? '', 0, 200));
    // Append debug file for easier diagnosis
    try {
        $dbg = __DIR__ . '/../uploads/qrcodes/regenerate_debug.log';
        $entry = "[" . date('Y-m-d H:i:s') . "] MISSING_ID method={$_SERVER['REQUEST_METHOD']} rawInput=" . substr($rawInput ?? '', 0, 500) . " POST=" . print_r($_POST, true) . "\n";
        file_put_contents($dbg, $entry, FILE_APPEND | LOCK_EX);
    } catch (Exception $e) {
        // ignore
    }
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid student ID'
    ]);
    exit;
}

// Diagnostic debug entry: record request for troubleshooting
try {
    $dbg = __DIR__ . '/../uploads/qrcodes/regenerate_debug.log';
    $entry = "[" . date('Y-m-d H:i:s') . "] REQUEST method={$_SERVER['REQUEST_METHOD']} student_id={$studentId} rawInput=" . str_replace("\n", ' ', substr($rawInput ?? '', 0, 1000)) . " POST=" . json_encode($_POST) . "\n";
    file_put_contents($dbg, $entry, FILE_APPEND | LOCK_EX);
} catch (Exception $e) {
    // ignore
}

try {
    // Get student details
    $stmt = $pdo->prepare("SELECT id, lrn, first_name, middle_name, last_name FROM students WHERE id = ?");
    $stmt->execute([$studentId]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);
    // Debug: record whether student was found
    try {
        $dbg = __DIR__ . '/../uploads/qrcodes/regenerate_debug.log';
        $entry = "[" . date('Y-m-d H:i:s') . "] STUDENT_LOOKUP id={$studentId} found=" . ($student ? '1' : '0') . "\n";
        file_put_contents($dbg, $entry, FILE_APPEND | LOCK_EX);
    } catch (Exception $e) {}
    
    if (!$student) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Student not found'
        ]);
        exit;
    }
    
    // Generate full name
    $fullName = trim($student['first_name'] . ' ' . $student['middle_name'] . ' ' . $student['last_name']);
    
    // Regenerate QR code
    $qrCodePath = regenerateStudentQRCode($student['id'], $student['lrn'], $fullName);

    // Debug: record result of generation
    try {
        $dbg = __DIR__ . '/../uploads/qrcodes/regenerate_debug.log';
        $entry = "[" . date('Y-m-d H:i:s') . "] QR_GENERATION id={$studentId} result=" . ($qrCodePath ? $qrCodePath : 'FAILED') . "\n";
        file_put_contents($dbg, $entry, FILE_APPEND | LOCK_EX);
    } catch (Exception $e) {}
    
    if ($qrCodePath) {
        // Update database with new QR code path. Only set updated_at if column exists.
        if (function_exists('columnExists') && columnExists($pdo, 'students', 'updated_at')) {
            $updateStmt = $pdo->prepare("UPDATE students SET qr_code = ?, updated_at = NOW() WHERE id = ?");
            $updateStmt->execute([$qrCodePath, $student['id']]);
        } else {
            $updateStmt = $pdo->prepare("UPDATE students SET qr_code = ? WHERE id = ?");
            $updateStmt->execute([$qrCodePath, $student['id']]);
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'QR code regenerated successfully',
            'qr_code_path' => '../' . $qrCodePath . '?v=' . time() // Add timestamp to force refresh
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to regenerate QR code. Please check server permissions.'
        ]);
    }
    
} catch (Exception $e) {
    // Log to both PHP log and our debug file
    error_log("QR regeneration error: " . $e->getMessage());
    try {
        $dbg = __DIR__ . '/../uploads/qrcodes/regenerate_debug.log';
        $entry = "[" . date('Y-m-d H:i:s') . "] EXCEPTION: " . $e->getMessage() . "\n";
        file_put_contents($dbg, $entry, FILE_APPEND | LOCK_EX);
    } catch (Exception $ex) {}
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error occurred'
    ]);
}
