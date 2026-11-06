-- =============================================================
--  Abelenkpe SDA Church — Database Schema
--  Generated for MySQL Workbench
--  Compatible: MySQL 8.0+
-- =============================================================

CREATE DATABASE IF NOT EXISTS abelenkpe_church
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE abelenkpe_church;

-- =============================================================
-- 1. MEMBERS
--    Core church member register
-- =============================================================
CREATE TABLE members (
  id             INT             NOT NULL AUTO_INCREMENT,
  member_number  VARCHAR(20)     NOT NULL COMMENT 'Auto-generated serial e.g. A-SDA001',
  full_name      VARCHAR(150)    NOT NULL,
  gender         ENUM('Male','Female','Other') NOT NULL,
  member_class   VARCHAR(100)    NOT NULL COMMENT 'Sabbath School class name',
  dob            DATE            DEFAULT NULL,
  phone          VARCHAR(30)     NOT NULL COMMENT 'Used for WhatsApp & calls',
  note           TEXT            DEFAULT NULL,
  created_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_member_number (member_number),
  KEY idx_phone (phone),
  KEY idx_member_class (member_class)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Main church member register';


-- =============================================================
-- 2. VISITORS
--    People who have visited the church
-- =============================================================
CREATE TABLE visitors (
  id             INT             NOT NULL AUTO_INCREMENT,
  full_name      VARCHAR(150)    NOT NULL,
  phone          VARCHAR(30)     DEFAULT NULL,
  gender         ENUM('Male','Female','Other') DEFAULT NULL,
  address        VARCHAR(255)    DEFAULT NULL,
  invited_by     VARCHAR(150)    DEFAULT NULL COMMENT 'Name of person who invited them',
  member_class   VARCHAR(100)    DEFAULT NULL COMMENT 'Sabbath School class if assigned',
  dob            DATE            DEFAULT NULL,
  note           TEXT            DEFAULT NULL,
  created_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_visitor_phone (phone),
  KEY idx_visitor_name  (full_name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Visitors to the church (not yet members)';


-- =============================================================
-- 3. VISIT HISTORY
--    Each Sabbath a visitor attends (one row per visit)
-- =============================================================
CREATE TABLE visit_history (
  id          INT   NOT NULL AUTO_INCREMENT,
  visitor_id  INT   NOT NULL,
  visit_date  DATE  NOT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_visitor_date (visitor_id, visit_date),
  KEY idx_visit_date (visit_date),

  CONSTRAINT fk_vh_visitor
    FOREIGN KEY (visitor_id) REFERENCES visitors (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Individual visit dates per visitor';


-- =============================================================
-- 4. KIDS (Children Ministry)
--    Children registered in the kids programme
-- =============================================================
CREATE TABLE kids (
  id                   INT           NOT NULL AUTO_INCREMENT,
  name                 VARCHAR(150)  NOT NULL,
  gender               ENUM('Male','Female','Other') DEFAULT NULL,
  kid_class            VARCHAR(100)  DEFAULT NULL COMMENT 'Children ministry class',
  dob                  DATE          DEFAULT NULL,
  guardian             VARCHAR(150)  DEFAULT NULL COMMENT 'Parent or guardian name',
  phone                VARCHAR(30)   DEFAULT NULL COMMENT 'Guardian contact phone',
  address              VARCHAR(255)  DEFAULT NULL,
  note                 TEXT          DEFAULT NULL,
  file_url             VARCHAR(500)  DEFAULT NULL COMMENT 'Uploaded file URL (if any)',
  file_name            VARCHAR(255)  DEFAULT NULL,
  linked_member_id     INT           DEFAULT NULL COMMENT 'Parent who is also a church member',
  created_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_kid_class    (kid_class),
  KEY idx_kid_phone    (phone),
  KEY idx_linked_member (linked_member_id),

  CONSTRAINT fk_kid_member
    FOREIGN KEY (linked_member_id) REFERENCES members (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Children enrolled in the kids ministry';


-- =============================================================
-- 5. ATTENDANCE SESSIONS (Members)
--    One row per Sabbath attendance session opened by admin
-- =============================================================
CREATE TABLE attendance_sessions (
  id            INT       NOT NULL AUTO_INCREMENT,
  session_date  DATE      NOT NULL,
  opened_at     TIMESTAMP DEFAULT NULL,
  closed_at     TIMESTAMP DEFAULT NULL,
  status        ENUM('open','closed') NOT NULL DEFAULT 'open',

  PRIMARY KEY (id),
  UNIQUE KEY uq_session_date (session_date)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Each Sabbath attendance session for adult members';


-- =============================================================
-- 6. MEMBER ATTENDANCE
--    Presence record per member per session
-- =============================================================
CREATE TABLE member_attendance (
  id          INT      NOT NULL AUTO_INCREMENT,
  session_id  INT      NOT NULL,
  member_id   INT      NOT NULL,
  present     TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = present, 0 = absent',

  PRIMARY KEY (id),
  UNIQUE KEY uq_session_member (session_id, member_id),
  KEY idx_ma_member (member_id),

  CONSTRAINT fk_ma_session
    FOREIGN KEY (session_id) REFERENCES attendance_sessions (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_ma_member
    FOREIGN KEY (member_id) REFERENCES members (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Attendance record: which members were present each session';


-- =============================================================
-- 7. KIDS ATTENDANCE SESSIONS
--    Separate session tracking for the children ministry
-- =============================================================
CREATE TABLE kids_attendance_sessions (
  id            INT       NOT NULL AUTO_INCREMENT,
  session_date  DATE      NOT NULL,
  opened_at     TIMESTAMP DEFAULT NULL,
  closed_at     TIMESTAMP DEFAULT NULL,
  status        ENUM('open','closed') NOT NULL DEFAULT 'open',

  PRIMARY KEY (id),
  UNIQUE KEY uq_kids_session_date (session_date)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Each Sabbath attendance session for the kids ministry';


-- =============================================================
-- 8. KIDS ATTENDANCE
--    Presence record per child per kids session
-- =============================================================
CREATE TABLE kids_attendance (
  id          INT      NOT NULL AUTO_INCREMENT,
  session_id  INT      NOT NULL,
  kid_id      INT      NOT NULL,
  present     TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = present, 0 = absent',

  PRIMARY KEY (id),
  UNIQUE KEY uq_kids_session_kid (session_id, kid_id),
  KEY idx_ka_kid (kid_id),

  CONSTRAINT fk_ka_session
    FOREIGN KEY (session_id) REFERENCES kids_attendance_sessions (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_ka_kid
    FOREIGN KEY (kid_id) REFERENCES kids (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Attendance record: which kids were present each session';


-- =============================================================
-- 9. CHURCH RECORDS
--    Uploaded documents (Minutes, Reports, etc.)
-- =============================================================
CREATE TABLE church_records (
  id           INT           NOT NULL AUTO_INCREMENT,
  title        VARCHAR(255)  NOT NULL,
  category     ENUM(
                 'Church Record',
                 'Secretary Record',
                 'Minutes',
                 'Report'
               ) NOT NULL,
  file_name    VARCHAR(255)  DEFAULT NULL,
  file_url     VARCHAR(500)  DEFAULT NULL,
  uploaded_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_record_category (category),
  KEY idx_record_uploaded  (uploaded_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Uploaded church documents and records';


-- =============================================================
-- 10. RECYCLE BIN
--     Soft-deleted records (any entity type) stored as JSON
--     so they can be restored
-- =============================================================
CREATE TABLE recycle_bin (
  id           INT           NOT NULL AUTO_INCREMENT,
  entity_type  VARCHAR(50)   NOT NULL COMMENT 'e.g. member, kid, visitor, record',
  entity_id    INT           NOT NULL COMMENT 'Original ID in source table',
  entity_data  JSON          NOT NULL COMMENT 'Full JSON snapshot at time of deletion',
  deleted_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_rb_entity_type (entity_type),
  KEY idx_rb_deleted_at  (deleted_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Soft-deleted records pending permanent removal or restoration';


-- =============================================================
-- SAMPLE VIEWS (optional helpers)
-- =============================================================

-- Current week attendance summary (members)
CREATE OR REPLACE VIEW v_current_session_summary AS
SELECT
  s.session_date,
  COUNT(ma.id)                              AS total_members,
  SUM(ma.present)                           AS present_count,
  COUNT(ma.id) - SUM(ma.present)           AS absent_count,
  ROUND(SUM(ma.present) / COUNT(ma.id) * 100, 1) AS attendance_pct
FROM attendance_sessions s
JOIN member_attendance ma ON ma.session_id = s.id
WHERE s.session_date = (SELECT MAX(session_date) FROM attendance_sessions)
GROUP BY s.session_date;

-- Visitor return frequency
CREATE OR REPLACE VIEW v_visitor_return_count AS
SELECT
  v.id,
  v.full_name,
  v.phone,
  COUNT(vh.id)    AS total_visits,
  MAX(vh.visit_date) AS last_visit
FROM visitors v
LEFT JOIN visit_history vh ON vh.visitor_id = v.id
GROUP BY v.id, v.full_name, v.phone;

-- Kids attendance summary per session
CREATE OR REPLACE VIEW v_kids_session_summary AS
SELECT
  s.session_date,
  COUNT(ka.id)        AS total_kids,
  SUM(ka.present)     AS present_count,
  COUNT(ka.id) - SUM(ka.present) AS absent_count
FROM kids_attendance_sessions s
JOIN kids_attendance ka ON ka.session_id = s.id
GROUP BY s.session_date;
