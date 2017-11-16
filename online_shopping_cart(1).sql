-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 16, 2017 at 03:26 PM
-- Server version: 10.1.28-MariaDB
-- PHP Version: 7.1.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `online_shopping_cart`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `calculate_checkout_cost` ()  BEGIN
DECLARE o_id INT;
DECLARE discount decimal(10,2);
DECLARE done bool;
DECLARE final_cost decimal(10,2);
DECLARE order_cost decimal(10,2);
DECLARE cur1 CURSOR FOR
	SELECT order_id,discount_coupon FROM payments;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;
OPEN cur1;
loop1: LOOP
	FETCH NEXT FROM cur1 INTO o_id,discount;
    IF done THEN
    	LEAVE loop1;
    END IF;
    SET order_cost = (SELECT orders.final_cost FROM orders WHERE id=o_id);
    SET final_cost = (order_cost - discount);
    UPDATE payments SET payments.checkout_cost = final_cost WHERE payments.order_id=o_id;
END LOOP loop1;
CLOSE cur1;
SELECT * FROM payments;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calculate_order_cost` ()  BEGIN
DECLARE orderID int;
DECLARE userID int;
DECLARE uid int;
DECLARE vid int;
DECLARE pid int;
DECLARE done bool;
DECLARE product_cost decimal(10,2);
DECLARE cur1 CURSOR FOR 
	SELECT id,user_id FROM orders;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cur1;
loop1: LOOP
			 FETCH NEXT FROM cur1 INTO orderID,userID;
               IF done THEN
        			LEAVE loop1;
               END IF;
             SET product_cost = (SELECT SUM(oh.product_quantity * v.price) FROM order_history oh,variants v WHERE oh.variant_id = v.id AND oh.user_id = userID);
            UPDATE orders o SET o.final_cost =  product_cost WHERE o.id=orderID;
            SELECT * FROM orders;
END LOOP loop1;
CLOSE cur1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clear_cart` ()  BEGIN
DECLARE u_id INT;
DECLARE v_id INT;
DECLARE p_id INT;
DECLARE p_qty INT;
DECLARE o_id INT;
DECLARE done bool;
DECLARE cur1 CURSOR FOR
	SELECT user_id,variant_id,product_id,product_quantity,order_id FROM carts;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cur1;
loop1: LOOP
		FETCH NEXT FROM cur1 INTO u_id,v_id,p_id,p_qty,o_id;
        IF done THEN 
        	LEAVE loop1;
        END IF;
        INSERT INTO order_history(user_id,variant_id,product_id,product_quantity,order_id) VALUES (u_id,v_id,p_id,p_qty,o_id);
END LOOP loop1;
DELETE FROM carts;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_into_payments` (IN `p_id` INT, IN `o_id` INT, IN `payment_method` VARCHAR(20), IN `discount` DECIMAL(10,2), IN `total_cost` DECIMAL(10,2), IN `pay_date` DATE, IN `pay_status` VARCHAR(10))  BEGIN
DECLARE roll_back bool DEFAULT false;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET roll_back =  true;
START TRANSACTION;
INSERT INTO payments(id,order_id,payment_type,discount_coupon,checkout_cost,payment_date,payment_status) VALUES (p_id,o_id,payment_method,discount,total_cost,pay_date,pay_status);
IF roll_back THEN
	ROLLBACK;
ELSE
	COMMIT;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `online_shopping_cart` (IN `uid` INT)  BEGIN
DECLARE order_cost decimal(10,2);
DECLARE discount decimal(10,2);
DECLARE final_cost decimal(10,2);
DECLARE stock1 INT;
DECLARE quantity INT;
DECLARE vid INT;
DECLARE u_id INT;
DECLARE v_id INT;
DECLARE p_id INT;
DECLARE p_qty INT;
DECLARE o_id INT;
DECLARE done BOOL;
DECLARE cur1 CURSOR FOR SELECT id FROM variants;
DECLARE cur2 CURSOR FOR
	SELECT user_id,variant_id,product_id,product_quantity,order_id FROM carts;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;
start transaction;
OPEN cur1;
loop1: LOOP
	FETCH NEXT FROM cur1 INTO vid;
	IF done THEN
		LEAVE loop1;
	END IF;
	SET stock1 = (SELECT v.stock FROM variants v,carts c, orders o WHERE o.user_id=uid AND o.id=c.order_id AND c.variant_id = v.id AND v.id=vid);
	SET quantity = (SELECT c.product_quantity FROM carts c,orders o WHERE c.user_id=uid AND c.variant_id=vid AND c.order_id=o.id);
	IF quantity>stock1 THEN
		ROLLBACK;
	ELSE
		UPDATE variants v,carts c,orders o SET v.stock = (stock1 - quantity) WHERE o.user_id=uid AND o.id=c.order_id AND c.variant_id = v.id AND v.id=vid;
	END IF;
END LOOP loop1;
CLOSE cur1;
SET done = FALSE;
SET order_cost=(SELECT SUM(v.price * c.product_quantity) FROM variants v,carts c WHERE c.user_id=uid AND v.id=c.variant_id);
UPDATE orders SET orders.final_cost = order_cost WHERE orders.user_id=uid;

SET discount = (SELECT p.discount_coupon FROM payments p WHERE p.id=uid);
SET final_cost = (order_cost - discount);
UPDATE payments,orders SET payments.checkout_cost = final_cost WHERE payments.order_id=orders.id AND orders.user_id=uid;

OPEN cur2;
loop2: LOOP
		FETCH NEXT FROM cur2 INTO u_id,v_id,p_id,p_qty,o_id;
        SELECT u_id;
        IF done THEN 
      		SELECT done;
        	LEAVE loop2;
        END IF;
        INSERT INTO order_history(user_id,variant_id,product_id,product_quantity,order_id) VALUES (u_id,v_id,p_id,p_qty,o_id);
        SELECT user_id FROM order_history;
END LOOP loop2;
CLOSE cur2;
DELETE FROM carts;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `test1` (IN `uid` INT)  BEGIN
DECLARE order_cost decimal(10,2);
DECLARE discount decimal(10,2);
DECLARE final_cost decimal(10,2);
DECLARE stock1 INT;
DECLARE quantity INT;
DECLARE vid INT;
DECLARE done BOOL;
DECLARE cur1 CURSOR FOR SELECT id FROM variants;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;
start transaction;
OPEN cur1;
loop1: LOOP
	FETCH NEXT FROM cur1 INTO vid;
	IF done THEN
		LEAVE loop1;
	END IF;
	SET stock1 = (SELECT v.stock FROM variants v,carts c, orders o WHERE o.user_id=uid AND o.id=c.order_id AND c.variant_id = v.id AND v.id=vid);
	SET quantity = (SELECT c.product_quantity FROM carts c,orders o WHERE c.user_id=uid AND c.variant_id=vid AND c.order_id=o.id);
	IF quantity>stock1 THEN
		ROLLBACK;
	ELSE
		UPDATE variants v,carts c,orders o SET v.stock = (stock1 - quantity) WHERE o.user_id=uid AND o.id=c.order_id AND c.variant_id = v.id AND v.id=vid;
	END IF;
END LOOP loop1;
CLOSE cur1;
SET order_cost=(SELECT SUM(v.price * c.product_quantity) FROM variants v,carts c WHERE c.user_id=uid AND v.id=c.variant_id);
UPDATE orders SET orders.final_cost = order_cost WHERE orders.user_id=uid;

SET discount = (SELECT p.discount_coupon FROM payments p WHERE p.id=uid);
SET final_cost = (order_cost - discount);
UPDATE payments,orders SET payments.checkout_cost = final_cost WHERE payments.order_id=orders.id AND orders.user_id=uid;
COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--
-- Creation: Nov 14, 2017 at 05:08 AM
--

CREATE TABLE `carts` (
  `user_id` int(11) DEFAULT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `product_quantity` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `carts`:
--   `user_id`
--       `users` -> `id`
--   `variant_id`
--       `variants` -> `id`
--   `product_id`
--       `products` -> `id`
--   `order_id`
--       `orders` -> `id`
--

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`user_id`, `variant_id`, `product_id`, `product_quantity`, `order_id`) VALUES
(1, 1, 1, 3, 1),
(1, 3, 2, 2, 1),
(2, 4, 2, 2, 2);

-- --------------------------------------------------------

--
-- Stand-in structure for view `monthly_report`
-- (See below for the actual view)
--
CREATE TABLE `monthly_report` (
`id` int(11)
,`order_date` date
,`product_name` varchar(20)
,`price` decimal(10,2)
,`total_item_price` decimal(20,2)
,`final_cost` decimal(10,2)
,`user_name` varchar(25)
,`email` varchar(25)
);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--
-- Creation: Nov 14, 2017 at 05:08 AM
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `order_status` varchar(10) DEFAULT NULL,
  `final_cost` decimal(10,2) DEFAULT NULL,
  `shipping_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `orders`:
--   `user_id`
--       `users` -> `id`
--

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `order_date`, `order_status`, `final_cost`, `shipping_date`) VALUES
(1, 1, '2017-11-14', 'Placed', '95.00', '2017-11-28'),
(2, 2, '2017-11-14', 'Placed', '70.00', '2017-11-29');

-- --------------------------------------------------------

--
-- Stand-in structure for view `order_details`
-- (See below for the actual view)
--
CREATE TABLE `order_details` (
`id` int(11)
,`final_cost` decimal(10,2)
,`order_date` date
,`discount_coupon` decimal(10,2)
,`payment_type` varchar(20)
,`payment_status` varchar(10)
);

-- --------------------------------------------------------

--
-- Table structure for table `order_history`
--
-- Creation: Nov 14, 2017 at 05:08 AM
--

CREATE TABLE `order_history` (
  `user_id` int(11) DEFAULT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `product_quantity` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `order_history`:
--   `user_id`
--       `users` -> `id`
--   `variant_id`
--       `variants` -> `id`
--   `product_id`
--       `products` -> `id`
--   `order_id`
--       `orders` -> `id`
--

--
-- Dumping data for table `order_history`
--

INSERT INTO `order_history` (`user_id`, `variant_id`, `product_id`, `product_quantity`, `order_id`) VALUES
(1, 1, 1, 3, 1),
(1, 3, 2, 2, 1),
(2, 4, 2, 2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--
-- Creation: Nov 16, 2017 at 08:50 AM
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `payment_type` varchar(20) DEFAULT NULL,
  `discount_coupon` decimal(10,2) DEFAULT NULL,
  `checkout_cost` decimal(10,2) DEFAULT '0.00',
  `payment_date` date DEFAULT NULL,
  `payment_status` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `payments`:
--   `order_id`
--       `orders` -> `id`
--

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `order_id`, `payment_type`, `discount_coupon`, `checkout_cost`, `payment_date`, `payment_status`) VALUES
(1, 1, 'Credit Card', '25.00', '70.00', '2017-11-14', 'Success'),
(2, 2, 'Credit Card', '15.00', '55.00', '2017-11-14', 'Success');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--
-- Creation: Nov 14, 2017 at 05:08 AM
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `product_name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `products`:
--

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `product_name`) VALUES
(1, 'Pen'),
(2, 'Bottle'),
(3, 'Cup'),
(4, 'Pillow'),
(5, 'Curtains');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--
-- Creation: Nov 14, 2017 at 05:08 AM
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `role` varchar(20) DEFAULT NULL,
  `email` varchar(25) DEFAULT NULL,
  `user_name` varchar(25) DEFAULT NULL,
  `contact` varchar(10) DEFAULT NULL,
  `address` varchar(40) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `users`:
--

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role`, `email`, `user_name`, `contact`, `address`, `created`, `updated`) VALUES
(1, 'buyer', 'syd@gmail.com', 'Shivani Deo', '1234567890', '9, Ramnagar, Bavdhan ', '2017-11-13 17:28:55', '0000-00-00 00:00:00'),
(2, 'buyer', 'antariksh@gmail.com', 'Antariksh Meshram', '2233445566', 'Aundh, Baner, Pune', '2017-11-13 17:30:00', '0000-00-00 00:00:00'),
(3, 'buyer', 'indore@gmail.com', 'Aditi Mantri', '4455667788', 'Maratha Mandhir,  Bavdhan Pune', '2017-11-13 17:32:10', '0000-00-00 00:00:00'),
(4, 'inventory manager', 'madan@gmail.com', 'Madan Somvanshi', '8877665544', 'Hinjewadi, Pune', '2017-11-13 17:34:45', '0000-00-00 00:00:00'),
(5, 'buyer', 'kamal@gmail.com', 'Kamal Singh', '3322114455', 'Kothrud, Pune', '2017-11-13 17:37:33', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `variants`
--
-- Creation: Nov 14, 2017 at 05:08 AM
--

CREATE TABLE `variants` (
  `id` int(11) NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `color_name` varchar(15) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- RELATIONSHIPS FOR TABLE `variants`:
--   `product_id`
--       `products` -> `id`
--

--
-- Dumping data for table `variants`
--

INSERT INTO `variants` (`id`, `product_id`, `color_name`, `stock`, `price`) VALUES
(1, 1, 'Blue', 7, '15.00'),
(2, 1, 'Red', 10, '20.00'),
(3, 2, 'Green', 8, '25.00'),
(4, 2, 'Black', 0, '35.00'),
(5, 3, 'Pink', 10, '50.00');

-- --------------------------------------------------------

--
-- Structure for view `monthly_report`
--
DROP TABLE IF EXISTS `monthly_report`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `monthly_report`  AS  select `o1`.`id` AS `id`,`o1`.`order_date` AS `order_date`,`p`.`product_name` AS `product_name`,`v`.`price` AS `price`,(`v`.`price` * `o2`.`product_quantity`) AS `total_item_price`,`o1`.`final_cost` AS `final_cost`,`u`.`user_name` AS `user_name`,`u`.`email` AS `email` from ((((`orders` `o1` join `products` `p`) join `variants` `v`) join `users` `u`) join `order_history` `o2`) where ((`o1`.`user_id` = `u`.`id`) and (`v`.`product_id` = `p`.`id`) and (`o2`.`order_id` = `o1`.`id`) and (`v`.`id` = `o2`.`variant_id`) and ((to_days(now()) - to_days(`o1`.`order_date`)) between 0 and 30)) ;

-- --------------------------------------------------------

--
-- Structure for view `order_details`
--
DROP TABLE IF EXISTS `order_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `order_details`  AS  select `o`.`id` AS `id`,`o`.`final_cost` AS `final_cost`,`o`.`order_date` AS `order_date`,`p`.`discount_coupon` AS `discount_coupon`,`p`.`payment_type` AS `payment_type`,`p`.`payment_status` AS `payment_status` from (`orders` `o` join `payments` `p`) where (`o`.`id` = `p`.`order_id`) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `order_history`
--
ALTER TABLE `order_history`
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `variants`
--
ALTER TABLE `variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `carts_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
  ADD CONSTRAINT `carts_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `carts_ibfk_4` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `order_history`
--
ALTER TABLE `order_history`
  ADD CONSTRAINT `order_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `order_history_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
  ADD CONSTRAINT `order_history_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `order_history_ibfk_4` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `variants`
--
ALTER TABLE `variants`
  ADD CONSTRAINT `variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
