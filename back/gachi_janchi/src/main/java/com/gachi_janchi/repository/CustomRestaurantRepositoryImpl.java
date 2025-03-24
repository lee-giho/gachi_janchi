package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Restaurant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CustomRestaurantRepositoryImpl implements CustomRestaurantRepository{

  private final MongoTemplate mongoTemplate;

  public CustomRestaurantRepositoryImpl(MongoTemplate mongoTemplate) {
    this.mongoTemplate = mongoTemplate;
  }

  @Override
  public List<Restaurant> searchRestaurants(String keyword) {
    Criteria criteria = new Criteria().orOperator(
            Criteria.where("restaurantName").regex(keyword, "i"),
            Criteria.where("categories").regex(keyword, "i"),
            Criteria.where("menu.name").regex(keyword, "i")
    );
    Query query = new Query(criteria);
    return mongoTemplate.find(query, Restaurant.class);
  }
}
