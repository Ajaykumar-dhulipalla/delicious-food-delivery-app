package com.tap.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/delecious_db";
    private static final String USERNAME = "root";      // Change to your MySQL username
    private static final String PASSWORD = "root";      // Change to your MySQL password

    public static Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return connection;
    }
    public static void main(String[] args) {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            System.out.println("Connection Successful! Java and MySQL are connected.");
        } else {
            System.out.println("Connection Failed. Check your URL, username, and password.");
        }
    }
}