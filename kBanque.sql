CREATE TABLE `transactions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(50) NOT NULL,
    `type` varchar(50) NOT NULL,
    `amount` int(11) NOT NULL,
    `date` datetime NOT NULL,
    PRIMARY KEY (`id`)
);