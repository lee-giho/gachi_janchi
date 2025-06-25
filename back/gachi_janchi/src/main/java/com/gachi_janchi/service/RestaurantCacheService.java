package com.gachi_janchi.service;

import com.gachi_janchi.dto.RestaurantWithIngredientAndReviewCountDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RestaurantCacheService {
  private final RedisTemplate<String, Object> redisTemplate;

  private final static String PREFIX = "restaurant:";

  private final static int TTL_VALUE = 10;

  public void cacheRestaurant(RestaurantWithIngredientAndReviewCountDto dto) {
    String key = PREFIX + dto.getId();
    redisTemplate.opsForValue().set(key, dto, Duration.ofMinutes(TTL_VALUE));
  }

  public RestaurantWithIngredientAndReviewCountDto getRestaurant(String id) {
    return (RestaurantWithIngredientAndReviewCountDto) redisTemplate.opsForValue().get(PREFIX + id);
  }

  public List<RestaurantWithIngredientAndReviewCountDto> getRestaurants(List<String> ids) {
    List<String> keys = ids.stream().map(id -> PREFIX + id).toList();
    List<Object> values = redisTemplate.opsForValue().multiGet(keys);
    return values.stream()
      .filter(Objects::nonNull)
      .map(obj -> (RestaurantWithIngredientAndReviewCountDto) obj)
      .toList();
  }

  public void cacheRestaurants(List<RestaurantWithIngredientAndReviewCountDto> dtos) {
    for (RestaurantWithIngredientAndReviewCountDto dto : dtos) {
      String key = PREFIX + dto.getId();
      redisTemplate.opsForValue().set(key, dto, Duration.ofMinutes(TTL_VALUE));
    }
  }
}
