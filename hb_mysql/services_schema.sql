-- $Id: schema-mysql.txt 23894 2007-05-01 17:24:07Z leeh $

CREATE TABLE users (
	id INTEGER AUTO_INCREMENT,
	username VARCHAR(10) NOT NULL,
	password VARCHAR(35) NOT NULL,
	email VARCHAR(100),
	suspender VARCHAR(30),
	suspend_reason VARCHAR(200),
	suspend_time INT UNSIGNED DEFAULT '0',
	reg_time INT UNSIGNED,
	last_time INT UNSIGNED,
	flags INT UNSIGNED,
	verify_token VARCHAR(8),
	language VARCHAR(255) DEFAULT '',
	PRIMARY KEY(id)
);
ALTER TABLE users ADD UNIQUE(username);

CREATE TABLE users_resetpass (
	username VARCHAR(10) NOT NULL,
	token VARCHAR(10),
	time INTEGER,
	PRIMARY KEY(username)
);
ALTER TABLE users_resetpass ADD INDEX (time);

CREATE TABLE users_resetemail (
	username VARCHAR(10) NOT NULL,
	token VARCHAR(10),
	email VARCHAR(100) DEFAULT NULL,
	time INTEGER,
	PRIMARY KEY(username)
);
ALTER TABLE users_resetemail ADD INDEX (time);

CREATE TABLE users_sync (
	id INTEGER AUTO_INCREMENT, 
	hook VARCHAR(50) NOT NULL,
	data TEXT,
	PRIMARY KEY(id)
);

CREATE TABLE nicks (
	nickname VARCHAR(9) NOT NULL,
	username VARCHAR(10) NOT NULL,
	reg_time INT UNSIGNED,
	last_time INT UNSIGNED,
	flags INT UNSIGNED,
	PRIMARY KEY(nickname)
);

CREATE TABLE channels (
	chname VARCHAR(200) NOT NULL,
	topic VARCHAR(160),
	url VARCHAR(100),
	createmodes VARCHAR(50),
	enforcemodes VARCHAR(50),
	tsinfo INT UNSIGNED,
	reg_time INT UNSIGNED,
	last_time INT UNSIGNED,
	flags INT UNSIGNED,
	suspender VARCHAR(30),
	suspend_reason VARCHAR(200),
	suspend_time INT UNSIGNED DEFAULT '0',
	PRIMARY KEY(chname)
);

CREATE TABLE channels_dropowner (
	chname VARCHAR(200) NOT NULL,
	token VARCHAR(10),
	time INTEGER,
	PRIMARY KEY(chname)
);
ALTER TABLE channels_dropowner ADD INDEX (time);

CREATE TABLE members (
	chname VARCHAR(200) NOT NULL,
	username VARCHAR(10) NOT NULL,
	lastmod VARCHAR(10) NOT NULL,
	level INT,
	flags INT UNSIGNED,
	suspend INT,
	PRIMARY KEY(chname, username)
);
ALTER TABLE members ADD INDEX (chname);
ALTER TABLE members ADD INDEX (username);

CREATE TABLE bans (
	chname VARCHAR(200) NOT NULL,
	mask VARCHAR(84) NOT NULL,
	reason VARCHAR(50) NOT NULL,
	username VARCHAR(10) NOT NULL,
	level INT,
	hold INT,
	PRIMARY KEY(chname, mask)
);
ALTER TABLE bans ADD INDEX (chname);

CREATE TABLE operbot (
	chname VARCHAR(200) NOT NULL,
	tsinfo INT UNSIGNED,
	oper VARCHAR(30),
	PRIMARY KEY(chname)
);

CREATE TABLE operserv (
	chname VARCHAR(200) NOT NULL,
	tsinfo INT UNSIGNED,
	oper VARCHAR(30),
	PRIMARY KEY(chname)
);

CREATE TABLE jupes (
	servername VARCHAR(63) NOT NULL,
	reason VARCHAR(50) NOT NULL,
	PRIMARY KEY(servername)
);

CREATE TABLE operbans (
	type CHAR(1) NOT NULL,
	mask VARCHAR(200) NOT NULL,
	reason VARCHAR(50) NOT NULL,
	operreason VARCHAR(50),
	hold INT UNSIGNED,
	create_time INT UNSIGNED,
	oper VARCHAR(30),
	remove BOOL,
	flags INT UNSIGNED,
	PRIMARY KEY(type, mask)
);

CREATE TABLE operbans_regexp (
	id INTEGER AUTO_INCREMENT,
	regex VARCHAR(255) NOT NULL,
	reason VARCHAR(50) NOT NULL,
	hold INTEGER,
	create_time INTEGER,
	oper VARCHAR(30),
	PRIMARY KEY(id)
);

CREATE TABLE operbans_regexp_neg (
	id INTEGER AUTO_INCREMENT,
	parent_id INTEGER NOT NULL,
	regex VARCHAR(255) NOT NULL,
	oper VARCHAR(30) NOT NULL,
	PRIMARY KEY(id)
);

CREATE TABLE global_welcome (
	id INTEGER,
	text TEXT,
	PRIMARY KEY(id)
);

CREATE TABLE email_banned_domain (
	domain VARCHAR(255) NOT NULL,
	PRIMARY KEY(domain)
);

CREATE TABLE ignore_hosts (
	hostname VARCHAR(255) NOT NULL,
	oper VARCHAR(30) NOT NULL,
	reason VARCHAR(255) NOT NULL,
	PRIMARY KEY(hostname)
);

CREATE TABLE memos(
	id INTEGER AUTO_INCREMENT,
	user_id INTEGER NOT NULL,
	source_id INTEGER NOT NULL,
	source VARCHAR(10) NOT NULL,
	timestamp INTEGER UNSIGNED DEFAULT '0',
	flags INTEGER UNSIGNED DEFAULT '0',
	text TEXT,
	PRIMARY KEY(id)
);

