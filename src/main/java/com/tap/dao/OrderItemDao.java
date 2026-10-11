package com.tap.dao;

import java.util.List;
import com.tap.model.OrderItem;

public interface OrderItemDao {
    int addOrderItem(OrderItem orderItem);
    OrderItem getOrderItem(int orderItemId);
    List<OrderItem> getOrderItemsByOrder(int orderId);
}