package com.gachi_janchi.service;

import com.gachi_janchi.dto.RestaurantWithIngredientDto;
import com.gachi_janchi.dto.RestaurantsByBoundsResponse;
import com.gachi_janchi.dto.RestaurantsByDongResponse;
import com.gachi_janchi.dto.RestaurantsByKeywordResponse;
import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.repository.RestaurantIngredientRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RestaurantService {
  @Autowired
  private RestaurantRepository restaurantRepository;

  @Autowired
  private RestaurantIngredientRepository restaurantIngredientRepository;

  @Autowired
  private IngredientService ingredientService;

  // dong을 기준으로 Restaurant 찾기
  public RestaurantsByDongResponse findRestaurantsByDong(String dong) {
    List<Restaurant> restaurants = restaurantRepository.findByAddress_Dong(dong);
    return new RestaurantsByDongResponse(restaurants);
  }

  // 지도에 보이는 영역을 기준으로 Restaurant 찾기
  public RestaurantsByBoundsResponse findRestaurantsInBounds(double latMin, double latMax, double lonMin, double lonMax) {
    List<Restaurant> restaurants = restaurantRepository.findByLocationLatitudeBetweenAndLocationLongitudeBetween(latMin, latMax, lonMin, lonMax);

    List<RestaurantWithIngredientDto> restaurantWithIngredientDtos = restaurants.stream()
            .map(restaurant -> {
              Ingredient ingredient = ingredientService.findIngredientByRestaurantId(restaurant.getId());
              return RestaurantWithIngredientDto.from(restaurant, ingredient);
            })
            .collect(Collectors.toList());

    return new RestaurantsByBoundsResponse(restaurantWithIngredientDtos);
  }

  // 검색어로 Restaurant 찾기
  public RestaurantsByKeywordResponse findRestaurantsByKeyword(String keyword) {
    List<Restaurant> restaurants = restaurantRepository.searchRestaurants(keyword);
    return new RestaurantsByKeywordResponse(restaurants);
  }

  // Restaurant 삭세 / 동시에 restaurantIngredient에서도 삭제
  @Transactional
  public void deleteRestaurant(String restaurantId) {
    // MySQL의 restaurant_ingredients에서 먼저 삭제
    restaurantIngredientRepository.deleteByRestaurantId(restaurantId);

    // MongoDB에서 음식점 삭제
    restaurantRepository.deleteById(restaurantId);

    System.out.println("음식점 삭제 완료: " + restaurantId);
  }
}
