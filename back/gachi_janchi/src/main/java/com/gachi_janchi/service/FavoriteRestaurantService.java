package com.gachi_janchi.service;

import com.gachi_janchi.dto.AddFavoriteRestaurantRequest;
import com.gachi_janchi.dto.AddFavoriteRestaurantResponse;
import com.gachi_janchi.dto.DeleteFavoriteRestaurantRequest;
import com.gachi_janchi.dto.DeleteFavoriteRestaurantResponse;
import com.gachi_janchi.entity.FavoriteRestaurant;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.FavoriteRestaurantRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FavoriteRestaurantService {
  private final FavoriteRestaurantRepository favoriteRestaurantRepository;
  private final RestaurantRepository restaurantRepository;
  private final JwtProvider jwtProvider;
  private final UserRepository userRepository;

  @Transactional
  public AddFavoriteRestaurantResponse addFavoriteRestaurant(AddFavoriteRestaurantRequest addFavoriteRestaurantRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String id = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));

    String restaurantId = addFavoriteRestaurantRequest.getRestaurantId();
    String userId = user.getId();

    // 음식점이 존재하는지 확인
    Restaurant restaurant = restaurantRepository.findById(restaurantId).orElseThrow(() -> new IllegalArgumentException("해당 음식점이 존재하지 않습니다. - " + restaurantId));

    // 이미 즐겨찾기 되어있는지 확인
    if (favoriteRestaurantRepository.findByUserIdAndRestaurantId(userId, restaurantId).isPresent()) {
      throw new IllegalArgumentException("이미 즐겨찾기한 음식점입니다.");
    }

    FavoriteRestaurant favoriteRestaurant = new FavoriteRestaurant(
            UUID.randomUUID().toString(),
            userId,
            restaurantId
    );
    favoriteRestaurantRepository.save(favoriteRestaurant);
    return new AddFavoriteRestaurantResponse("즐겨찾기 추가 완료");
  }


  // 특정 사용자의 즐겨찾기 목록 조회
  public List<FavoriteRestaurant> getUserFavorites(String userId) {
    return favoriteRestaurantRepository.findByUserId(userId);
  }

  // 즐겨찾기 삭제

  @Transactional
  public DeleteFavoriteRestaurantResponse deleteFavoriteRestaurant(DeleteFavoriteRestaurantRequest deleteFavoriteRestaurantRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String id = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));

    String restaurantId = deleteFavoriteRestaurantRequest.getRestaurantId();
    String userId = user.getId();

    if (favoriteRestaurantRepository.findByUserIdAndRestaurantId(userId, restaurantId).isEmpty()) {
      throw new IllegalArgumentException("해당 즐겨찾기가 존재하지 않습니다.");
    }
    favoriteRestaurantRepository.deleteByUserIdAndRestaurantId(userId, restaurantId);
    return new DeleteFavoriteRestaurantResponse("즐겨찾기 삭제 완료");
  }
}
