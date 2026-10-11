package com.tap.model;

import java.sql.Timestamp;

public class Rating {
    private int ratingId;
    private int orderId;
    private int userId;
    private int rating;
    private String tags;
    private String comment;
    private Timestamp createdAt;

    public Rating() {}

    public Rating(int orderId, int userId, int rating, String tags, String comment) {
        this.orderId = orderId;
        this.userId = userId;
        this.rating = rating;
        this.tags = tags;
        this.comment = comment;
    }

    public int getRatingId() { return ratingId; }
    public void setRatingId(int ratingId) { this.ratingId = ratingId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}