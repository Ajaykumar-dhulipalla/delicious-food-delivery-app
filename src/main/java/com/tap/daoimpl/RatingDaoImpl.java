package com.tap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import com.tap.dao.RatingDao;
import com.tap.model.Rating;
import com.tap.util.DBConnection;

public class RatingDaoImpl implements RatingDao {

    private static final String INSERT_RATING = 
        "INSERT INTO `order_ratings` (`order_id`, `user_id`, `rating`, `tags`, `comment`) VALUES (?, ?, ?, ?, ?)";
    
    private static final String GET_RATING_BY_ORDER_ID = 
        "SELECT * FROM `order_ratings` WHERE `order_id` = ?";

    private static final String GET_ALL_RATINGS = 
        "SELECT * FROM `order_ratings`";

    @Override
    public boolean addRating(Rating rating) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_RATING)) {

            ps.setInt(1, rating.getOrderId());
            ps.setInt(2, rating.getUserId());
            ps.setInt(3, rating.getRating());
            ps.setString(4, rating.getTags());
            ps.setString(5, rating.getComment());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Rating getRatingByOrderId(int orderId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(GET_RATING_BY_ORDER_ID)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractRating(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Map<Integer, Rating> getAllRatingsMap() {
        Map<Integer, Rating> map = new HashMap<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(GET_ALL_RATINGS);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Rating r = extractRating(rs);
                map.put(r.getOrderId(), r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    private Rating extractRating(ResultSet rs) throws SQLException {
        Rating r = new Rating();
        r.setRatingId(rs.getInt("rating_id"));
        r.setOrderId(rs.getInt("order_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRating(rs.getInt("rating"));
        r.setTags(rs.getString("tags"));
        r.setComment(rs.getString("comment"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }
}