-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 10, 2018 at 08:23 PM
-- Server version: 10.1.30-MariaDB
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `php_stock`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addnewbreadcrumb` (IN `PageTitleParent` VARCHAR(100), `PageTitle` VARCHAR(100), `PageURL` VARCHAR(100))  GoodBye: BEGIN
-- Need three parameters (PageTitleParent, PageTitle, and PageURL),
-- look at this line --> `Page_Title` = PageTitleParent);
-- look at this line --> VALUES (PageTitle, PageURL, ParentLevel, (ParentLevel + 1));
DECLARE ParentLevel INTEGER;
DECLARE RecCount INTEGER;
DECLARE CheckRecCount INTEGER;
DECLARE MyPageTitle VARCHAR(100);
  
SET ParentLevel = (SELECT Rgt FROM `breadcrumblinks` WHERE
`Page_Title` = PageTitleParent);
  
SET CheckRecCount = (SELECT COUNT(*) AS RecCount FROM `breadcrumblinks` WHERE
`Page_Title` = PageTitle);
    IF CheckRecCount > 0 THEN
        SET MyPageTitle = CONCAT("The following Page_Title is already exists in database: ", PageTitle);
        SELECT MyPageTitle;
        LEAVE GoodBye;
  END IF;
  
UPDATE `breadcrumblinks`
   SET Lft = CASE WHEN Lft > ParentLevel THEN
      Lft + 2
    ELSE
      Lft + 0
    END,
   Rgt = CASE WHEN Rgt >= ParentLevel THEN
      Rgt + 2
   ELSE
      Rgt + 0
   END
WHERE  Rgt >= ParentLevel;
  
SET RecCount = (SELECT COUNT(*) FROM `breadcrumblinks`);
    IF RecCount = 0 THEN
        -- this is for handling the first record
        INSERT INTO `breadcrumblinks` (Page_Title, Page_URL, Lft, Rgt)
                    VALUES (PageTitle, PageURL, 1, 2);
    ELSE
        -- whereas the following is for the second record, and so forth!
        INSERT INTO `breadcrumblinks` (Page_Title, Page_URL, Lft, Rgt)
                    VALUES (PageTitle, PageURL, ParentLevel, (ParentLevel + 1));
    END IF;
  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletebreadcrumbbasedonpagetitle` (IN `PageTitle` VARCHAR(100))  BEGIN
-- Need one parameter (PageTitle), look at the line: WHERE  Page_Title = PageTitle;
DECLARE DeletedPageTitle VARCHAR(100);
DECLARE DeletedLft INTEGER;
DECLARE DeletedRgt INTEGER;
  
SELECT `Page_Title`, `Lft`, `Rgt`
INTO   DeletedPageTitle, DeletedLft, DeletedRgt
FROM   `breadcrumblinks`
WHERE `Page_Title` = PageTitle;
  
DELETE FROM `breadcrumblinks`
WHERE Lft BETWEEN DeletedLft AND DeletedRgt;
  
UPDATE `breadcrumblinks`
   SET Lft = CASE WHEN Lft > DeletedLft THEN
             Lft - (DeletedRgt - DeletedLft + 1)
          ELSE
             Lft
          END,
       Rgt = CASE WHEN Rgt > DeletedLft THEN
             Rgt - (DeletedRgt - DeletedLft + 1)
          ELSE
             Rgt
          END
   WHERE Lft > DeletedLft
      OR Rgt > DeletedLft;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getbreadcrumblinks` (IN `PageTitleParent` VARCHAR(100), `PageTitle` VARCHAR(100), `PageURL` VARCHAR(100))  GoodBye: BEGIN
-- Need three parameters (PageTitleParent, PageTitle, and PageURL),
-- look at this line --> `Page_Title` = PageTitleParent);
-- look at this line --> VALUES (PageTitle, PageURL, ParentLevel, (ParentLevel + 1));
DECLARE ParentLevel INTEGER;
DECLARE RecCount INTEGER;
DECLARE CheckRecCount INTEGER;
DECLARE MyPageTitle VARCHAR(100);
  
SET ParentLevel = (SELECT Rgt FROM `breadcrumblinks` WHERE
`Page_Title` = PageTitleParent);
  
SET CheckRecCount = (SELECT COUNT(*) AS RecCount FROM `breadcrumblinks` WHERE
`Page_Title` = PageTitle);
    IF CheckRecCount > 0 THEN
        SET MyPageTitle = CONCAT("The following Page_Title is already exists in database: ", PageTitle);
        SELECT MyPageTitle;
        LEAVE GoodBye;
  END IF;
  
UPDATE `breadcrumblinks`
   SET Lft = CASE WHEN Lft > ParentLevel THEN
      Lft + 2
    ELSE
      Lft + 0
    END,
   Rgt = CASE WHEN Rgt >= ParentLevel THEN
      Rgt + 2
   ELSE
      Rgt + 0
   END
WHERE  Rgt >= ParentLevel;
  
SET RecCount = (SELECT COUNT(*) FROM `breadcrumblinks`);
    IF RecCount = 0 THEN
        -- this is for handling the first record
        INSERT INTO `breadcrumblinks` (Page_Title, Page_URL, Lft, Rgt)
                    VALUES (PageTitle, PageURL, 1, 2);
    ELSE
        -- whereas the following is for the second record, and so forth!
        INSERT INTO `breadcrumblinks` (Page_Title, Page_URL, Lft, Rgt)
                    VALUES (PageTitle, PageURL, ParentLevel, (ParentLevel + 1));
    END IF;
  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `movebreadcrumb` (IN `CurrentRoot` VARCHAR(100), IN `NewParent` VARCHAR(100))  BEGIN
-- Need two parameters: (1) CurrentRoot, and (2) NewParent.
DECLARE Origin_Lft INTEGER;
DECLARE Origin_Rgt INTEGER;
DECLARE NewParent_Rgt INTEGER;
  
SELECT `Lft`, `Rgt`
    INTO Origin_Lft, Origin_Rgt
    FROM `breadcrumblinks`
    WHERE `Page_Title` = CurrentRoot;
SET NewParent_Rgt = (SELECT `Rgt` FROM `breadcrumblinks`
    WHERE `Page_Title` = NewParent);
UPDATE `breadcrumblinks`
    SET `Lft` = `Lft` +
    CASE
        WHEN NewParent_Rgt < Origin_Lft
            THEN CASE
                WHEN Lft BETWEEN Origin_Lft AND Origin_Rgt
                    THEN NewParent_Rgt - Origin_Lft
                WHEN Lft BETWEEN NewParent_Rgt  AND Origin_Lft - 1
                    THEN Origin_Rgt - Origin_Lft + 1
                ELSE 0 END
        WHEN NewParent_Rgt > Origin_Rgt
            THEN CASE
                WHEN Lft BETWEEN Origin_Lft AND Origin_Rgt
                    THEN NewParent_Rgt - Origin_Rgt - 1
                WHEN Lft BETWEEN Origin_Rgt + 1 AND NewParent_Rgt - 1
                    THEN Origin_Lft - Origin_Rgt - 1
                ELSE 0 END
            ELSE 0 END,
    Rgt = Rgt +
    CASE
        WHEN NewParent_Rgt < Origin_Lft
            THEN CASE
        WHEN Rgt BETWEEN Origin_Lft AND Origin_Rgt
            THEN NewParent_Rgt - Origin_Lft
        WHEN Rgt BETWEEN NewParent_Rgt AND Origin_Lft - 1
            THEN Origin_Rgt - Origin_Lft + 1
        ELSE 0 END
        WHEN NewParent_Rgt > Origin_Rgt
            THEN CASE
                WHEN Rgt BETWEEN Origin_Lft AND Origin_Rgt
                    THEN NewParent_Rgt - Origin_Rgt - 1
                WHEN Rgt BETWEEN Origin_Rgt + 1 AND NewParent_Rgt - 1
                    THEN Origin_Lft - Origin_Rgt - 1
                ELSE 0 END
            ELSE 0 END;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `announcement`
--

CREATE TABLE `announcement` (
  `Announcement_ID` int(11) UNSIGNED NOT NULL,
  `Is_Active` enum('N','Y') NOT NULL DEFAULT 'N',
  `Topic` varchar(50) NOT NULL,
  `Message` mediumtext NOT NULL,
  `Date_LastUpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Language` char(2) NOT NULL DEFAULT 'en',
  `Auto_Publish` enum('Y','N') DEFAULT 'N',
  `Date_Start` datetime DEFAULT NULL,
  `Date_End` datetime DEFAULT NULL,
  `Date_Created` datetime DEFAULT NULL,
  `Created_By` varchar(200) DEFAULT NULL,
  `Translated_ID` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `announcement`
--

INSERT INTO `announcement` (`Announcement_ID`, `Is_Active`, `Topic`, `Message`, `Date_LastUpdate`, `Language`, `Auto_Publish`, `Date_Start`, `Date_End`, `Date_Created`, `Created_By`, `Translated_ID`) VALUES
(1, 'Y', 'First Announcement (English)', '<p>Please note that this is the <strong>First Announcement</strong> in <strong>English</strong>. This announcement text came from announcement table which also supports for multi-language and auto-publish. Thanks for seeing this! <img src=\"http://www.ilovephpmaker.com/wp-includes/images/smilies/icon_smile.gif\" alt=\":)\" class=\"wp-smiley\">  <strong><span style=\"background-color: #ffffff; color: #ff00ff;\"><br /></span></strong></p>', '2014-02-06 09:26:46', 'en', 'Y', '2014-02-01 00:00:01', '2014-02-10 23:59:59', '2014-02-06 13:27:51', 'andrew', 2),
(2, 'Y', 'First Announcement (Indonesian)', '<p>Ini teks <strong>Pengumuman </strong>yang<strong> Pertama</strong> dalam <strong>Bahasa Indonesia</strong>. Teks pengumuman ini berasal dari tabel announcement yang mendukung <strong>multi-bahasa</strong> dan <strong>terbit-otomatis</strong> berdasarkan durasi tanggal tertentu. :)</p>', '2014-02-06 09:26:46', 'id', 'Y', '2014-02-01 00:00:01', '2014-02-10 23:59:59', '2014-02-06 13:28:08', 'janet', 1),
(3, 'N', 'Second Announcement (English)', '<p>This is the <strong>Second Announcement</strong> in <strong>English</strong>. This announcement text came from announcement table which also supports for <strong>multi-language</strong> and <strong>auto-publish</strong>.</p>', '2014-02-06 02:09:25', 'en', 'Y', '2014-02-11 00:00:01', '2014-02-20 23:59:59', '2014-02-06 10:57:43', 'nancy', 4),
(4, 'N', 'Second Announcement (Indonesian)', '<p>Ini <strong>Pengumuman</strong> yang <strong>Kedua</strong> dalam <strong>Bahasa Indonesia</strong>.&nbsp;Teks pengumuman ini berasal dari tabel announcement yang mendukung <strong>multi-bahasa</strong> dan <strong>terbit-otomatis</strong> berdasarkan durasi tanggal tertentu. :)</p>', '2014-02-06 02:11:17', 'id', 'Y', '2014-02-11 00:00:01', '2014-02-20 23:59:59', '2014-02-06 13:29:21', 'margaret', 3),
(5, 'N', 'Third Announcement (English)', '<p>This is the third Announcement in English.</p>', '2013-04-12 17:01:31', 'en', 'Y', '2014-08-01 00:00:01', '2014-08-31 23:59:59', '2014-02-06 10:59:24', 'janet', 6),
(6, 'N', 'Third Announcement (Indonesian)', '<p>Ini teks pengumuman yang ketiga dalam bahasa Indonesia.<em><strong><br /></strong></em></p>', '2014-02-06 08:09:52', 'id', 'Y', '2014-08-01 00:00:01', '2014-08-31 23:59:59', '2014-02-06 13:30:06', 'robert', 5),
(7, 'N', 'Fourth Announcement (English)', '<p>This is the fourth announcement in English.</p>', '2014-02-06 06:02:38', 'en', 'Y', '2014-05-01 00:00:01', '2014-05-31 23:59:59', '2014-02-06 10:21:35', 'margaret', 8),
(8, 'N', 'Fourth Announcement (Indonesian)', '<p>Ini adalah teks pengumuman yang keempat (dalam bahasa Indonesia).</p>', '2014-02-06 04:45:17', 'id', 'Y', '2014-05-01 00:00:01', '2014-05-31 23:59:59', '2014-02-06 11:06:20', 'janet', 7),
(9, 'N', 'Fifth Announcement (English)', '<p>This is the fifth announcement in English.</p>', '2014-02-05 15:01:14', 'en', 'Y', '2014-06-01 00:00:01', '2014-06-30 23:59:59', '2014-02-05 19:47:24', 'andrew', 10),
(10, 'N', 'Fifth Announcement (Indonesian)', '<p>Sedangkan yang ini adalah pengumuman yang kelima dalam bahasa Indonesia.</p>', '2014-02-05 15:01:14', 'id', 'Y', '2014-06-01 00:00:01', '2014-06-30 23:59:59', '2014-02-05 19:47:24', 'andrew', 9);

-- --------------------------------------------------------

--
-- Table structure for table `a_customers`
--

CREATE TABLE `a_customers` (
  `Customer_ID` int(11) NOT NULL,
  `Customer_Number` varchar(20) NOT NULL,
  `Customer_Name` varchar(50) NOT NULL,
  `Address` text NOT NULL,
  `City` varchar(50) NOT NULL,
  `Country` varchar(30) NOT NULL,
  `Contact_Person` varchar(50) NOT NULL,
  `Phone_Number` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Mobile_Number` varchar(50) NOT NULL,
  `Notes` varchar(50) NOT NULL,
  `Balance` double DEFAULT '0',
  `Date_Added` datetime DEFAULT NULL,
  `Added_By` varchar(50) DEFAULT NULL,
  `Date_Updated` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_customers`
--

INSERT INTO `a_customers` (`Customer_ID`, `Customer_Number`, `Customer_Name`, `Address`, `City`, `Country`, `Contact_Person`, `Phone_Number`, `Email`, `Mobile_Number`, `Notes`, `Balance`, `Date_Added`, `Added_By`, `Date_Updated`, `Updated_By`) VALUES
(1, 'Customer-00000000001', 'First Customer', 'Address for the first customer', 'Bekasi', 'Indonesia', 'CP First Customer', '021323235232', 'cp.first@gmail.com', '08123242490', 'Another note again.', 670000, '2015-02-14 11:42:54', 'Administrator', '2018-05-08 01:58:04', 'Administrator'),
(2, 'Customer-00000000002', 'Second Customer', 'Address for the second customer.', 'Depok', 'Indonesia', 'CP Second Customer', '0214982008', 'cp.second@gmail.com', '08124242422', 'Any note here', 150000, '2015-02-14 11:43:45', 'Administrator', '2015-02-14 11:44:20', 'Administrator'),
(3, 'Customer-00000000003', 'Third Customer', 'Another address again for third customer', 'Tangerang', 'Indonesia', 'CP Third Customer', '0215800823', 'cp.third@gmail.com', '0812482092300', 'Some note here', 280000, '2015-02-14 11:44:24', 'Administrator', '2015-02-14 11:45:03', 'Administrator'),
(4, 'Customer-00000000004', 'Fourth Customer', 'Address for the fourth customer', 'Jakarta', 'Indonesia', 'CP Fourth Customer', '02183204800', 'cp.fourth@gmail.com', '081282084902', 'What note here', 900000, '2015-02-14 11:45:09', 'Administrator', '2015-02-14 11:45:49', 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `a_payment_transactions`
--

CREATE TABLE `a_payment_transactions` (
  `Payment_ID` int(11) NOT NULL,
  `Ref_ID` varchar(20) DEFAULT NULL,
  `Type` enum('sales','purchase') DEFAULT NULL,
  `Customer` varchar(20) DEFAULT NULL,
  `Supplier` varchar(20) DEFAULT NULL,
  `Sub_Total` double NOT NULL DEFAULT '0',
  `Payment` double NOT NULL DEFAULT '0',
  `Balance` double NOT NULL DEFAULT '0',
  `Due_Date` date DEFAULT NULL,
  `Date_Transaction` date DEFAULT NULL,
  `Date_Added` datetime DEFAULT NULL,
  `Added_By` varchar(50) DEFAULT NULL,
  `Date_Updated` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_payment_transactions`
--

INSERT INTO `a_payment_transactions` (`Payment_ID`, `Ref_ID`, `Type`, `Customer`, `Supplier`, `Sub_Total`, `Payment`, `Balance`, `Due_Date`, `Date_Transaction`, `Date_Added`, `Added_By`, `Date_Updated`, `Updated_By`) VALUES
(1, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 30000000, 2500000, 27500000, '2015-02-14', '2015-02-14', '2015-02-14 12:10:52', 'Administrator', '2015-02-14 12:11:04', 'Administrator'),
(2, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 27500000, 1000000, 26500000, '2015-02-14', '2015-02-14', '2015-02-14 12:11:08', 'Administrator', '2015-02-14 12:11:18', 'Administrator'),
(3, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 26500000, 5000000, 21500000, '2015-02-14', '2015-02-14', '2015-02-14 12:12:00', 'Administrator', '2015-02-14 12:12:12', 'Administrator'),
(4, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 21500000, 7000000, 14500000, '2015-02-14', '2015-02-14', '2015-02-14 12:12:15', 'Administrator', '2015-02-14 12:12:20', 'Administrator'),
(5, 'Purchase-00000000005', 'purchase', '-', 'Supplier-00000000001', 4640000, 1200000, 3440000, '2015-02-14', '2015-02-14', '2015-02-14 12:13:48', 'Administrator', '2015-02-14 12:13:56', 'Administrator'),
(6, 'Purchase-00000000005', 'purchase', '-', 'Supplier-00000000001', 3440000, 700000, 2740000, '2015-02-14', '2015-02-14', '2015-02-14 12:14:00', 'Administrator', '2015-02-14 12:14:13', 'Administrator'),
(7, 'Purchase-00000000006', 'purchase', '-', 'Supplier-00000000002', 7500000, 1100000, 6400000, '2015-02-14', '2015-02-14', '2015-02-14 12:14:43', 'Administrator', '2015-02-14 12:14:53', 'Administrator'),
(8, 'Purchase-00000000006', 'purchase', '-', 'Supplier-00000000002', 6400000, 1000000, 5400000, '2015-02-14', '2015-02-14', '2015-02-14 12:15:07', 'Administrator', '2015-02-14 12:15:18', 'Administrator'),
(9, 'Purchase-00000000005', 'purchase', '-', 'Supplier-00000000001', 2740000, 500000, 2240000, '2015-02-14', '2015-02-14', '2015-02-14 12:15:29', 'Administrator', '2015-02-14 12:15:36', 'Administrator'),
(10, 'Purchase-00000000002', 'purchase', '-', 'Supplier-00000000002', 5250000, 1200000, 4050000, '2015-02-14', '2015-02-14', '2015-02-14 12:16:09', 'Administrator', '2015-02-14 12:16:15', 'Administrator'),
(11, 'Purchase-00000000002', 'purchase', '-', 'Supplier-00000000002', 4050000, 500000, 3550000, '2015-02-14', '2015-02-14', '2015-02-14 12:16:27', 'Administrator', '2015-02-14 12:16:32', 'Administrator'),
(12, 'Purchase-00000000004', 'purchase', '-', 'Supplier-00000000004', 2000000, 300000, 1700000, '2015-02-14', '2015-02-14', '2015-02-14 12:16:54', 'Administrator', '2015-02-14 12:17:03', 'Administrator'),
(13, 'Purchase-00000000003', 'purchase', '-', 'Supplier-00000000003', 5000000, 1400000, 3600000, '2015-02-14', '2015-02-14', '2015-02-14 12:17:36', 'Administrator', '2015-02-14 12:17:45', 'Administrator'),
(14, 'Sales-00000000000003', 'sales', 'Customer-00000000003', '-', 400000, 120000, 280000, '2015-02-14', '2015-02-14', '2015-02-14 12:17:56', 'Administrator', '2015-02-14 12:18:02', 'Administrator'),
(15, 'Sales-00000000000002', 'sales', 'Customer-00000000002', '-', 30500, 30500, 0, '2015-02-14', '2015-02-14', '2015-02-14 12:18:11', 'Administrator', '2015-02-14 12:18:21', 'Administrator'),
(16, 'Sales-00000000000001', 'sales', 'Customer-00000000001', '-', 700000, 50000, 650000, '2015-02-14', '2015-02-14', '2015-02-14 12:18:30', 'Administrator', '2015-02-14 12:18:36', 'Administrator'),
(17, 'Sales-00000000000001', 'sales', 'Customer-00000000001', '-', 650000, 80000, 570000, '2015-02-14', '2015-02-14', '2015-02-14 12:18:40', 'Administrator', '2015-02-14 12:18:45', 'Administrator'),
(18, 'Sales-00000000000008', 'sales', 'Customer-00000000004', '-', 1300000, 400000, 900000, '2015-02-14', '2015-02-14', '2015-02-14 12:25:04', 'Administrator', '2015-02-14 12:25:12', 'Administrator'),
(19, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 14500000, 3000000, 11500000, '2015-02-14', '2015-02-14', '2015-02-14 12:25:25', 'Administrator', '2015-02-14 12:25:31', 'Administrator'),
(20, 'Purchase-00000000006', 'purchase', '-', 'Supplier-00000000002', 5400000, 1200000, 4200000, '2015-02-14', '2015-02-14', '2015-02-14 12:26:12', 'Administrator', '2015-02-14 12:26:20', 'Administrator'),
(21, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 11500000, 200000, 11300000, '2015-02-14', '2015-02-14', '2015-02-14 12:26:45', 'Administrator', '2015-02-14 12:26:51', 'Administrator'),
(22, 'Sales-00000000000001', 'sales', 'Customer-00000000001', '-', 570000, 200000, 370000, '2015-02-14', '2015-02-14', '2015-02-14 12:27:30', 'Administrator', '2015-02-14 12:27:37', 'Administrator'),
(23, 'Sales-00000000000006', 'sales', 'Customer-00000000001', '-', 50000, 50000, 0, '2018-05-07', '2018-05-07', '2018-05-07 18:53:24', 'Administrator', '2018-05-07 18:53:42', 'Administrator'),
(24, 'Purchase-00000000001', 'purchase', '-', 'Supplier-00000000001', 2500000, 2500000, 0, '2018-05-07', '2018-05-07', '2018-05-07 21:08:57', 'Administrator', '2018-05-07 21:10:03', 'Administrator'),
(25, 'Purchase-00000000002', 'purchase', '-', 'Supplier-00000000002', 3550000, 3550000, 0, '2018-05-08', '2018-05-08', '2018-05-08 01:53:33', 'Administrator', '2018-05-08 01:53:54', 'Administrator'),
(26, 'Purchase-00000000003', 'purchase', '-', 'Supplier-00000000003', 3600000, 56780, 3543220, '2018-05-08', '2018-05-08', '2018-05-08 01:53:59', 'Administrator', '2018-05-08 01:54:14', 'Administrator'),
(27, 'Purchase-00000000007', 'purchase', '-', 'Supplier-00000000001', 11300000, 11300000, 0, '2018-05-10', '2018-05-10', '2018-05-10 23:53:52', 'Administrator', '2018-05-10 23:54:04', 'Administrator'),
(28, 'Purchase-00000000006', 'purchase', '-', 'Supplier-00000000002', 4200000, 4200000, 0, '2018-05-10', '2018-05-10', '2018-05-10 23:54:21', 'Administrator', '2018-05-10 23:54:52', 'Administrator'),
(29, 'Purchase-00000000005', 'purchase', '-', 'Supplier-00000000001', 2240000, 2240000, 0, '2018-05-10', '2018-05-10', '2018-05-10 23:56:00', 'Administrator', '2018-05-10 23:56:08', 'Administrator'),
(30, 'Purchase-00000000004', 'purchase', '-', 'Supplier-00000000004', 1700000, 1700, 1698300, '2018-05-10', '2018-05-10', '2018-05-10 23:56:34', 'Administrator', '2018-05-10 23:56:47', 'Administrator'),
(31, 'Purchase-00000000004', 'purchase', '-', 'Supplier-00000000004', 1698300, 2000, 1696300, '2018-05-10', '2018-05-10', '2018-05-10 23:58:12', 'Administrator', '2018-05-10 23:58:22', 'Administrator'),
(32, 'Purchase-00000000004', 'purchase', '-', 'Supplier-00000000004', 1696300, 196300, 1500000, '2018-05-10', '2018-05-10', '2018-05-10 23:58:57', 'Administrator', '2018-05-10 23:59:19', 'Administrator'),
(33, 'Purchase-00000000004', 'purchase', '-', 'Supplier-00000000004', 1500000, 150000, 1350000, '2018-05-10', '2018-05-10', '2018-05-10 23:59:37', 'Administrator', '2018-05-11 00:00:25', 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `a_purchases`
--

CREATE TABLE `a_purchases` (
  `Purchase_ID` int(11) NOT NULL,
  `Purchase_Number` varchar(20) NOT NULL,
  `Purchase_Date` datetime NOT NULL,
  `Supplier_ID` varchar(20) NOT NULL,
  `Notes` varchar(50) DEFAULT NULL,
  `Total_Amount` double(20,0) DEFAULT '0',
  `Total_Payment` double(20,0) DEFAULT '0',
  `Total_Balance` double(20,0) DEFAULT '0',
  `Date_Added` datetime DEFAULT NULL,
  `Added_By` varchar(50) DEFAULT NULL,
  `Date_Updated` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_purchases`
--

INSERT INTO `a_purchases` (`Purchase_ID`, `Purchase_Number`, `Purchase_Date`, `Supplier_ID`, `Notes`, `Total_Amount`, `Total_Payment`, `Total_Balance`, `Date_Added`, `Added_By`, `Date_Updated`, `Updated_By`) VALUES
(1, 'Purchase-00000000001', '2015-02-14 11:47:05', 'Supplier-00000000001', NULL, 182500000, 182500000, 0, '2015-02-14 11:47:05', 'Administrator', '2015-02-14 11:47:39', 'Administrator'),
(2, 'Purchase-00000000002', '2015-02-14 11:48:20', 'Supplier-00000000002', NULL, 65250000, 65250000, 0, '2015-02-14 11:48:20', 'Administrator', '2015-02-14 11:49:00', 'Administrator'),
(3, 'Purchase-00000000003', '2015-02-14 11:49:36', 'Supplier-00000000003', NULL, 40000000, 36456780, 3543220, '2015-02-14 11:49:36', 'Administrator', '2015-02-14 11:50:19', 'Administrator'),
(4, 'Purchase-00000000004', '2015-02-14 11:54:01', 'Supplier-00000000004', NULL, 10000000, 8650000, 1350000, '2015-02-14 11:54:01', 'Administrator', '2015-02-14 11:54:30', 'Administrator'),
(5, 'Purchase-00000000005', '2015-02-14 11:55:39', 'Supplier-00000000001', NULL, 52640000, 52640000, 0, '2015-02-14 11:55:39', 'Administrator', '2015-02-14 11:56:15', 'Administrator'),
(6, 'Purchase-00000000006', '2015-02-14 11:58:46', 'Supplier-00000000002', NULL, 50000000, 50000000, 0, '2015-02-14 11:58:46', 'Administrator', '2015-02-14 12:00:11', 'Administrator'),
(7, 'Purchase-00000000007', '2015-02-14 12:01:04', 'Supplier-00000000001', NULL, 100000000, 100000000, 0, '2015-02-14 12:01:04', 'Administrator', '2015-02-14 12:01:52', 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `a_purchases_detail`
--

CREATE TABLE `a_purchases_detail` (
  `Purchase_ID` int(11) NOT NULL,
  `Purchase_Number` varchar(20) NOT NULL,
  `Supplier_Number` varchar(20) NOT NULL,
  `Stock_Item` varchar(15) NOT NULL,
  `Purchasing_Quantity` double(20,0) NOT NULL DEFAULT '0',
  `Purchasing_Price` double(20,0) NOT NULL DEFAULT '0',
  `Selling_Price` double(20,0) NOT NULL DEFAULT '0',
  `Purchasing_Total_Amount` double(20,0) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_purchases_detail`
--

INSERT INTO `a_purchases_detail` (`Purchase_ID`, `Purchase_Number`, `Supplier_Number`, `Stock_Item`, `Purchasing_Quantity`, `Purchasing_Price`, `Selling_Price`, `Purchasing_Total_Amount`) VALUES
(1, 'Purchase-00000000001', 'Supplier-00000000001', 'Stock-000000001', 1000, 100000, 110000, 100000000),
(2, 'Purchase-00000000001', 'Supplier-00000000001', 'Stock-000000002', 25000, 3300, 3500, 82500000),
(3, 'Purchase-00000000002', 'Supplier-00000000002', 'Stock-000000003', 500, 12500, 15000, 6250000),
(4, 'Purchase-00000000002', 'Supplier-00000000002', 'Stock-000000007', 10000, 2000, 2300, 20000000),
(5, 'Purchase-00000000002', 'Supplier-00000000002', 'Stock-000000009', 2000, 7000, 7900, 14000000),
(6, 'Purchase-00000000002', 'Supplier-00000000002', 'Stock-000000008', 5000, 5000, 5800, 25000000),
(7, 'Purchase-00000000003', 'Supplier-00000000003', 'Stock-000000004', 50000, 200, 250, 10000000),
(8, 'Purchase-00000000003', 'Supplier-00000000003', 'Stock-000000005', 10000, 1500, 1800, 15000000),
(9, 'Purchase-00000000003', 'Supplier-00000000003', 'Stock-000000006', 5000, 3000, 3200, 15000000),
(10, 'Purchase-00000000004', 'Supplier-00000000004', 'Stock-000000010', 2000, 5000, 5400, 10000000),
(11, 'Purchase-00000000005', 'Supplier-00000000001', 'Stock-000000001', 500, 100000, 110000, 50000000),
(12, 'Purchase-00000000005', 'Supplier-00000000001', 'Stock-000000002', 800, 3300, 3500, 2640000),
(13, 'Purchase-00000000006', 'Supplier-00000000002', 'Stock-000000003', 2000, 12500, 15000, 25000000),
(14, 'Purchase-00000000006', 'Supplier-00000000002', 'Stock-000000007', 3000, 2000, 2300, 6000000),
(15, 'Purchase-00000000006', 'Supplier-00000000002', 'Stock-000000008', 1000, 5000, 5800, 5000000),
(16, 'Purchase-00000000006', 'Supplier-00000000002', 'Stock-000000009', 2000, 7000, 7900, 14000000),
(17, 'Purchase-00000000007', 'Supplier-00000000001', 'Stock-000000001', 1000, 100000, 110000, 100000000);

-- --------------------------------------------------------

--
-- Table structure for table `a_sales`
--

CREATE TABLE `a_sales` (
  `Sales_ID` int(11) NOT NULL,
  `Sales_Number` varchar(20) NOT NULL,
  `Sales_Date` datetime NOT NULL,
  `Customer_ID` varchar(20) NOT NULL,
  `Notes` varchar(50) DEFAULT NULL,
  `Total_Amount` double DEFAULT '0',
  `Total_Payment` double DEFAULT '0',
  `Total_Balance` double DEFAULT '0',
  `Discount_Type` char(1) DEFAULT NULL,
  `Discount_Percentage` double DEFAULT '0',
  `Discount_Amount` double DEFAULT '0',
  `Tax_Percentage` double DEFAULT '0',
  `Tax_Amount` double DEFAULT '0',
  `Tax_Description` varchar(50) DEFAULT NULL,
  `Final_Total_Amount` double DEFAULT '0',
  `Date_Added` datetime DEFAULT NULL,
  `Added_By` varchar(50) DEFAULT NULL,
  `Date_Updated` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_sales`
--

INSERT INTO `a_sales` (`Sales_ID`, `Sales_Number`, `Sales_Date`, `Customer_ID`, `Notes`, `Total_Amount`, `Total_Payment`, `Total_Balance`, `Discount_Type`, `Discount_Percentage`, `Discount_Amount`, `Tax_Percentage`, `Tax_Amount`, `Tax_Description`, `Final_Total_Amount`, `Date_Added`, `Added_By`, `Date_Updated`, `Updated_By`) VALUES
(1, 'Sales-00000000000001', '2015-02-14 12:03:06', 'Customer-00000000001', NULL, 1807300, 1527665, 370000, 'P', 5, 90365, 10, 180730, NULL, 1897665, '2015-02-14 12:03:06', 'Administrator', '2015-02-14 12:06:06', 'Administrator'),
(2, 'Sales-00000000000002', '2015-02-14 12:06:38', 'Customer-00000000002', NULL, 130500, 130500, 0, 'P', 0, 0, 0, 0, NULL, 130500, '2015-02-14 12:06:38', 'Administrator', '2015-02-14 12:07:12', 'Administrator'),
(3, 'Sales-00000000000003', '2015-02-14 12:07:48', 'Customer-00000000003', NULL, 866400, 629720, 280000, 'P', 5, 43320, 10, 86640, 'PPh Pasal 21', 909720, '2015-02-14 12:07:48', 'Administrator', '2015-02-14 12:09:18', 'Administrator'),
(4, 'Sales-00000000000004', '2015-02-14 12:09:30', 'Customer-00000000004', NULL, 157400, 165270, 0, 'P', 5, 7870, 10, 15740, 'Pph Pasal 21', 165270, '2015-02-14 12:09:30', 'Administrator', '2015-02-14 12:10:21', 'Administrator'),
(5, 'Sales-00000000000005', '2015-02-14 12:19:45', 'Customer-00000000001', NULL, 513500, 239175, 300000, 'P', 5, 25675, 10, 51350, 'Pph Pasal 21', 539175, '2015-02-14 12:19:45', 'Administrator', '2015-02-14 12:20:21', 'Administrator'),
(6, 'Sales-00000000000006', '2015-02-14 12:20:49', 'Customer-00000000001', NULL, 154300, 154300, 0, 'P', 0, 0, 0, 0, NULL, 154300, '2015-02-14 12:20:49', 'Administrator', '2015-02-14 12:21:23', 'Administrator'),
(7, 'Sales-00000000000007', '2015-02-14 12:21:39', 'Customer-00000000002', NULL, 244600, 106830, 150000, 'P', 5, 12230, 10, 24460, NULL, 256830, '2015-02-14 12:21:39', 'Administrator', '2015-02-14 12:22:43', 'Administrator'),
(8, 'Sales-00000000000008', '2015-02-14 12:23:05', 'Customer-00000000004', NULL, 2255000, 1467750, 900000, 'P', 5, 112750, 10, 225500, NULL, 2367750, '2015-02-14 12:23:05', 'Administrator', '2015-02-14 12:24:00', 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `a_sales_detail`
--

CREATE TABLE `a_sales_detail` (
  `Sales_ID` int(11) NOT NULL,
  `Sales_Number` varchar(20) NOT NULL,
  `Supplier_Number` varchar(20) NOT NULL,
  `Stock_Item` varchar(15) NOT NULL,
  `Sales_Quantity` double NOT NULL DEFAULT '0',
  `Purchasing_Price` double NOT NULL DEFAULT '0',
  `Sales_Price` double NOT NULL DEFAULT '0',
  `Sales_Total_Amount` double NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_sales_detail`
--

INSERT INTO `a_sales_detail` (`Sales_ID`, `Sales_Number`, `Supplier_Number`, `Stock_Item`, `Sales_Quantity`, `Purchasing_Price`, `Sales_Price`, `Sales_Total_Amount`) VALUES
(1, 'Sales-00000000000001', 'Supplier-00000000001', 'Stock-000000001', 10, 100000, 110000, 1100000),
(2, 'Sales-00000000000001', 'Supplier-00000000001', 'Stock-000000002', 35, 3300, 3500, 122500),
(3, 'Sales-00000000000001', 'Supplier-00000000002', 'Stock-000000003', 10, 12500, 15000, 150000),
(4, 'Sales-00000000000001', 'Supplier-00000000002', 'Stock-000000007', 20, 2000, 2300, 46000),
(5, 'Sales-00000000000001', 'Supplier-00000000002', 'Stock-000000008', 15, 5000, 5800, 87000),
(6, 'Sales-00000000000001', 'Supplier-00000000002', 'Stock-000000009', 30, 7000, 7900, 237000),
(7, 'Sales-00000000000001', 'Supplier-00000000004', 'Stock-000000010', 12, 5000, 5400, 64800),
(8, 'Sales-00000000000002', 'Supplier-00000000003', 'Stock-000000004', 50, 200, 250, 12500),
(9, 'Sales-00000000000002', 'Supplier-00000000003', 'Stock-000000005', 30, 1500, 1800, 54000),
(10, 'Sales-00000000000002', 'Supplier-00000000003', 'Stock-000000006', 20, 3000, 3200, 64000),
(11, 'Sales-00000000000003', 'Supplier-00000000001', 'Stock-000000001', 5, 100000, 110000, 550000),
(12, 'Sales-00000000000003', 'Supplier-00000000002', 'Stock-000000003', 12, 12500, 15000, 180000),
(13, 'Sales-00000000000003', 'Supplier-00000000003', 'Stock-000000005', 20, 1500, 1800, 36000),
(14, 'Sales-00000000000003', 'Supplier-00000000004', 'Stock-000000010', 10, 5000, 5400, 54000),
(15, 'Sales-00000000000003', 'Supplier-00000000002', 'Stock-000000008', 8, 5000, 5800, 46400),
(16, 'Sales-00000000000004', 'Supplier-00000000001', 'Stock-000000002', 12, 3300, 3500, 42000),
(17, 'Sales-00000000000004', 'Supplier-00000000002', 'Stock-000000007', 10, 2000, 2300, 23000),
(18, 'Sales-00000000000004', 'Supplier-00000000003', 'Stock-000000006', 12, 3000, 3200, 38400),
(19, 'Sales-00000000000004', 'Supplier-00000000004', 'Stock-000000010', 10, 5000, 5400, 54000),
(20, 'Sales-00000000000005', 'Supplier-00000000001', 'Stock-000000001', 4, 100000, 110000, 440000),
(21, 'Sales-00000000000005', 'Supplier-00000000001', 'Stock-000000002', 21, 3300, 3500, 73500),
(22, 'Sales-00000000000006', 'Supplier-00000000002', 'Stock-000000003', 6, 12500, 15000, 90000),
(23, 'Sales-00000000000006', 'Supplier-00000000002', 'Stock-000000008', 7, 5000, 5800, 40600),
(24, 'Sales-00000000000006', 'Supplier-00000000002', 'Stock-000000009', 3, 7000, 7900, 23700),
(25, 'Sales-00000000000007', 'Supplier-00000000004', 'Stock-000000010', 12, 5000, 5400, 64800),
(26, 'Sales-00000000000007', 'Supplier-00000000002', 'Stock-000000007', 36, 2000, 2300, 82800),
(27, 'Sales-00000000000007', 'Supplier-00000000003', 'Stock-000000005', 40, 1500, 1800, 72000),
(28, 'Sales-00000000000007', 'Supplier-00000000003', 'Stock-000000004', 100, 200, 250, 25000),
(29, 'Sales-00000000000008', 'Supplier-00000000001', 'Stock-000000001', 12, 100000, 110000, 1320000),
(30, 'Sales-00000000000008', 'Supplier-00000000001', 'Stock-000000002', 30, 3300, 3500, 105000),
(31, 'Sales-00000000000008', 'Supplier-00000000002', 'Stock-000000003', 40, 12500, 15000, 600000),
(32, 'Sales-00000000000008', 'Supplier-00000000002', 'Stock-000000007', 100, 2000, 2300, 230000);

-- --------------------------------------------------------

--
-- Table structure for table `a_stock_categories`
--

CREATE TABLE `a_stock_categories` (
  `Category_ID` int(11) NOT NULL,
  `Category_Name` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_stock_categories`
--

INSERT INTO `a_stock_categories` (`Category_ID`, `Category_Name`) VALUES
(1, 'First Category'),
(2, 'Second Category'),
(3, 'Third Category'),
(4, 'Fourth Category'),
(5, 'Fifth Category'),
(6, 'SG 20w50');

-- --------------------------------------------------------

--
-- Table structure for table `a_stock_items`
--

CREATE TABLE `a_stock_items` (
  `Stock_ID` int(11) NOT NULL,
  `Supplier_Number` varchar(20) NOT NULL,
  `Stock_Number` varchar(15) NOT NULL,
  `Stock_Name` varchar(50) NOT NULL,
  `Unit_Of_Measurement` varchar(20) NOT NULL,
  `Category` int(11) NOT NULL,
  `Purchasing_Price` double(20,0) NOT NULL DEFAULT '0',
  `Selling_Price` double(20,0) NOT NULL DEFAULT '0',
  `Notes` varchar(50) NOT NULL,
  `Quantity` double(20,0) NOT NULL DEFAULT '0',
  `Date_Added` datetime DEFAULT NULL,
  `Added_By` varchar(50) DEFAULT NULL,
  `Date_Updated` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_stock_items`
--

INSERT INTO `a_stock_items` (`Stock_ID`, `Supplier_Number`, `Stock_Number`, `Stock_Name`, `Unit_Of_Measurement`, `Category`, `Purchasing_Price`, `Selling_Price`, `Notes`, `Quantity`, `Date_Added`, `Added_By`, `Date_Updated`, `Updated_By`) VALUES
(4, 'Supplier-00000000003', 'Stock-000000004', 'Fourth Stock Item', 'Item', 4, 200, 250, 'Keterangan untuk barang keempat.', 49850, '2014-02-11 08:21:22', 'Administrator', '2015-02-12 19:37:24', 'Administrator'),
(5, 'Supplier-00000000003', 'Stock-000000005', 'Fifth Stock Item', 'Item', 1, 1500, 1800, '-', 9910, '2014-02-11 08:21:22', 'Administrator', '2015-02-12 19:38:16', 'Administrator'),
(6, 'Supplier-00000000003', 'Stock-000000006', 'Sixth Stock Item', 'Item', 2, 3000, 3200, '-', 4968, '2014-02-11 08:21:22', 'Administrator', '2015-02-12 19:37:24', 'Administrator'),
(7, 'Supplier-00000000002', 'Stock-000000007', 'Seventh Stock Item', 'Item', 1, 2000, 2300, 'This is only another notes.', 12834, '2014-02-11 08:21:22', 'Administrator', '2015-02-12 19:37:24', 'Administrator'),
(8, 'Supplier-00000000002', 'Stock-000000008', 'Eighth Stock Item', 'Item', 2, 5000, 5800, 'Another notes again.', 5970, '2014-02-11 08:21:22', 'Administrator', '2015-02-12 19:37:24', 'Administrator'),
(9, 'Supplier-00000000002', 'Stock-000000009', 'Ninth Stock Item', 'Item', 3, 7000, 7900, 'Again another notes haha.', 3967, '2014-02-11 08:21:22', 'Administrator', '2015-02-12 19:37:24', 'Administrator'),
(11, 'Supplier-00000000004', 'Stock-000000010', 'SG 20w50', '1500', 6, 2300, 2400, 'Oil', 300, '2018-05-11 00:14:05', 'Administrator', '2018-05-11 00:18:05', 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `a_suppliers`
--

CREATE TABLE `a_suppliers` (
  `Supplier_ID` int(11) NOT NULL,
  `Supplier_Number` varchar(20) NOT NULL,
  `Supplier_Name` varchar(50) NOT NULL,
  `Address` text NOT NULL,
  `City` varchar(20) NOT NULL,
  `Country` varchar(50) NOT NULL,
  `Contact_Person` varchar(50) NOT NULL,
  `Phone_Number` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Mobile_Number` varchar(50) NOT NULL,
  `Notes` text NOT NULL,
  `Balance` double DEFAULT '0',
  `Is_Stock_Available` enum('N','Y') NOT NULL DEFAULT 'N',
  `Date_Added` datetime DEFAULT NULL,
  `Added_By` varchar(50) DEFAULT NULL,
  `Date_Updated` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_suppliers`
--

INSERT INTO `a_suppliers` (`Supplier_ID`, `Supplier_Number`, `Supplier_Name`, `Address`, `City`, `Country`, `Contact_Person`, `Phone_Number`, `Email`, `Mobile_Number`, `Notes`, `Balance`, `Is_Stock_Available`, `Date_Added`, `Added_By`, `Date_Updated`, `Updated_By`) VALUES
(2, 'Supplier-00000000002', 'Second Supplier', 'Address for the second supplier', 'Jakarta', 'Indonesia', 'Martina Navatrilova', '02148272080', 'martina.nav@gmail.com', '081232442840', 'Just a note for Martina.', 0, 'Y', '2015-02-14 11:39:16', 'Administrator', '2015-02-14 11:40:00', 'Administrator'),
(3, 'Supplier-00000000003', 'Third Supplier', 'Address for the third supplier.', 'Surabaya', 'Indonesia', 'Joko Sentul', '03142348293', 'joko.sentoel@gmail.com', '081242009827', 'A note for third supplier.', 3543220, 'Y', '2015-02-14 11:40:03', 'Administrator', '2015-02-14 11:41:39', 'Administrator'),
(5, 'Supplier-00000000004', 'Petromin', 'Khanewal', 'Khanewal', 'Pakistan', 'Waheed', '0652121212', 'mirza@gmail.com', '03087656756', 'Nothing', 0, 'N', '2018-05-11 00:09:38', 'Administrator', '2018-05-11 00:12:26', 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `a_unit_of_measurement`
--

CREATE TABLE `a_unit_of_measurement` (
  `UOM_ID` varchar(10) NOT NULL,
  `UOM_Description` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `a_unit_of_measurement`
--

INSERT INTO `a_unit_of_measurement` (`UOM_ID`, `UOM_Description`) VALUES
('Item', 'Item'),
('1500', 'Purchase');

-- --------------------------------------------------------

--
-- Table structure for table `breadcrumblinks`
--

CREATE TABLE `breadcrumblinks` (
  `Page_Title` varchar(100) NOT NULL,
  `Page_URL` varchar(100) NOT NULL,
  `Lft` int(4) NOT NULL,
  `Rgt` int(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `help`
--

CREATE TABLE `help` (
  `Help_ID` int(11) NOT NULL,
  `Language` char(2) NOT NULL,
  `Topic` varchar(255) NOT NULL,
  `Description` longtext NOT NULL,
  `Category` int(11) NOT NULL,
  `Order` int(11) NOT NULL,
  `Display_in_Page` varchar(100) NOT NULL,
  `Updated_By` varchar(20) DEFAULT NULL,
  `Last_Updated` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `help`
--

INSERT INTO `help` (`Help_ID`, `Language`, `Topic`, `Description`, `Category`, `Order`, `Display_in_Page`, `Updated_By`, `Last_Updated`) VALUES
(1, 'en', 'Login', 'This is help for Login page.', 1, 1, 'login.php', 'Masino', '2014-05-26 21:32:24'),
(2, 'en', 'Request Password', 'This is help for Request Password page.', 2, 1, 'forgotpwd.php', 'Admin', '2014-05-26 14:39:50'),
(3, 'en', 'Change Password', 'This is help for Change Password page.', 2, 2, 'changepwd.php', 'Admin', '2014-05-26 14:40:24'),
(4, 'en', 'Registration', 'This is help for Registration page.', 1, 2, 'register.php', 'Admin', '2014-05-26 14:50:46'),
(5, 'en', 'Help', 'This is help for Help page.', 3, 1, 'helplist.php', NULL, NULL),
(6, 'en', 'Help (Categories)', 'This is help for Help (Categories) page.', 3, 2, 'help_categorieslist.php', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `help_categories`
--

CREATE TABLE `help_categories` (
  `Category_ID` int(11) NOT NULL,
  `Language` char(2) NOT NULL,
  `Category_Description` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `help_categories`
--

INSERT INTO `help_categories` (`Category_ID`, `Language`, `Category_Description`) VALUES
(1, 'en', 'First Category'),
(2, 'en', 'Second Category'),
(3, 'en', 'Third Category');

-- --------------------------------------------------------

--
-- Table structure for table `languages`
--

CREATE TABLE `languages` (
  `Language_Code` char(2) NOT NULL,
  `Language_Name` varchar(20) NOT NULL,
  `Default` enum('Y','N') DEFAULT 'N',
  `Site_Logo` varchar(100) NOT NULL,
  `Site_Title` varchar(100) NOT NULL,
  `Default_Thousands_Separator` varchar(5) DEFAULT NULL,
  `Default_Decimal_Point` varchar(5) DEFAULT NULL,
  `Default_Currency_Symbol` varchar(10) DEFAULT NULL,
  `Default_Money_Thousands_Separator` varchar(5) DEFAULT NULL,
  `Default_Money_Decimal_Point` varchar(5) DEFAULT NULL,
  `Terms_And_Condition_Text` text NOT NULL,
  `Announcement_Text` text NOT NULL,
  `About_Text` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `languages`
--

INSERT INTO `languages` (`Language_Code`, `Language_Name`, `Default`, `Site_Logo`, `Site_Title`, `Default_Thousands_Separator`, `Default_Decimal_Point`, `Default_Currency_Symbol`, `Default_Money_Thousands_Separator`, `Default_Money_Decimal_Point`, `Terms_And_Condition_Text`, `Announcement_Text`, `About_Text`) VALUES
('en', 'English', 'Y', '-', 'PHPMaker Demo Project', ',', '.', '$', ',', '.', 'This is the terms and conditions text from database. You can edit this text from the languages table ...', 'This is the announcement text from database. You can edit this text from the languages table ...', '<span class=\'dialogtitle\' style=\'white-space: nowrap;\'>Stock Inventory Management, version 1.0</span><br><br>Managing your stock inventory so easily...<br><br><br><br><br>Web Developer:<br></span>Masino Sinaga (masino.sinaga@gmail.com)<br>Website: <a href=\'http://www.ilovephpmaker.com\' title=\'I Love PHPMaker\' target=\'_blank\'>http://www.ilovephpmaker.com</a><br><br><br>'),
('id', 'Indonesia', 'N', '-', 'PHPMaker Proyek Demo', '.', ',', 'Rp', '.', ',', 'Ini teks syarat dan ketentuan dari database. Anda dapat mengubah teks ini dari tabel languages ... ', 'Ini teks pengumuman dari database. Anda dapat mengubah teks ini dari tabel languages ...', '<span class=\'dialogtitle\' style=\'white-space: nowrap;\'>Stock Inventory Management, version 1.0</span><br><br>Mengelola persediaan barang Anda dengan begitu mudahnya...<br><br><br><br><br>Web Developer:<br></span>Masino Sinaga (masino.sinaga@gmail.com)<br>Website: <a href=\'http://www.ilovephpmaker.com\' title=\'I Love PHPMaker\' target=\'_blank\'>http://www.ilovephpmaker.com</a><br><br><br>');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `Option_ID` int(11) UNSIGNED NOT NULL,
  `Option_Default` enum('Y','N') DEFAULT 'N',
  `Default_Theme` varchar(30) DEFAULT NULL,
  `Menu_Horizontal` enum('Y','N') DEFAULT 'Y',
  `Vertical_Menu_Width` int(3) DEFAULT '150',
  `Show_Border_Layout` enum('N','Y') DEFAULT 'Y',
  `Show_Shadow_Layout` enum('N','Y') DEFAULT 'Y',
  `Show_Announcement` enum('Y','N') DEFAULT 'N',
  `Demo_Mode` enum('N','Y') DEFAULT 'N',
  `Show_Page_Processing_Time` enum('Y','N') DEFAULT 'N',
  `Allow_User_Preferences` enum('N','Y') DEFAULT 'Y',
  `SMTP_Server` varchar(50) DEFAULT NULL,
  `SMTP_Server_Port` varchar(5) DEFAULT NULL,
  `SMTP_Server_Username` varchar(50) DEFAULT NULL,
  `SMTP_Server_Password` varchar(50) DEFAULT NULL,
  `Sender_Email` varchar(50) DEFAULT NULL,
  `Recipient_Email` varchar(50) DEFAULT NULL,
  `Use_Default_Locale` enum('Y','N') DEFAULT 'Y',
  `Default_Language` varchar(5) DEFAULT NULL,
  `Default_Timezone` varchar(50) DEFAULT NULL,
  `Default_Thousands_Separator` varchar(5) DEFAULT NULL,
  `Default_Decimal_Point` varchar(5) DEFAULT NULL,
  `Default_Currency_Symbol` varchar(10) DEFAULT NULL,
  `Default_Money_Thousands_Separator` varchar(5) DEFAULT NULL,
  `Default_Money_Decimal_Point` varchar(5) DEFAULT NULL,
  `Maintenance_Mode` enum('N','Y') DEFAULT 'N',
  `Maintenance_Finish_DateTime` datetime DEFAULT NULL,
  `Auto_Normal_After_Maintenance` enum('Y','N') DEFAULT 'Y',
  `Allow_User_To_Register` enum('Y','N') DEFAULT 'Y',
  `Suspend_New_User_Account` enum('N','Y') DEFAULT 'N',
  `User_Need_Activation_After_Registered` enum('Y','N') DEFAULT 'Y',
  `Show_Captcha_On_Registration_Page` enum('Y','N') DEFAULT 'N',
  `Show_Terms_And_Conditions_On_Registration_Page` enum('Y','N') DEFAULT 'Y',
  `Show_Captcha_On_Login_Page` enum('N','Y') DEFAULT 'N',
  `Show_Captcha_On_Forgot_Password_Page` enum('N','Y') DEFAULT 'N',
  `Show_Captcha_On_Change_Password_Page` enum('N','Y') DEFAULT 'N',
  `User_Auto_Login_After_Activation_Or_Registration` enum('Y','N') DEFAULT 'Y',
  `User_Auto_Logout_After_Idle_In_Minutes` int(3) DEFAULT '20',
  `User_Login_Maximum_Retry` int(3) DEFAULT '3',
  `User_Login_Retry_Lockout` int(3) DEFAULT '5',
  `Redirect_To_Last_Visited_Page_After_Login` enum('Y','N') DEFAULT 'Y',
  `Enable_Password_Expiry` enum('Y','N') DEFAULT 'Y',
  `Password_Expiry_In_Days` int(3) DEFAULT '90',
  `Show_Entire_Header` enum('Y','N') DEFAULT 'Y',
  `Logo_Width` int(3) DEFAULT '170',
  `Show_Site_Title_In_Header` enum('Y','N') DEFAULT 'Y',
  `Show_Current_User_In_Header` enum('Y','N') DEFAULT 'Y',
  `Text_Align_In_Header` enum('left','center','right') DEFAULT 'left',
  `Site_Title_Text_Style` enum('normal','capitalize','uppercase') DEFAULT 'normal',
  `Language_Selector_Visibility` enum('inheader','belowheader','hidethemall') DEFAULT 'inheader',
  `Language_Selector_Align` enum('autoadjust','left','center','right') DEFAULT 'autoadjust',
  `Show_Entire_Footer` enum('Y','N') DEFAULT 'Y',
  `Show_Text_In_Footer` enum('Y','N') DEFAULT 'Y',
  `Show_Back_To_Top_On_Footer` enum('N','Y') DEFAULT 'Y',
  `Show_Terms_And_Conditions_On_Footer` enum('Y','N') DEFAULT 'Y',
  `Show_About_Us_On_Footer` enum('N','Y') DEFAULT 'Y',
  `Pagination_Position` enum('1','2','3') DEFAULT '3',
  `Pagination_Style` enum('1','2') DEFAULT '2',
  `Selectable_Records_Per_Page` varchar(50) DEFAULT '1,2,3,5,10,15,20,50',
  `Selectable_Groups_Per_Page` varchar(50) DEFAULT '1,2,3,5,10',
  `Default_Record_Per_Page` int(3) DEFAULT '10',
  `Default_Group_Per_Page` int(3) DEFAULT '3',
  `Maximum_Selected_Records` int(3) DEFAULT '50',
  `Maximum_Selected_Groups` int(3) DEFAULT '50',
  `Show_PageNum_If_Record_Not_Over_Pagesize` enum('Y','N') DEFAULT 'Y',
  `Table_Width_Style` enum('1','2','3') DEFAULT '2' COMMENT '1 = Scroll, 2 = Normal, 3 = 100%',
  `Scroll_Table_Width` int(4) DEFAULT '800',
  `Scroll_Table_Height` int(4) DEFAULT '300',
  `Show_Record_Number_On_List_Page` enum('N','Y') DEFAULT 'Y',
  `Show_Empty_Table_On_List_Page` enum('N','Y') DEFAULT 'Y',
  `Search_Panel_Collapsed` enum('Y','N') DEFAULT 'Y',
  `Filter_Panel_Collapsed` enum('Y','N') DEFAULT 'Y',
  `Rows_Vertical_Align_Top` enum('N','Y') DEFAULT 'Y',
  `Show_Add_Success_Message` enum('N','Y') DEFAULT 'Y',
  `Show_Edit_Success_Message` enum('N','Y') DEFAULT 'Y',
  `jQuery_Auto_Hide_Success_Message` enum('N','Y') DEFAULT 'N',
  `Show_Record_Number_On_Detail_Preview` enum('N','Y') DEFAULT 'Y',
  `Show_Empty_Table_In_Detail_Preview` enum('N','Y') DEFAULT 'Y',
  `Detail_Preview_Table_Width` int(3) DEFAULT '100',
  `Password_Minimum_Length` int(2) DEFAULT '6',
  `Password_Maximum_Length` int(2) DEFAULT '20',
  `Password_Must_Comply_With_Minumum_Length` enum('N','Y') DEFAULT 'Y',
  `Password_Must_Comply_With_Maximum_Length` enum('N','Y') DEFAULT 'Y',
  `Password_Must_Contain_At_Least_One_Lower_Case` enum('N','Y') DEFAULT 'Y',
  `Password_Must_Contain_At_Least_One_Upper_Case` enum('N','Y') DEFAULT 'Y',
  `Password_Must_Contain_At_Least_One_Numeric` enum('N','Y') DEFAULT 'Y',
  `Password_Must_Contain_At_Least_One_Symbol` enum('N','Y') DEFAULT 'Y',
  `Password_Must_Be_Difference_Between_Old_And_New` enum('N','Y') DEFAULT 'Y',
  `Export_Record_Options` enum('selectedrecords','currentpage','allpages') DEFAULT 'selectedrecords',
  `Show_Record_Number_On_Exported_List_Page` enum('N','Y') DEFAULT 'Y',
  `Use_Table_Setting_For_Export_Field_Caption` enum('N','Y') DEFAULT 'Y',
  `Use_Table_Setting_For_Export_Original_Value` enum('N','Y') DEFAULT 'Y',
  `Font_Name` varchar(50) DEFAULT 'tahoma',
  `Font_Size` varchar(4) DEFAULT '11px',
  `Use_Javascript_Message` enum('1','0') DEFAULT '1',
  `Login_Window_Type` enum('popup','default') DEFAULT 'popup',
  `Forgot_Password_Window_Type` enum('popup','default') DEFAULT 'popup',
  `Change_Password_Window_Type` enum('popup','default') DEFAULT 'popup',
  `Registration_Window_Type` enum('popup','default') DEFAULT 'popup',
  `Reset_Password_Field_Options` enum('EmailOrUsername','Username','Email') DEFAULT 'EmailOrUsername',
  `Action_Button_Alignment` enum('Right','Left') DEFAULT 'Right'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`Option_ID`, `Option_Default`, `Default_Theme`, `Menu_Horizontal`, `Vertical_Menu_Width`, `Show_Border_Layout`, `Show_Shadow_Layout`, `Show_Announcement`, `Demo_Mode`, `Show_Page_Processing_Time`, `Allow_User_Preferences`, `SMTP_Server`, `SMTP_Server_Port`, `SMTP_Server_Username`, `SMTP_Server_Password`, `Sender_Email`, `Recipient_Email`, `Use_Default_Locale`, `Default_Language`, `Default_Timezone`, `Default_Thousands_Separator`, `Default_Decimal_Point`, `Default_Currency_Symbol`, `Default_Money_Thousands_Separator`, `Default_Money_Decimal_Point`, `Maintenance_Mode`, `Maintenance_Finish_DateTime`, `Auto_Normal_After_Maintenance`, `Allow_User_To_Register`, `Suspend_New_User_Account`, `User_Need_Activation_After_Registered`, `Show_Captcha_On_Registration_Page`, `Show_Terms_And_Conditions_On_Registration_Page`, `Show_Captcha_On_Login_Page`, `Show_Captcha_On_Forgot_Password_Page`, `Show_Captcha_On_Change_Password_Page`, `User_Auto_Login_After_Activation_Or_Registration`, `User_Auto_Logout_After_Idle_In_Minutes`, `User_Login_Maximum_Retry`, `User_Login_Retry_Lockout`, `Redirect_To_Last_Visited_Page_After_Login`, `Enable_Password_Expiry`, `Password_Expiry_In_Days`, `Show_Entire_Header`, `Logo_Width`, `Show_Site_Title_In_Header`, `Show_Current_User_In_Header`, `Text_Align_In_Header`, `Site_Title_Text_Style`, `Language_Selector_Visibility`, `Language_Selector_Align`, `Show_Entire_Footer`, `Show_Text_In_Footer`, `Show_Back_To_Top_On_Footer`, `Show_Terms_And_Conditions_On_Footer`, `Show_About_Us_On_Footer`, `Pagination_Position`, `Pagination_Style`, `Selectable_Records_Per_Page`, `Selectable_Groups_Per_Page`, `Default_Record_Per_Page`, `Default_Group_Per_Page`, `Maximum_Selected_Records`, `Maximum_Selected_Groups`, `Show_PageNum_If_Record_Not_Over_Pagesize`, `Table_Width_Style`, `Scroll_Table_Width`, `Scroll_Table_Height`, `Show_Record_Number_On_List_Page`, `Show_Empty_Table_On_List_Page`, `Search_Panel_Collapsed`, `Filter_Panel_Collapsed`, `Rows_Vertical_Align_Top`, `Show_Add_Success_Message`, `Show_Edit_Success_Message`, `jQuery_Auto_Hide_Success_Message`, `Show_Record_Number_On_Detail_Preview`, `Show_Empty_Table_In_Detail_Preview`, `Detail_Preview_Table_Width`, `Password_Minimum_Length`, `Password_Maximum_Length`, `Password_Must_Comply_With_Minumum_Length`, `Password_Must_Comply_With_Maximum_Length`, `Password_Must_Contain_At_Least_One_Lower_Case`, `Password_Must_Contain_At_Least_One_Upper_Case`, `Password_Must_Contain_At_Least_One_Numeric`, `Password_Must_Contain_At_Least_One_Symbol`, `Password_Must_Be_Difference_Between_Old_And_New`, `Export_Record_Options`, `Show_Record_Number_On_Exported_List_Page`, `Use_Table_Setting_For_Export_Field_Caption`, `Use_Table_Setting_For_Export_Original_Value`, `Font_Name`, `Font_Size`, `Use_Javascript_Message`, `Login_Window_Type`, `Forgot_Password_Window_Type`, `Change_Password_Window_Type`, `Registration_Window_Type`, `Reset_Password_Field_Options`, `Action_Button_Alignment`) VALUES
(1, 'Y', 'theme-green.css', 'Y', 150, 'N', 'N', 'N', 'Y', 'N', 'Y', 'mail.posindonesia.co.id', '25', 'masino_sinaga@posindonesia.co.id', NULL, 'masino_sinaga@posindonesia.co.id', 'masino_sinaga@posindonesia.co.id', 'Y', 'id', 'Asia/Jakarta', '.', ',', 'Rp&nbsp;', '.', ',', 'N', '2013-11-12 00:00:00', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'Y', 15, 2, 1, 'Y', 'Y', 30, 'Y', 480, 'Y', 'Y', 'right', 'normal', 'belowheader', 'autoadjust', 'Y', 'Y', 'Y', 'Y', 'Y', '3', '2', '1,2,3,5,7,10,15,20,50,100,500,1000', '1,2,3,4,5,10', 10, 3, 50, 5, 'N', '3', 1200, 400, 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 0, 4, 20, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'currentpage', 'Y', 'Y', 'Y', 'arial', '14px', '1', 'popup', 'popup', 'popup', 'popup', 'EmailOrUsername', 'Right');

-- --------------------------------------------------------

--
-- Table structure for table `stats_counter`
--

CREATE TABLE `stats_counter` (
  `Type` varchar(50) NOT NULL DEFAULT '',
  `Variable` varchar(50) NOT NULL DEFAULT '',
  `Counter` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats_counter`
--

INSERT INTO `stats_counter` (`Type`, `Variable`, `Counter`) VALUES
('total', 'hits', 451),
('browser', 'WebTV', 0),
('browser', 'Lynx', 0),
('browser', 'MSIE', 0),
('browser', 'Opera', 0),
('browser', 'Konqueror', 0),
('browser', 'Netscape', 0),
('browser', 'FireFox', 451),
('browser', 'Bot', 0),
('browser', 'Other', 0),
('os', 'Windows', 451),
('os', 'Linux', 0),
('os', 'Mac', 0),
('os', 'FreeBSD', 0),
('os', 'SunOS', 0),
('os', 'IRIX', 0),
('os', 'BeOS', 0),
('os', 'OS/2', 0),
('os', 'AIX', 0),
('os', 'Other', 0);

-- --------------------------------------------------------

--
-- Table structure for table `stats_counterlog`
--

CREATE TABLE `stats_counterlog` (
  `IP_Address` varchar(50) NOT NULL DEFAULT '',
  `Hostname` varchar(50) DEFAULT NULL,
  `First_Visit` datetime NOT NULL,
  `Last_Visit` datetime NOT NULL,
  `Counter` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats_counterlog`
--

INSERT INTO `stats_counterlog` (`IP_Address`, `Hostname`, `First_Visit`, `Last_Visit`, `Counter`) VALUES
('127.0.0.1', 'MasinoSinaga-PC', '2015-02-13 12:46:22', '2015-02-14 12:30:59', 451);

-- --------------------------------------------------------

--
-- Table structure for table `stats_date`
--

CREATE TABLE `stats_date` (
  `Year` smallint(6) NOT NULL DEFAULT '0',
  `Month` tinyint(4) NOT NULL DEFAULT '0',
  `Date` tinyint(4) NOT NULL DEFAULT '0',
  `Hits` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats_date`
--

INSERT INTO `stats_date` (`Year`, `Month`, `Date`, `Hits`) VALUES
(2015, 1, 1, 0),
(2015, 1, 2, 0),
(2015, 1, 3, 0),
(2015, 1, 4, 0),
(2015, 1, 5, 0),
(2015, 1, 6, 0),
(2015, 1, 7, 0),
(2015, 1, 8, 0),
(2015, 1, 9, 0),
(2015, 1, 10, 0),
(2015, 1, 11, 0),
(2015, 1, 12, 0),
(2015, 1, 13, 0),
(2015, 1, 14, 0),
(2015, 1, 15, 0),
(2015, 1, 16, 0),
(2015, 1, 17, 0),
(2015, 1, 18, 0),
(2015, 1, 19, 0),
(2015, 1, 20, 0),
(2015, 1, 21, 0),
(2015, 1, 22, 0),
(2015, 1, 23, 0),
(2015, 1, 24, 0),
(2015, 1, 25, 0),
(2015, 1, 26, 0),
(2015, 1, 27, 0),
(2015, 1, 28, 0),
(2015, 1, 29, 0),
(2015, 1, 30, 0),
(2015, 1, 31, 0),
(2015, 2, 1, 0),
(2015, 2, 2, 0),
(2015, 2, 3, 0),
(2015, 2, 4, 0),
(2015, 2, 5, 0),
(2015, 2, 6, 0),
(2015, 2, 7, 0),
(2015, 2, 8, 0),
(2015, 2, 9, 0),
(2015, 2, 10, 0),
(2015, 2, 11, 0),
(2015, 2, 12, 0),
(2015, 2, 13, 27),
(2015, 2, 14, 424),
(2015, 2, 15, 0),
(2015, 2, 16, 0),
(2015, 2, 17, 0),
(2015, 2, 18, 0),
(2015, 2, 19, 0),
(2015, 2, 20, 0),
(2015, 2, 21, 0),
(2015, 2, 22, 0),
(2015, 2, 23, 0),
(2015, 2, 24, 0),
(2015, 2, 25, 0),
(2015, 2, 26, 0),
(2015, 2, 27, 0),
(2015, 2, 28, 0),
(2015, 3, 1, 0),
(2015, 3, 2, 0),
(2015, 3, 3, 0),
(2015, 3, 4, 0),
(2015, 3, 5, 0),
(2015, 3, 6, 0),
(2015, 3, 7, 0),
(2015, 3, 8, 0),
(2015, 3, 9, 0),
(2015, 3, 10, 0),
(2015, 3, 11, 0),
(2015, 3, 12, 0),
(2015, 3, 13, 0),
(2015, 3, 14, 0),
(2015, 3, 15, 0),
(2015, 3, 16, 0),
(2015, 3, 17, 0),
(2015, 3, 18, 0),
(2015, 3, 19, 0),
(2015, 3, 20, 0),
(2015, 3, 21, 0),
(2015, 3, 22, 0),
(2015, 3, 23, 0),
(2015, 3, 24, 0),
(2015, 3, 25, 0),
(2015, 3, 26, 0),
(2015, 3, 27, 0),
(2015, 3, 28, 0),
(2015, 3, 29, 0),
(2015, 3, 30, 0),
(2015, 3, 31, 0),
(2015, 4, 1, 0),
(2015, 4, 2, 0),
(2015, 4, 3, 0),
(2015, 4, 4, 0),
(2015, 4, 5, 0),
(2015, 4, 6, 0),
(2015, 4, 7, 0),
(2015, 4, 8, 0),
(2015, 4, 9, 0),
(2015, 4, 10, 0),
(2015, 4, 11, 0),
(2015, 4, 12, 0),
(2015, 4, 13, 0),
(2015, 4, 14, 0),
(2015, 4, 15, 0),
(2015, 4, 16, 0),
(2015, 4, 17, 0),
(2015, 4, 18, 0),
(2015, 4, 19, 0),
(2015, 4, 20, 0),
(2015, 4, 21, 0),
(2015, 4, 22, 0),
(2015, 4, 23, 0),
(2015, 4, 24, 0),
(2015, 4, 25, 0),
(2015, 4, 26, 0),
(2015, 4, 27, 0),
(2015, 4, 28, 0),
(2015, 4, 29, 0),
(2015, 4, 30, 0),
(2015, 5, 1, 0),
(2015, 5, 2, 0),
(2015, 5, 3, 0),
(2015, 5, 4, 0),
(2015, 5, 5, 0),
(2015, 5, 6, 0),
(2015, 5, 7, 0),
(2015, 5, 8, 0),
(2015, 5, 9, 0),
(2015, 5, 10, 0),
(2015, 5, 11, 0),
(2015, 5, 12, 0),
(2015, 5, 13, 0),
(2015, 5, 14, 0),
(2015, 5, 15, 0),
(2015, 5, 16, 0),
(2015, 5, 17, 0),
(2015, 5, 18, 0),
(2015, 5, 19, 0),
(2015, 5, 20, 0),
(2015, 5, 21, 0),
(2015, 5, 22, 0),
(2015, 5, 23, 0),
(2015, 5, 24, 0),
(2015, 5, 25, 0),
(2015, 5, 26, 0),
(2015, 5, 27, 0),
(2015, 5, 28, 0),
(2015, 5, 29, 0),
(2015, 5, 30, 0),
(2015, 5, 31, 0),
(2015, 6, 1, 0),
(2015, 6, 2, 0),
(2015, 6, 3, 0),
(2015, 6, 4, 0),
(2015, 6, 5, 0),
(2015, 6, 6, 0),
(2015, 6, 7, 0),
(2015, 6, 8, 0),
(2015, 6, 9, 0),
(2015, 6, 10, 0),
(2015, 6, 11, 0),
(2015, 6, 12, 0),
(2015, 6, 13, 0),
(2015, 6, 14, 0),
(2015, 6, 15, 0),
(2015, 6, 16, 0),
(2015, 6, 17, 0),
(2015, 6, 18, 0),
(2015, 6, 19, 0),
(2015, 6, 20, 0),
(2015, 6, 21, 0),
(2015, 6, 22, 0),
(2015, 6, 23, 0),
(2015, 6, 24, 0),
(2015, 6, 25, 0),
(2015, 6, 26, 0),
(2015, 6, 27, 0),
(2015, 6, 28, 0),
(2015, 6, 29, 0),
(2015, 6, 30, 0),
(2015, 7, 1, 0),
(2015, 7, 2, 0),
(2015, 7, 3, 0),
(2015, 7, 4, 0),
(2015, 7, 5, 0),
(2015, 7, 6, 0),
(2015, 7, 7, 0),
(2015, 7, 8, 0),
(2015, 7, 9, 0),
(2015, 7, 10, 0),
(2015, 7, 11, 0),
(2015, 7, 12, 0),
(2015, 7, 13, 0),
(2015, 7, 14, 0),
(2015, 7, 15, 0),
(2015, 7, 16, 0),
(2015, 7, 17, 0),
(2015, 7, 18, 0),
(2015, 7, 19, 0),
(2015, 7, 20, 0),
(2015, 7, 21, 0),
(2015, 7, 22, 0),
(2015, 7, 23, 0),
(2015, 7, 24, 0),
(2015, 7, 25, 0),
(2015, 7, 26, 0),
(2015, 7, 27, 0),
(2015, 7, 28, 0),
(2015, 7, 29, 0),
(2015, 7, 30, 0),
(2015, 7, 31, 0),
(2015, 8, 1, 0),
(2015, 8, 2, 0),
(2015, 8, 3, 0),
(2015, 8, 4, 0),
(2015, 8, 5, 0),
(2015, 8, 6, 0),
(2015, 8, 7, 0),
(2015, 8, 8, 0),
(2015, 8, 9, 0),
(2015, 8, 10, 0),
(2015, 8, 11, 0),
(2015, 8, 12, 0),
(2015, 8, 13, 0),
(2015, 8, 14, 0),
(2015, 8, 15, 0),
(2015, 8, 16, 0),
(2015, 8, 17, 0),
(2015, 8, 18, 0),
(2015, 8, 19, 0),
(2015, 8, 20, 0),
(2015, 8, 21, 0),
(2015, 8, 22, 0),
(2015, 8, 23, 0),
(2015, 8, 24, 0),
(2015, 8, 25, 0),
(2015, 8, 26, 0),
(2015, 8, 27, 0),
(2015, 8, 28, 0),
(2015, 8, 29, 0),
(2015, 8, 30, 0),
(2015, 8, 31, 0),
(2015, 9, 1, 0),
(2015, 9, 2, 0),
(2015, 9, 3, 0),
(2015, 9, 4, 0),
(2015, 9, 5, 0),
(2015, 9, 6, 0),
(2015, 9, 7, 0),
(2015, 9, 8, 0),
(2015, 9, 9, 0),
(2015, 9, 10, 0),
(2015, 9, 11, 0),
(2015, 9, 12, 0),
(2015, 9, 13, 0),
(2015, 9, 14, 0),
(2015, 9, 15, 0),
(2015, 9, 16, 0),
(2015, 9, 17, 0),
(2015, 9, 18, 0),
(2015, 9, 19, 0),
(2015, 9, 20, 0),
(2015, 9, 21, 0),
(2015, 9, 22, 0),
(2015, 9, 23, 0),
(2015, 9, 24, 0),
(2015, 9, 25, 0),
(2015, 9, 26, 0),
(2015, 9, 27, 0),
(2015, 9, 28, 0),
(2015, 9, 29, 0),
(2015, 9, 30, 0),
(2015, 10, 1, 0),
(2015, 10, 2, 0),
(2015, 10, 3, 0),
(2015, 10, 4, 0),
(2015, 10, 5, 0),
(2015, 10, 6, 0),
(2015, 10, 7, 0),
(2015, 10, 8, 0),
(2015, 10, 9, 0),
(2015, 10, 10, 0),
(2015, 10, 11, 0),
(2015, 10, 12, 0),
(2015, 10, 13, 0),
(2015, 10, 14, 0),
(2015, 10, 15, 0),
(2015, 10, 16, 0),
(2015, 10, 17, 0),
(2015, 10, 18, 0),
(2015, 10, 19, 0),
(2015, 10, 20, 0),
(2015, 10, 21, 0),
(2015, 10, 22, 0),
(2015, 10, 23, 0),
(2015, 10, 24, 0),
(2015, 10, 25, 0),
(2015, 10, 26, 0),
(2015, 10, 27, 0),
(2015, 10, 28, 0),
(2015, 10, 29, 0),
(2015, 10, 30, 0),
(2015, 10, 31, 0),
(2015, 11, 1, 0),
(2015, 11, 2, 0),
(2015, 11, 3, 0),
(2015, 11, 4, 0),
(2015, 11, 5, 0),
(2015, 11, 6, 0),
(2015, 11, 7, 0),
(2015, 11, 8, 0),
(2015, 11, 9, 0),
(2015, 11, 10, 0),
(2015, 11, 11, 0),
(2015, 11, 12, 0),
(2015, 11, 13, 0),
(2015, 11, 14, 0),
(2015, 11, 15, 0),
(2015, 11, 16, 0),
(2015, 11, 17, 0),
(2015, 11, 18, 0),
(2015, 11, 19, 0),
(2015, 11, 20, 0),
(2015, 11, 21, 0),
(2015, 11, 22, 0),
(2015, 11, 23, 0),
(2015, 11, 24, 0),
(2015, 11, 25, 0),
(2015, 11, 26, 0),
(2015, 11, 27, 0),
(2015, 11, 28, 0),
(2015, 11, 29, 0),
(2015, 11, 30, 0),
(2015, 12, 1, 0),
(2015, 12, 2, 0),
(2015, 12, 3, 0),
(2015, 12, 4, 0),
(2015, 12, 5, 0),
(2015, 12, 6, 0),
(2015, 12, 7, 0),
(2015, 12, 8, 0),
(2015, 12, 9, 0),
(2015, 12, 10, 0),
(2015, 12, 11, 0),
(2015, 12, 12, 0),
(2015, 12, 13, 0),
(2015, 12, 14, 0),
(2015, 12, 15, 0),
(2015, 12, 16, 0),
(2015, 12, 17, 0),
(2015, 12, 18, 0),
(2015, 12, 19, 0),
(2015, 12, 20, 0),
(2015, 12, 21, 0),
(2015, 12, 22, 0),
(2015, 12, 23, 0),
(2015, 12, 24, 0),
(2015, 12, 25, 0),
(2015, 12, 26, 0),
(2015, 12, 27, 0),
(2015, 12, 28, 0),
(2015, 12, 29, 0),
(2015, 12, 30, 0),
(2015, 12, 31, 0);

-- --------------------------------------------------------

--
-- Table structure for table `stats_hour`
--

CREATE TABLE `stats_hour` (
  `Year` smallint(6) NOT NULL DEFAULT '0',
  `Month` tinyint(4) NOT NULL DEFAULT '0',
  `Date` tinyint(4) NOT NULL DEFAULT '0',
  `Hour` tinyint(4) NOT NULL DEFAULT '0',
  `Hits` int(11) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats_hour`
--

INSERT INTO `stats_hour` (`Year`, `Month`, `Date`, `Hour`, `Hits`) VALUES
(2015, 2, 13, 0, 0),
(2015, 2, 13, 1, 0),
(2015, 2, 13, 2, 0),
(2015, 2, 13, 3, 0),
(2015, 2, 13, 4, 0),
(2015, 2, 13, 5, 0),
(2015, 2, 13, 6, 0),
(2015, 2, 13, 7, 0),
(2015, 2, 13, 8, 0),
(2015, 2, 13, 9, 0),
(2015, 2, 13, 10, 0),
(2015, 2, 13, 11, 0),
(2015, 2, 13, 12, 3),
(2015, 2, 13, 13, 2),
(2015, 2, 13, 14, 14),
(2015, 2, 13, 15, 0),
(2015, 2, 13, 16, 0),
(2015, 2, 13, 17, 0),
(2015, 2, 13, 18, 8),
(2015, 2, 13, 19, 0),
(2015, 2, 13, 20, 0),
(2015, 2, 13, 21, 0),
(2015, 2, 13, 22, 0),
(2015, 2, 13, 23, 0),
(2015, 2, 14, 0, 0),
(2015, 2, 14, 1, 0),
(2015, 2, 14, 2, 0),
(2015, 2, 14, 3, 0),
(2015, 2, 14, 4, 0),
(2015, 2, 14, 5, 0),
(2015, 2, 14, 6, 0),
(2015, 2, 14, 7, 0),
(2015, 2, 14, 8, 0),
(2015, 2, 14, 9, 0),
(2015, 2, 14, 10, 43),
(2015, 2, 14, 11, 225),
(2015, 2, 14, 12, 156),
(2015, 2, 14, 13, 0),
(2015, 2, 14, 14, 0),
(2015, 2, 14, 15, 0),
(2015, 2, 14, 16, 0),
(2015, 2, 14, 17, 0),
(2015, 2, 14, 18, 0),
(2015, 2, 14, 19, 0),
(2015, 2, 14, 20, 0),
(2015, 2, 14, 21, 0),
(2015, 2, 14, 22, 0),
(2015, 2, 14, 23, 0);

-- --------------------------------------------------------

--
-- Table structure for table `stats_month`
--

CREATE TABLE `stats_month` (
  `Year` smallint(6) NOT NULL DEFAULT '0',
  `Month` tinyint(4) NOT NULL DEFAULT '0',
  `Hits` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats_month`
--

INSERT INTO `stats_month` (`Year`, `Month`, `Hits`) VALUES
(2015, 1, 0),
(2015, 2, 451),
(2015, 3, 0),
(2015, 4, 0),
(2015, 5, 0),
(2015, 6, 0),
(2015, 7, 0),
(2015, 8, 0),
(2015, 9, 0),
(2015, 10, 0),
(2015, 11, 0),
(2015, 12, 0);

-- --------------------------------------------------------

--
-- Table structure for table `stats_year`
--

CREATE TABLE `stats_year` (
  `Year` smallint(6) NOT NULL DEFAULT '0',
  `Hits` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats_year`
--

INSERT INTO `stats_year` (`Year`, `Hits`) VALUES
(2015, 451);

-- --------------------------------------------------------

--
-- Table structure for table `themes`
--

CREATE TABLE `themes` (
  `Theme_ID` varchar(25) NOT NULL,
  `Theme_Name` varchar(25) NOT NULL,
  `Default` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `themes`
--

INSERT INTO `themes` (`Theme_ID`, `Theme_Name`, `Default`) VALUES
('theme-blue.css', 'Blue', 'N'),
('theme-dark.css', 'Dark', 'N'),
('theme-darkglass.css', 'Dark Glass', 'N'),
('theme-glass.css', 'Glass', 'N'),
('theme-green.css', 'Green', 'N'),
('theme-maroon.css', 'Maroon', 'Y'),
('theme-olive.css', 'Olive', 'N'),
('theme-professional.css', 'Professional', 'N'),
('theme-purple.css', 'Purple', 'N'),
('theme-red.css', 'Red', 'N'),
('theme-sand.css', 'Sand', 'N'),
('theme-silver.css', 'Silver', 'N'),
('theme-default.css', 'Default', 'N'),
('theme-black.css', 'Black', 'N'),
('theme-gray.css', 'Gray', 'N'),
('theme-white.cs', 'White', 'N');

-- --------------------------------------------------------

--
-- Table structure for table `timezone`
--

CREATE TABLE `timezone` (
  `Timezone` varchar(50) NOT NULL,
  `Default` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `timezone`
--

INSERT INTO `timezone` (`Timezone`, `Default`) VALUES
('Africa/Abidjan', 'N'),
('Africa/Accra', 'N'),
('Africa/Addis_Ababa', 'N'),
('Africa/Algiers', 'N'),
('Africa/Asmara', 'N'),
('Africa/Asmera', 'N'),
('Africa/Bamako', 'N'),
('Africa/Bangui', 'N'),
('Africa/Banjul', 'N'),
('Africa/Bissau', 'N'),
('Africa/Blantyre', 'N'),
('Africa/Brazzaville', 'N'),
('Africa/Bujumbura', 'N'),
('Africa/Cairo', 'N'),
('Africa/Casablanca', 'N'),
('Africa/Ceuta', 'N'),
('Africa/Conakry', 'N'),
('Africa/Dakar', 'N'),
('Africa/Dar_es_Salaam', 'N'),
('Africa/Djibouti', 'N'),
('Africa/Douala', 'N'),
('Africa/El_Aaiun', 'N'),
('Africa/Freetown', 'N'),
('Africa/Gaborone', 'N'),
('Africa/Harare', 'N'),
('Africa/Johannesburg', 'N'),
('Africa/Kampala', 'N'),
('Africa/Khartoum', 'N'),
('Africa/Kigali', 'N'),
('Africa/Kinshasa', 'N'),
('Africa/Lagos', 'N'),
('Africa/Libreville', 'N'),
('Africa/Lome', 'N'),
('Africa/Luanda', 'N'),
('Africa/Lubumbashi', 'N'),
('Africa/Lusaka', 'N'),
('Africa/Malabo', 'N'),
('Africa/Maputo', 'N'),
('Africa/Maseru', 'N'),
('Africa/Mbabane', 'N'),
('Africa/Mogadishu', 'N'),
('Africa/Monrovia', 'N'),
('Africa/Nairobi', 'N'),
('Africa/Ndjamena', 'N'),
('Africa/Niamey', 'N'),
('Africa/Nouakchott', 'N'),
('Africa/Ouagadougou', 'N'),
('Africa/Porto-Novo', 'N'),
('Africa/Sao_Tome', 'N'),
('Africa/Timbuktu', 'N'),
('Africa/Tripoli', 'N'),
('Africa/Tunis', 'N'),
('Africa/Windhoek', 'N'),
('America/Adak', 'N'),
('America/Anchorage', 'N'),
('America/Anguilla', 'N'),
('America/Antigua', 'N'),
('America/Araguaina', 'N'),
('America/Argentina/Buenos_Aires', 'N'),
('America/Argentina/Catamarca', 'N'),
('America/Argentina/ComodRivadavia', 'N'),
('America/Argentina/Cordoba', 'N'),
('America/Argentina/Jujuy', 'N'),
('America/Argentina/La_Rioja', 'N'),
('America/Argentina/Mendoza', 'N'),
('America/Argentina/Rio_Gallegos', 'N'),
('America/Argentina/Salta', 'N'),
('America/Argentina/San_Juan', 'N'),
('America/Argentina/San_Luis', 'N'),
('America/Argentina/Tucuman', 'N'),
('America/Argentina/Ushuaia', 'N'),
('America/Aruba', 'N'),
('America/Asuncion', 'N'),
('America/Atikokan', 'N'),
('America/Atka', 'N'),
('America/Bahia', 'N'),
('America/Bahia_Banderas', 'N'),
('America/Barbados', 'N'),
('America/Belem', 'N'),
('America/Belize', 'N'),
('America/Blanc-Sablon', 'N'),
('America/Boa_Vista', 'N'),
('America/Bogota', 'N'),
('America/Boise', 'N'),
('America/Buenos_Aires', 'N'),
('America/Cambridge_Bay', 'N'),
('America/Campo_Grande', 'N'),
('America/Cancun', 'N'),
('America/Caracas', 'N'),
('America/Catamarca', 'N'),
('America/Cayenne', 'N'),
('America/Cayman', 'N'),
('America/Chicago', 'N'),
('America/Chihuahua', 'N'),
('America/Coral_Harbour', 'N'),
('America/Cordoba', 'N'),
('America/Costa_Rica', 'N'),
('America/Cuiaba', 'N'),
('America/Curacao', 'N'),
('America/Danmarkshavn', 'N'),
('America/Dawson', 'N'),
('America/Dawson_Creek', 'N'),
('America/Denver', 'N'),
('America/Detroit', 'N'),
('America/Dominica', 'N'),
('America/Edmonton', 'N'),
('America/Eirunepe', 'N'),
('America/El_Salvador', 'N'),
('America/Ensenada', 'N'),
('America/Fort_Wayne', 'N'),
('America/Fortaleza', 'N'),
('America/Glace_Bay', 'N'),
('America/Godthab', 'N'),
('America/Goose_Bay', 'N'),
('America/Grand_Turk', 'N'),
('America/Grenada', 'N'),
('America/Guadeloupe', 'N'),
('America/Guatemala', 'N'),
('America/Guayaquil', 'N'),
('America/Guyana', 'N'),
('America/Halifax', 'N'),
('America/Havana', 'N'),
('America/Hermosillo', 'N'),
('America/Indiana/Indianapolis', 'N'),
('America/Indiana/Knox', 'N'),
('America/Indiana/Marengo', 'N'),
('America/Indiana/Petersburg', 'N'),
('America/Indiana/Tell_City', 'N'),
('America/Indiana/Vevay', 'N'),
('America/Indiana/Vincennes', 'N'),
('America/Indiana/Winamac', 'N'),
('America/Indianapolis', 'N'),
('America/Inuvik', 'N'),
('America/Iqaluit', 'N'),
('America/Jamaica', 'N'),
('America/Jujuy', 'N'),
('America/Juneau', 'N'),
('America/Kentucky/Louisville', 'N'),
('America/Kentucky/Monticello', 'N'),
('America/Knox_IN', 'N'),
('America/La_Paz', 'N'),
('America/Lima', 'N'),
('America/Los_Angeles', 'N'),
('America/Louisville', 'N'),
('America/Maceio', 'N'),
('America/Managua', 'N'),
('America/Manaus', 'N'),
('America/Marigot', 'N'),
('America/Martinique', 'N'),
('America/Matamoros', 'N'),
('America/Mazatlan', 'N'),
('America/Mendoza', 'N'),
('America/Menominee', 'N'),
('America/Merida', 'N'),
('America/Mexico_City', 'N'),
('America/Miquelon', 'N'),
('America/Moncton', 'N'),
('America/Monterrey', 'N'),
('America/Montevideo', 'N'),
('America/Montreal', 'N'),
('America/Montserrat', 'N'),
('America/Nassau', 'N'),
('America/New_York', 'N'),
('America/Nipigon', 'N'),
('America/Nome', 'N'),
('America/Noronha', 'N'),
('America/North_Dakota/Center', 'N'),
('America/North_Dakota/New_Salem', 'N'),
('America/Ojinaga', 'N'),
('America/Panama', 'N'),
('America/Pangnirtung', 'N'),
('America/Paramaribo', 'N'),
('America/Phoenix', 'N'),
('America/Port-au-Prince', 'N'),
('America/Port_of_Spain', 'N'),
('America/Porto_Acre', 'N'),
('America/Porto_Velho', 'N'),
('America/Puerto_Rico', 'N'),
('America/Rainy_River', 'N'),
('America/Rankin_Inlet', 'N'),
('America/Recife', 'N'),
('America/Regina', 'N'),
('America/Resolute', 'N'),
('America/Rio_Branco', 'N'),
('America/Rosario', 'N'),
('America/Santa_Isabel', 'N'),
('America/Santarem', 'N'),
('America/Santiago', 'N'),
('America/Santo_Domingo', 'N'),
('America/Sao_Paulo', 'N'),
('America/Scoresbysund', 'N'),
('America/Shiprock', 'N'),
('America/St_Barthelemy', 'N'),
('America/St_Johns', 'N'),
('America/St_Kitts', 'N'),
('America/St_Lucia', 'N'),
('America/St_Thomas', 'N'),
('America/St_Vincent', 'N'),
('America/Swift_Current', 'N'),
('America/Tegucigalpa', 'N'),
('America/Thule', 'N'),
('America/Thunder_Bay', 'N'),
('America/Tijuana', 'N'),
('America/Toronto', 'N'),
('America/Tortola', 'N'),
('America/Vancouver', 'N'),
('America/Virgin', 'N'),
('America/Whitehorse', 'N'),
('America/Winnipeg', 'N'),
('America/Yakutat', 'N'),
('America/Yellowknife', 'N'),
('Antarctica/Casey', 'N'),
('Antarctica/Davis', 'N'),
('Antarctica/DumontDUrville', 'N'),
('Antarctica/Macquarie', 'N'),
('Antarctica/Mawson', 'N'),
('Antarctica/McMurdo', 'N'),
('Antarctica/Palmer', 'N'),
('Antarctica/Rothera', 'N'),
('Antarctica/South_Pole', 'N'),
('Antarctica/Syowa', 'N'),
('Antarctica/Vostok', 'N'),
('Asia/Aden', 'N'),
('Asia/Almaty', 'N'),
('Asia/Amman', 'N'),
('Asia/Anadyr', 'N'),
('Asia/Aqtau', 'N'),
('Asia/Aqtobe', 'N'),
('Asia/Ashgabat', 'N'),
('Asia/Ashkhabad', 'N'),
('Asia/Baghdad', 'N'),
('Asia/Bahrain', 'N'),
('Asia/Baku', 'N'),
('Asia/Bangkok', 'N'),
('Asia/Beirut', 'N'),
('Asia/Bishkek', 'N'),
('Asia/Brunei', 'N'),
('Asia/Calcutta', 'N'),
('Asia/Choibalsan', 'N'),
('Asia/Chongqing', 'N'),
('Asia/Chungking', 'N'),
('Asia/Colombo', 'N'),
('Asia/Dacca', 'N'),
('Asia/Damascus', 'N'),
('Asia/Dhaka', 'N'),
('Asia/Dili', 'N'),
('Asia/Dubai', 'N'),
('Asia/Dushanbe', 'N'),
('Asia/Gaza', 'N'),
('Asia/Harbin', 'N'),
('Asia/Ho_Chi_Minh', 'N'),
('Asia/Hong_Kong', 'N'),
('Asia/Hovd', 'N'),
('Asia/Irkutsk', 'N'),
('Asia/Istanbul', 'N'),
('Asia/Jakarta', 'Y'),
('Asia/Jayapura', 'N'),
('Asia/Jerusalem', 'N'),
('Asia/Kabul', 'N'),
('Asia/Kamchatka', 'N'),
('Asia/Karachi', 'N'),
('Asia/Kashgar', 'N'),
('Asia/Kathmandu', 'N'),
('Asia/Katmandu', 'N'),
('Asia/Kolkata', 'N'),
('Asia/Krasnoyarsk', 'N'),
('Asia/Kuala_Lumpur', 'N'),
('Asia/Kuching', 'N'),
('Asia/Kuwait', 'N'),
('Asia/Macao', 'N'),
('Asia/Macau', 'N'),
('Asia/Magadan', 'N'),
('Asia/Makassar', 'N'),
('Asia/Manila', 'N'),
('Asia/Muscat', 'N'),
('Asia/Nicosia', 'N'),
('Asia/Novokuznetsk', 'N'),
('Asia/Novosibirsk', 'N'),
('Asia/Omsk', 'N'),
('Asia/Oral', 'N'),
('Asia/Phnom_Penh', 'N'),
('Asia/Pontianak', 'N'),
('Asia/Pyongyang', 'N'),
('Asia/Qatar', 'N'),
('Asia/Qyzylorda', 'N'),
('Asia/Rangoon', 'N'),
('Asia/Riyadh', 'N'),
('Asia/Saigon', 'N'),
('Asia/Sakhalin', 'N'),
('Asia/Samarkand', 'N'),
('Asia/Seoul', 'N'),
('Asia/Shanghai', 'N'),
('Asia/Singapore', 'N'),
('Asia/Taipei', 'N'),
('Asia/Tashkent', 'N'),
('Asia/Tbilisi', 'N'),
('Asia/Tehran', 'N'),
('Asia/Tel_Aviv', 'N'),
('Asia/Thimbu', 'N'),
('Asia/Thimphu', 'N'),
('Asia/Tokyo', 'N'),
('Asia/Ujung_Pandang', 'N'),
('Asia/Ulaanbaatar', 'N'),
('Asia/Ulan_Bator', 'N'),
('Asia/Urumqi', 'N'),
('Asia/Vientiane', 'N'),
('Asia/Vladivostok', 'N'),
('Asia/Yakutsk', 'N'),
('Asia/Yekaterinburg', 'N'),
('Asia/Yerevan', 'N'),
('Atlantic/Azores', 'N'),
('Atlantic/Bermuda', 'N'),
('Atlantic/Canary', 'N'),
('Atlantic/Cape_Verde', 'N'),
('Atlantic/Faeroe', 'N'),
('Atlantic/Faroe', 'N'),
('Atlantic/Jan_Mayen', 'N'),
('Atlantic/Madeira', 'N'),
('Atlantic/Reykjavik', 'N'),
('Atlantic/South_Georgia', 'N'),
('Atlantic/St_Helena', 'N'),
('Atlantic/Stanley', 'N'),
('Australia/ACT', 'N'),
('Australia/Adelaide', 'N'),
('Australia/Brisbane', 'N'),
('Australia/Broken_Hill', 'N'),
('Australia/Canberra', 'N'),
('Australia/Currie', 'N'),
('Australia/Darwin', 'N'),
('Australia/Eucla', 'N'),
('Australia/Hobart', 'N'),
('Australia/LHI', 'N'),
('Australia/Lindeman', 'N'),
('Australia/Lord_Howe', 'N'),
('Australia/Melbourne', 'N'),
('Australia/North', 'N'),
('Australia/NSW', 'N'),
('Australia/Perth', 'N'),
('Australia/Queensland', 'N'),
('Australia/South', 'N'),
('Australia/Sydney', 'N'),
('Australia/Tasmania', 'N'),
('Australia/Victoria', 'N'),
('Australia/West', 'N'),
('Australia/Yancowinna', 'N'),
('Europe/Amsterdam', 'N'),
('Europe/Andorra', 'N'),
('Europe/Athens', 'N'),
('Europe/Belfast', 'N'),
('Europe/Belgrade', 'N'),
('Europe/Berlin', 'N'),
('Europe/Bratislava', 'N'),
('Europe/Brussels', 'N'),
('Europe/Bucharest', 'N'),
('Europe/Budapest', 'N'),
('Europe/Chisinau', 'N'),
('Europe/Copenhagen', 'N'),
('Europe/Dublin', 'N'),
('Europe/Gibraltar', 'N'),
('Europe/Guernsey', 'N'),
('Europe/Helsinki', 'N'),
('Europe/Isle_of_Man', 'N'),
('Europe/Istanbul', 'N'),
('Europe/Jersey', 'N'),
('Europe/Kaliningrad', 'N'),
('Europe/Kiev', 'N'),
('Europe/Lisbon', 'N'),
('Europe/Ljubljana', 'N'),
('Europe/London', 'N'),
('Europe/Luxembourg', 'N'),
('Europe/Madrid', 'N'),
('Europe/Malta', 'N'),
('Europe/Mariehamn', 'N'),
('Europe/Minsk', 'N'),
('Europe/Monaco', 'N'),
('Europe/Moscow', 'N'),
('Europe/Nicosia', 'N'),
('Europe/Oslo', 'N'),
('Europe/Paris', 'N'),
('Europe/Podgorica', 'N'),
('Europe/Prague', 'N'),
('Europe/Riga', 'N'),
('Europe/Rome', 'N'),
('Europe/Samara', 'N'),
('Europe/San_Marino', 'N'),
('Europe/Sarajevo', 'N'),
('Europe/Simferopol', 'N'),
('Europe/Skopje', 'N'),
('Europe/Sofia', 'N'),
('Europe/Stockholm', 'N'),
('Europe/Tallinn', 'N'),
('Europe/Tirane', 'N'),
('Europe/Tiraspol', 'N'),
('Europe/Uzhgorod', 'N'),
('Europe/Vaduz', 'N'),
('Europe/Vatican', 'N'),
('Europe/Vienna', 'N'),
('Europe/Vilnius', 'N'),
('Europe/Volgograd', 'N'),
('Europe/Warsaw', 'N'),
('Europe/Zagreb', 'N'),
('Europe/Zaporozhye', 'N'),
('Europe/Zurich', 'N'),
('Indian/Antananarivo', 'N'),
('Indian/Chagos', 'N'),
('Indian/Christmas', 'N'),
('Indian/Cocos', 'N'),
('Indian/Comoro', 'N'),
('Indian/Kerguelen', 'N'),
('Indian/Mahe', 'N'),
('Indian/Maldives', 'N'),
('Indian/Mauritius', 'N'),
('Indian/Mayotte', 'N'),
('Indian/Reunion', 'N'),
('Pacific/Apia', 'N'),
('Pacific/Auckland', 'N'),
('Pacific/Chatham', 'N'),
('Pacific/Chuuk', 'N'),
('Pacific/Easter', 'N'),
('Pacific/Efate', 'N'),
('Pacific/Enderbury', 'N'),
('Pacific/Fakaofo', 'N'),
('Pacific/Fiji', 'N'),
('Pacific/Funafuti', 'N'),
('Pacific/Galapagos', 'N'),
('Pacific/Gambier', 'N'),
('Pacific/Guadalcanal', 'N'),
('Pacific/Guam', 'N'),
('Pacific/Honolulu', 'N'),
('Pacific/Johnston', 'N'),
('Pacific/Kiritimati', 'N'),
('Pacific/Kosrae', 'N'),
('Pacific/Kwajalein', 'N'),
('Pacific/Majuro', 'N'),
('Pacific/Marquesas', 'N'),
('Pacific/Midway', 'N'),
('Pacific/Nauru', 'N'),
('Pacific/Niue', 'N'),
('Pacific/Norfolk', 'N'),
('Pacific/Noumea', 'N'),
('Pacific/Pago_Pago', 'N'),
('Pacific/Palau', 'N'),
('Pacific/Pitcairn', 'N'),
('Pacific/Pohnpei', 'N'),
('Pacific/Ponape', 'N'),
('Pacific/Port_Moresby', 'N'),
('Pacific/Rarotonga', 'N'),
('Pacific/Saipan', 'N'),
('Pacific/Samoa', 'N'),
('Pacific/Tahiti', 'N'),
('Pacific/Tarawa', 'N'),
('Pacific/Tongatapu', 'N'),
('Pacific/Truk', 'N'),
('Pacific/Wake', 'N'),
('Pacific/Wallis', 'N'),
('Pacific/Yap', 'N');

-- --------------------------------------------------------

--
-- Table structure for table `userlevelpermissions`
--

CREATE TABLE `userlevelpermissions` (
  `User_Level_ID` int(11) NOT NULL,
  `Table_Name` varchar(255) NOT NULL,
  `Permission` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `userlevelpermissions`
--

INSERT INTO `userlevelpermissions` (`User_Level_ID`, `Table_Name`, `Permission`) VALUES
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}announcement', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}breadcrumblinks', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}help', 1512),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}help_categories', 1512),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}languages', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}settings', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}stats_counter', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}stats_counterlog', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}stats_date', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}stats_hour', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}stats_month', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}stats_year', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}themes', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}timezone', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}users', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}userlevelpermissions', 0),
(1, '{6C2D28B4-9AD2-4C08-A6B0-679C21196D80}userlevels', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_stock_items', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_suppliers', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_purchases', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_purchases_detail', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_customers', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_sales', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_sales_detail', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_payment_transactions', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_stock_categories', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_unit_of_measurement', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}announcement', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}breadcrumblinks', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}help', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}help_categories', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}languages', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}settings', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_counter', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_counterlog', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_date', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_hour', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_month', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_year', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}themes', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}timezone', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}userlevelpermissions', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}userlevels', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}users', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_sales_outstandings', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_purchases_outstandings', 8),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_sales_details', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_purchases_details', 0),
(1, '{B36B93AF-B58F-461B-B767-5F08C12493E9}dashboard.php', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_stock_items', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_suppliers', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_purchases', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_purchases_detail', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_customers', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_sales', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_sales_detail', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_payment_transactions', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_stock_categories', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}a_unit_of_measurement', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}announcement', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}breadcrumblinks', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}help', 104),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}help_categories', 104),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}languages', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}settings', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_counter', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_counterlog', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_date', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_hour', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_month', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}stats_year', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}themes', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}timezone', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}userlevelpermissions', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}userlevels', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}users', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_sales_outstandings', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_purchases_outstandings', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_sales_details', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}view_purchases_details', 0),
(-2, '{B36B93AF-B58F-461B-B767-5F08C12493E9}dashboard.php', 0);

-- --------------------------------------------------------

--
-- Table structure for table `userlevels`
--

CREATE TABLE `userlevels` (
  `User_Level_ID` int(11) NOT NULL,
  `User_Level_Name` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `userlevels`
--

INSERT INTO `userlevels` (`User_Level_ID`, `User_Level_Name`) VALUES
(-1, 'Administrator'),
(0, 'Default'),
(1, 'Standar'),
(-2, 'Anonymous');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `Username` varchar(50) NOT NULL,
  `Password` varchar(64) NOT NULL,
  `First_Name` varchar(50) DEFAULT NULL,
  `Last_Name` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `User_Level` int(11) DEFAULT NULL,
  `Report_To` int(11) DEFAULT NULL,
  `Activated` enum('N','Y') NOT NULL DEFAULT 'N',
  `Locked` enum('Y','N') DEFAULT 'N',
  `Profile` text,
  `Current_URL` text,
  `Theme` varchar(30) DEFAULT 'theme-default.css',
  `Menu_Horizontal` enum('N','Y') DEFAULT 'Y',
  `Table_Width_Style` enum('3','2','1') DEFAULT '2' COMMENT '1 = Scroll, 2 = Normal, 3 = 100%',
  `Scroll_Table_Width` int(11) DEFAULT '1100',
  `Scroll_Table_Height` int(11) DEFAULT '300',
  `Rows_Vertical_Align_Top` enum('Y','N') DEFAULT 'Y',
  `Language` char(2) DEFAULT 'en',
  `Redirect_To_Last_Visited_Page_After_Login` enum('Y','N') DEFAULT 'N',
  `Font_Name` varchar(50) DEFAULT 'arial',
  `Font_Size` varchar(4) DEFAULT '13px'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`Username`, `Password`, `First_Name`, `Last_Name`, `Email`, `User_Level`, `Report_To`, `Activated`, `Locked`, `Profile`, `Current_URL`, `Theme`, `Menu_Horizontal`, `Table_Width_Style`, `Scroll_Table_Width`, `Scroll_Table_Height`, `Rows_Vertical_Align_Top`, `Language`, `Redirect_To_Last_Visited_Page_After_Login`, `Font_Name`, `Font_Size`) VALUES
('Shehzad', '2b1e7a85ac4b64ede76028a280ab3a89', 'Shehzad', 'Mirza', 'shehzad@gmail.com', -1, NULL, 'Y', 'Y', 'a:8:{s:9:\"SessionID\";s:0:\"\";s:20:\"LastAccessedDateTime\";s:0:\"\";s:15:\"LoginRetryCount\";i:0;s:20:\"LastBadLoginDateTime\";s:0:\"\";s:18:\"RegisteredDateTime\";s:0:\"\";s:17:\"LastLoginDateTime\";s:0:\"\";s:18:\"LastLogoutDateTime\";s:19:\"2018/05/08 00:58:53\";s:23:\"LastPasswordChangedDate\";s:0:\"\";}', '/php_stock/dashboard.php', 'theme-maroon.css', 'Y', '2', 1100, 300, 'Y', 'en', 'N', 'arial', '14px');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_purchases_details`
-- (See below for the actual view)
--
CREATE TABLE `view_purchases_details` (
`Purchase_ID` int(11)
,`Purchase_Number` varchar(20)
,`Supplier_Number` varchar(20)
,`Stock_Item` varchar(15)
,`Purchasing_Quantity` double(20,0)
,`Purchasing_Price` double(20,0)
,`Selling_Price` double(20,0)
,`Purchasing_Total_Amount` double(20,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_purchases_outstandings`
-- (See below for the actual view)
--
CREATE TABLE `view_purchases_outstandings` (
`Purchase_ID` int(11)
,`Purchase_Number` varchar(20)
,`Purchase_Date` datetime
,`Supplier_ID` varchar(20)
,`Notes` varchar(50)
,`Total_Amount` double(20,0)
,`Total_Payment` double(20,0)
,`Total_Balance` double(20,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_sales_details`
-- (See below for the actual view)
--
CREATE TABLE `view_sales_details` (
`Sales_ID` int(11)
,`Sales_Number` varchar(20)
,`Supplier_Number` varchar(20)
,`Stock_Item` varchar(15)
,`Sales_Quantity` double
,`Purchasing_Price` double
,`Sales_Price` double
,`Sales_Total_Amount` double
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_sales_outstandings`
-- (See below for the actual view)
--
CREATE TABLE `view_sales_outstandings` (
`Sales_ID` int(11)
,`Sales_Number` varchar(20)
,`Sales_Date` datetime
,`Customer_ID` varchar(20)
,`Notes` varchar(50)
,`Total_Amount` double
,`Total_Payment` double
,`Total_Balance` double
,`Discount_Type` char(1)
,`Discount_Percentage` double
,`Discount_Amount` double
,`Tax_Percentage` double
,`Tax_Description` varchar(50)
,`Final_Total_Amount` double
);

-- --------------------------------------------------------

--
-- Structure for view `view_purchases_details`
--
DROP TABLE IF EXISTS `view_purchases_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_purchases_details`  AS  select `a_purchases_detail`.`Purchase_ID` AS `Purchase_ID`,`a_purchases_detail`.`Purchase_Number` AS `Purchase_Number`,`a_purchases_detail`.`Supplier_Number` AS `Supplier_Number`,`a_purchases_detail`.`Stock_Item` AS `Stock_Item`,`a_purchases_detail`.`Purchasing_Quantity` AS `Purchasing_Quantity`,`a_purchases_detail`.`Purchasing_Price` AS `Purchasing_Price`,`a_purchases_detail`.`Selling_Price` AS `Selling_Price`,`a_purchases_detail`.`Purchasing_Total_Amount` AS `Purchasing_Total_Amount` from `a_purchases_detail` ;

-- --------------------------------------------------------

--
-- Structure for view `view_purchases_outstandings`
--
DROP TABLE IF EXISTS `view_purchases_outstandings`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_purchases_outstandings`  AS  select `a_purchases`.`Purchase_ID` AS `Purchase_ID`,`a_purchases`.`Purchase_Number` AS `Purchase_Number`,`a_purchases`.`Purchase_Date` AS `Purchase_Date`,`a_purchases`.`Supplier_ID` AS `Supplier_ID`,`a_purchases`.`Notes` AS `Notes`,`a_purchases`.`Total_Amount` AS `Total_Amount`,`a_purchases`.`Total_Payment` AS `Total_Payment`,`a_purchases`.`Total_Balance` AS `Total_Balance` from `a_purchases` where (`a_purchases`.`Total_Balance` <> 0) ;

-- --------------------------------------------------------

--
-- Structure for view `view_sales_details`
--
DROP TABLE IF EXISTS `view_sales_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_sales_details`  AS  select `a_sales_detail`.`Sales_ID` AS `Sales_ID`,`a_sales_detail`.`Sales_Number` AS `Sales_Number`,`a_sales_detail`.`Supplier_Number` AS `Supplier_Number`,`a_sales_detail`.`Stock_Item` AS `Stock_Item`,`a_sales_detail`.`Sales_Quantity` AS `Sales_Quantity`,`a_sales_detail`.`Purchasing_Price` AS `Purchasing_Price`,`a_sales_detail`.`Sales_Price` AS `Sales_Price`,`a_sales_detail`.`Sales_Total_Amount` AS `Sales_Total_Amount` from `a_sales_detail` ;

-- --------------------------------------------------------

--
-- Structure for view `view_sales_outstandings`
--
DROP TABLE IF EXISTS `view_sales_outstandings`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_sales_outstandings`  AS  select `a_sales`.`Sales_ID` AS `Sales_ID`,`a_sales`.`Sales_Number` AS `Sales_Number`,`a_sales`.`Sales_Date` AS `Sales_Date`,`a_sales`.`Customer_ID` AS `Customer_ID`,`a_sales`.`Notes` AS `Notes`,`a_sales`.`Total_Amount` AS `Total_Amount`,`a_sales`.`Total_Payment` AS `Total_Payment`,`a_sales`.`Total_Balance` AS `Total_Balance`,`a_sales`.`Discount_Type` AS `Discount_Type`,`a_sales`.`Discount_Percentage` AS `Discount_Percentage`,`a_sales`.`Discount_Amount` AS `Discount_Amount`,`a_sales`.`Tax_Percentage` AS `Tax_Percentage`,`a_sales`.`Tax_Description` AS `Tax_Description`,`a_sales`.`Final_Total_Amount` AS `Final_Total_Amount` from `a_sales` where (`a_sales`.`Total_Balance` <> 0) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcement`
--
ALTER TABLE `announcement`
  ADD PRIMARY KEY (`Announcement_ID`);

--
-- Indexes for table `a_customers`
--
ALTER TABLE `a_customers`
  ADD PRIMARY KEY (`Customer_ID`);

--
-- Indexes for table `a_payment_transactions`
--
ALTER TABLE `a_payment_transactions`
  ADD PRIMARY KEY (`Payment_ID`);

--
-- Indexes for table `a_purchases`
--
ALTER TABLE `a_purchases`
  ADD PRIMARY KEY (`Purchase_ID`),
  ADD KEY `TSupplierTBeli` (`Supplier_ID`);

--
-- Indexes for table `a_purchases_detail`
--
ALTER TABLE `a_purchases_detail`
  ADD PRIMARY KEY (`Purchase_ID`),
  ADD KEY `TBarangTDBeli` (`Stock_Item`),
  ADD KEY `TBeliTDBeli` (`Purchase_Number`);

--
-- Indexes for table `a_sales`
--
ALTER TABLE `a_sales`
  ADD PRIMARY KEY (`Sales_ID`),
  ADD UNIQUE KEY `NoFaktur` (`Sales_Number`),
  ADD KEY `TCustomerTJual` (`Customer_ID`);

--
-- Indexes for table `a_sales_detail`
--
ALTER TABLE `a_sales_detail`
  ADD PRIMARY KEY (`Sales_ID`),
  ADD KEY `TBarangTDJual` (`Stock_Item`),
  ADD KEY `TJualTDJual` (`Sales_Number`);

--
-- Indexes for table `a_stock_categories`
--
ALTER TABLE `a_stock_categories`
  ADD PRIMARY KEY (`Category_ID`);

--
-- Indexes for table `a_stock_items`
--
ALTER TABLE `a_stock_items`
  ADD PRIMARY KEY (`Stock_ID`);

--
-- Indexes for table `a_suppliers`
--
ALTER TABLE `a_suppliers`
  ADD PRIMARY KEY (`Supplier_ID`),
  ADD UNIQUE KEY `KodeCust` (`Supplier_Number`);

--
-- Indexes for table `a_unit_of_measurement`
--
ALTER TABLE `a_unit_of_measurement`
  ADD PRIMARY KEY (`UOM_ID`);

--
-- Indexes for table `breadcrumblinks`
--
ALTER TABLE `breadcrumblinks`
  ADD PRIMARY KEY (`Page_Title`);

--
-- Indexes for table `help`
--
ALTER TABLE `help`
  ADD PRIMARY KEY (`Help_ID`);

--
-- Indexes for table `help_categories`
--
ALTER TABLE `help_categories`
  ADD PRIMARY KEY (`Category_ID`);

--
-- Indexes for table `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`Language_Code`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`Option_ID`);

--
-- Indexes for table `stats_counter`
--
ALTER TABLE `stats_counter`
  ADD PRIMARY KEY (`Type`,`Variable`);

--
-- Indexes for table `stats_counterlog`
--
ALTER TABLE `stats_counterlog`
  ADD PRIMARY KEY (`IP_Address`);

--
-- Indexes for table `stats_date`
--
ALTER TABLE `stats_date`
  ADD PRIMARY KEY (`Date`,`Month`,`Year`);

--
-- Indexes for table `stats_hour`
--
ALTER TABLE `stats_hour`
  ADD PRIMARY KEY (`Date`,`Hour`,`Month`,`Year`);

--
-- Indexes for table `stats_month`
--
ALTER TABLE `stats_month`
  ADD PRIMARY KEY (`Year`,`Month`);

--
-- Indexes for table `stats_year`
--
ALTER TABLE `stats_year`
  ADD PRIMARY KEY (`Year`);

--
-- Indexes for table `themes`
--
ALTER TABLE `themes`
  ADD PRIMARY KEY (`Theme_ID`);

--
-- Indexes for table `timezone`
--
ALTER TABLE `timezone`
  ADD PRIMARY KEY (`Timezone`);

--
-- Indexes for table `userlevelpermissions`
--
ALTER TABLE `userlevelpermissions`
  ADD PRIMARY KEY (`User_Level_ID`,`Table_Name`);

--
-- Indexes for table `userlevels`
--
ALTER TABLE `userlevels`
  ADD PRIMARY KEY (`User_Level_ID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`Username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcement`
--
ALTER TABLE `announcement`
  MODIFY `Announcement_ID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `a_customers`
--
ALTER TABLE `a_customers`
  MODIFY `Customer_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `a_payment_transactions`
--
ALTER TABLE `a_payment_transactions`
  MODIFY `Payment_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `a_purchases`
--
ALTER TABLE `a_purchases`
  MODIFY `Purchase_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `a_purchases_detail`
--
ALTER TABLE `a_purchases_detail`
  MODIFY `Purchase_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `a_sales`
--
ALTER TABLE `a_sales`
  MODIFY `Sales_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `a_sales_detail`
--
ALTER TABLE `a_sales_detail`
  MODIFY `Sales_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `a_stock_categories`
--
ALTER TABLE `a_stock_categories`
  MODIFY `Category_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `a_stock_items`
--
ALTER TABLE `a_stock_items`
  MODIFY `Stock_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `a_suppliers`
--
ALTER TABLE `a_suppliers`
  MODIFY `Supplier_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `Option_ID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
