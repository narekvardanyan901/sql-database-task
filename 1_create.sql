


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




