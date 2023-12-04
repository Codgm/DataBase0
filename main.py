import mysql.connector
from datetime import datetime


# MySQL 연결 설정
db_connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="@Sgm700121",
    database="train"
)

# 커서 생성
db_cursor = db_connection.cursor()

def get_passenger_info():
    try:
        print("Enter passenger information:")
        name = input("Name: ")

        # Insert into Passenger table
        insert_passenger_query = """
        INSERT INTO Passenger (Name) VALUES (%s)
        """
        db_cursor.execute(insert_passenger_query, (name,))
        db_connection.commit()

        print("Passenger information saved.")
        return db_cursor.lastrowid  # Return the auto-incremented PassengerID

    except Exception as e:
        db_connection.rollback()
        print(f"Error during passenger information entry: {e}")
        return None

def get_route_info():
    try:
        print("\nEnter route information:")
        start = input("Starting station: ")
        end = input("Destination station: ")

        # Query to get available routes
        get_routes_query = """
        SELECT RouteID
        FROM DetailedRoute
        WHERE Start = %s AND End = %s
        """
        db_cursor.execute(get_routes_query, (start, end))
        routes = db_cursor.fetchall()

        if not routes:
            print("No available routes found.")
            return None

        print("\nAvailable routes:")
        for route in routes:
            print(route[0])

        route_id = int(input("Choose a route (enter RouteID): "))
        return route_id

    except Exception as e:
        print(f"Error during route information entry: {e}")
        return None

def get_train_info(route_id):
    try:
        print("\nEnter travel time information:")
        date_str = input("Travel date (YYYY-MM-DD): ")
        travel_date = datetime.strptime(date_str, "%Y-%m-%d").date()

        # Query to get available trains for the selected route and date
        get_trains_query = """
        SELECT train_id, departure_time, arrival_time
        FROM Timetable
        WHERE TimeID IN (
            SELECT TimeID
            FROM Seat
            WHERE TrainID IN (
                SELECT TrainID
                FROM DetailedRoute
                WHERE RouteID = %s
            )
        ) AND operating_day = %s
        """
        db_cursor.execute(get_trains_query, (route_id, travel_date))
        trains = db_cursor.fetchall()

        if not trains:
            print("No available trains found.")
            return None

        print("\nAvailable trains:")
        for train in trains:
            print(f"TrainID: {train[0]}, Departure: {train[1]}, Arrival: {train[2]}")

        train_id = int(input("Choose a train (enter TrainID): "))
        return train_id

    except Exception as e:
        print(f"Error during train information entry: {e}")
        return None

def get_seat_info(train_id, travel_date):
    try:
        print("\nEnter seat information:")

        # Query to get available seats for the selected train and date
        get_seats_query = """
        SELECT CarriageNum, SeatNum
        FROM Seat
        WHERE TrainID = %s AND TimeID IN (
            SELECT TimeID
            FROM Timetable
            WHERE operating_day = %s
        ) 
        """
        db_cursor.execute(get_seats_query, (train_id, travel_date))
        seats = db_cursor.fetchall()

        if not seats:
            print("No available seats found.")
            return None

        print("\nAvailable seats:")
        for seat in seats:
            print(f"CarriageNum: {seat[0]}, SeatNum: {seat[1]}")

        carriage_num = int(input("Choose a carriage (enter CarriageNum): "))
        seat_num = int(input("Choose a seat (enter SeatNum): "))
        return carriage_num, seat_num
    except Exception as e:
        print(f"Error during seat information entry: {e}")
        return None, None


def get_service_info():
    try:
        print("\nEnter service information:")

        # Query to get available services
        get_services_query = """
        SELECT ServiceID, Service_type, Service_cost
        FROM Service_Type
        """
        db_cursor.execute(get_services_query)
        services = db_cursor.fetchall()

        if not services:
            print("No available services found.")
            return None

        print("\nAvailable services:")
        for service in services:
            print(f"ServiceID: {service[0]}, Type: {service[1]}, Cost: {service[2]}")

        service_id = int(input("Choose a service (enter ServiceID) or enter 0 to skip: "))
        return service_id
    except Exception as e:
        print(f"Error during service information entry: {e}")
        return None

def get_feedback_info():
    try:
        print("\nEnter feedback information:")
        name = input("Your Name: ")
        feedback_contents = input("Feedback contents: ")
        date_str = input("Date (YYYY-MM-DD HH:mm:ss): ")
        feedback_date = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")

        # Get available trains for feedback
        get_trains_query = """
        SELECT TrainID
        FROM Train
        """
        db_cursor.execute(get_trains_query)
        trains = db_cursor.fetchall()

        if not trains:
            print("No available trains found.")
            return None

        print("\nAvailable trains for feedback:")
        for train in trains:
            print(train[0])

        train_id = int(input("Choose a train (enter TrainID): "))

        # Insert into feedback table
        insert_feedback_query = """
        INSERT INTO feedback (Feedback_ID, Name, Date, Feedback_contents, TrainID) VALUES (%s, %s, %s, %s, %s)
        """
        db_cursor.execute(insert_feedback_query, ("", name, feedback_date, feedback_contents, train_id))
        db_connection.commit()

        print("Feedback information saved.")
        return db_cursor.lastrowid

    except Exception as e:
        db_connection.rollback()
        print(f"Error during feedback information entry: {e}")
        return None

def make_payment(passenger_id, train_id, carriage_num, seat_num, time_id, route_id, fare_id, promotion_id=None,
                 point_payment_id=None, service_id=None):
    try:
        # Insert into Payment table
        insert_payment_query = """
        INSERT INTO Payment (TrainID, CarriageNum, SeatNum, TimeID, PassengerID, RouteID, FareID, PromotionID, PointPaymentID)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        payment_values = (
            train_id, carriage_num, seat_num, time_id, passenger_id, route_id, fare_id, promotion_id, point_payment_id)
        db_cursor.execute(insert_payment_query, payment_values)
        db_connection.commit()

        payment_id = db_cursor.lastrowid  # Get the auto-incremented PaymentID

        # Update Seat table to mark the seat as occupied
        update_seat_query = """
        UPDATE Seat
        WHERE TrainID = %s AND CarriageNum = %s AND SeatNum = %s AND TimeID = %s
        """
        seat_values = (train_id, carriage_num, seat_num, time_id)
        db_cursor.execute(update_seat_query, seat_values)
        db_connection.commit()

        if service_id is not None:
            # Insert into Service_Payment table
            insert_service_payment_query = """
            INSERT INTO Service_Payment (PaymentID, ServiceID)
            VALUES (%s, %s)
            """
            service_payment_values = (payment_id, service_id)
            db_cursor.execute(insert_service_payment_query, service_payment_values)
            db_connection.commit()

        print(f"Payment successful. PaymentID: {payment_id}")

        # Ask if the passenger wants to request a refund
        refund_choice = input("Do you want to request a refund? (y/n): ").lower()
        if refund_choice == 'y':
            complete_refund(payment_id)

    except Exception as e:
        db_connection.rollback()
        print(f"Error during payment: {e}")

def complete_refund(payment_id):
    try:
        # Insert into Refund table
        insert_refund_query = """
        INSERT INTO Refund (PaymentID)
        VALUES (%s)
        """
        refund_values = (payment_id,)
        db_cursor.execute(insert_refund_query, refund_values)
        db_connection.commit()

        print(f"Refund successful. PaymentID: {payment_id}")

    except Exception as e:
        db_connection.rollback()
        print(f"Error during refund: {e}")


try:
    passenger_id = int(input("Enter PassengerID: "))

    get_passenger_info()
    route_id = get_route_info()

    if route_id is not None:
        train_id = get_train_info(route_id)

        if train_id is not None:
            date_str = input("Enter travel date (YYYY-MM-DD): ")
            travel_date = datetime.strptime(date_str, "%Y-%m-%d").date()

            carriage_num, seat_num = get_seat_info(train_id, travel_date)

            if carriage_num is not None and seat_num is not None:
                # Additional information such as fare, promotion, and point payment can be added
                # For simplicity, I'm using placeholders here
                make_payment(passenger_id, train_id, carriage_num, seat_num, None, route_id, None, None, None)

                service_id = get_service_info()

                if service_id is not None:
                    # Complete the payment including the selected service
                    make_payment(passenger_id, train_id, carriage_num, seat_num, None, route_id, None, None, None,
                                 service_id)

                    # User prompted for refund
                    refund_choice = input("Do you want to request a refund? (y/n): ").lower()
                    if refund_choice == 'y':
                        payment_id = int(input("Enter PaymentID to refund: "))
                        complete_refund(payment_id)

except Exception as e:
    print(f"Error: {e}")


finally:
    # MySQL 연결 종료
    db_cursor.close()
    db_connection.close()