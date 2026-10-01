CREATE TABLE IF NOT EXISTS government_employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(60) NOT NULL,
    department VARCHAR(50) NOT NULL,
    rank VARCHAR(50) NOT NULL,
    salary INT NOT NULL,
    CONSTRAINT fk_government_employees_players FOREIGN KEY (identifier) REFERENCES users (identifier) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS government_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(60) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT fk_government_applications_players FOREIGN KEY (identifier) REFERENCES users (identifier) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS government_licenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(60) NOT NULL,
    type VARCHAR(50) NOT NULL,
    CONSTRAINT fk_government_licenses_players FOREIGN KEY (identifier) REFERENCES users (identifier) ON DELETE CASCADE
);

INSERT INTO government_employees (identifier, department, rank, salary) VALUES ('steam:11000010d6a3a4d', 'Police', 'Commissioner', 12000);
INSERT INTO government_employees (identifier, department, rank, salary) VALUES ('steam:11000010d6a3a4e', 'Fire', 'Chief', 12000);
INSERT INTO government_employees (identifier, department, rank, salary) VALUES ('steam:11000010d6a3a4f', 'Health', 'Director', 12000);