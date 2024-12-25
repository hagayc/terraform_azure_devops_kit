USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RestaurantDB')
BEGIN
    CREATE DATABASE RestaurantDB;
END;
GO

USE RestaurantDB;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='restaurants' AND xtype='U')
BEGIN
    CREATE TABLE restaurants (
        id INT PRIMARY KEY IDENTITY(1,1),
        name NVARCHAR(100),
        style NVARCHAR(50),
        address NVARCHAR(200),
        open_hour TIME,
        close_hour TIME,
        vegetarian BIT
    );

    CREATE TABLE request_logs (
        id INT PRIMARY KEY IDENTITY(1,1),
        request_time DATETIME DEFAULT GETUTCDATE(),
        request_params NVARCHAR(500),
        response_data NVARCHAR(500)
    );

    -- Insert sample data into restaurants table
    INSERT INTO restaurants (name, style, address, open_hour, close_hour, vegetarian)
    VALUES 
        ('Pizza Hut', 'Italian', 'wherever street 99, somewhere', '09:00', '23:00', 0),
        ('Vegan Delight', 'Italian', '123 Green St', '11:00', '22:00', 1),
        ('Seoul Kitchen', 'Korean', '456 Asian Ave', '10:00', '21:00', 0),
        ('Le Petit Bistro', 'French', '789 Europe Blvd', '12:00', '23:00', 0),
        ('Curry Palace', 'Indian', '21 Spice Lane', '11:00', '22:30', 0),
        ('Burger Town', 'American', '88 Fastfood Way', '08:00', '00:00', 0),
        ('Green Bowl', 'Vegetarian', '102 Healthy Rd', '10:00', '20:00', 1),
        ('Sushi World', 'Japanese', '77 Sushi St', '11:30', '22:00', 0),
        ('Taco Fiesta', 'Mexican', '15 Fiesta Ave', '09:30', '21:00', 0),
        ('Pasta Lovers', 'Italian', '44 Gourmet St', '10:00', '23:00', 1),
        ('Pizza Place', 'Italian', '50 Pepperoni Ave', '10:00', '22:00', 0),
        ('Vegan Haven', 'Vegetarian', '99 Plant-Based Rd', '09:00', '21:00', 1),
        ('BBQ Smokehouse', 'American', '101 Grill Ln', '12:00', '23:00', 0),
        ('Dim Sum Palace', 'Chinese', '555 Dragon Blvd', '11:00', '22:00', 0),
        ('Mediterranean Magic', 'Mediterranean', '24 Olive St', '10:00', '22:30', 0),
        ('Spicy Corner', 'Indian', '85 Curry Ave', '11:30', '23:00', 1),
        ('Fast Taco', 'Mexican', '18 Quick St', '09:00', '20:00', 0),
        ('Zen Garden', 'Japanese', '22 Sakura Lane', '11:30', '22:30', 0),
        ('French Connection', 'French', '700 Paris Rd', '12:00', '23:00', 0);

    -- Insert sample data into request_logs table
    INSERT INTO request_logs (request_params, response_data)
    VALUES
        ('{"endpoint": "/restaurants", "query": "?style=Italian"}', '{"count":3,"results":["Pizza Hut","Vegan Delight","Pasta Lovers"]}'),
        ('{"endpoint": "/restaurants", "query": "?vegetarian=true"}', '{"count":2,"results":["Vegan Delight","Green Bowl"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Korean"}', '{"count":1,"results":["Seoul Kitchen"]}'),
        ('{"endpoint": "/restaurants", "query": "?open_now=true"}', '{"count":5,"results":["Pizza Hut","Seoul Kitchen","Le Petit Bistro","Curry Palace","Burger Town"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=French"}', '{"count":1,"results":["Le Petit Bistro"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Japanese"}', '{"count":1,"results":["Sushi World"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Mexican"}', '{"count":1,"results":["Taco Fiesta"]}'),
        ('{"endpoint": "/restaurants", "query": "?open_hour=10:00"}', '{"count":2,"results":["Seoul Kitchen","Green Bowl"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Italian"}', '{"count":4,"results":["Pizza Hut","Pizza Place","Vegan Delight","Pasta Lovers"]}'),
        ('{"endpoint": "/restaurants", "query": "?vegetarian=true"}', '{"count":2,"results":["Green Bowl","Vegan Haven"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Chinese"}', '{"count":1,"results":["Dim Sum Palace"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Indian"}', '{"count":2,"results":["Curry Palace","Spicy Corner"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=French"}', '{"count":2,"results":["Le Petit Bistro","French Connection"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Japanese"}', '{"count":2,"results":["Sushi World","Zen Garden"]}'),
        ('{"endpoint": "/restaurants", "query": "?style=Mexican"}', '{"count":2,"results":["Taco Fiesta","Fast Taco"]}'),
        ('{"endpoint": "/restaurants", "query": "?open_hour=09:00"}', '{"count":3,"results":["Pizza Hut","Fast Taco","Vegan Haven"]}');
END;
GO


