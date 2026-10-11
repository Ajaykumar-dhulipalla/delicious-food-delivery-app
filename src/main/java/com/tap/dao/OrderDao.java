package com.tap.dao;

import java.util.List;
import com.tap.model.Order;

public interface OrderDao {
    int addOrder(Order order);
    Order getOrder(int orderId);
    List<Order> getOrdersByUser(int userId);
    List<Order> getAllOrders();
    int updateOrderStatus(int orderId, String status);
    int getOrderCountByUserId(int userId);
    
    // New method for floating live order toast
    Order getActiveOrderByUserId(int userId);
}