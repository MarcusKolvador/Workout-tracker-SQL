CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER, -- unique user id
    "first_name" TEXT NOT NULL, -- user's name
    "last_name" TEXT NOT NULL, -- user's last name
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "user_data" (
    "id" INTEGER, -- unique id of user's time-specific data record
    "user_id" INTEGER, -- id of the user the data record is tied to
    "session_id" INTEGER, -- id of the session the data record is tied to
    "user_weight_kg" NUMERIC CHECK("user_weight_kg" >= 0), -- user's weight at time of record, in kg
    "perceived_readiness" INTEGER CHECK("perceived_readiness" BETWEEN 1 AND 10), -- percieved readiness for the training session on a scale of 1 to 10
    "date_of_input" TIMESTAMP NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M', 'NOW')), -- date of recording of the data
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("session_id") REFERENCES "sessions"("id"),
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "exercises" (
    "id" INTEGER, -- unique id of the recorded exercise type
    "exercise_name" TEXT NOT NULL, -- name of the exercise added to the record
    "equipment_needed" TEXT, -- equipment needed to perform the exercise
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "sessions" (
    "id" INTEGER, -- unique id of the workout session
    "user_id" INTEGER, -- id of the user the session is tied to
    "user_data_id" INTEGER, -- id of the user_data record the session is tied to
    "sRPE" INTEGER NOT NULL CHECK("sRPE" BETWEEN 1 AND 10), -- rpe of the session
    "date_of_input" TIMESTAMP NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M', 'NOW')), -- date the session took place on, as yyyy-mm-dd
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("user_data_id") REFERENCES "user_data"("id"),
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "performances" (
    "id" INTEGER, -- unique id of the performance record/exercise
    "session_id" INTEGER, -- id of session the performance is tied to
    "user_id" INTEGER, -- id of the user the performance is tied to
    "exercise_id" INTEGER NOT NULL, -- id of the exercise performed
    "date_of_input" TIMESTAMP NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M', 'NOW')), -- datetime of the exercise performance
    "weight" NUMERIC NOT NULL, -- weight moved
    "reps" INTEGER NOT NULL, -- reps the exercise was performed for
    "RPE" INTEGER NOT NULL CHECK("RPE" BETWEEN 1 AND 10), -- rpe of the exercise performed
    "set_no" INTEGER NOT NULL DEFAULT 0, -- the no. of the set in the session of given exercise
    FOREIGN KEY("exercise_id") REFERENCES "exercises"("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("session_id") REFERENCES "sessions"("id"),
    PRIMARY KEY("id")
);

-- automatically updates set numbers of exercises
CREATE TRIGGER IF NOT EXISTS set_no_increment
AFTER INSERT ON performances
BEGIN
    UPDATE performances
    SET set_no = (
        SELECT COALESCE(MAX(p.set_no) + 1, 1)
        FROM performances p
        WHERE p.session_id = NEW.session_id
        AND p.exercise_id = NEW.exercise_id
    )
    WHERE rowid = NEW.rowid;
END;

-- automatically links sessions with user_data entries
CREATE TRIGGER IF NOT EXISTS link_data_session
AFTER INSERT ON "sessions"
BEGIN
    UPDATE "user_data"
    SET "session_id" = (SELECT MAX("id") FROM "sessions")
    WHERE "user_id" = NEW.user_id
    AND "id" = (SELECT MAX("id") FROM "user_data" WHERE "user_id" = NEW.user_id);
END;
CREATE TRIGGER IF NOT EXISTS link_session_data
AFTER UPDATE ON "user_data"
BEGIN
    UPDATE "sessions"
    SET "user_data_id" = NEW.id
    WHERE "user_id" = NEW.user_id
    AND "id" = (SELECT MAX("id") FROM "sessions" WHERE "user_id" = NEW.user_id);
END;

-- indexes
CREATE INDEX "view_exercises" ON "exercises"("exercise_name", "equipment_needed");
CREATE INDEX "sessions_view" ON "sessions"("user_id", "user_data_id");
CREATE INDEX "user_names" ON "users"("first_name", "last_name");
CREATE INDEX "performances_user_id" ON "performances"("user_id", "exercise_id", "session_id");

-- views
CREATE VIEW "view_user_sessions"
AS
SELECT sessions.user_id, sessions.id AS "session_id", user_data.user_weight_kg, user_data.perceived_readiness, user_data.date_of_input AS "start time",
sessions.sRPE, sessions.date_of_input AS "end time", exercises.exercise_name, performances.weight, performances.reps, performances.RPE, performances.set_no
FROM "sessions"
JOIN "exercises" ON exercises.id = performances.exercise_id
JOIN "user_data" ON sessions.user_data_id = user_data.id
JOIN "performances" ON sessions.id = performances.session_id;




