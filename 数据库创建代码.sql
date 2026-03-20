-- =============================================
-- 1. 创建数据库
-- =============================================
CREATE DATABASE IF NOT EXISTS education_system 
DEFAULT CHARACTER SET utf8mb4  -- 支持emoji等特殊字符
DEFAULT COLLATE utf8mb4_unicode_ci;  -- 通用排序规则，适配多语言

USE education_system;

-- =============================================
-- 2. 创建角色表
-- =============================================
CREATE TABLE IF NOT EXISTS `role` (
  `role_id` INT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_desc` VARCHAR(200) DEFAULT NULL COMMENT '角色描述',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- =============================================
-- 3. 创建权限表
-- =============================================
CREATE TABLE IF NOT EXISTS `permission` (
  `perm_id` INT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `perm_name` VARCHAR(50) NOT NULL COMMENT '权限名称',
  `perm_url` VARCHAR(200) DEFAULT NULL COMMENT '权限资源路径',
  `perm_type` TINYINT DEFAULT 1 COMMENT '权限类型（1-菜单，2-按钮）',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`perm_id`),
  UNIQUE KEY `uk_perm_name` (`perm_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限表';

-- =============================================
-- 4. 创建角色权限关联表
-- =============================================
CREATE TABLE IF NOT EXISTS `role_permission` (
  `rp_id` INT NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `role_id` INT NOT NULL COMMENT '角色ID',
  `perm_id` INT NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`rp_id`),
  UNIQUE KEY `uk_role_perm` (`role_id`,`perm_id`),
  KEY `idx_perm_id` (`perm_id`),
  CONSTRAINT `fk_rp_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_perm_id` FOREIGN KEY (`perm_id`) REFERENCES `permission` (`perm_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限关联表';

-- =============================================
-- 5. 创建用户表
-- =============================================
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` INT NOT NULL AUTO_INCREMENT COMMENT '用户唯一标识',
  `user_no` VARCHAR(50) NOT NULL COMMENT '用户学号/工号',
  `user_name` VARCHAR(50) NOT NULL COMMENT '用户姓名',
  `user_pwd` VARCHAR(100) NOT NULL COMMENT '用户密码（加密存储）',
  `role_id` INT NOT NULL COMMENT '所属角色ID',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_user_no` (`user_no`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_user_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =============================================
-- 6. 创建科研项目表
-- =============================================
CREATE TABLE IF NOT EXISTS `research_project` (
  `rpj_id` INT NOT NULL AUTO_INCREMENT COMMENT '科研项目ID',
  `project_name` VARCHAR(100) NOT NULL COMMENT '项目名称',
  `project_no` VARCHAR(50) NOT NULL COMMENT '项目编号',
  `project_target` VARCHAR(500) DEFAULT NULL COMMENT '项目目标',
  `leader_id` INT NOT NULL COMMENT '负责人ID（关联用户）',
  `project_budget` DECIMAL(12,2) DEFAULT NULL COMMENT '项目预算金额',
  `actual_budget` DECIMAL(12,2) DEFAULT NULL COMMENT '实际经费金额',
  `project_status` TINYINT DEFAULT 0 COMMENT '项目状态（0-进行中，1-已完成，2-已终止）',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`rpj_id`),
  UNIQUE KEY `uk_project_no` (`project_no`),
  KEY `idx_leader_id` (`leader_id`),
  CONSTRAINT `fk_rpj_leader_id` FOREIGN KEY (`leader_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科研项目表';

-- =============================================
-- 7. 创建项目结果表
-- =============================================
CREATE TABLE IF NOT EXISTS `project_result` (
  `res_id` INT NOT NULL AUTO_INCREMENT COMMENT '结果ID',
  `rpj_id` INT NOT NULL COMMENT '关联科研项目ID',
  `result_target` VARCHAR(200) DEFAULT NULL COMMENT '成果目标',
  `result_date` DATE DEFAULT NULL COMMENT '成果日期',
  `result_num` INT DEFAULT 0 COMMENT '成果数量',
  `result_type` TINYINT DEFAULT 0 COMMENT '成果类型（0-论文，1-专利，2-软著等）',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`res_id`),
  KEY `idx_rpj_id` (`rpj_id`),
  CONSTRAINT `fk_res_rpj_id` FOREIGN KEY (`rpj_id`) REFERENCES `research_project` (`rpj_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目结果表';

-- =============================================
-- 8. 创建教学项目表
-- =============================================
CREATE TABLE IF NOT EXISTS `teaching_project` (
  `tpj_id` INT NOT NULL AUTO_INCREMENT COMMENT '教学项目ID',
  `course_name` VARCHAR(100) NOT NULL COMMENT '课程名称',
  `course_id` VARCHAR(50) NOT NULL COMMENT '课程编号',
  `teacher_name` VARCHAR(50) NOT NULL COMMENT '授课教师姓名',
  `term` VARCHAR(20) NOT NULL COMMENT '学期（如2024-2025-1）',
  `credit` DECIMAL(3,1) DEFAULT NULL COMMENT '学分',
  `student_count` INT DEFAULT 0 COMMENT '选课学生人数',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`tpj_id`),
  UNIQUE KEY `uk_course_id_term` (`course_id`,`term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教学项目表';

-- =============================================
-- 9. 创建学生排名表
-- =============================================
CREATE TABLE IF NOT EXISTS `student_rank` (
  `sr_id` INT NOT NULL AUTO_INCREMENT COMMENT '排名记录ID',
  `user_id` INT NOT NULL COMMENT '学生用户ID',
  `term` VARCHAR(20) NOT NULL COMMENT '学期',
  `avg_score` DECIMAL(5,2) DEFAULT NULL COMMENT '平均绩点/成绩',
  `competition_award` VARCHAR(200) DEFAULT NULL COMMENT '竞赛获奖情况',
  `annual_award` VARCHAR(200) DEFAULT NULL COMMENT '年度获奖情况',
  `student_effect` VARCHAR(500) DEFAULT NULL COMMENT '学生成果',
  `delete_flag` TINYINT DEFAULT 0 COMMENT '删除标识（0-未删除，1-已删除）',
  PRIMARY KEY (`sr_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_sr_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生排名表';
