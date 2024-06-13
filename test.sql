-- create users
INSERT INTO "users" ("first_name", "last_name")
VALUES ("Kacper", "Kubiak");

INSERT INTO "users" ("first_name", "last_name")
VALUES ("John", "Shepard");

-- user A, B, A logging
INSERT INTO "user_data" ("user_id", "user_weight_kg", "perceived_readiness")
SELECT "id", 80, 7
FROM "users"
WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak';

INSERT INTO "sessions" ("user_id", "user_data_id", "sRPE")
SELECT "id", 1, 6
FROM "users"
WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak';

INSERT INTO "user_data" ("user_id", "user_weight_kg", "perceived_readiness")
SELECT "id", 80, 7
FROM "users"
WHERE "first_name" = 'John' AND "last_name" = 'Shepard';

INSERT INTO "sessions" ("user_id", "user_data_id", "sRPE")
SELECT "id", 1, 6
FROM "users"
WHERE "first_name" = 'John' AND "last_name" = 'Shepard';

INSERT INTO "user_data" ("user_id", "user_weight_kg", "perceived_readiness")
SELECT "id", 80, 7
FROM "users"
WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak';

INSERT INTO "sessions" ("user_id", "user_data_id", "sRPE")
SELECT "id", 1, 6
FROM "users"
WHERE "first_name" = 'Kacper' AND "last_name" = 'Kubiak';
