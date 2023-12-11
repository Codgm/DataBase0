USE train;

DROP TABLE IF EXISTS Refund;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS Service_Payment;
drop table IF EXISTS Payment;
drop table IF EXISTS PointPay;
drop table IF EXISTS CargoPayment;
drop table IF EXISTS connected_route;
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
DROP TABLE IF EXISTS ConvenienceFacility;
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

CREATE TABLE IF NOT EXISTS Station (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(255) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Facilities Text,
    PlatformCount INT

);

CREATE TABLE IF NOT EXISTS `train`.`Route` (
  `RouteID` INT NOT NULL,
  `StartID` INT NOT NULL,
  `EndID` INT NOT NULL,
  PRIMARY KEY (`RouteID`),
  FOREIGN KEY (`StartID`) REFERENCES `train`.`Station` (`StationID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`EndID`) REFERENCES `train`.`Station` (`StationID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`DetailedRoute` (
  `DetailedRouteID` INT NOT NULL AUTO_INCREMENT,
  `StartID` INT NOT NULL,
  `EndID` INT NOT NULL,
  PRIMARY KEY (`DetailedRouteID`),
  FOREIGN KEY (`StartID`) REFERENCES `train`.`Station` (`StationID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`EndID`) REFERENCES `train`.`Station` (`StationID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Connected_Route` (
  `RouteID` INT NOT NULL,
  `num` INT NOT NULL,
  `DetailedRouteID` INT NOT NULL,
  PRIMARY KEY (`RouteID`, `num`,`DetailedRouteID`),
  FOREIGN KEY (`DetailedRouteID`) REFERENCES `train`.`DetailedRoute` (`DetailedRouteID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`RouteID`) REFERENCES `train`.`Route` (`RouteID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Fare` (
  `FareID` INT NOT NULL,
  `Fare` INT NOT NULL,
  PRIMARY KEY (`FareID`)
);

CREATE TABLE IF NOT EXISTS `train`.`Promotion` (
  `PromotionID` INT NOT NULL,
  `discount` INT NOT NULL,
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
  `SeatInformation` INT NOT NULL,
  `TimeID` INT NOT NULL,
  PRIMARY KEY (`TrainID`, `CarriageNum`, `TimeID`),
  FOREIGN KEY (`TrainID`) REFERENCES `train`.`Train` (`TrainID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`TimeID`) REFERENCES `train`.`Timetable` (`TimeID`) 
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `train`.`Passenger` (
  `PassengerID` INT NOT NULL,
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
  FOREIGN KEY (`TrainID`, `CarriageNum`, `TimeID`) REFERENCES `train`.`Seat` (`TrainID`, `CarriageNum`, `TimeID`)
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
  `FareID` INT NOT NULL,
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
  FOREIGN KEY (`FareID`) REFERENCES `train`.`Fare` (`FareID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`RouteID`) REFERENCES `train`.`Route` (`RouteID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ConvenienceFacility (
   id INT PRIMARY KEY AUTO_INCREMENT,
    StationID INT,
    toilet INT,
    convenienceStore INT,
    restaurant INT,
    cafe INT,
    giftshop INT,
    ticketStore INT,
    ParkingArea INT,
    ATM INT,

    FOREIGN KEY (StationID) REFERENCES Station(StationID)
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
  PRIMARY KEY (`ServiceID`)
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

-- Station 테이블에 데이터 삽입
DELIMITER //
CREATE PROCEDURE InsertStation(IN StationName VARCHAR(255), IN Location VARCHAR(255), IN PlatformCount INT)
BEGIN
    INSERT INTO Station(StationName, Location, PlatformCount) VALUES (StationName, Location, PlatformCount);
END //
DELIMITER ;

-- DetailedRoute 테이블에 새로운 레코드가 삽입될 때마다 Connected_Route 테이블에 대응하는 레코드가 자동으로 삽입
DELIMITER //
CREATE TRIGGER AfterInsertDetailedRoute
AFTER INSERT ON DetailedRoute
FOR EACH ROW
BEGIN
    DECLARE StartStation INT;
    DECLARE EndStation INT;
    
    SELECT StartID, EndID INTO StartStation, EndStation FROM DetailedRoute WHERE DetailedRouteID = NEW.DetailedRouteID;
    
    INSERT INTO Connected_Route(RouteID, num, DetailedRouteID)
    VALUES (NEW.DetailedRouteID, 1, NEW.DetailedRouteID),
           (NEW.DetailedRouteID, 2, StartStation),
           (NEW.DetailedRouteID, 3, EndStation);
END //
DELIMITER ;

-- Promotion 및 Fare에 데이터를 삽입할 때 자동으로 할인 및 요금 정보를 적용
DELIMITER //
CREATE PROCEDURE ApplyPromotionAndFare(IN promoID INT, IN fareID INT)
BEGIN
    DECLARE discountValue INT;
    DECLARE fareValue INT;
    
    -- Promotion 테이블에서 할인율 조회
    SELECT discount INTO discountValue FROM Promotion WHERE PromotionID = promoID;
    
    -- Fare 테이블에서 기본 요금 조회
    SELECT Fare INTO fareValue FROM Fare WHERE FareID = fareID;
    
    -- 할인된 요금을 Fare 테이블에 업데이트
    UPDATE Fare SET Fare = fareValue - (fareValue * discountValue / 100) WHERE FareID = fareID;
END //
DELIMITER ;

-- 트리거 생성
DELIMITER //
CREATE TRIGGER AfterInsertPromotionAndFare
AFTER INSERT ON Promotion
FOR EACH ROW
BEGIN
    DECLARE fareID INT;
    
    -- Fare 테이블에 새로운 일반 요금 추가
    INSERT INTO Fare (Fare) VALUES (10000);
    
    -- 방금 추가된 Fare의 FareID 가져오기
    SELECT MAX(FareID) INTO fareID FROM Fare;
    
    -- 새로 추가된 Promotion과 Fare 정보를 프로시저를 통해 업데이트
    CALL ApplyPromotionAndFare(NEW.PromotionID, fareID);
END //
DELIMITER ;

-- 새로운 화물 데이터가 삽입될 때 자동으로 프로시저와 트리거를 사용하여 결제 정보를 추가
DELIMITER //
CREATE PROCEDURE CreateCargoPayment(IN cargoID INT, IN routeID INT, IN fareID INT, IN paymentAmount DECIMAL(10, 2), IN paymentDate DATE)
BEGIN
    -- 화물 결제 정보를 CargoPayment 테이블에 추가
    INSERT INTO CargoPayment (CargoID, RouteID, FareID, PaymentAmount, PaymentDate)
    VALUES (cargoID, routeID, fareID, paymentAmount, paymentDate);
    
    -- 화물 결제 정보를 Payment 테이블에 추가
    INSERT INTO Payment (CargoID, RouteID, FareID, PaymentAmount, PaymentDate)
    VALUES (cargoID, routeID, fareID, paymentAmount, paymentDate);
END //
DELIMITER ;

-- 트리거 생성
DELIMITER //
CREATE TRIGGER AfterInsertCargo
AFTER INSERT ON Cargo
FOR EACH ROW
BEGIN
    DECLARE routeID INT;
    DECLARE fareID INT;
    
    -- Cargo, Route 및 Fare 테이블에 새로운 데이터 추가
    SET routeID = 1; -- 적절한 노선 ID로 설정
    SET fareID = 1;  -- 적절한 요금 ID로 설정
    
    -- 새로 추가된 Cargo 및 관련 정보를 프로시저를 통해 결제 정보로 추가
    CALL CreateCargoPayment(NEW.CargoID, routeID, fareID, NEW.CargoWeight * NEW.CargoType, CURRENT_DATE);
END //
DELIMITER ;

-- 화물 예약 및 처리 함수
DELIMITER //
CREATE FUNCTION ReserveAndProcessCargoBulk(cargoDataList TEXT)
RETURNS INT
NO SQL
BEGIN
    DECLARE cargoID INT;
    DECLARE routeID INT;
    DECLARE fareID INT;
    DECLARE paymentAmount DECIMAL(10, 2);

    -- 임시 테이블 생성
    CREATE TEMPORARY TABLE IF NOT EXISTS TempCargoData (
        CargoType INT,
        CargoWeight INT
    );

    -- 콤마(,)를 기준으로 문자열을 분리하여 TempCargoData 테이블에 삽입
    INSERT INTO TempCargoData (CargoType, CargoWeight)
    SELECT CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(cargoDataList, ',', n.digit+1), ',', -1) AS UNSIGNED) AS CargoType,
           CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(cargoDataList, ',', n.digit+1), ',', -1) AS UNSIGNED) AS CargoWeight
    FROM generator_1_to_1000 n
    WHERE n.digit < LENGTH(cargoDataList) - LENGTH(REPLACE(cargoDataList, ',', '')) + 1;

    -- 화물 정보 삽입
    INSERT INTO Cargo (CargoType, CargoWeight)
    SELECT CargoType, CargoWeight FROM TempCargoData;

    -- 새로 추가된 화물 정보의 ID 가져오기
    SELECT LAST_INSERT_ID() INTO cargoID;

    -- 화물 운송 노선 정보 삽입 (가정: 노선은 고정 값)
    INSERT INTO Route (StartID, EndID) VALUES (1, 2);

    -- 새로 추가된 노선 정보의 ID 가져오기
    SELECT LAST_INSERT_ID() INTO routeID;

    -- 화물 요금 정보 삽입 (가정: 요금은 고정 값)
    INSERT INTO Fare (Fare) VALUES (100);

    -- 새로 추가된 요금 정보의 ID 가져오기
    SELECT LAST_INSERT_ID() INTO fareID;

    -- 화물 운송 비용 계산
    SET paymentAmount = (SELECT SUM(CargoWeight * CargoType) FROM TempCargoData);

    -- 화물 결제 정보를 CargoPayment 테이블에 추가
    INSERT INTO CargoPayment (CargoID, RouteID, FareID, PaymentAmount, PaymentDate)
    VALUES (cargoID, routeID, fareID, paymentAmount, CURRENT_DATE);

    -- 화물 결제 정보를 Payment 테이블에 추가
    INSERT INTO Payment (CargoID, RouteID, FareID, PaymentAmount, PaymentDate)
    VALUES (cargoID, routeID, fareID, paymentAmount, CURRENT_DATE);

    -- 임시 테이블 삭제
    DROP TEMPORARY TABLE IF EXISTS TempCargoData;

    -- 예약한 화물 정보의 ID 반환
    RETURN cargoID;
END //
DELIMITER ;


-- 새로운 물품 분실 정보 삽입 시 처리
DELIMITER //
CREATE PROCEDURE HandleLostItem(IN ownerName VARCHAR(255), IN itemInfo TEXT, IN dateInfo DATE, IN foundLocation INT, IN processingStatus VARCHAR(50))
BEGIN
    -- 물품 분실 정보 삽입
    INSERT INTO LostItems (OwnerName, ItemInfo, DateInfo, FoundLocation, ProcessingStatus)
    VALUES (ownerName, itemInfo, dateInfo, foundLocation, processingStatus);
END //
DELIMITER ;

--  새로운 사고 정보 삽입 시 처리
CREATE PROCEDURE HandleAccident(IN stationID INT, IN accidentTime DATETIME, IN weather VARCHAR(255), 
    IN accidentType VARCHAR(255), IN injuredCount INT, IN actionTaken TEXT)
    -- 사고 정보 삽입
    INSERT INTO AccidentInfo (StationID, AccidentTime, Weather, AccidentType, InjuredCount, ActionTaken)
    VALUES (stationID, accidentTime, weather, accidentType, injuredCount, actionTaken);
END //
DELIMITER ;

-- LostItems 테이블에 새로운 데이터가 삽입될 때 처리
DELIMITER //
CREATE TRIGGER AfterInsertLostItem
AFTER INSERT ON LostItems
FOR EACH ROW
BEGIN
    -- 새로 추가된 LostItems 데이터에 대한 처리 프로시저 호출
    CALL HandleLostItem(NEW.OwnerName, NEW.ItemInfo, NEW.DateInfo, NEW.FoundLocation, NEW.ProcessingStatus);
END //
DELIMITER ;    

-- AccidentInfo 테이블에 새로운 데이터가 삽입될 때 처리
DELIMITER //
CREATE TRIGGER AfterInsertAccident
AFTER INSERT ON AccidentInfo
FOR EACH ROW
BEGIN
    -- 새로 추가된 AccidentInfo 데이터에 대한 처리 프로시저 호출
    CALL HandleAccident(NEW.StationID, NEW.AccidentTime, NEW.Weather, NEW.AccidentType, NEW.InjuredCount, NEW.ActionTaken);
END //
DELIMITER ;

-- 환불 정보를 기록
DELIMITER //
CREATE PROCEDURE RecordRefund(IN paymentID INT)
BEGIN
    -- 환불 정보를 Refund 테이블에 추가
    INSERT INTO Refund (PaymentID) VALUES (paymentID);
END //
DELIMITER ;

-- 결제 정보를 업데이트하여 환불 여부를 나타낸다
DELIMITER //
CREATE PROCEDURE UpdatePaymentForRefund(IN paymentID INT)
BEGIN
    -- 결제 정보를 업데이트하여 환불 여부를 나타냄
    UPDATE Payment SET Refunded = TRUE WHERE PaymentID = paymentID;
END //
DELIMITER ;

-- 환불 처리 함수
DELIMITER //
CREATE FUNCTION ProcessRefund(paymentID INT) RETURNS BOOLEAN DETERMINISTIC
BEGIN
    -- 결제 정보 업데이트
    CALL UpdatePaymentForRefund(paymentID);
    
    -- 환불 정보 기록
    CALL RecordRefund(paymentID);

    -- 성공적으로 환불 처리되었음을 반환
    RETURN TRUE;
END //
DELIMITER ;
