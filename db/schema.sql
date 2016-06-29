
DROP TABLE IF EXISTS problems;
CREATE TABLE problems(
	id INTEGER PRIMARY KEY,
	title TEXT,
	content TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS answers;
CREATE TABLE answers(
	id INTEGER PRIMARY KEY,
	problem_id INTEGER,
	title TEXT,
	content TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id INTEGER PRIMARY KEY,
	answer_id INTEGER,
	comment TEXT,
	name TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id INTEGER PRIMARY KEY,
	username TEXT,
	usertype TEXT,
	-- you MUST use password_digest
	password_digest TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);