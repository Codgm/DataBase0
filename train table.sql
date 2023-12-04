USE train;

DROP TABLE IF EXISTS Refund;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS Service_Payment;
drop table IF EXISTS Payment;
drop table IF EXISTS PointPay;
drop table IF EXISTS CargoPayment;
drop table IF EXISTS DetailedRoute;
drop table IF EXISTS Seat;
drop table IF EXISTS Passenger;
drop table IF EXISTS Route;
drop table IF EXISTS Fare;
drop table IF EXISTS Promotion;
drop table IF EXISTS Service;
drop table IF EXISTS Cargo;
drop table IF EXISTS CargoCustomer;

DROP TABLE IF EXISTS ActualOperation;
DROP TABLE IF EXISTS LostItems;
DROP TABLE IF EXISTS AccidentInfo;
DROP TABLE IF EXISTS Station;
DROP TABLE IF EXISTS AttendanceRecord;
DROP TABLE IF EXISTS CustomerConsultationRecord;
DROP TABLE IF EXISTS WorkSchedule;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Timetable;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS product_info;
DROP TABLE IF EXISTS vending_payment;
DROP TABLE IF EXISTS vending_machine;
DROP TABLE IF EXISTS maintenance_record;
DROP TABLE IF EXISTS maintenance;
drop table IF EXISTS Train;
DROP TABLE IF EXISTS Service_Type;

CREATE TABLE IF NOT EXISTS `train`.`Route` (
  `RouteID` INT NOT NULL,
  PRIMARY KEY (`RouteID`)
);

CREATE TABLE IF NOT EXISTS `train`.`DetailedRoute` (
  `RouteID` INT NOT NULL,
  `RouteNum` INT NOT NULL,
  `Start` INT NOT NULL,
  `End` INT NOT NULL,
  PRIMARY KEY (`RouteID`, `RouteNum`),
  FOREIGN KEY (`RouteID`) REFERENCES `train`.`Route` (`RouteID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Fare` (
  `FareID` INT NOT NULL,
  `ServiceID` INT NOT NULL,
  `Fare` INT NOT NULL,
  PRIMARY KEY (`FareID`)
);

CREATE TABLE IF NOT EXISTS `train`.`Promotion` (
  `PromotionID` INT NOT NULL,
  PRIMARY KEY (`PromotionID`)
);

CREATE TABLE IF NOT EXISTS `train`.`Train` (
  `TrainID` INT NOT NULL,
  PRIMARY KEY (`TrainID`)
);

CREATE TABLE IF NOT EXISTS `train`.`Timetable` (
  `TimeID` INT NOT NULL,
  train_id INT,
  departure_time TIME,
  arrival_time TIME,
  operating_day DATE,
  PRIMARY KEY (`TimeID`),
  FOREIGN KEY (train_id) REFERENCES `train`.`Train`(`TrainID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `train`.`Seat` (
  `TrainID` INT NOT NULL,
  `CarriageNum` INT NOT NULL,
  `SeatNum` INT NOT NULL,
  `TimeID` INT NOT NULL,
  PRIMARY KEY (`TrainID`, `CarriageNum`, `SeatNum`, `TimeID`),
  FOREIGN KEY (`TrainID`) REFERENCES `train`.`Train` (`TrainID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`TimeID`) REFERENCES `train`.`Timetable` (`TimeID`) 
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Passenger` (
  `PassengerID` INT NOT NULL,
  Name VARCHAR(255) NOT NULL,
  PRIMARY KEY (`PassengerID`)
);

CREATE TABLE IF NOT EXISTS `train`.`PointPay` (
  `PointPaymentID` INT NOT NULL AUTO_INCREMENT,
  `PassengerID` INT NOT NULL,
  `PointsBefore` INT NOT NULL,
  `PointsAfter` INT NOT NULL,
  `PointsUsed` INT NOT NULL,
  PRIMARY KEY (`PointPaymentID`),
  FOREIGN KEY (`PassengerID`) REFERENCES `train`.`Passenger` (`PassengerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Payment` (
  `PaymentID` INT NOT NULL AUTO_INCREMENT,
  `TrainID` INT NOT NULL,
  `CarriageNum` INT NOT NULL,
  `SeatNum` INT NOT NULL,
  `TimeID` INT NOT NULL,
  `PassengerID` INT NOT NULL,
  `RouteID` INT NOT NULL,
  `FareID` INT NOT NULL,
  `PromotionID` INT,
  `PointPaymentID` INT,
  `Refunded` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`PaymentID`),
  FOREIGN KEY (`TrainID`, `CarriageNum`, `SeatNum`, `TimeID`) REFERENCES `train`.`Seat` (`TrainID`, `CarriageNum`, `SeatNum`, `TimeID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`PassengerID`) REFERENCES `train`.`Passenger` (`PassengerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`RouteID`) REFERENCES `train`.`Route` (`RouteID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`FareID`) REFERENCES `train`.`Fare` (`FareID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`PromotionID`) REFERENCES `train`.`Promotion` (`PromotionID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  FOREIGN KEY (`PointPaymentID`) REFERENCES `train`.`PointPay` (`PointPaymentID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`CargoCustomer` (
  `CustomerID` INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`CustomerID`)
);

CREATE TABLE IF NOT EXISTS `train`.`Cargo` (
  `CargoID` INT NOT NULL AUTO_INCREMENT,
  `CargoType` INT NOT NULL,
  `CargoWeight` INT NOT NULL,
  PRIMARY KEY (`CargoID`)
);

CREATE TABLE IF NOT EXISTS `train`.`CargoPayment` (
  `CargoPaymentID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `CargoID` INT NOT NULL,
  `RouteID` INT NOT NULL,
  `PaymentAmount` DECIMAL(10, 2) NOT NULL,
  `PaymentDate` DATE NOT NULL,
  `IsRefunded` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`CargoPaymentID`),
  FOREIGN KEY (`CustomerID`) REFERENCES `train`.`CargoCustomer` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`CargoID`) REFERENCES `train`.`Cargo` (`CargoID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`RouteID`) REFERENCES `train`.`Route` (`RouteID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Station (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(255) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Facilities Text,
    PlatformCount INT
    
);

CREATE TABLE IF NOT EXISTS ActualOperation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    TimetableID INT,
    DepartureStationID INT,
    ArrivalStationID INT,
    DepartureTime DATETIME,
    ArrivalTime DATETIME,
    Changes TEXT,
    
    FOREIGN KEY (TimetableID) REFERENCES Timetable(`TimeID`),
    FOREIGN KEY (DepartureStationID) REFERENCES Station(StationID),
    FOREIGN KEY (ArrivalStationID) REFERENCES Station(StationID)
);




CREATE TABLE IF NOT EXISTS LostItems (
    id INT PRIMARY KEY AUTO_INCREMENT,
    OwnerName VARCHAR(255) ,
    ItemInfo TEXT,
    DateInfo DATE,
    FoundLocation INT,
    ProcessingStatus VARCHAR(50),
    
    FOREIGN KEY (FoundLocation) REFERENCES Station(StationID)
);


CREATE TABLE IF NOT EXISTS AccidentInfo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    StationID INT,
    AccidentTime DATETIME,
    Weather VARCHAR(255),
    AccidentType VARCHAR(255),
    InjuredCount INT,
    ActionTaken TEXT,
    
    FOREIGN KEY (StationID) REFERENCES Station(StationID)
);

CREATE TABLE IF NOT EXISTS Employee (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ReferenceID INT,
    WorkScheduleID INT,
    EmployeeName VARCHAR(255) NOT NULL,
    Salary INT,
    Position VARCHAR(255),
    ContactNumber VARCHAR(20),
    HireDate DATE,
    EmployeeInfo TEXT
);

CREATE TABLE IF NOT EXISTS WorkSchedule (
    id INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    ScheduleID INT,
    WorkType VARCHAR(255),
    WorkDescription TEXT,
    WorkStatus VARCHAR(50),
    
    FOREIGN KEY (ScheduleID) REFERENCES `TimeTable`(`TimeID`),
    FOREIGN KEY (EmployeeID) REFERENCES `Employee`(id)
);


CREATE TABLE IF NOT EXISTS AttendanceRecord (
    id INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    AttendanceDateTime DATETIME,
    AttendanceStatus VARCHAR(50),
    AttendanceLocation VARCHAR(255),
    
    FOREIGN KEY (EmployeeID) REFERENCES Employee(id)
);


CREATE TABLE IF NOT EXISTS CustomerConsultationRecord (
    id INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    CustomerName VARCHAR(255) NOT NULL,
    ConsultationDate DATE,
    ConsultationType VARCHAR(255),
    ConsultationContent TEXT,
    ProcessingStatus VARCHAR(50),
    
    FOREIGN KEY (EmployeeID) REFERENCES Employee(id)
);

                    
CREATE TABLE IF NOT EXISTS `train`.`Refund` (
refund_id INT PRIMARY KEY AUTO_INCREMENT,
`PaymentID` INT NOT NULL,
FOREIGN KEY (`PaymentID`) REFERENCES `train`.`Payment`(`PaymentID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Service_Type` (
  `ServiceID` INT NOT NULL,
  `Service_type` INT NOT NULL,
  `Service_cost` INT NOT NULL,
  PRIMARY KEY (`ServiceID`, `Service_type`)
);

CREATE TABLE IF NOT EXISTS `train`.`Service_Payment` (
  `PaymentID` INT NOT NULL,
  `ServiceID` INT NOT NULL,
  PRIMARY KEY (`PaymentID`,`ServiceID`),
  FOREIGN KEY (`PaymentID`) REFERENCES `train`.`Payment`(`PaymentID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`ServiceID`) REFERENCES `train`.`Service_Type`(`ServiceID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`vending_machine` (
  `Vending_Machine_ID` INT NOT NULL,
  `Install_Date` DATE NOT NULL,
  `Install_Location` VARCHAR(45) NOT NULL,
  `management_company_name` VARCHAR(45) NOT NULL,
  `manager` VARCHAR(45) NOT NULL,
  `TrainID` INT NOT NULL,
  PRIMARY KEY (`Vending_Machine_ID`),
  FOREIGN KEY (`TrainID`)
  REFERENCES `train`.`Train` (`TrainID`)
  );
  
  CREATE TABLE IF NOT EXISTS `train`.`Vending_payment` (
  `Payment_ID` INT NOT NULL,
  `Payment_Date` DATE NOT NULL,
  `Payment_method` VARCHAR(45) NOT NULL,
  `Product_ID` INT NOT NULL,
  `Price` INT NOT NULL,
  `Vending_machine_ID` INT NOT NULL,  
  PRIMARY KEY (`Payment_ID`),
  FOREIGN KEY (`Vending_machine_ID`) 
  REFERENCES `train`.`Vending_Machine`(`Vending_machine_ID`)
  );
  
CREATE TABLE IF NOT EXISTS `train`.`product_info` (
  `Product_ID` INT NOT NULL,
  `Product_Name` VARCHAR(45) NOT NULL,
  `Product_Price` VARCHAR(45) NOT NULL,
  `expiration_date` DATE NOT NULL,
  PRIMARY KEY (`Product_ID`)
);

CREATE TABLE IF NOT EXISTS `train`.`stock` (
  `Stock_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `Receiving_date` DATE NOT NULL,
  `Vending_machine_ID` INT NOT NULL,
  `Product_ID` INT NOT NULL,
  PRIMARY KEY (`Stock_id`),
  FOREIGN KEY (`Vending_Machine_ID`)
  REFERENCES `train`.`Vending_Machine` (`Vending_Machine_ID`),
  FOREIGN KEY (`Product_ID`) 
  REFERENCES `train`.`Product_Info` (`Product_ID`)
);

CREATE TABLE IF NOT EXISTS `train`.`maintenance` (
  `Maintenance_ID` INT NOT NULL,
  `mechanic_ID` VARCHAR(45) NOT NULL,
  `TrainID` INT NOT NULL,
  FOREIGN KEY (`TrainID`)
  REFERENCES `train`.`Train` (`TrainID`),
  PRIMARY KEY (`Maintenance_ID`, `mechanic_ID`)
  );

CREATE TABLE IF NOT EXISTS `train`.`maintenance_record` (
  `Maintenance_ID` INT,
  `Maintenance_Record` VARCHAR(45) NOT NULL,
  `Maintenance_Datetime` DATE NOT NULL,
   FOREIGN KEY (`Maintenance_ID`)
    REFERENCES `train`.`maintenance` (`Maintenance_ID`)
  );

  CREATE TABLE IF NOT EXISTS `train`.`feedback` (
  `Feedback_ID` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Date` DATETIME NOT NULL,
  `Feedback_contents` LONGTEXT NOT NULL,
  `TrainID` INT NOT NULL,
  FOREIGN KEY (`TrainID`)
  REFERENCES `train`.`Train` (`TrainID`),
  PRIMARY KEY (`Feedback_ID`)
  );

#drop table employees;
