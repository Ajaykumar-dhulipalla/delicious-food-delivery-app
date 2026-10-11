package com.tap.dao;

import java.util.List;
import com.tap.model.Menu;

public interface MenuDao {
    int addMenu(Menu menu);
    Menu getMenu(int menuId);
    List<Menu> getAllMenusByRestaurant(int restaurantId);
    int updateMenu(Menu menu);
    int deleteMenu(int menuId);
}