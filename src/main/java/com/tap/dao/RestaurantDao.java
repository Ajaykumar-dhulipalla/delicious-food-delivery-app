package com.tap.dao;

import java.util.List;
import com.tap.model.Restaurant;

public interface RestaurantDao {
    int addRestaurant(Restaurant restaurant);
    Restaurant getRestaurant(int restaurantId);
    List<Restaurant> getAllRestaurants();
    List<Restaurant> searchRestaurants(String keyword);
    int updateRestaurant(Restaurant restaurant);
    int deleteRestaurant(int restaurantId);
    
    // Dynamic review aggregation methods
    double getAverageRating(int restaurantId);
    int getReviewCount(int restaurantId);

    // Dynamic rating sync methods
    boolean updateRestaurantRating(int restaurantId, double newRating);
    boolean syncRestaurantAverageRating(int restaurantId);
}