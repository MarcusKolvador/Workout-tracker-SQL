-- Create a new user
INSERT INTO "users" ("first_name", "last_name")
VALUES ("Kacper", "Kubiak");

INSERT INTO "users" ("first_name", "last_name")
VALUES ("John", "Shepard");

-- Add a user's user_data for a user with a given first and last name on the current day
INSERT INTO "user_data" ("user_id", "user_weight_kg", "perceived_readiness")
SELECT "id", 80, 7
FROM "users"
WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak';

INSERT INTO "user_data" ("user_id", "user_weight_kg", "perceived_readiness")
SELECT "id", 80, 7
FROM "users"
WHERE "first_name" = 'John' AND "last_name" = 'Shepard';

-- Create a new workout session on the current day, for a user with a given first and last name
INSERT INTO "sessions" ("user_id", "user_data_id", "sRPE")
SELECT "id", 1, 6
FROM "users"
WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak';

INSERT INTO "sessions" ("user_id", "user_data_id", "sRPE")
SELECT "id", 1, 6
FROM "users"
WHERE "first_name" = 'John' AND "last_name" = 'Shepard';

-- View the exercise base
SELECT "exercise_name", "equipment_needed"
FROM "exercises";

-- Search for an exercise in the exercise base with a given equipment
SELECT "exercise_name"
FROM "exercises"
WHERE "equipment_needed" LIKE '%"bench"%';

-- Add an exercise to the exercise base
INSERT INTO "exercises" ("exercise_name", "equipment_needed")
VALUES ('bench press', '["bench", "barbell"]');

-- Add a performance of an exercise with a given user and session id (1)
INSERT INTO "performances" ("session_id", "user_id", "exercise_id", "weight", "reps", "RPE")
SELECT 1,
(SELECT "id" FROM "users" WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak'),
(SELECT "id" FROM "exercises" WHERE LOWER("exercise_name") = LOWER('bench press')),
70, 4, 5;

-- Find all workout sessions of a user, with a given first and last name
SELECT * FROM "sessions"
WHERE "user_id" = (
    SELECT "id" FROM "users"
    WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak'
);

-- Find all performances of a given exercise of a user with a given first and last name
SELECT * FROM "performances"
WHERE "user_id" = (
    SELECT "id" FROM "users"
    WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak'
)
AND "exercise_id" = (
    SELECT "id" FROM "exercises"
    WHERE "exercise_name" = 'bench press'
);

-- Display details of a particular workout session of an individual with a given first and last name
SELECT sessions.id, user_data.user_weight_kg, user_data.perceived_readiness, user_data.date_of_input AS "start time",
sessions.sRPE, sessions.date_of_input AS "end time"
FROM "sessions"
JOIN "user_data" ON sessions.user_data_id = user_data.id
WHERE sessions.user_id = (
    SELECT "id" FROM "users"
    WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak'
)
AND sessions.id = 1;

-- Display the above, but with added exercises
SELECT sessions.id AS "session_id", user_data.user_weight_kg, user_data.perceived_readiness, user_data.date_of_input AS "start time",
sessions.sRPE, sessions.date_of_input AS "end time", exercises.exercise_name, performances.weight, performances.reps, performances.RPE, performances.set_no
FROM "sessions"
JOIN "exercises" ON exercises.id = performances.exercise_id
JOIN "user_data" ON sessions.user_data_id = user_data.id
JOIN "performances" ON sessions.id = performances.session_id
WHERE sessions.user_id = (
    SELECT "id" FROM "users"
    WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak'
)
AND sessions.id = 1;

-- OOOOR USE A view

SELECT * FROM "view_user_sessions"
WHERE user_id = (
    SELECT "id" FROM "users"
    WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak'
)
AND session_id = 1;
