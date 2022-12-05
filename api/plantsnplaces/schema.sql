DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS plant;
DROP TABLE IF EXISTS plant_location;


CREATE TABLE user (
    username VARCHAR PRIMARY KEY,
    password VARCHAR NOT NULL
);

CREATE TABLE plant (
    name VARCHAR PRIMARY KEY
);

CREATE TABLE plant_location (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user VARCHAR NOT NULL,
    plant VARCHAR NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    image_path VARCHAR,
    CONSTRAINT fk_user
    FOREIGN KEY (user)
    REFERENCES user(username),
    CONSTRAINT fk_plant
    FOREIGN KEY (plant)
    REFERENCES plant(name)
);
