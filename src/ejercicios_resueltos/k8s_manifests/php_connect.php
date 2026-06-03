<?php
/**
 * Simple PHP TCP/IP socket connection example
 * Connects to a given host and port, sends a message, and reads the response.
 */

// Configuration
$host = "mysql-pod"; // Replace with your target host
$port = 80;            // Replace with your target port
$timeout = 5;          // Connection timeout in seconds

// Attempt to open a socket connection
$socket = @fsockopen($host, $port, $errno, $errstr, $timeout);

if (!$socket) {
    // Connection failed
    echo "Error: Unable to connect to $host on port $port\n";
    echo "Reason: [$errno] $errstr\n";
    exit(1);
}

echo "Connected to $host on port $port\n";
