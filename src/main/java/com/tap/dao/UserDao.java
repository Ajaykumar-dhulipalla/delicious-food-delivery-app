package com.tap.dao;

import java.util.List;
import com.tap.model.User;

public interface UserDao {
    int addUser(User user);
    User getUser(int userId);
    User getUserByEmail(String email);
    List<User> getAllUsers();
    int updateUser(User user);
    int updateProfile(int userId, String username, String phone, String address);
    int updatePassword(int userId, String newPassword);
    int deleteUser(int userId);
}