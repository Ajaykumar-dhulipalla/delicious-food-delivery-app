package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.OrderItemDao;
import com.tap.model.OrderItem;
import com.tap.util.DBConnection;

public class OrderItemDaoImpl implements OrderItemDao {

    // Using lowercase `orderitem` matching your MySQL database table
    private static final String INSERT_ORDER_ITEM = 
        "INSERT INTO `orderitem` (`orderId`, `menuId`, `totalAmount`) VALUES (?, ?, ?)";
        
    private static final String SELECT_ORDER_ITEM_BY_ID = 
        "SELECT * FROM `orderitem` WHERE `orderItemId` = ?";
        
    private static final String SELECT_ITEMS_BY_ORDER_ID = 
        "SELECT * FROM `orderitem` WHERE `orderId` = ?";

    @Override
    public int addOrderItem(OrderItem orderItem) {
        int status = 0;
        System.out.println("--> [OrderItemDao] Attempting to insert OrderItem for Order ID: " 
                + orderItem.getOrderId() 
                + ", Menu ID: " + orderItem.getMenuId() 
                + ", Total: " + orderItem.getTotalAmount());

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_ORDER_ITEM)) {

            ps.setInt(1, orderItem.getOrderId());
            ps.setInt(2, orderItem.getMenuId());
            ps.setDouble(3, orderItem.getTotalAmount());

            status = ps.executeUpdate();
            System.out.println("--> [OrderItemDao] Success: " + status + " item row inserted.");
        } catch (SQLException e) {
            System.err.println("!!! [OrderItemDao] SQL EXCEPTION DURING INSERT !!!");
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("!!! [OrderItemDao] GENERAL EXCEPTION DURING INSERT !!!");
            e.printStackTrace();
        }
        return status;
    }

    @Override
    public OrderItem getOrderItem(int orderItemId) {
        OrderItem orderItem = null;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_ORDER_ITEM_BY_ID)) {

            ps.setInt(1, orderItemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orderItem = extractOrderItemFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orderItem;
    }

    @Override
    public List<OrderItem> getOrderItemsByOrder(int orderId) {
        List<OrderItem> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_ITEMS_BY_ORDER_ID)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderItemFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private OrderItem extractOrderItemFromResultSet(ResultSet rs) throws SQLException {
        return new OrderItem(
            rs.getInt("orderItemId"),
            rs.getInt("orderId"),
            rs.getInt("menuId"),
            rs.getDouble("totalAmount")
        );
    }
}