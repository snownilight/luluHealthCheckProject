-- Daily health summaries table
CREATE TABLE IF NOT EXISTS daily_health_summaries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    date DATE UNIQUE NOT NULL,
    total_water_intake_ml DOUBLE DEFAULT 0.0,
    total_food_intake_g DOUBLE DEFAULT 0.0,
    average_weight_kg DOUBLE DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Chronological care logs (Digital Contact Book)
CREATE TABLE IF NOT EXISTS care_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_id VARCHAR(50) UNIQUE NOT NULL,
    event_type VARCHAR(20) NOT NULL,
    operator VARCHAR(50) NOT NULL,
    value DOUBLE,
    unit VARCHAR(10),
    note VARCHAR(255),
    event_timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_care_logs_event_timestamp (event_timestamp)
);

-- Weekly/Monthly historical weight tracking
CREATE TABLE IF NOT EXISTS weight_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    weight_kg DOUBLE NOT NULL,
    recorded_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_weight_logs_recorded_at (recorded_at)
);
