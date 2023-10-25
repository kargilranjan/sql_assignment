CREATE DATABASE IF NOT EXISTS Starwars;

-- Switch to the Starwars database
USE Starwars;

-- Create the Characters table
CREATE TABLE Characters (
    Name VARCHAR(50),
    Race VARCHAR(50),
    Homeworld VARCHAR(50),
    Affiliation VARCHAR(50)
);

-- Create the Planets table
CREATE TABLE Planets (
    Name VARCHAR(50),
    Type VARCHAR(50),
    Affiliation VARCHAR(50)
);

-- Create the SimpleQuery table
CREATE TABLE SimpleQuery (
    Name VARCHAR(50),
    Type VARCHAR(50),
    Affiliation VARCHAR(50)
);

-- Create the TimeTable table
CREATE TABLE TimeTable (
    CharacterName VARCHAR(50),
    PlanetName VARCHAR(50),
    Movie INT,
    Time_of_Arrival INT,
    Time_of_Departure INT
);

-- Insert data into the Characters table
INSERT INTO Characters (Name, Race, Homeworld, Affiliation)
VALUES
    ('Han Solo', 'Human', 'Corellia', 'rebels'),
    ('Princess Leia', 'Human', 'Alderaan', 'rebels'),
    ('Luke Skywalker', 'Human', 'Tatooine', 'rebels'),
    ('Darth Vader', 'Human', 'Unknown', 'empire'),
    ('Chewbacca', 'Wookie', 'Kashyyyk', 'rebels'),
    ('C-3 PO', 'Droid', 'Unknown', 'rebels'),
    ('R2-D2', 'Droid', 'Unknown', 'rebels'),
    ('Obi-Wan Kenobi', 'Human', 'Tatooine', 'rebels'),
    ('Lando Calrissian', 'Human', 'Unknown', 'rebels'),
    ('Yoda', 'Unknown', 'Unknown', 'neutral'),
    ('Jabba the Hutt', 'Hutt', 'Unknown', 'neutral'),
    ('Owen Lars', 'Human', 'Tatooine', 'neutral'),
    ('Rancor', 'Rancor', 'Unknown', 'neutral');

-- Insert data into the Planets table
INSERT INTO Planets (Name, Type, Affiliation)
VALUES
    ('Tatooine', 'desert', 'neutral'),
    ('Hoth', 'ice', 'rebels'),
    ('Dagobah', 'swamp', 'neutral'),
    ('Death Star', 'artificial', 'empire'),
    ('Endor', 'forest', 'neutral'),
    ('Bespin', 'gas', 'neutral'),
    ('Star Destroyer', 'artificial', 'empire'),
    ('Kashyyyk', 'forest', 'rebels'),
    ('Corellia', 'temperate', 'rebels'),
    ('Alderaan', 'temperate', 'rebels');
    
    1.Write a procedure track_character(character)that accepts a character name and returns a result set that contains a list of the movie scenes the character is in.For each movie, track the total number of scenes and the planet where the character appears. The result set should contain the character’s name, the planet name, the movie name, and the sum of the movie scene length for that specific planet in that movie for that character. 
DELIMITER //
CREATE PROCEDURE track_character(IN character_name VARCHAR(50))
BEGIN
    -- Create a temporary table to store the result set
    CREATE TEMPORARY TABLE CharacterScenes (
        CharacterName VARCHAR(50),
        PlanetName VARCHAR(50),
        MovieName VARCHAR(50),
        TotalSceneLength INT
    );

    -- Cursor to iterate through movies
    DECLARE done INT DEFAULT 0;
    DECLARE movie_name VARCHAR(50);
    DECLARE movie_cursor CURSOR FOR
    SELECT DISTINCT Movie
    FROM TimeTable
    WHERE CharacterName = character_name;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Variables for storing scene length and planet name
    DECLARE total_scene_length INT;
    DECLARE planet_name VARCHAR(50);

    OPEN movie_cursor;
    movie_loop: LOOP
        FETCH movie_cursor INTO movie_name;
        IF done THEN
            LEAVE movie_loop;
        END IF;

        -- Cursor to calculate the total scene length on each planet for the character
        DECLARE planet_cursor CURSOR FOR
        SELECT PlanetName, SUM(Time_of_Departure - Time_of_Arrival) AS SceneLength
        FROM TimeTable
        WHERE CharacterName = character_name AND Movie = movie_name
        GROUP BY PlanetName;
        
        OPEN planet_cursor;
        planet_loop: LOOP
            FETCH planet_cursor INTO planet_name, total_scene_length;

            -- Insert the results into the temporary table
            INSERT INTO CharacterScenes (CharacterName, PlanetName, MovieName, TotalSceneLength)
            VALUES (character_name, planet_name, movie_name, total_scene_length);

        END LOOP planet_loop;
        CLOSE planet_cursor;

    END LOOP movie_loop;
    CLOSE movie_cursor;

    -- Select the results from the temporary table
    SELECT * FROM CharacterScenes;

    -- Drop the temporary table
    DROP TEMPORARY TABLE CharacterScenes;
END 
DELIMITER ;

2.Write a procedure track_planet(planet)that accepts a planet name and returns a result set that contain the planet name, the movie name, and the number of characters that appear on that planet during that movie. 
DELIMITER //
CREATE PROCEDURE track_planet(IN planet_name VARCHAR(50))
BEGIN
    -- Create a temporary table to store the result set
    CREATE TEMPORARY TABLE PlanetCharacters (
        PlanetName VARCHAR(50),
        MovieName VARCHAR(50),
        CharacterCount INT
    );

    -- Cursor to iterate through movies
    DECLARE done INT DEFAULT 0;
    DECLARE movie_name VARCHAR(50);
    DECLARE movie_cursor CURSOR FOR
    SELECT DISTINCT Movie
    FROM TimeTable
    WHERE PlanetName = planet_name;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Variables for counting characters
    DECLARE character_count INT;

    OPEN movie_cursor;
    movie_loop: LOOP
        FETCH movie_cursor INTO movie_name;
        IF done THEN
            LEAVE movie_loop;
        END IF;

        -- Count the number of characters on the planet in the movie
        SELECT COUNT(DISTINCT CharacterName) INTO character_count
        FROM TimeTable
        WHERE PlanetName = planet_name AND Movie = movie_name;

        -- Insert the results into the temporary table
        INSERT INTO PlanetCharacters (PlanetName, MovieName, CharacterCount)
        VALUES (planet_name, movie_name, character_count);

    END LOOP movie_loop;
    CLOSE movie_cursor;

    -- Select the results from the temporary table
    SELECT * FROM PlanetCharacters;

    -- Drop the temporary table
    DROP TEMPORARY TABLE PlanetCharacters;
END 
DELIMITER ;

3.Write a function named planet_hopping(character). It accepts a character name and returns the number of planets the character has appeared on. 
DELIMITER //
CREATE FUNCTION planet_hopping(character_name VARCHAR(50))
RETURNS INT
BEGIN
    DECLARE planet_count INT;

    -- Count the number of distinct planets the character has appeared on
    SELECT COUNT(DISTINCT PlanetName) INTO planet_count
    FROM TimeTable
    WHERE CharacterName = character_name;

    RETURN planet_count;
END 
DELIMITER ;

4.Write a function named planet_most_visited(character) that accepts a character name and returns the name of the planet where the character appeared the most ( as measured in scene counts). 
DELIMITER //
CREATE FUNCTION planet_most_visited(character_name VARCHAR(50))
RETURNS VARCHAR(50)
BEGIN
    DECLARE most_visited_planet VARCHAR(50);

    -- Get the planet where the character appeared the most
    SELECT PlanetName INTO most_visited_planet
    FROM (
        SELECT PlanetName, COUNT(*) AS SceneCount
        FROM TimeTable
        WHERE CharacterName = character_name
        GROUP BY PlanetName
        ORDER BY SceneCount DESC
        LIMIT 1
    ) AS TempTable;

    RETURN most_visited_planet;
END 
DELIMITER ;

5.Write a function named home_affiliation_same(character) that accepts a character name and returns TRUE if the character has the same affiliation as his home planet, FALSE if the character has a different affiliation than his home planet or NULL if the home planet or the affiliation is not known. 
DELIMITER //
CREATE FUNCTION home_affiliation_same(character_name VARCHAR(50))
RETURNS VARCHAR(5)
BEGIN
    DECLARE char_affiliation VARCHAR(50);
    DECLARE home_affiliation VARCHAR(50);
    DECLARE result VARCHAR(5);

    -- Get the character's affiliation
    SELECT Affiliation INTO char_affiliation
    FROM Characters
    WHERE Name = character_name;

    -- Get the character's home planet
    SELECT Homeworld INTO home_affiliation
    FROM Characters
    WHERE Name = character_name;

    -- Check if both character affiliation and home affiliation are known
    IF char_affiliation IS NOT NULL AND home_affiliation IS NOT NULL THEN
        IF char_affiliation = home_affiliation THEN
            SET result = 'TRUE';
        ELSE
            SET result = 'FALSE';
        END IF;
    ELSE
        SET result = NULL;
    END IF;

    RETURN result;
END 
DELIMITER ;

6.Write a function named planet_in_num_movies that accepts a planet’s name as an argument and returns the number of movies that the planet appeared in. 
DELIMITER //
CREATE FUNCTION planet_in_num_movies(planet_name VARCHAR(50))
RETURNS INT
BEGIN
    DECLARE movie_count INT;

    -- Count the number of movies the planet appeared in
    SELECT COUNT(DISTINCT Movie) INTO movie_count
    FROM TimeTable
    WHERE PlanetName = planet_name;

    RETURN movie_count;
END 
DELIMITER ;

7.Write a procedurenamed character_with_affiliation(affiliation) that accepts an affiliation and returns the character records(all fields associated with the character) with that affiliation. 
DELIMITER //
CREATE PROCEDURE character_with_affiliation(IN character_affiliation VARCHAR(50))
BEGIN
    -- Retrieve character records with the specified affiliation
    SELECT *
    FROM Characters
    WHERE Affiliation = character_affiliation;
END 
DELIMITER ;

-- 8.Write a trigger that updates the field scenes_in_db for the movie records in the Movies table. The field should contain the maximum scene number found in the timetable table for that movie.Call the trigger timetable_after_insert. Insert the following records into the database.Insert records into the timetable table that places 'Chewbacca’, and ‘Princess Leia’ on 'Endor' in scenes 11 through 12 for movie 3. Ensure that the scenesinDB is properly updated for this data. 
DELIMITER //
CREATE TRIGGER timetable_after_insert AFTER INSERT ON TimeTable
FOR EACH ROW
BEGIN
    DECLARE max_scene_number INT;

    -- Find the maximum scene number for the inserted movie
    SELECT MAX(`Time of Arrival`) INTO max_scene_number
    FROM TimeTable
    WHERE Movie = NEW.Movie;

    -- Update the scenes_in_db field for the movie in the Movies table
    UPDATE Movies
    SET scenes_in_db = max_scene_number
    WHERE MovieID = NEW.Movie;
END;

DELIMITER ;

-- 9.Create and execute a prepared statement from the SQL workbench that calls track_character with the argument ‘ Princess Leia’. Use a user session variable to pass the argument to the function. 
SET @character_name = 'Princess Leia';
SET @sql = CONCAT('CALL track_character(''', @character_name, ''')');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 10.Create and execute a prepared statement that calls planet_in_num_movies() with the argument ‘Bespin’. Once again use a user session variable to pass the argument to the function.
SET @planet_name = 'Bespin';
SET @sql = CONCAT('SELECT planet_in_num_movies(''', @planet_name, ''')');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;