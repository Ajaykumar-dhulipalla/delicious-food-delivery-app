package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.RestaurantDao;
import com.tap.model.Restaurant;
import com.tap.util.DBConnection;

public class RestaurantDaoImpl implements RestaurantDao {

    private static final String INSERT_RESTAURANT = "INSERT INTO `Restaurant` (`name`, `cuisineType`, `deliveryTime`, `address`, `adminUserId`, `rating`, `isActive`, `imagePath`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private static final String SELECT_RESTAURANT_BY_ID = "SELECT * FROM `Restaurant` WHERE `restaurantId` = ?";
    private static final String SELECT_ALL_RESTAURANTS = "SELECT * FROM `Restaurant`";
    private static final String SEARCH_RESTAURANTS = "SELECT * FROM `Restaurant` WHERE `name` LIKE ? OR `cuisineType` LIKE ?";
    private static final String UPDATE_RESTAURANT = "UPDATE `Restaurant` SET `name` = ?, `cuisineType` = ?, `deliveryTime` = ?, `address` = ?, `adminUserId` = ?, `rating` = ?, `isActive` = ?, `imagePath` = ? WHERE `restaurantId` = ?";
    private static final String DELETE_RESTAURANT = "DELETE FROM `Restaurant` WHERE `restaurantId` = ?";
    private static final String UPDATE_RATING_ONLY = "UPDATE `Restaurant` SET `rating` = ? WHERE `restaurantId` = ?";

    @Override
    public int addRestaurant(Restaurant restaurant) {
        int status = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_RESTAURANT)) {

            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setInt(3, restaurant.getDeliveryTime());
            ps.setString(4, restaurant.getAddress());
            ps.setInt(5, restaurant.getAdminUserId());
            ps.setDouble(6, restaurant.getRating());
            ps.setBoolean(7, restaurant.getIsActive());
            ps.setString(8, restaurant.getImagePath());

            status = ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }

    @Override
    public Restaurant getRestaurant(int restaurantId) {
        Restaurant restaurant = null;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_RESTAURANT_BY_ID)) {

            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    restaurant = extractRestaurantFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return restaurant;
    }

    @Override
    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(SELECT_ALL_RESTAURANTS)) {

            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Restaurant> searchRestaurants(String keyword) {
        List<Restaurant> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SEARCH_RESTAURANTS)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractRestaurantFromResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int updateRestaurant(Restaurant restaurant) {
        int status = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE_RESTAURANT)) {

            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setInt(3, restaurant.getDeliveryTime());
            ps.setString(4, restaurant.getAddress());
            ps.setInt(5, restaurant.getAdminUserId());
            ps.setDouble(6, restaurant.getRating());
            ps.setBoolean(7, restaurant.getIsActive());
            ps.setString(8, restaurant.getImagePath());
            ps.setInt(9, restaurant.getRestaurantId());

            status = ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }

    @Override
    public int deleteRestaurant(int restaurantId) {
        int status = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(DELETE_RESTAURANT)) {

            ps.setInt(1, restaurantId);
            status = ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }

    @Override
    public double getAverageRating(int restaurantId) {
        String sql = "SELECT AVG(r.rating) AS avgRating "
                   + "FROM `order_ratings` r "
                   + "JOIN `orders` o ON r.order_id = o.orderId "
                   + "WHERE o.restaurantId = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble("avgRating");
                    if (!rs.wasNull() && avg > 0) {
                        return Math.round(avg * 10.0) / 10.0;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Fallback: If no orders have been reviewed yet, return the default rating from Restaurant table
        Restaurant res = getRestaurant(restaurantId);
        return (res != null) ? res.getRating() : 4.5;
    }

    @Override
    public int getReviewCount(int restaurantId) {
        String sql = "SELECT COUNT(r.rating_id) AS reviewCount "
                   + "FROM `order_ratings` r "
                   + "JOIN `orders` o ON r.order_id = o.orderId "
                   + "WHERE o.restaurantId = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("reviewCount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean updateRestaurantRating(int restaurantId, double newRating) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE_RATING_ONLY)) {

            ps.setDouble(1, Math.round(newRating * 10.0) / 10.0);
            ps.setInt(2, restaurantId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean syncRestaurantAverageRating(int restaurantId) {
        double avg = getAverageRating(restaurantId);
        return updateRestaurantRating(restaurantId, avg);
    }

    private Restaurant extractRestaurantFromResultSet(ResultSet rs) throws Exception {
        return new Restaurant(
            rs.getInt("restaurantId"),
            rs.getString("name"),
            rs.getString("cuisineType"),
            rs.getInt("deliveryTime"),
            rs.getString("address"),
            rs.getInt("adminUserId"),
            rs.getDouble("rating"),
            rs.getBoolean("isActive"),
            rs.getString("imagePath")
        );
    }
}