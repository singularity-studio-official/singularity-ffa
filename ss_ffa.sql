CREATE TABLE IF NOT EXISTS `ss_ffa_stats` (
    `citizenid` varchar(50) NOT NULL,
    `kills` int(11) NOT NULL DEFAULT 0,
    `deaths` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
