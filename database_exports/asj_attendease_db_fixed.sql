-- ============================================================
-- AttendEase v3.0 - Academy of St. Joseph Claveria
-- Portable Database Export - Ready to import on any device
-- Generated: Mar 09, 2026
-- Compatible with: MySQL 5.7+ / MySQL 8.0 / MariaDB 10.3+
-- ============================================================
--
-- HOW TO IMPORT:
-- 1. Open phpMyAdmin on the target computer
-- 2. Create a new database (e.g. "asj_attendease_db")
-- 3. Select that database
-- 4. Go to Import tab
-- 5. Choose this file and click Go
-- 6. Update config/secrets.local.php with the database name you chose
--
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS = 0;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------
-- Drop existing views first (they depend on tables)
-- --------------------------------------------------------
DROP VIEW IF EXISTS `v_daily_attendance_summary_v3`;
DROP VIEW IF EXISTS `v_student_roster_v3`;
DROP VIEW IF EXISTS `v_teacher_roster`;

-- --------------------------------------------------------
-- Drop existing tables (order matters for foreign keys)
-- --------------------------------------------------------
DROP TABLE IF EXISTS `user_badges`;
DROP TABLE IF EXISTS `behavior_alerts`;
DROP TABLE IF EXISTS `attendance`;
DROP TABLE IF EXISTS `teacher_attendance`;
DROP TABLE IF EXISTS `admin_activity_log`;
DROP TABLE IF EXISTS `sms_logs`;
DROP TABLE IF EXISTS `sms_templates`;
DROP TABLE IF EXISTS `system_settings`;
DROP TABLE IF EXISTS `attendance_schedules`;
DROP TABLE IF EXISTS `badges`;
DROP TABLE IF EXISTS `students`;
DROP TABLE IF EXISTS `teachers`;
DROP TABLE IF EXISTS `sections`;
DROP TABLE IF EXISTS `admin_users`;

-- --------------------------------------------------------
-- Drop existing procedures
-- --------------------------------------------------------
DROP PROCEDURE IF EXISTS `AddColumnIfNotExists`;
DROP PROCEDURE IF EXISTS `DropIndexIfExists`;
DROP PROCEDURE IF EXISTS `GetStudentAttendance`;
DROP PROCEDURE IF EXISTS `MarkAttendance_v3`;
DROP PROCEDURE IF EXISTS `RegisterStudent_v3`;
DROP PROCEDURE IF EXISTS `RegisterTeacher`;
DROP PROCEDURE IF EXISTS `RenameColumnIfExists`;

-- ============================================================
-- TABLE STRUCTURES AND DATA (created FIRST so views/procedures work)
-- ============================================================

-- --------------------------------------------------------
-- Table: admin_users
-- --------------------------------------------------------
CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Hashed password (MD5 or bcrypt)',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Admin full name',
  `role` enum('admin','teacher','staff','student') COLLATE utf8mb4_unicode_ci DEFAULT 'admin',
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `reset_token` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_active_users` (`is_active`,`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Admin and staff user accounts';

INSERT INTO `admin_users` (`id`, `username`, `password`, `email`, `full_name`, `role`, `is_active`, `last_login`, `created_at`, `updated_at`, `reset_token`, `reset_token_expires`) VALUES
(1, 'admin', '0192023a7bbd73250516f069df18b500', 'asjclaveria.attendance@gmail.com', 'System Administrator', 'admin', 1, '2026-02-28 05:37:55', '2025-11-07 06:18:21', '2026-02-28 05:37:55', NULL, NULL);

-- --------------------------------------------------------
-- Table: sections
-- --------------------------------------------------------
CREATE TABLE `sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `grade_level` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Grade level (e.g., Grade 12)',
  `section_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Section name',
  `adviser` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Class adviser name',
  `school_year` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'School year (e.g., 2024-2025)',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Active/inactive status',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `am_start_time` time DEFAULT '07:30:00',
  `am_late_threshold` time DEFAULT '08:00:00',
  `am_end_time` time DEFAULT '12:00:00',
  `pm_start_time` time DEFAULT '13:00:00',
  `pm_late_threshold` time DEFAULT '13:30:00',
  `pm_end_time` time DEFAULT '17:00:00',
  `session` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `uses_custom_schedule` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_section` (`grade_level`,`section_name`),
  KEY `idx_grade_section` (`grade_level`,`section_name`),
  KEY `idx_active` (`is_active`),
  KEY `idx_sections_schedule` (`am_start_time`,`pm_start_time`),
  KEY `idx_sections_am_start` (`am_start_time`),
  KEY `idx_sections_pm_start` (`pm_start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Section management for ASJ';

INSERT INTO `sections` (`id`, `grade_level`, `section_name`, `adviser`, `school_year`, `is_active`, `created_at`, `updated_at`, `am_start_time`, `am_late_threshold`, `am_end_time`, `pm_start_time`, `pm_late_threshold`, `pm_end_time`, `session`, `schedule_id`, `uses_custom_schedule`) VALUES
(12, '7', 'St. Francis', 'Janice Tabuyo', '2026-2027', 1, '2026-02-27 16:47:22', '2026-02-27 16:47:22', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(13, '7', 'St. Hildegard', 'Florendo Sagun Jr.', '2026-2027', 1, '2026-02-27 16:47:59', '2026-02-27 16:47:59', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(14, '7', 'St. Jerome', 'Valerie Shayne Talosig', '2026-2027', 1, '2026-02-27 16:48:23', '2026-02-27 16:48:23', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(15, '8', 'St. Andrew', 'Anabelle Labii', '2026-2027', 1, '2026-02-27 16:48:41', '2026-02-27 16:48:41', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(16, '8', 'St. Monica', 'Christian Joel Bumagat', '2026-2027', 1, '2026-02-27 16:48:56', '2026-02-27 16:48:56', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(17, '8', 'St. Bernard', 'Rey Ann Joyce Manguba', '2026-2027', 1, '2026-02-27 16:49:24', '2026-02-27 16:49:24', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(18, '9', 'St. Arnold', 'Arnie Mae Ricardos', '2026-2027', 1, '2026-02-27 16:49:40', '2026-02-27 16:49:40', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(19, '9', 'St. Joseph', 'Sionie Vhy Sagun', '2026-2027', 1, '2026-02-27 16:49:59', '2026-02-27 16:49:59', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(20, '10', 'St. Charles', 'Sheryl Vicente', '2026-2027', 1, '2026-02-27 16:50:14', '2026-02-27 16:50:14', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(21, '10', 'St. Albert', 'Raffy Carinan', '2026-2027', 1, '2026-02-27 16:50:27', '2026-02-27 16:50:27', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(22, '10', 'St. Cecilia', 'Charisse Lagazo', '2026-2027', 1, '2026-02-27 16:50:46', '2026-02-27 16:50:46', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(23, '11', 'St. Therese', 'Janibie John Pascua', '2026-2027', 1, '2026-02-27 16:51:05', '2026-02-27 16:51:05', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(24, '11', 'St. Regina', 'Vanessa Agtang', '2026-2027', 1, '2026-02-27 16:51:28', '2026-02-27 16:51:28', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(25, '11', 'St. Jude', 'Irevince Aquino', '2026-2027', 1, '2026-02-27 16:51:48', '2026-02-27 16:51:48', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(26, '12', 'St. Ignatius De Loyola', 'Kamille Gerard Villa', '2026-2027', 1, '2026-02-27 16:52:04', '2026-02-27 16:52:04', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(27, '12', 'St. Dominic', 'Gonieto Hernandez', '2026-2027', 1, '2026-02-27 16:52:27', '2026-02-27 16:52:27', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(28, '12', 'Blessed Aloysius', 'Alyza Marie Daleja', '2026-2027', 1, '2026-02-27 16:52:45', '2026-02-27 16:52:45', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0),
(29, '12', 'St. Benedict', 'Joy Ann V. Torres', '2026-2027', 1, '2026-02-27 16:53:02', '2026-02-27 16:53:02', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '00:00:00', '', 1, 0);

-- --------------------------------------------------------
-- Table: students
-- --------------------------------------------------------
CREATE TABLE `students` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lrn` varchar(13) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Learner Reference Number (11-13 digits)',
  `first_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Middle name for DepEd forms',
  `last_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sex` enum('Male','Female','M','F') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Male' COMMENT 'Sex for SF2 reporting',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Parent email for alerts notifications',
  `class` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Grade level (e.g., Grade 12)',
  `section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Section name',
  `qr_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'QR code data for scanning',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `mobile_number` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Parent mobile number for SMS notifications',
  PRIMARY KEY (`id`),
  UNIQUE KEY `lrn` (`lrn`),
  KEY `idx_lrn` (`lrn`),
  KEY `idx_section` (`section`),
  KEY `idx_class` (`class`),
  KEY `idx_gender` (`sex`),
  KEY `idx_students_section` (`section`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Student records for The Josephites';

INSERT INTO `students` (`id`, `lrn`, `first_name`, `middle_name`, `last_name`, `sex`, `email`, `class`, `section`, `qr_code`, `created_at`, `mobile_number`) VALUES
(81, '102452180047', 'Sofia Beatrice', 'R.', 'Acon', 'Male', 'benjiegumarangruiz5@gmail.com', 'Grade 7', 'St. Jerome', 'uploads/qrcodes/student_81.png', '2026-02-27 16:53:16', '09804448951'),
(82, '102615180007', 'Ruvie', '', 'Ancheta', 'Male', 'benjiegumarangruiz5@gmail.com', 'Grade 7', 'St. Hildegard', 'uploads/qrcodes/student_82.png', '2026-02-27 16:53:16', '09706161722'),
(83, '102918180011', 'Catriona Cute', '', 'Nak', 'Female', '', 'Grade 9', 'ST. JOSEPH', 'uploads/qrcodes/student_83.png', '2026-02-27 16:53:16', '09598406341'),
(84, '02915130007', 'Thoreviz', 'P.', 'Ilaga', 'Male', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. DOMINIC', 'uploads/qrcodes/student_84.png', '2026-02-27 16:53:16', '09685324777'),
(85, '102606170041', 'Kherin Clark', '', 'Ramos', 'Male', '', 'Grade 11', 'ST. REGINA', '', '2026-02-27 16:53:16', '09978857205'),
(86, '415023160001', 'Zysean', '', 'Cadang', 'Male', 'frithzkenneth1014@gmail.com', 'Grade 8', 'ST. ANDREW', 'uploads/qrcodes/student_86.png', '2026-02-27 16:53:16', '09804448951'),
(87, '400363180019', 'Ariane', 'Alcantara', 'Grande', 'Male', '', 'Grade 7', 'St. Francis', 'uploads/qrcodes/student_87.png', '2026-02-27 16:53:16', ''),
(88, '102608180035', 'Emira Kirsten', '', 'Alupay', 'Female', 'agudapaula11@gmail.com', 'Grade 10', 'ST. CECILIA', 'uploads/qrcodes/student_88.png', '2026-02-27 16:53:16', '09685324777'),
(89, '22163599', 'Ivan Thoe', 'C.', 'de Peralta', 'Male', '', 'Grade 7', 'St. Hildegard', 'uploads/qrcodes/student_89.png', '2026-02-27 16:53:16', ''),
(90, '102605180007', 'Michaela Dane', '', 'Dalire', 'Male', 'frithzkenneth1014@gmail.com', 'Grade 8', 'ST. BERNARD', 'uploads/qrcodes/student_90.png', '2026-02-27 16:53:16', '09706161722'),
(91, '102607180007', 'Christian', 'M.', 'Cabutan', 'Male', 'princessliannetolentino5@gmail.com', 'Grade 12', 'BLESSED ALOYSIUS', 'uploads/qrcodes/student_91.png', '2026-02-27 16:53:16', '09706161722'),
(92, '102915180006', 'Akijah Zyrus', '', 'Comado', 'Male', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. BENEDICT', 'uploads/qrcodes/student_92.png', '2026-02-27 16:53:16', '09598406341'),
(93, '102609170009', 'Jamina', '', 'De Loyola', 'Female', 'jamesbrianelg@gmail.com', 'Grade 9', 'ST. JOSEPH', 'uploads/qrcodes/student_93.png', '2026-02-27 16:53:16', '09706161722'),
(94, '102622170002', 'Isaiah', '', 'Duro', 'Male', '', 'Grade 8', 'ST. BERNARD', 'uploads/qrcodes/student_94.png', '2026-02-27 16:53:16', '09804448951'),
(95, '400363170003', 'Janelle', '', 'Ubi', 'Female', 'frithzkenneth1014@gmail.com', 'Grade 8', 'ST. ANDREW', 'uploads/qrcodes/student_95.png', '2026-02-27 16:53:16', '09598406341'),
(96, '102612170012', 'Heio Leigh', '', 'Pante', 'Male', '', 'Grade 11', 'ST. JUDE', '', '2026-02-27 16:53:16', '09685324777'),
(97, '10290020126', 'Reigniah Mae', '', 'Dagosos', 'Male', 'frithzkenneth1014@gmail.com', 'Grade 8', 'St. Monica', 'uploads/qrcodes/student_97.png', '2026-02-27 16:53:16', '09706161722'),
(98, '400363160002', 'Lorie Jane', 'A.', 'Cantor', 'Male', '', 'Grade 7', 'St. Andrew', 'uploads/qrcodes/student_98.png', '2026-02-27 16:53:16', ''),
(99, '102612170001', 'Dwyane', '', 'Milan', 'Male', 'jamesbrianelg@gmail.com', 'Grade 9', 'ST. JOSEPH', 'uploads/qrcodes/student_99.png', '2026-02-27 16:53:16', '09598406341'),
(100, '102915180030', 'Jhanella', 'E.', 'Libed', 'Female', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. DOMINIC', 'uploads/qrcodes/student_100.png', '2026-02-27 16:53:16', '09706161722'),
(101, '10358321800', 'Ace Xander', 'A.', 'Campos', 'Male', '', 'Grade 10', 'ST. ALBERT', 'uploads/qrcodes/student_101.png', '2026-02-27 16:53:16', '09685324777'),
(102, '102607180019', 'Hannah Eunice', 'R.', 'Espejo', 'Male', 'benjiegumarangruiz5@gmail.com', 'Grade 7', 'St. Jerome', 'uploads/qrcodes/student_102.png', '2026-02-27 16:53:16', '09978857205'),
(103, '102609180048', 'Done Laure', '', 'De Leon', 'Male', '', 'Grade 7', 'St. Francis', 'uploads/qrcodes/student_103.png', '2026-02-27 16:53:16', ''),
(104, '102920170001', 'Khryzha Kyle', 'A.', 'Omlayni', 'Male', '', 'Grade 8', 'St. Andrew', 'uploads/qrcodes/student_104.png', '2026-02-27 16:53:16', ''),
(105, '102915180010', 'Vllb. Gino', 'M.', 'dwew', 'Male', 'benjiegumarangruiz5@gmail.com', 'Grade 7', 'St. Hildegard', 'uploads/qrcodes/student_105.png', '2026-02-27 16:53:16', '09706161722'),
(106, '400363180018', 'Jane', 'A.', 'Bacolod', 'Male', '', 'Grade 7', 'ST. BERNARD', 'uploads/qrcodes/student_106.png', '2026-02-27 16:53:16', '09804448951'),
(107, '102608130015', 'Jonte', '', 'Harurut', 'Male', '', 'Grade 10', 'ST. CHARLES', 'uploads/qrcodes/student_107.png', '2026-02-27 16:53:16', '09706161722'),
(108, '102915180018', 'Nathalie', '', 'Kleyre', 'Male', '', 'Grade 7', 'St. Francis', 'uploads/qrcodes/student_108.png', '2026-02-27 16:53:16', ''),
(109, '400363160010', 'John Carl', '', 'Gidugo', 'Male', 'agudapaula11@gmail.com', 'Grade 10', 'ST. CHARLES', 'uploads/qrcodes/student_109.png', '2026-02-27 16:53:16', '09706161722'),
(110, '102608140082', 'Raine', '', 'Uanib', 'Female', 'jamesbrianelg@gmail.com', 'Grade 9', 'ST. ARNOLD', 'uploads/qrcodes/student_110.png', '2026-02-27 16:53:16', '09598406341'),
(563, '10260518007', 'Michaela', '', 'Dalire', 'Male', 'benjiegumarangruiz5@gmail.com', 'Grade 7', 'ST. JEROME', 'uploads/qrcodes/student_563.png', '2026-02-27 23:32:01', '09923567890'),
(564, '400363140014', 'Raine', 'Angela', 'Baccaray', 'Female', 'agudapaula11@gmail.com', 'Grade 10', 'ST. ALBERT', 'uploads/qrcodes/student_564.png', '2026-02-27 23:32:01', '09972345437'),
(565, '101207180019', 'Hannah', 'Eunice', 'Espejo', 'Female', 'agudapaula11@gmail.com', 'Grade 10', 'ST. CECILIA', 'uploads/qrcodes/student_565.png', '2026-02-27 23:32:01', '09706161722'),
(566, '102915180005', 'Arkian', '', 'Camudo', 'Male', 'jamesbrianelg@gmail.com', 'Grade 9', 'ST. ARNOLD', 'uploads/qrcodes/student_566.png', '2026-02-27 23:32:01', '09598406341'),
(567, '135032180004', 'Ace', 'Xander', 'Campos', 'Male', 'jamesbrianelg@gmail.com', 'Grade 9', 'ST. ARNOLD', 'uploads/qrcodes/student_567.png', '2026-02-27 23:32:01', '09804448951'),
(568, '10290020003', 'Reignel', '', 'Dagasao', 'Male', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. BENEDICT', 'uploads/qrcodes/student_568.png', '2026-02-27 23:32:01', '09685324777'),
(569, '101617120012', 'Freya', '', 'Ramos', 'Male', '', 'Grade 8', 'ST. MONICA', '', '2026-02-27 23:32:01', '09706161722'),
(570, '102608140038', 'EDWIN', '', 'VILIENTE JR.', 'Male', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. DOMINIC', 'uploads/qrcodes/student_570.png', '2026-02-27 23:32:01', '09804448951'),
(571, '102610130011', 'ALBEN', '', 'RICHARDS', 'Male', '', 'Grade 11', 'ST. REGINA', 'uploads/qrcodes/student_571.png', '2026-02-27 23:32:01', '09978857205'),
(572, '102899140172', 'Ronalyn', '', 'Matalcero', 'Female', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. IGNATIUS DE LOYOLA', 'uploads/qrcodes/student_572.png', '2026-02-27 23:32:01', '09706161722'),
(573, '102609130028', 'Jade', '', 'Pedronan', 'Male', '', 'Grade 8', 'ST. MONICA', '', '2026-02-27 23:32:01', '09598406341'),
(574, '483548151132', 'Astrid', 'Denise', 'Nebab', 'Female', 'jashershy@gmail.com', 'Grade 11', 'ST. JUDE', 'uploads/qrcodes/student_574.png', '2026-02-27 23:32:01', '09804448951'),
(575, '102608140089', 'Karen', 'grace', 'fermin', 'Female', 'agudapaula11@gmail.com', 'Grade 10', 'ST. CECILIA', 'uploads/qrcodes/student_575.png', '2026-02-27 23:32:01', '09685324777'),
(576, '102608140017', 'Jeorge', NULL, 'Taloza', 'Male', '', 'Grade 12', NULL, 'uploads/qrcodes/student_576.png', '2026-02-27 23:32:01', ''),
(577, '102921130020', 'Bea', 'cassandra', 'Agcaoili', 'Male', 'princessliannetolentino5@gmail.com', 'Grade 12', 'ST. IGNATIUS DE LOYOLA', 'uploads/qrcodes/student_577.png', '2026-02-27 23:32:01', '09804448951'),
(578, '102608140008', 'Alynna', '', 'Agnir', 'Female', 'princesstolentino751@gmail.com', 'Grade 12', 'ST. DOMINIC', 'uploads/qrcodes/student_578.png', '2026-02-27 23:32:01', '09598406341'),
(579, '102618130001', 'Elias', '', 'Bautista', 'Male', '', 'Grade 12', 'BLESSED ALOYSIUS', 'uploads/qrcodes/student_579.png', '2026-02-27 23:32:01', '09978857205'),
(580, '102915130002', 'Jorenz', '', 'Agustin', 'Male', 'agudapaula11@gmail.com', 'Grade 10', 'ST. ALBERT', 'uploads/qrcodes/student_580.png', '2026-02-27 23:32:01', '09598406341'),
(581, '102608180036', 'Kristine', '', 'Alupay', 'Female', '', 'Grade 12', 'ST. BENEDICT', 'uploads/qrcodes/student_581.png', '2026-02-27 23:32:01', '09706161722'),
(582, '102615130012', 'Irish', 'hershy', 'Macaculop', 'Male', '', 'Grade 11', 'ST. THERESE', 'uploads/qrcodes/student_582.png', '2026-02-27 23:32:01', '09706161722'),
(583, '102859140046', 'Rhodlance', 'Angelo', 'Acang', 'Male', 'lanceacang@gmail.com', 'Grade 11', 'ST. REGINA', 'uploads/qrcodes/student_583.png', '2026-02-27 23:32:01', '09598406341'),
(584, '102609130037', 'Paula', 'Victoria', 'Aguda', 'Female', 'jashershy@gmail.com', 'Grade 11', 'ST. JUDE', 'uploads/qrcodes/student_584.png', '2026-02-27 23:32:01', '09598406341'),
(585, '102607140037', 'Benjamin', '', 'Ruiz Jr', 'Male', 'benjiegumarangruiz5@gmail.com', 'Grade 11', 'ST. THERESE', 'uploads/qrcodes/student_585.png', '2026-02-27 23:32:01', '09598406341'),
(586, '102621130011', 'Frithz', 'Kenneth', 'Andajao', 'Male', 'frithzkenneth1014@gmail.com', 'Grade 12', 'BLESSED ALOYSIUS', 'uploads/qrcodes/student_586.png', '2026-02-27 23:32:01', '09706161722'),
(587, '102915130007', 'Ryan', '', 'Rivera', 'Male', 'riveraryan112@gmail.com', 'Grade 11', 'ST. THERESE', 'uploads/qrcodes/student_587.png', '2026-02-27 23:32:01', '09978857205'),
(588, '102610140002', 'Princess', 'Lianne', 'Tolentino', 'Male', 'jashershy@gmail.com', 'Grade 11', 'ST. THERESE', 'uploads/qrcodes/student_588.png', '2026-02-27 23:32:01', '09804448951'),
(589, '10260961008', 'James', 'Brianne', 'Guillen', 'Male', '', 'Grade 10', 'ST. CHARLES', 'uploads/qrcodes/student_589.png', '2026-02-27 23:32:01', '09978857205'),
(590, '101016150253', 'Nortanifa', '', 'Macaraya', 'Male', '', 'Grade 12', 'ST. IGNATIUS DE LOYOLA', 'uploads/qrcodes/student_590.png', '2026-02-27 23:32:01', '09978857205');

-- --------------------------------------------------------
-- Table: teachers
-- --------------------------------------------------------
CREATE TABLE `teachers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sex` enum('Male','Female') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Male',
  `mobile_number` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Contact number',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email address for notifications',
  `department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Department or subject area',
  `position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Job position/title',
  `qr_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Path to QR code image',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `shift` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT 'morning' COMMENT 'Teacher shift: morning|afternoon|both',
  `Faculty_ID_Number` char(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_teachers_employee_number` (`Faculty_ID_Number`),
  KEY `idx_department` (`department`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Teacher records for AttendEase v3.0';

INSERT INTO `teachers` (`id`, `first_name`, `middle_name`, `last_name`, `sex`, `mobile_number`, `email`, `department`, `position`, `qr_code`, `is_active`, `created_at`, `updated_at`, `shift`, `Faculty_ID_Number`) VALUES
(81, 'Florendo', 'U', 'Sagun Jr.', 'Male', '', '', 'FILIPINO', 'St. Hildegard Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(82, 'Janice', 'Mae P.', 'Tabuyo', 'Female', '', '', 'MATH', 'St. Francis Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(83, 'Valerie Shayne', 'C.', 'Talosig', 'Female', '', '', '', 'General Adviser (Grade 7)', 'uploads/qrcodes/teacher_TEACHER1234576.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:23:15', 'both', '1234576'),
(84, 'Anabelle', 'B.', 'Labii', 'Female', '', '', 'ENGLISH', 'St. Andrew Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(85, 'Christian Joel', 'Q.', 'Bumagat', 'Male', '', '', 'MAPEH', 'St. Monica Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(86, 'Rey Ann Joyce', 'R.', 'Manguba', 'Female', '', '', 'TLE', 'St. Bernard Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(87, 'Arnie Mae', 'C.', 'Ricardos', 'Female', '', '', 'MAPEH', 'St. Arnold Adviser', 'uploads/qrcodes/teacher_TEACHER8655465.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:24:54', 'both', '8655465'),
(88, 'Sionie Vhy', 'Y.', 'Sagun', 'Female', '', '', '', 'St. Joseph Adviser', 'uploads/qrcodes/teacher_TEACHER0000091.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:23:51', 'both', '0000091'),
(89, 'Sheryl', 'A.', 'Vicente', 'Female', '', '', 'FILIPINO', 'St. Charles Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(90, 'Raffy', 'D.', 'Carinan', 'Male', '', '', '', 'St. Albert Adviser', 'uploads/qrcodes/teacher_TEACHER5672360.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:21:42', 'both', '5672360'),
(91, 'Charisse', '', 'Lagazo', 'Female', '', '', 'SCIENCE', 'St. Cecilia Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(92, 'Janibie John', 'A.', 'Pascua', 'Male', '', '', '', 'St. Therese Adviser', 'uploads/qrcodes/teacher_TEACHER6969696.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:22:12', 'both', '6969696'),
(93, 'Vanessa', 'L.', 'Agtang', 'Female', '', '', 'ENGLISH', 'St. Regina Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(94, 'Irevince', 'D.', 'Aquino', 'Male', '', '', 'MATH', 'St. Jude Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(95, 'Gonieto', 'P.', 'Hernandez', 'Male', '', '', 'ENGLISH', 'St. Dominic Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(96, 'Alyza Marie', 'A.', 'Daleja', 'Female', '', '', '', 'Aloy Adviser', 'uploads/qrcodes/teacher_TEACHER6767676.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:22:43', 'both', '6767676'),
(97, 'Joy Ann V.', '', 'Torres', 'Female', '', '', 'SCIENCE', 'St. Benedict Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(98, 'Kamille Gerard', 'F.', 'Villa', 'Female', '', '', 'ENGLISH', 'St. Ignatius de Loyola Adviser', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(99, 'Liberty', 'A.', 'Espejo', 'Female', '', '', 'ESP', 'COM ADVISER', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(100, 'Krizelle Faye', 'S.', 'Aguda', 'Female', '', '', 'MATH', 'SCHOOL REGISTRAR', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(101, 'Myrna', 'A.', 'Nudalo', 'Female', '', '', 'ENGLISH', 'Library-in-charge', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(102, 'Rachelle C.', '', 'De Peralta', 'Female', '', '', 'ENGLISH', 'Academic Coordinator', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(103, 'Wilma', 'D.', 'Tylan', 'Female', '', '', 'FILIPINO', 'GUIDANCE COUNSELOR', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(104, 'REMAR', 'P.', 'AGCAOILI', 'Male', '', '', '', 'SCHOOL PRINCIPAL', 'uploads/qrcodes/teacher_TEACHER0000001.png', 1, '2026-02-27 16:23:48', '2026-02-28 01:24:17', 'both', '0000001'),
(105, 'APRIL JOYCE', 'G.', 'NEBAB', 'Female', '', '', 'TLE', 'SCHOOL TREASURER', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(106, 'CHRISTIAN', 'I.', 'AGBAYANI', 'Male', '', '', 'AP', 'Bookkeeper', '', 1, '2026-02-27 16:23:48', '2026-02-27 16:23:48', 'both', NULL),
(107, 'Alvin', '', 'Guard', 'Male', '0959-840-6341', 'nenoraikk@yahoo.com', 'Other', 'Staff', 'uploads/qrcodes/teacher_TEACHER4567891.png', 1, '2026-02-28 01:21:08', '2026-02-28 01:21:08', 'both', '4567891');

-- --------------------------------------------------------
-- Table: attendance
-- --------------------------------------------------------
CREATE TABLE `attendance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lrn` varchar(13) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Student LRN',
  `date` date NOT NULL COMMENT 'Attendance date',
  `morning_time_in` time DEFAULT NULL,
  `morning_time_out` time DEFAULT NULL,
  `section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Student section at time of attendance',
  `status` enum('present','absent','late','half_day','morning_only','afternoon_only','time_in','time_out') COLLATE utf8mb4_unicode_ci DEFAULT 'present',
  `email_sent` tinyint(1) DEFAULT '0' COMMENT 'Email notification sent flag',
  `remarks` text COLLATE utf8mb4_unicode_ci COMMENT 'Optional remarks or notes',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `afternoon_time_in` time DEFAULT NULL,
  `afternoon_time_out` time DEFAULT NULL,
  `is_late_morning` tinyint(1) DEFAULT '0',
  `is_late_afternoon` tinyint(1) DEFAULT '0',
  `period_number` tinyint(3) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_daily_attendance` (`lrn`,`date`),
  KEY `idx_date_section` (`date`,`section`),
  KEY `idx_lrn_date` (`lrn`,`date`),
  KEY `idx_status` (`status`),
  KEY `idx_email_sent` (`email_sent`),
  KEY `idx_attendance_date_lrn` (`date`,`lrn`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`lrn`) REFERENCES `students` (`lrn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Daily Time In/Out attendance records';

INSERT INTO `attendance` (`id`, `lrn`, `date`, `morning_time_in`, `morning_time_out`, `section`, `status`, `email_sent`, `remarks`, `created_at`, `updated_at`, `afternoon_time_in`, `afternoon_time_out`, `is_late_morning`, `is_late_afternoon`, `period_number`) VALUES
(32, '102915180010', '2026-02-28', '08:09:48', NULL, 'St. Hildegard', 'late', 0, NULL, '2026-02-28 00:09:48', '2026-02-28 05:31:35', '13:31:35', NULL, 1, 1, NULL),
(33, '102920170001', '2026-02-28', '10:44:17', NULL, 'St. Andrew', 'late', 0, NULL, '2026-02-28 02:44:17', '2026-02-28 02:44:17', NULL, NULL, 1, 0, NULL),
(34, '400363180019', '2026-02-28', '11:06:33', NULL, 'St. Francis', 'late', 0, NULL, '2026-02-28 03:06:33', '2026-02-28 03:06:33', NULL, NULL, 1, 0, NULL),
(35, '102899140172', '2026-02-28', '11:57:57', NULL, 'ST. IGNATIUS DE LOYOLA', 'late', 0, NULL, '2026-02-28 03:57:57', '2026-02-28 03:57:57', NULL, NULL, 1, 0, NULL),
(36, '102615130012', '2026-02-28', NULL, NULL, 'ST. THERESE', 'present', 0, NULL, '2026-02-28 05:17:04', '2026-02-28 05:17:04', '13:17:04', NULL, 0, 0, NULL),
(37, '102610140002', '2026-02-28', NULL, NULL, 'ST. THERESE', 'late', 0, NULL, '2026-02-28 05:31:08', '2026-02-28 05:31:08', '13:31:08', NULL, 0, 1, NULL);

-- --------------------------------------------------------
-- Table: teacher_attendance
-- --------------------------------------------------------
CREATE TABLE `teacher_attendance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL COMMENT 'Attendance date',
  `morning_time_in` time DEFAULT NULL COMMENT 'Morning Time In',
  `morning_time_out` time DEFAULT NULL COMMENT 'Morning Time Out',
  `afternoon_time_in` time DEFAULT NULL COMMENT 'Afternoon Time In',
  `afternoon_time_out` time DEFAULT NULL COMMENT 'Afternoon Time Out',
  `is_late_morning` tinyint(1) DEFAULT '0',
  `is_late_afternoon` tinyint(1) DEFAULT '0',
  `status` enum('present','absent','late','half_day','on_leave') COLLATE utf8mb4_unicode_ci DEFAULT 'present',
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `department` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `shift` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT 'morning',
  `employee_number` char(7) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_teacher_attendance_employee_date` (`employee_number`,`date`),
  KEY `idx_date` (`date`),
  KEY `idx_status` (`status`),
  KEY `ix_teacher_attendance_employee_number` (`employee_number`),
  KEY `idx_employee_number` (`employee_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Teacher attendance records';

INSERT INTO `teacher_attendance` (`id`, `date`, `morning_time_in`, `morning_time_out`, `afternoon_time_in`, `afternoon_time_out`, `is_late_morning`, `is_late_afternoon`, `status`, `remarks`, `created_at`, `updated_at`, `department`, `shift`, `employee_number`) VALUES
(1, '2026-02-08', '12:56:46', NULL, '15:05:00', NULL, 0, 0, 'late', NULL, '2026-02-08 04:56:46', '2026-02-08 07:05:31', 'Science', 'morning', NULL),
(6, '2026-02-10', '17:14:32', '17:15:40', NULL, NULL, 0, 0, 'late', NULL, '2026-02-10 09:14:32', '2026-02-10 09:15:40', '', 'morning', '0328061'),
(7, '2026-02-13', '16:12:32', '16:12:56', NULL, NULL, 1, 0, 'late', NULL, '2026-02-13 08:12:32', '2026-02-13 08:12:56', '', 'morning', '0328061'),
(11, '2026-02-13', '16:24:33', '16:26:27', NULL, NULL, 1, 0, 'late', NULL, '2026-02-13 08:24:33', '2026-02-13 08:26:27', '', 'morning', '0000002'),
(12, '2026-02-13', '16:24:59', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-13 08:24:59', '2026-02-13 08:24:59', '', 'morning', '0000022'),
(13, '2026-02-13', '16:26:43', '16:27:39', NULL, NULL, 1, 0, 'late', NULL, '2026-02-13 08:26:43', '2026-02-13 08:27:39', '', 'morning', '2233445'),
(14, '2026-02-13', '16:37:17', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-13 08:37:17', '2026-02-13 08:37:17', '', 'morning', '0000003'),
(15, '2026-02-18', '14:59:07', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-18 06:59:07', '2026-02-18 06:59:07', '', 'morning', '0328061'),
(16, '2026-02-18', '14:59:22', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-18 06:59:22', '2026-02-18 06:59:22', '', 'morning', '2233445'),
(17, '2026-02-26', '20:53:04', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-26 12:53:04', '2026-02-26 12:53:04', '', 'morning', '2233445'),
(18, '2026-02-27', '23:52:15', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-27 15:52:15', '2026-02-27 15:52:15', '', 'morning', '0328061'),
(19, '2026-02-27', '23:52:32', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-27 15:52:32', '2026-02-27 15:52:32', '', 'morning', '2233445'),
(20, '2026-02-27', '23:58:37', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-27 15:58:37', '2026-02-27 15:58:37', '', 'morning', '1122884'),
(21, '2026-02-28', '10:44:05', NULL, NULL, NULL, 1, 0, 'late', NULL, '2026-02-28 02:44:05', '2026-02-28 02:44:05', '', 'morning', '0000091'),
(22, '2026-02-28', NULL, NULL, '13:15:52', NULL, 0, 0, 'present', NULL, '2026-02-28 05:15:52', '2026-02-28 05:15:52', '', 'morning', '1234576'),
(23, '2026-02-28', NULL, NULL, '13:16:24', NULL, 0, 0, 'present', NULL, '2026-02-28 05:16:24', '2026-02-28 05:16:24', '', 'morning', '6969696'),
(24, '2026-02-28', NULL, NULL, '13:17:15', NULL, 0, 0, 'present', NULL, '2026-02-28 05:17:15', '2026-02-28 05:17:15', '', 'morning', '6767676');

-- --------------------------------------------------------
-- Table: attendance_schedules
-- --------------------------------------------------------
CREATE TABLE `attendance_schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Default Schedule',
  `grade_level` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Specific grade level or NULL for all',
  `section_id` int(11) DEFAULT NULL COMMENT 'Specific section or NULL for all',
  `morning_start` time NOT NULL DEFAULT '07:00:00',
  `morning_end` time NOT NULL DEFAULT '12:00:00',
  `morning_late_after` time NOT NULL DEFAULT '07:30:00' COMMENT 'Time after which student is marked late',
  `afternoon_start` time NOT NULL DEFAULT '13:00:00',
  `afternoon_end` time NOT NULL DEFAULT '17:00:00',
  `afternoon_late_after` time NOT NULL DEFAULT '13:30:00' COMMENT 'Time after which student is marked late',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'Default schedule if no specific match',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_grade` (`grade_level`),
  KEY `idx_section` (`section_id`),
  KEY `idx_active` (`is_active`),
  KEY `idx_default` (`is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Attendance schedule rules for late detection';

INSERT INTO `attendance_schedules` (`id`, `schedule_name`, `grade_level`, `section_id`, `morning_start`, `morning_end`, `morning_late_after`, `afternoon_start`, `afternoon_end`, `afternoon_late_after`, `is_default`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Default Schedule', NULL, NULL, '07:00:00', '12:00:00', '07:30:00', '13:00:00', '17:30:00', '13:30:00', 1, 1, '2026-02-03 07:58:57', '2026-02-05 08:39:53');

-- --------------------------------------------------------
-- Table: badges
-- --------------------------------------------------------
CREATE TABLE `badges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `badge_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `badge_description` text COLLATE utf8mb4_unicode_ci,
  `badge_icon` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'fa-award' COMMENT 'FontAwesome icon class',
  `badge_color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#4CAF50' COMMENT 'Badge color hex',
  `criteria_type` enum('perfect_attendance','on_time_streak','most_improved','monthly_perfect','early_bird','consistent') COLLATE utf8mb4_unicode_ci NOT NULL,
  `criteria_value` int(11) DEFAULT NULL COMMENT 'Numeric criteria (e.g., streak days)',
  `criteria_period` enum('daily','weekly','monthly','yearly') COLLATE utf8mb4_unicode_ci DEFAULT 'monthly',
  `applicable_roles` set('student','teacher') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student,teacher',
  `points` int(11) DEFAULT '10' COMMENT 'Points awarded for this badge',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_criteria` (`criteria_type`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Achievement badges for attendance';

INSERT INTO `badges` (`id`, `badge_name`, `badge_description`, `badge_icon`, `badge_color`, `criteria_type`, `criteria_value`, `criteria_period`, `applicable_roles`, `points`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Perfect Attendance', 'No absences for the entire month', 'award', '#ffd700', 'perfect_attendance', 0, 'monthly', 'student,teacher', 50, 1, '2026-02-03 07:58:57', '2026-02-03 09:21:54'),
(2, 'On-Time Champ', '20 consecutive on-time arrivals', 'fa-clock', '#4CAF50', 'on_time_streak', 20, 'daily', 'student,teacher', 30, 1, '2026-02-03 07:58:57', '2026-02-03 07:58:57'),
(3, 'Most Improved', 'Significant attendance improvement over previous month', 'fa-chart-line', '#2196F3', 'most_improved', 20, 'monthly', 'student,teacher', 40, 1, '2026-02-03 07:58:57', '2026-02-03 07:58:57'),
(4, 'Early Bird', 'Arrived early for 10 consecutive days', 'fa-sun', '#FF9800', 'early_bird', 10, 'daily', 'student,teacher', 25, 1, '2026-02-03 07:58:57', '2026-02-03 07:58:57'),
(5, 'Consistent Achiever', '100% attendance for the week', 'fa-trophy', '#9C27B0', 'consistent', 5, 'weekly', 'student,teacher', 20, 1, '2026-02-03 07:58:57', '2026-02-03 07:58:57'),
(21, 'Perfect Attendance', 'No absences for the entire month', 'gem', '#ffd700', 'perfect_attendance', 0, 'monthly', 'student,teacher', 50, 1, '2026-02-05 08:22:09', '2026-02-10 09:17:38'),
(22, 'On-Time Champ', '20 consecutive on-time arrivals', 'fa-clock', '#4CAF50', 'on_time_streak', 20, 'daily', 'student,teacher', 30, 1, '2026-02-05 08:22:09', '2026-02-05 08:22:09'),
(23, 'Most Improved', 'Significant attendance improvement over previous month', 'fa-chart-line', '#2196F3', 'most_improved', 20, 'monthly', 'student,teacher', 40, 1, '2026-02-05 08:22:09', '2026-02-05 08:22:09'),
(24, 'Early Bird', 'Arrived early for 10 consecutive days', 'fa-sun', '#FF9800', 'early_bird', 10, 'daily', 'student,teacher', 25, 1, '2026-02-05 08:22:09', '2026-02-05 08:22:09'),
(25, 'Consistent Achiever', '100% attendance for the week', 'fa-trophy', '#9C27B0', 'consistent', 5, 'weekly', 'student,teacher', 20, 1, '2026-02-05 08:22:09', '2026-02-05 08:22:09');

-- --------------------------------------------------------
-- Table: behavior_alerts
-- --------------------------------------------------------
CREATE TABLE `behavior_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_type` enum('student','teacher') COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'LRN for students, employee_id for teachers',
  `alert_type` enum('frequent_late','consecutive_absence','sudden_absence','attendance_drop','perfect_streak') COLLATE utf8mb4_unicode_ci NOT NULL,
  `alert_message` text COLLATE utf8mb4_unicode_ci,
  `occurrences` int(11) DEFAULT '1',
  `period_start` date DEFAULT NULL,
  `period_end` date DEFAULT NULL,
  `date_detected` date NOT NULL,
  `severity` enum('info','warning','critical') COLLATE utf8mb4_unicode_ci DEFAULT 'warning',
  `is_acknowledged` tinyint(1) DEFAULT '0',
  `acknowledged_by` int(11) DEFAULT NULL,
  `acknowledged_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Admin notes when acknowledging alert',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_type`,`user_id`),
  KEY `idx_type` (`alert_type`),
  KEY `idx_acknowledged` (`is_acknowledged`),
  KEY `idx_date` (`date_detected`),
  KEY `idx_severity` (`severity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Behavior monitoring alerts';

-- --------------------------------------------------------
-- Table: admin_activity_log
-- --------------------------------------------------------
CREATE TABLE `admin_activity_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Action performed',
  `details` text COLLATE utf8mb4_unicode_ci COMMENT 'Action details',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP address',
  `user_agent` text COLLATE utf8mb4_unicode_ci COMMENT 'Browser user agent',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `admin_activity_log_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Admin activity audit log';

INSERT INTO `admin_activity_log` (`id`, `admin_id`, `username`, `action`, `details`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, NULL, 'LOGOUT', 'Admin logged out', '::1', NULL, '2025-11-07 08:05:20'),
(2, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 0 attendance records.', '::1', NULL, '2025-11-07 08:14:57'),
(3, 1, NULL, 'EDIT_SECTION', 'Updated section: KALACHUCHI', '::1', NULL, '2025-11-07 08:49:22'),
(4, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 0 attendance records.', '::1', NULL, '2025-11-07 08:51:10'),
(5, 1, NULL, 'DELETE_SECTION', 'Deleted section: KALACHUCHI', '::1', NULL, '2025-11-07 08:51:23'),
(6, 1, NULL, 'MANUAL_ATTENDANCE', 'Marked time_in for LRN: 136514240419 on 2025-11-08 at 15:09', '::1', NULL, '2025-11-08 07:09:32'),
(7, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2025-11-08 07:34:30'),
(8, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2025-11-08 07:46:55'),
(9, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2025-11-08 08:19:15'),
(10, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2025-11-08 08:27:21'),
(11, 1, NULL, 'ADD_SECTION', 'Added section: Integrity', '::1', NULL, '2025-11-08 08:39:56'),
(12, 1, NULL, 'ADD_SECTION', 'Added section: Excellence', '::1', NULL, '2025-11-08 08:40:24'),
(13, 1, NULL, 'ADD_SECTION', 'Added section: Evangalization', '::1', NULL, '2025-11-08 08:40:40'),
(14, 1, NULL, 'ADD_SECTION', 'Added section: Social Responsibility', '::1', NULL, '2025-11-08 08:40:54'),
(15, 1, NULL, 'ADD_SECTION', 'Added section: Peace', '::1', NULL, '2025-11-08 08:41:06'),
(16, 1, NULL, 'ADD_SECTION', 'Added section: Justice', '::1', NULL, '2025-11-08 08:41:23'),
(17, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2025-11-08 08:55:33'),
(18, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2025-11-08 09:00:14'),
(19, 1, NULL, 'EDIT_BADGE', 'Updated badge: Perfect Attendance', '::1', NULL, '2026-02-03 09:21:55'),
(20, 1, NULL, 'DELETE_SCHEDULE', 'Deleted schedule: Default Schedule', '::1', NULL, '2026-02-03 09:48:32'),
(21, 1, NULL, 'DELETE_SCHEDULE', 'Deleted schedule: Default Schedule', '::1', NULL, '2026-02-03 09:48:35'),
(22, 1, NULL, 'DELETE_SCHEDULE', 'Deleted schedule: Default Schedule', '::1', NULL, '2026-02-03 09:48:38'),
(23, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Perfect Attendance', '::1', NULL, '2026-02-03 09:49:12'),
(24, 1, NULL, 'DELETE_BADGE', 'Deleted badge: On-Time Champ', '::1', NULL, '2026-02-03 09:49:14'),
(25, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Most Improved', '::1', NULL, '2026-02-03 09:49:17'),
(26, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Early Bird', '::1', NULL, '2026-02-03 09:49:19'),
(27, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Consistent Achiever', '::1', NULL, '2026-02-03 09:49:20'),
(28, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Perfect Attendance', '::1', NULL, '2026-02-03 09:49:22'),
(29, 1, NULL, 'DELETE_BADGE', 'Deleted badge: On-Time Champ', '::1', NULL, '2026-02-03 09:49:24'),
(30, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Most Improved', '::1', NULL, '2026-02-03 09:49:26'),
(31, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Early Bird', '::1', NULL, '2026-02-03 09:49:28'),
(32, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Consistent Achiever', '::1', NULL, '2026-02-03 09:49:30'),
(33, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Perfect Attendance', '::1', NULL, '2026-02-03 09:49:32'),
(34, 1, NULL, 'DELETE_BADGE', 'Deleted badge: On-Time Champ', '::1', NULL, '2026-02-03 09:49:34'),
(35, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Most Improved', '::1', NULL, '2026-02-03 09:49:36'),
(36, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Early Bird', '::1', NULL, '2026-02-03 09:49:38'),
(37, 1, NULL, 'DELETE_BADGE', 'Deleted badge: Consistent Achiever', '::1', NULL, '2026-02-03 09:49:40'),
(38, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 1 attendance records.', '::1', NULL, '2026-02-03 09:56:03'),
(39, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Zach Reihge Jaudian (LRN: 136514240419). Also deleted 0 attendance records.', '::1', NULL, '2026-02-03 10:33:37'),
(40, 1, NULL, 'EDIT_SECTION', 'Updated section: KALACHUCHI', '::1', NULL, '2026-02-03 10:50:27'),
(41, 1, NULL, 'EDIT_SCHEDULE', 'Updated schedule: Default Schedule', '::1', NULL, '2026-02-03 10:53:15'),
(42, 1, NULL, 'LOGOUT', 'Admin logged out', '::1', NULL, '2026-02-03 11:34:27'),
(43, 1, NULL, 'ADD_TEACHER', 'Added teacher: Habib Jaudian (ID: 1)', '::1', NULL, '2026-02-03 11:38:04'),
(44, 1, NULL, 'DELETE_SCHEDULE', 'Deleted schedule: Default Schedule', '::1', NULL, '2026-02-05 08:39:31'),
(45, 1, NULL, 'EDIT_SCHEDULE', 'Updated schedule: Default Schedule', '::1', NULL, '2026-02-05 08:39:53'),
(46, 1, NULL, 'EDIT_SECTION', 'Updated section: BARBERA', '::1', NULL, '2026-02-05 09:10:29'),
(47, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Regine Agates (Num: 2233445)', '::1', NULL, '2026-02-08 06:08:42'),
(48, 1, NULL, 'MANUAL_ATTENDANCE', 'Marked teacher time_in for: 2233445 (Regine Agates) on 2026-02-08 at 15:04:00', '::1', NULL, '2026-02-08 07:05:03'),
(49, 1, NULL, 'MANUAL_ATTENDANCE', 'Marked teacher time_in for: 2233445 (Regine Agates) on 2026-02-08 at 15:05:00', '::1', NULL, '2026-02-08 07:05:31'),
(50, 1, NULL, 'EDIT_SECTION', 'Updated section: BARBERA', '::1', NULL, '2026-02-08 07:58:40'),
(51, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Habib Jaudian (Num: 0328061)', '::1', NULL, '2026-02-10 08:45:57'),
(52, 1, NULL, 'EDIT_BADGE', 'Updated badge: Perfect Attendance', '::1', NULL, '2026-02-10 09:17:38'),
(53, 1, NULL, 'AWARD_BADGE', 'Awarded badge ID 21 to student ID 136511140086', '::1', NULL, '2026-02-12 07:22:29'),
(54, 1, NULL, 'AWARD_BADGE', 'Awarded badge ID 21 to student ID 136511140086', '::1', NULL, '2026-02-12 07:49:42'),
(55, 1, NULL, 'AWARD_BADGE', 'Awarded badge ID 21 to student ID 136514240419', '::1', NULL, '2026-02-12 07:50:07'),
(56, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Dniren Adamolli (LRN: 16). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 03:12:12'),
(57, 1, NULL, 'DELETE_TEACHER', 'Deleted teacher: Emlen Arman (ID: N/A). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 03:26:17'),
(58, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 03:37:45'),
(59, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Alana Allsup (LRN: 30). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 03:42:17'),
(60, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Jasper Alvares (LRN: 74). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 03:42:21'),
(61, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Ryley Alywen (LRN: 7). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 03:42:39'),
(62, 1, NULL, 'DELETE_STUDENT', 'Deleted student: See Andrejevic (LRN: 21). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 03:50:07'),
(63, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 03:53:05'),
(64, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 03:58:20'),
(65, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 03:59:45'),
(66, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 03:59:54'),
(67, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 04:06:33'),
(68, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 04:12:26'),
(69, 1, NULL, 'ADD_TEACHER', 'Added teacher: Ambatukam ImAtAClub (Num: 0365789)', '::1', NULL, '2026-02-27 04:15:57'),
(70, 1, NULL, 'ADD_SECTION', 'Added section: Jones', '::1', NULL, '2026-02-27 05:10:29'),
(71, 1, NULL, 'DELETE_SECTION', 'Deleted section: Evangalization', '::1', NULL, '2026-02-27 06:08:45'),
(72, 1, NULL, 'DELETE_SECTION', 'Deleted section: Peace', '::1', NULL, '2026-02-27 06:16:12'),
(73, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Tracey Melland (LRN: 33). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 11:59:58'),
(74, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Jae McIlwrick (LRN: 54). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 12:16:17'),
(75, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Cassondra Trahearn (LRN: 40). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 12:25:45'),
(76, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Vonny Wiffill (LRN: 1). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 12:37:51'),
(77, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Edyth Tringham (LRN: 63). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 12:37:58'),
(78, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Gradeigh Izaac (LRN: 71). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 13:07:22'),
(79, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Nappie Aronov (LRN: 77). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 15:31:44'),
(80, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Terra Baldelli (LRN: 4). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 15:48:40'),
(81, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Timmy Bardnam (LRN: 38). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 15:49:07'),
(82, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Nerissa Beavon (LRN: 27). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 15:49:12'),
(83, 1, NULL, 'DELETE_STUDENT', 'Deleted student: TestJones TestJones (LRN: 1234567891011). Also deleted 1 attendance records.', '::1', NULL, '2026-02-27 15:49:25'),
(84, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Asher Spellessy (LRN: 46). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 15:49:36'),
(85, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Veriee Starton (LRN: 58). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 15:49:55'),
(86, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Kamille Gerard Villa (Num: 2233445)', '::1', NULL, '2026-02-27 15:52:20'),
(87, 1, NULL, 'ADD_SECTION', 'Added section: St. Ignatius De Loyola', '::1', NULL, '2026-02-27 15:52:39'),
(88, 1, NULL, 'DELETE_STUDENT', 'Deleted student: KimiRaikkonen Suniga (LRN: 102608130039). Also deleted 1 attendance records.', '::1', NULL, '2026-02-27 15:56:58'),
(89, 1, NULL, 'ADD_TEACHER', 'Added teacher: Mary Rose Rasaroso (Num: 1122884)', '::1', NULL, '2026-02-27 15:57:05'),
(90, 1, NULL, 'DELETE_SECTION', 'Deleted section: Social Responsibility', '::1', NULL, '2026-02-27 15:57:12'),
(91, 1, NULL, 'DELETE_SECTION', 'Deleted section: Justice', '::1', NULL, '2026-02-27 15:57:19'),
(92, 1, NULL, 'DELETE_SECTION', 'Deleted section: Excellence', '::1', NULL, '2026-02-27 15:57:27'),
(93, 1, NULL, 'EDIT_SECTION', 'Updated section: Barbera', '::1', NULL, '2026-02-27 15:58:22'),
(94, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Edmund Bech (LRN: 12). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 16:00:21'),
(95, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Haydon Broseke (LRN: 61). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 16:00:25'),
(96, 1, NULL, 'DELETE_STUDENT', 'Deleted student: Kevin Coomer (LRN: 26). Also deleted 0 attendance records.', '::1', NULL, '2026-02-27 16:00:29'),
(97, 1, NULL, 'ADD_SECTION', 'Added section: St. Francis', '::1', NULL, '2026-02-27 16:47:22'),
(98, 1, NULL, 'ADD_SECTION', 'Added section: St. Hildegard', '::1', NULL, '2026-02-27 16:47:59'),
(99, 1, NULL, 'ADD_SECTION', 'Added section: St. Jerome', '::1', NULL, '2026-02-27 16:48:23'),
(100, 1, NULL, 'ADD_SECTION', 'Added section: St. Andrew', '::1', NULL, '2026-02-27 16:48:41'),
(101, 1, NULL, 'ADD_SECTION', 'Added section: St. Monica', '::1', NULL, '2026-02-27 16:48:56'),
(102, 1, NULL, 'ADD_SECTION', 'Added section: St. Bernard', '::1', NULL, '2026-02-27 16:49:24'),
(103, 1, NULL, 'ADD_SECTION', 'Added section: St. Arnold', '::1', NULL, '2026-02-27 16:49:40'),
(104, 1, NULL, 'ADD_SECTION', 'Added section: St. Joseph', '::1', NULL, '2026-02-27 16:49:59'),
(105, 1, NULL, 'ADD_SECTION', 'Added section: St. Charles', '::1', NULL, '2026-02-27 16:50:14'),
(106, 1, NULL, 'ADD_SECTION', 'Added section: St. Albert', '::1', NULL, '2026-02-27 16:50:27'),
(107, 1, NULL, 'ADD_SECTION', 'Added section: St. Cecilia', '::1', NULL, '2026-02-27 16:50:46'),
(108, 1, NULL, 'ADD_SECTION', 'Added section: St. Therese', '::1', NULL, '2026-02-27 16:51:05'),
(109, 1, NULL, 'ADD_SECTION', 'Added section: St. Regina', '::1', NULL, '2026-02-27 16:51:28'),
(110, 1, NULL, 'ADD_SECTION', 'Added section: St. Jude', '::1', NULL, '2026-02-27 16:51:48'),
(111, 1, NULL, 'ADD_SECTION', 'Added section: St. Ignatius De Loyola', '::1', NULL, '2026-02-27 16:52:04'),
(112, 1, NULL, 'ADD_SECTION', 'Added section: St. Dominic', '::1', NULL, '2026-02-27 16:52:27'),
(113, 1, NULL, 'ADD_SECTION', 'Added section: Blessed Aloysius', '::1', NULL, '2026-02-27 16:52:45'),
(114, 1, NULL, 'ADD_SECTION', 'Added section: St. Benedict', '::1', NULL, '2026-02-27 16:53:02'),
(115, 1, NULL, 'ADD_TEACHER', 'Added teacher: Alvin Guard (Num: 4567891)', '::1', NULL, '2026-02-28 01:21:08'),
(116, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Raffy Carinan (Num: 5672360)', '::1', NULL, '2026-02-28 01:21:41'),
(117, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Janibie John Pascua (Num: 6969696)', '::1', NULL, '2026-02-28 01:22:10'),
(118, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Alyza Marie Daleja (Num: 6767676)', '::1', NULL, '2026-02-28 01:22:42'),
(119, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Valerie Shayne Talosig (Num: 1234576)', '::1', NULL, '2026-02-28 01:23:14'),
(120, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Sionie Vhy Sagun (Num: 0000091)', '::1', NULL, '2026-02-28 01:23:50'),
(121, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: REMAR AGCAOILI (Num: 0000001)', '::1', NULL, '2026-02-28 01:24:16'),
(122, 1, NULL, 'EDIT_TEACHER', 'Updated teacher: Arnie Mae Ricardos (Num: 8655465)', '::1', NULL, '2026-02-28 01:24:53'),
(123, 1, NULL, 'LOGOUT', 'Admin logged out', '::1', NULL, '2026-02-28 05:37:48');

-- --------------------------------------------------------
-- Table: sms_logs
-- --------------------------------------------------------
CREATE TABLE `sms_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipient_type` enum('student','teacher','parent') COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mobile_number` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` enum('late','absent','time_in','time_out','alert','custom') COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','sent','failed','queued') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `provider_response` text COLLATE utf8mb4_unicode_ci COMMENT 'SMS gateway response',
  `message_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Provider message ID',
  `cost` decimal(10,4) DEFAULT NULL COMMENT 'SMS cost if applicable',
  `sent_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_recipient` (`recipient_type`,`recipient_id`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`message_type`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SMS notification logs';

-- --------------------------------------------------------
-- Table: sms_templates
-- --------------------------------------------------------
CREATE TABLE `sms_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_type` enum('late','absent','time_in','time_out','alert') COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_template` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Use placeholders: {name}, {date}, {time}, {status}',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_template` (`template_name`),
  KEY `idx_type` (`template_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SMS message templates';

INSERT INTO `sms_templates` (`id`, `template_name`, `template_type`, `message_template`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'student_late', 'late', 'LATE NOTICE: {name} arrived late at {time} on {date}. - ASJ Attendance System', 1, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(2, 'student_absent', 'absent', 'ABSENT NOTICE: {name} was marked absent on {date}. Please contact the school if this is incorrect. - ASJ Attendance System', 1, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(3, 'student_time_in', 'time_in', '{name} has arrived at school at {time} on {date}. - ASJ Attendance System', 1, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(4, 'student_time_out', 'time_out', '{name} has left school at {time} on {date}. - ASJ Attendance System', 1, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(5, 'behavior_alert', 'alert', 'ATTENTION: {name} has been flagged for {status}. Please contact the guidance office. - ASJ Attendance System', 1, '2026-02-03 07:58:57', '2026-02-05 08:22:09');

-- --------------------------------------------------------
-- Table: system_settings
-- --------------------------------------------------------
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci,
  `setting_type` enum('string','number','boolean','json') COLLATE utf8mb4_unicode_ci DEFAULT 'string',
  `setting_group` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'general',
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_editable` tinyint(1) DEFAULT '1',
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_setting` (`setting_key`),
  KEY `idx_group` (`setting_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System configuration settings';

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `setting_type`, `setting_group`, `description`, `is_editable`, `updated_by`, `created_at`, `updated_at`) VALUES
(1, 'morning_session_start', '06:00', 'string', 'attendance', 'Morning session start time', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(2, 'morning_session_end', '12:00', 'string', 'attendance', 'Morning session end time', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(3, 'afternoon_session_start', '12:00', 'string', 'attendance', 'Afternoon session start time', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(4, 'afternoon_session_end', '18:00', 'string', 'attendance', 'Afternoon session end time', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(5, 'sms_enabled', '0', 'boolean', 'notifications', 'Enable SMS notifications', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(6, 'sms_provider', 'semaphore', 'string', 'notifications', 'SMS gateway provider', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(7, 'sms_on_late', '1', 'boolean', 'notifications', 'Send SMS on late arrival', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(8, 'sms_on_absent', '1', 'boolean', 'notifications', 'Send SMS on absence', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(9, 'behavior_monitoring_enabled', '1', 'boolean', 'monitoring', 'Enable behavior monitoring', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(10, 'late_threshold_weekly', '3', 'number', 'monitoring', 'Late occurrences per week to trigger alert', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(11, 'absence_threshold_consecutive', '2', 'number', 'monitoring', 'Consecutive absences to trigger alert', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(12, 'badges_enabled', '1', 'boolean', 'badges', 'Enable badge system', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(13, 'badge_notifications', '1', 'boolean', 'badges', 'Notify users when badges are earned', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(14, 'school_name', 'Academy of St. Joseph Claveria, Cagayan Inc.', 'string', 'school', 'School name', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09'),
(15, 'school_year', '2025-2026', 'string', 'school', 'Current school year', 1, NULL, '2026-02-03 07:58:57', '2026-02-05 08:22:09');

-- --------------------------------------------------------
-- Table: user_badges
-- --------------------------------------------------------
CREATE TABLE `user_badges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_type` enum('student','teacher') COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'LRN for students, employee_id for teachers',
  `badge_id` int(11) NOT NULL,
  `date_earned` date NOT NULL,
  `period_start` date DEFAULT NULL,
  `period_end` date DEFAULT NULL,
  `is_displayed` tinyint(1) DEFAULT '1' COMMENT 'Show on profile',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_type`,`user_id`),
  KEY `idx_badge` (`badge_id`),
  KEY `idx_date` (`date_earned`),
  CONSTRAINT `fk_user_badge` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Badges earned by users';

-- ============================================================
-- VIEWS (created AFTER tables so they can reference them)
-- ============================================================

-- --------------------------------------------------------
-- View: v_daily_attendance_summary_v3
-- --------------------------------------------------------
CREATE SQL SECURITY INVOKER VIEW `v_daily_attendance_summary_v3` AS
SELECT
  `a`.`date` AS `date`,
  `a`.`section` AS `section`,
  COUNT(0) AS `total_records`,
  SUM(CASE WHEN (`a`.`morning_time_in` IS NOT NULL) THEN 1 ELSE 0 END) AS `morning_present`,
  SUM(CASE WHEN (`a`.`afternoon_time_in` IS NOT NULL) THEN 1 ELSE 0 END) AS `afternoon_present`,
  SUM(CASE WHEN (`a`.`is_late_morning` = 1) THEN 1 ELSE 0 END) AS `morning_late`,
  SUM(CASE WHEN (`a`.`is_late_afternoon` = 1) THEN 1 ELSE 0 END) AS `afternoon_late`,
  SUM(CASE WHEN ((`a`.`morning_time_in` IS NOT NULL) AND (`a`.`morning_time_out` IS NULL)) THEN 1 ELSE 0 END) AS `needs_morning_out`,
  SUM(CASE WHEN ((`a`.`afternoon_time_in` IS NOT NULL) AND (`a`.`afternoon_time_out` IS NULL)) THEN 1 ELSE 0 END) AS `needs_afternoon_out`
FROM `attendance` AS `a`
GROUP BY `a`.`date`, `a`.`section`
ORDER BY `a`.`date` DESC;

-- --------------------------------------------------------
-- View: v_student_roster_v3
-- --------------------------------------------------------
CREATE SQL SECURITY INVOKER VIEW `v_student_roster_v3` AS
SELECT
  `s`.`id` AS `id`,
  `s`.`lrn` AS `lrn`,
  CONCAT(`s`.`first_name`, ' ', COALESCE(CONCAT(LEFT(`s`.`middle_name`, 1), '. '), ''), `s`.`last_name`) AS `full_name`,
  `s`.`class` AS `class`,
  `s`.`section` AS `section`,
  `s`.`mobile_number` AS `mobile_number`,
  `s`.`sex` AS `sex`,
  (SELECT MAX(`attendance`.`date`) FROM `attendance` WHERE (`attendance`.`lrn` = `s`.`lrn`)) AS `last_attendance_date`,
  (SELECT COUNT(0) FROM `user_badges` WHERE ((`user_badges`.`user_type` = 'student') AND (`user_badges`.`user_id` = `s`.`lrn`))) AS `badge_count`
FROM `students` AS `s`
ORDER BY `s`.`class` ASC, `s`.`section` ASC, `s`.`last_name` ASC;

-- --------------------------------------------------------
-- View: v_teacher_roster
-- --------------------------------------------------------
CREATE SQL SECURITY INVOKER VIEW `v_teacher_roster` AS
SELECT
  `t`.`id` AS `id`,
  `t`.`Faculty_ID_Number` AS `employee_id`,
  CONCAT(`t`.`first_name`, ' ', COALESCE(CONCAT(LEFT(`t`.`middle_name`, 1), '. '), ''), `t`.`last_name`) AS `full_name`,
  `t`.`department` AS `department`,
  `t`.`position` AS `position`,
  `t`.`mobile_number` AS `mobile_number`,
  `t`.`sex` AS `sex`,
  `t`.`is_active` AS `is_active`,
  (SELECT MAX(`teacher_attendance`.`date`) FROM `teacher_attendance` WHERE (`teacher_attendance`.`employee_number` = `t`.`Faculty_ID_Number`)) AS `last_attendance_date`,
  (SELECT COUNT(0) FROM `user_badges` WHERE ((`user_badges`.`user_type` = 'teacher') AND (`user_badges`.`user_id` = `t`.`Faculty_ID_Number`))) AS `badge_count`
FROM `teachers` AS `t`
ORDER BY `t`.`department` ASC, `t`.`last_name` ASC;

-- ============================================================
-- STORED PROCEDURES (created LAST - after all tables exist)
-- ============================================================

DELIMITER $$

CREATE PROCEDURE `AddColumnIfNotExists` (IN `tableName` VARCHAR(64), IN `columnName` VARCHAR(64), IN `columnDef` VARCHAR(255))
BEGIN
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = tableName 
        AND COLUMN_NAME = columnName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` ADD COLUMN `', columnName, '` ', columnDef);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE `DropIndexIfExists` (IN `tableName` VARCHAR(64), IN `indexName` VARCHAR(64))
BEGIN
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.STATISTICS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = tableName 
        AND INDEX_NAME = indexName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` DROP INDEX `', indexName, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE `GetStudentAttendance` (IN `p_lrn` VARCHAR(13), IN `p_start_date` DATE, IN `p_end_date` DATE)
BEGIN
    SELECT 
        a.*,
        CONCAT(s.first_name, ' ', s.last_name) as student_name,
        s.class,
        s.section
    FROM attendance a
    INNER JOIN students s ON a.lrn = s.lrn
    WHERE a.lrn = p_lrn
      AND a.date BETWEEN p_start_date AND p_end_date
    ORDER BY a.date DESC;
END$$

CREATE PROCEDURE `MarkAttendance_v3` (IN `p_user_type` ENUM('student','teacher'), IN `p_user_id` VARCHAR(20), IN `p_date` DATE, IN `p_time` TIME, IN `p_action` ENUM('time_in','time_out'), IN `p_section_id` INT)
BEGIN
    DECLARE v_session VARCHAR(10);
    DECLARE v_is_late TINYINT DEFAULT 0;
    DECLARE v_late_after TIME;
    DECLARE v_morning_end TIME DEFAULT '12:00:00';
    
    IF p_time < v_morning_end THEN
        SET v_session = 'morning';
    ELSE
        SET v_session = 'afternoon';
    END IF;
    
    IF v_session = 'morning' THEN
        SELECT morning_late_after INTO v_late_after
        FROM attendance_schedules 
        WHERE (section_id = p_section_id OR (section_id IS NULL AND is_default = 1))
            AND is_active = 1
        ORDER BY section_id DESC
        LIMIT 1;
    ELSE
        SELECT afternoon_late_after INTO v_late_after
        FROM attendance_schedules 
        WHERE (section_id = p_section_id OR (section_id IS NULL AND is_default = 1))
            AND is_active = 1
        ORDER BY section_id DESC
        LIMIT 1;
    END IF;
    
    IF p_action = 'time_in' AND v_late_after IS NOT NULL THEN
        IF p_time > v_late_after THEN
            SET v_is_late = 1;
        END IF;
    END IF;
    
    IF p_user_type = 'student' THEN
        IF v_session = 'morning' THEN
            IF p_action = 'time_in' THEN
                INSERT INTO attendance (lrn, date, morning_time_in, is_late_morning, status)
                VALUES (p_user_id, p_date, p_time, v_is_late, IF(v_is_late, 'late', 'present'))
                ON DUPLICATE KEY UPDATE 
                    morning_time_in = p_time,
                    is_late_morning = v_is_late,
                    status = IF(v_is_late, 'late', 'present'),
                    updated_at = CURRENT_TIMESTAMP;
            ELSE
                UPDATE attendance 
                SET morning_time_out = p_time, updated_at = CURRENT_TIMESTAMP
                WHERE lrn = p_user_id AND date = p_date;
            END IF;
        ELSE
            IF p_action = 'time_in' THEN
                INSERT INTO attendance (lrn, date, afternoon_time_in, is_late_afternoon, status)
                VALUES (p_user_id, p_date, p_time, v_is_late, IF(v_is_late, 'late', 'present'))
                ON DUPLICATE KEY UPDATE 
                    afternoon_time_in = p_time,
                    is_late_afternoon = v_is_late,
                    updated_at = CURRENT_TIMESTAMP;
            ELSE
                UPDATE attendance 
                SET afternoon_time_out = p_time, updated_at = CURRENT_TIMESTAMP
                WHERE lrn = p_user_id AND date = p_date;
            END IF;
        END IF;
    ELSE
        IF v_session = 'morning' THEN
            IF p_action = 'time_in' THEN
                INSERT INTO teacher_attendance (employee_number, date, morning_time_in, is_late_morning, status)
                VALUES (p_user_id, p_date, p_time, v_is_late, IF(v_is_late, 'late', 'present'))
                ON DUPLICATE KEY UPDATE 
                    morning_time_in = p_time,
                    is_late_morning = v_is_late,
                    status = IF(v_is_late, 'late', 'present'),
                    updated_at = CURRENT_TIMESTAMP;
            ELSE
                UPDATE teacher_attendance 
                SET morning_time_out = p_time, updated_at = CURRENT_TIMESTAMP
                WHERE employee_number = p_user_id AND date = p_date;
            END IF;
        ELSE
            IF p_action = 'time_in' THEN
                INSERT INTO teacher_attendance (employee_number, date, afternoon_time_in, is_late_afternoon, status)
                VALUES (p_user_id, p_date, p_time, v_is_late, IF(v_is_late, 'late', 'present'))
                ON DUPLICATE KEY UPDATE 
                    afternoon_time_in = p_time,
                    is_late_afternoon = v_is_late,
                    updated_at = CURRENT_TIMESTAMP;
            ELSE
                UPDATE teacher_attendance 
                SET afternoon_time_out = p_time, updated_at = CURRENT_TIMESTAMP
                WHERE employee_number = p_user_id AND date = p_date;
            END IF;
        END IF;
    END IF;
    
    SELECT v_is_late AS is_late, v_session AS session;
END$$

CREATE PROCEDURE `RegisterStudent_v3` (IN `p_lrn` VARCHAR(13), IN `p_first_name` VARCHAR(50), IN `p_middle_name` VARCHAR(50), IN `p_last_name` VARCHAR(50), IN `p_sex` VARCHAR(10), IN `p_mobile_number` VARCHAR(15), IN `p_class` VARCHAR(50), IN `p_section` VARCHAR(50))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    IF p_lrn NOT REGEXP '^[0-9]{11,13}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid LRN format. Must be 11-13 digits.';
    END IF;
    
    IF p_mobile_number NOT REGEXP '^(09|\\+639)[0-9]{9}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid mobile number format. Use 09XX-XXX-XXXX or +639XX-XXX-XXXX.';
    END IF;
    
    INSERT INTO students (
        lrn, first_name, middle_name, last_name, 
        sex, mobile_number, class, section
    )
    VALUES (
        p_lrn, p_first_name, p_middle_name, p_last_name,
        p_sex, p_mobile_number, p_class, p_section
    );
    
    COMMIT;
END$$

CREATE PROCEDURE `RegisterTeacher` (IN `p_employee_id` VARCHAR(20), IN `p_first_name` VARCHAR(50), IN `p_middle_name` VARCHAR(50), IN `p_last_name` VARCHAR(50), IN `p_sex` VARCHAR(10), IN `p_mobile_number` VARCHAR(15), IN `p_department` VARCHAR(100), IN `p_position` VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO teachers (
        employee_id, first_name, middle_name, last_name, 
        sex, mobile_number, department, position
    )
    VALUES (
        p_employee_id, p_first_name, p_middle_name, p_last_name,
        p_sex, p_mobile_number, p_department, p_position
    );
    
    COMMIT;
END$$

CREATE PROCEDURE `RenameColumnIfExists` (IN `tableName` VARCHAR(64), IN `oldColumnName` VARCHAR(64), IN `newColumnName` VARCHAR(64), IN `columnDef` VARCHAR(255))
BEGIN
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = tableName 
        AND COLUMN_NAME = oldColumnName
    ) AND NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = tableName 
        AND COLUMN_NAME = newColumnName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` CHANGE COLUMN `', oldColumnName, '` `', newColumnName, '` ', columnDef);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- RE-ENABLE FOREIGN KEY CHECKS
-- ============================================================
SET FOREIGN_KEY_CHECKS = 1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
