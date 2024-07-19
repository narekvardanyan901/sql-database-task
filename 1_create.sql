


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
    venueID INT REFERENCES venue(venueId)
    
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


