-- phpMyAdmin SQL Dump
-- version 4.7.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Nov 12, 2017 at 10:32 PM
-- Server version: 5.6.35
-- PHP Version: 7.1.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ecommerce`
--

-- --------------------------------------------------------

--
-- Table structure for table `card_details`
--

CREATE TABLE `card_details` (
  `transaction_id` int(11) DEFAULT NULL,
  `card_type` varchar(10) DEFAULT NULL,
  `card_number` varchar(16) DEFAULT NULL,
  `cvv` varchar(3) DEFAULT NULL,
  `exp_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `card_details`
--

INSERT INTO `card_details` (`transaction_id`, `card_type`, `card_number`, `cvv`, `exp_date`) VALUES
(1, 'Credit', '1234123456782345', '120', '2018-11-28');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `item_id` int(11) NOT NULL DEFAULT '0',
  `product_id` int(11) NOT NULL,
  `colour` varchar(10) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`item_id`, `product_id`, `colour`, `price`, `quantity`) VALUES
(1, 1, 'Grey', 700, 10),
(2, 1, 'Black', 750, 5),
(3, 1, 'Rose Gold', 800, 5),
(4, 2, 'Gold', 500, 10),
(5, 2, 'Space Grey', 550, 10);

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `order_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `order_details`
--

INSERT INTO `order_details` (`order_id`, `item_id`, `price`) VALUES
(1, 1, 700),
(1, 4, 500);

-- --------------------------------------------------------

--
-- Table structure for table `order_list`
--

CREATE TABLE `order_list` (
  `order_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `total_cost` float DEFAULT NULL,
  `order_status` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `order_list`
--

INSERT INTO `order_list` (`order_id`, `user_id`, `order_date`, `total_cost`, `order_status`) VALUES
(1, 2, '2017-11-13', 1200, 'Dispatched');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `transaction_id` int(11) NOT NULL DEFAULT '0',
  `order_id` int(11) DEFAULT NULL,
  `payment_mode` varchar(15) DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `total_amount` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`transaction_id`, `order_id`, `payment_mode`, `discount`, `total_amount`) VALUES
(1, 1, 'Cash', 0, 1200);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `product_id` int(11) NOT NULL DEFAULT '0',
  `product_name` varchar(20) NOT NULL,
  `supplier` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`product_id`, `product_name`, `supplier`) VALUES
(1, 'MacBook', 'Apple'),
(2, 'iPhone', 'Apple'),
(3, 'iPad', 'Apple'),
(4, 'Apple Air Pods', 'Apple'),
(5, 'Apple Watch', 'Apple');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `user_type` varchar(20) NOT NULL,
  `name` varchar(25) NOT NULL,
  `email` varchar(20) NOT NULL,
  `passwrd` varchar(15) NOT NULL,
  `birth_date` date NOT NULL,
  `address` varchar(40) NOT NULL,
  `phone_number` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `user_type`, `name`, `email`, `passwrd`, `birth_date`, `address`, `phone_number`) VALUES
(1, 'Inventory Manager', 'Shivani', 'syd@gmail.com', 'shivani', '1996-03-07', '9 Ramnagar, Ramnagar colony Bavdhan', '9673957569'),
(2, 'User', 'Antariksh', 'antarikshm@gmail.com', 'antariksh', '1994-04-28', 'Behind McDs, Kothrud Pune', '8668283075'),
(3, 'User', 'Oshine', 'osh.dsa@gmail.com', 'oshine', '1994-10-20', 'VNIT girls hostel, Nagpur', '1234567891'),
(4, 'User', 'Acksharaa', 'acku@gmail.com', 'acksharaa', '1994-09-13', 'Cinnamon gardens, Sri Lanka', '3344556677'),
(5, 'User', 'Catherine', 'cathy@gmail.com', 'catherine', '1995-05-28', 'Magarpatta, Pune', '1122334455');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `card_details`
--
ALTER TABLE `card_details`
  ADD KEY `transaction_id` (`transaction_id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `p_id` (`product_id`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD KEY `order_id` (`order_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `order_list`
--
ALTER TABLE `order_list`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `u_id` (`user_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `card_details`
--
ALTER TABLE `card_details`
  ADD CONSTRAINT `card_details_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `payment` (`transaction_id`);

--
-- Constraints for table `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`);

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order_list` (`order_id`),
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);

--
-- Constraints for table `order_list`
--
ALTER TABLE `order_list`
  ADD CONSTRAINT `order_list_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order_list` (`order_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
