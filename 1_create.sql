


CREATE TABLE venue (
    venueID INT IDENTITY(1,1) PRIMARY KEY,
    venueName NVARCHAR(300) NOT NULL,
    venueLocation NVARCHAR(300) NOT NULL
) ;

CREATE TABLE events (
    eventID INT IDENTITY(1,1) PRIMARY KEY ,
    eventName NVARCHAR(300) NOT NULL,
    eventDateTime DATETIME NOT NULL,
    eventDescription NVARCHAR(MAX) NOT NULL,
    venueID INT REFERENCES venue(venueID)
    
) ;

CREATE TABLE currency (
    currencyID INT IDENTITY(1,1) PRIMARY KEY,
    currencyCode VARCHAR(3)
) ;

CREATE TABLE tickets (
    ticketID INT IDENTITY(1,1) PRIMARY KEY,
    tickeType NVARCHAR(200) NOT NULL,
    ticketPrice DECIMAL NOT NULL,
    eventID INT REFERENCES events(eventID) ON DELETE CASCADE,
    currencyID int REFERENCES currency (currencyID)
) ;

CREATE TABLE attendees (
    attendeeID INT IDENTITY(1,1) PRIMARY KEY,
    attendeeName NVARCHAR(200) NOT NULL,
    attendeeContact NVARCHAR(200) NOT NULL
) ;

CREATE TABLE attendeesEvents (
    eventID INT REFERENCES events(eventID) ON DELETE CASCADE,
    attendeeID INT REFERENCES attendees(attendeeID) ON DELETE CASCADE,
    PRIMARY KEY (eventID , attendeeID)
) ;

CREATE TABLE atendeesTickets(
    attendeeID INT REFERENCES attendees(attendeeID) ON DELETE CASCADE ,
    ticketID INT REFERENCES tickets(ticketID) ON DELETE CASCADE,
    PRIMARY KEY (attendeeID , ticketID)
)

CREATE NONCLUSTERED INDEX IX_event_name ON events (eventName);

CREATE NONCLUSTERED INDEX IX_event_dateTime ON events (eventDateTime);

CREATE NONCLUSTERED INDEX IX_venue_name ON venue (venueName);


CREATE TABLE venueNameUpdateLog (
   logID int IDENTITY(1,1) PRIMARY key,
   updatedVenueID INT,
   newVenueName NVARCHAR(300),
   oldVenueName NVARCHAR(300),
   updateTime DATETIME
) ;

CREATE TABLE venueLocationUpdateLog (
   logID int IDENTITY(1,1) PRIMARY key,
   updatedVenueID INT,
   newVenueLocation NVARCHAR(300),
   oldVenueLocation NVARCHAR(300),
   updateTime DATETIME
) ; 

CREATE TABLE eventNameUpdateLog (
   logID int IDENTITY(1,1) PRIMARY key,
   updatedEventID INT,
   newEventName NVARCHAR(300),
   oldEventName  NVARCHAR(300),
   updateTime DATETIME
) ;


CREATE TABLE eventDateUpdateLog (
   logID int IDENTITY(1,1) PRIMARY key,
   updatedEventID INT,
   newEventDate DATETIME ,
   oldEventDate DATETIME ,
   updateTime DATETIME
) ;

GO

CREATE TRIGGER trgAfterVenueNameUpdate 
ON venue
AFTER UPDATE 
AS 
BEGIN
INSERT INTO venueNameUpdateLog(updatedVenueID , newVenueName , oldVenueName , updateTime)
SELECT inserted.venueID , inserted.venueName , deleted.venueName , GETDATE()
FROM inserted join deleted ON inserted.venueID = deleted.venueID
END ;

GO


CREATE TRIGGER trgAfterVenueLocationUpdate 
ON venue
AFTER UPDATE 
AS 
BEGIN
INSERT INTO venueLocationUpdateLog(updatedVenueID , newVenueLocation , oldVenueLocation , updateTime)
SELECT inserted.venueID , inserted.venueLocation , deleted.venueLocation , GETDATE()
FROM inserted join deleted ON inserted.venueID = deleted.venueID
END ;

GO


CREATE TRIGGER trgAfterEventNameUpdate
ON events
AFTER UPDATE
AS
BEGIN
INSERT INTO eventNameUpdateLog (updatedEventID,newEventName,oldEventName,updateTime)
SELECT inserted.eventID ,inserted.eventName , deleted.eventName , GETDATE()
FROM inserted join deleted ON inserted.eventID = deleted.eventID
END;

GO 

CREATE TRIGGER trgAfterEventDateUpdate
ON events
AFTER UPDATE
AS
BEGIN
INSERT INTO eventDateUpdateLog (updatedEventID,newEventDate,oldEventDate,updateTime)
SELECT inserted.eventID ,inserted.eventDateTime , deleted.eventDateTime , GETDATE()
FROM inserted join deleted ON inserted.eventID = deleted.eventID
END;


CREATE TABLE reservedVenues (
    reservationID INT IDENTITY (1,1),
    venueID INT REFERENCES venue(venueID)  ON DELETE CASCADE ,
    reservationDate DATE NOT NULL,
    PRIMARY KEY (venueID , reservationDate)

)

GO

CREATE PROCEDURE bookVenueByDate
 @venueID INT ,
 @reservationDate DATE,
 @insertedID INT OUTPUT,
 @statusCode INT OUTPUT
 AS
 BEGIN
    IF EXISTS(SELECT * FROM reservedVenues where venueID = @venueID and reservationDate = @reservationDate)
        BEGIN
        SET @statusCode = 1
        SET @insertedID = null
        END
    ELSE    
        BEGIN
        INSERT INTO reservedVenues (venueID , reservationDate)
        VALUES(@venueID,@reservationDate)
        SET @insertedID = SCOPE_IDENTITY()
        SET @statusCode = 0 
        END
 END

GO

CREATE FUNCTION freeVenuesByDate (@date date)
RETURNS TABLE 
AS
RETURN
(
    select v.venueID  , v.venueName , v.venueLocation , v.venueLevel from 
    venue as v LEFT JOIN reservedVenues as r  ON v.venueID = r.venueID AND r.reservationDate = @date WHERE r.venueID IS NULL
);

GO

ALTER TABLE venue 
ADD venueLevel int CHECK(venueLevel between 1 and 3) NOT NULL ;

CREATE TABLE eventTypes(
    eventTypeID int IDENTITY(1,1) PRIMARY KEY , 
    eventType NVARCHAR (100) NOT NULL

)

CREATE TABLE thirdLevelVenues (
    venueID INT  UNIQUE NOT NULL,
    eventTypeID INT  NOT NULL,
    FOREIGN KEY (venueID) REFERENCES venue(venueID) ON DELETE CASCADE,
    FOREIGN KEY (eventTypeID) REFERENCES eventTypes(eventTypeID) ON DELETE CASCADE

)

CREATE TABLE secondLevelVenues(
    venueID INT  NOT NULL ,
    eventTypeID INT   NOT NULL,
    PRIMARY KEY (venueID,eventTypeID),
    FOREIGN KEY (venueID) REFERENCES venue(venueID) ON DELETE CASCADE,
    FOREIGN KEY (eventTypeID) REFERENCES eventTypes(eventTypeID) ON DELETE CASCADE

)

GO

CREATE TRIGGER insertInThirdLevelVenues
ON thirdLevelVenues
INSTEAD OF INSERT 
AS
BEGIN
 INSERT INTO thirdLevelVenues (venueID , eventTypeID)
 SELECT inserted.venueID , inserted.eventTypeID FROM
 inserted join venue ON inserted.venueID = venue.venueID WHERE venue.venueLevel = 3
END

GO

CREATE TRIGGER insertInSecondLevelVenues
ON secondLevelVenues
INSTEAD OF INSERT 
AS
BEGIN
 INSERT INTO secondLevelVenues (venueID , eventTypeID)
 SELECT inserted.venueID , inserted.eventTypeID FROM
 inserted join venue ON inserted.venueID = venue.venueID WHERE venue.venueLevel = 2
END