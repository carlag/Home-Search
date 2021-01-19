CREATE TYPE save_mark AS ENUM ('liked', 'rejected', 'unsure');

CREATE TABLE IF NOT EXISTS properties (
    listing_id TEXT NOT NULL,
    listing_url TEXT NOT NULL,
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL,
    price FLOAT,
    ocr_size FLOAT,
    floor_plan TEXT,
    mark save_mark,
    PRIMARY KEY(listing_id)
);