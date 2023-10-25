-- https://en.wikibooks.org/wiki/SQL_Exercises/Pieces_and_providers
use project5;
CREATE TABLE Pieces (
 Code INTEGER PRIMARY KEY NOT NULL,
 Name TEXT NOT NULL
 );
CREATE TABLE Providers (
 Code VARCHAR(40) 
 PRIMARY KEY NOT NULL,  
 Name TEXT NOT NULL 
 );
CREATE TABLE Provides (
 Piece INTEGER, 
 FOREIGN KEY (Piece) REFERENCES Pieces(Code),
 Provider VARCHAR(40), 
 FOREIGN KEY (Provider) REFERENCES Providers(Code),  
 Price INTEGER NOT NULL,
 PRIMARY KEY(Piece, Provider) 
 );
 
-- alternative one for SQLite
  /* 
 CREATE TABLE Provides (
 Piece INTEGER,
 Provider VARCHAR(40),  
 Price INTEGER NOT NULL,
 PRIMARY KEY(Piece, Provider) 
 );
 */
 
 
INSERT INTO Providers(Code, Name) VALUES('HAL','Clarke Enterprises');
INSERT INTO Providers(Code, Name) VALUES('RBT','Susan Calvin Corp.');
INSERT INTO Providers(Code, Name) VALUES('TNBC','Skellington Supplies');

INSERT INTO Pieces(Code, Name) VALUES(1,'Sprocket');
INSERT INTO Pieces(Code, Name) VALUES(2,'Screw');
INSERT INTO Pieces(Code, Name) VALUES(3,'Nut');
INSERT INTO Pieces(Code, Name) VALUES(4,'Bolt');

INSERT INTO Provides(Piece, Provider, Price) VALUES(1,'HAL',10);
INSERT INTO Provides(Piece, Provider, Price) VALUES(1,'RBT',15);
INSERT INTO Provides(Piece, Provider, Price) VALUES(2,'HAL',20);
INSERT INTO Provides(Piece, Provider, Price) VALUES(2,'RBT',15);
INSERT INTO Provides(Piece, Provider, Price) VALUES(2,'TNBC',14);
INSERT INTO Provides(Piece, Provider, Price) VALUES(3,'RBT',50);
INSERT INTO Provides(Piece, Provider, Price) VALUES(3,'TNBC',45);
INSERT INTO Provides(Piece, Provider, Price) VALUES(4,'HAL',5);
INSERT INTO Provides(Piece, Provider, Price) VALUES(4,'RBT',7);



--------------------------------------------------------------------------------------------------------------------------------------------
                                        -- OUERIES IN PROJECT 5

-- 5.1 Select the name of all the pieces. 

                                 select name
                                 from pieces;
-- 5.2  Select all the providers' data. 
                           select *
                           from providers;
                           
-- 5.3 Obtain the average price of each piece (show only the piece code and the average price).
					
                    select piece,avg(price)
                    from provides
                    group by piece;



-- 5.4  Obtain the names of all providers who supply piece 1.
                  select p.name,pp.piece
                  from providers as p join provides as pp
                  on pp.provider=p.code
                  where piece=1;


-- 5.5 Select the name of pieces provided by provider with code "HAL".
                 
                     select p.name,pp.provider
                     from pieces as p join provides as pp
                     on p.code =pp.piece
                     where provider='hal';
                     

-- 5.6
-- ---------------------------------------------
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Interesting and important one.
-- For each piece, find the most expensive offering of that piece and include the piece name, provider name, and price 
-- (note that there could be two providers who supply the same piece at the most expensive price).
                      
                     select provides.piece,pieces.name as piecename,providers.name as provider_name,provides.price as max_price
                     from pieces join provides
                     on pieces.code=provides.piece
                     join providers 
                     on provides.provider=providers.code
                     where price in (select max(price)
                                     from provides
                                     group by piece);
-- ---------------------------------------------
-- 5.7 Add an entry to the database to indicate that "Skellington Supplies" (code "TNBC") will provide sprockets (code "1") for 7 cents each.
		
                                insert into provides 
                                values(1,'TNBC',7);
-- 5.8 Increase all prices by one cent.
          update provides
          set price=price+1
          where piece in(1,2,3,4);
-- 5.9 Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply bolts (code 4).
          select * from providers;
                     
                          delete from provides
                          where piece=4 and provider='rbt';
                               
-- 5.10 Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply any pieces 
    -- (the provider should still remain in the database).

                 delete from provides
                          where  provider='rbt';