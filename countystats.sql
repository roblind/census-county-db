-- MySQL dump 10.13  Distrib 5.1.36, for Win32 (ia32)
--
-- Host: localhost    Database: security_dev
-- ------------------------------------------------------
-- Server version	5.1.36-community-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `useraddrs`
--

DROP TABLE IF EXISTS `countystats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countystats` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fipscd` varchar(5) DEFAULT NULL,
  `popu_2010` int(10) unsigned DEFAULT 0,
  `popu_pct_chg_10yr` decimal(3,1) signed DEFAULT 0,
  `popu_2000` int(10) unsigned DEFAULT 0,
  `popu_pct_under5` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_under18` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_over65` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_female` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_white` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_black` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_indig` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_asian` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_island` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_multiracial` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_hispanic` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_white_nonhisp` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_samehome_1yrplus` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_foreign_born` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_hsgrad_over25` decimal(3,1) unsigned DEFAULT 0,
  `popu_pct_bachdeg_over25` decimal(3,1) unsigned DEFAULT 0,
  `nbr_of_vets` int(10) unsigned DEFAULT 0,
  `mean_minutes_to_work` decimal(4,1) unsigned DEFAULT 0,
  `housing_units` int(10) unsigned DEFAULT 0,
  `homeower_pct` decimal(3,1) unsigned DEFAULT 0,
  `housing_units_pct_multiunit` decimal(3,1) unsigned DEFAULT 0,
  `median_val_ownocc` int(10) unsigned DEFAULT 0,
  `nbr_of_households` int(10) unsigned DEFAULT 0,
  `persons_per_household` decimal(3,1) unsigned DEFAULT 0,
  `per_cap_inc_past12mths` int(10) unsigned DEFAULT 0,
  `median_household_inc` int(10) unsigned DEFAULT 0,
  `popu_pct_below_poverty` decimal(3,1) unsigned DEFAULT 0,
  `priv_nonfarm_estabs` int(10) unsigned DEFAULT 0,
  `priv_nonfarm_employment` int(10) unsigned DEFAULT 0,
  `priv_nonfarm_employment_pct_chg_9yr` decimal(3,1) signed DEFAULT 0,
  `nonemployer_estabs` int(10) unsigned DEFAULT 0,
  `total_firms` int(10) unsigned DEFAULT 0,
  `black_owned_firms_pct` decimal(3,1) unsigned DEFAULT 0,
  `asian_owned_firms_pct` decimal(3,1) unsigned DEFAULT 0,
  `hispanic_owned_firms_pct` decimal(3,1) unsigned DEFAULT 0,
  `women_owned_firms_pct` decimal(3,1) unsigned DEFAULT 0,
  `manufacturer_shipments` int(10) unsigned DEFAULT 0,
  `wholesale_sales` int(10) unsigned DEFAULT 0,
  `retail_sales` int(10) unsigned DEFAULT 0,
  `retail_sales_per_cap` int(10) unsigned DEFAULT 0,
  `accomo_food_sales` int(10) unsigned DEFAULT 0,
  `building_permits` int(10) unsigned DEFAULT 0,
  `fed_spending` int(10) unsigned DEFAULT 0,
  `area_sq_mi` decimal(8,2) unsigned DEFAULT 0,
  `persons_per_sq_mi` decimal(8,2) unsigned DEFAULT 0,
  
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;