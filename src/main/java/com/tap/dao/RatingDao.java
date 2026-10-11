package com.tap.dao;

import java.util.Map;
import com.tap.model.Rating;

public interface RatingDao {
    boolean addRating(Rating rating);
    Rating getRatingByOrderId(int orderId);
    Map<Integer, Rating> getAllRatingsMap();
}