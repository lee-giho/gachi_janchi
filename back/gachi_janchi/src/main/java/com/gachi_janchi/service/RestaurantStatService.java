package com.gachi_janchi.service;

import com.gachi_janchi.entity.RestaurantStat;
import com.gachi_janchi.entity.Review;
import com.gachi_janchi.event.ReviewUpdateEvent;
import com.gachi_janchi.repository.RestaurantStatRepository;
import com.gachi_janchi.repository.ReviewRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.List;

@Slf4j
@Service
public class RestaurantStatService {

  @Autowired
  private RestaurantStatRepository restaurantStatRepository;

  @Autowired
  private ReviewRepository reviewRepository;

  @Async
  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
  public void handleReviewUpdatedEvent(ReviewUpdateEvent event) {
    String restaurantId = event.getRestaurantId();
    try {
      List<Review> reviews = reviewRepository.findByRestaurantId(restaurantId);

      if(reviews.isEmpty()) {
        if (restaurantStatRepository.existsById(restaurantId)) {
          restaurantStatRepository.deleteById(restaurantId);
          log.info("RestaurantStat 삭제됨: {}", restaurantId);
        } else {
          log.info("RestaurantStat에 {}가 없음", restaurantId);
        }
        return;
      }

      long count = reviews.size();
      double average = reviews.stream()
        .mapToInt(Review::getRating)
        .average()
        .orElse(0.0);

      RestaurantStat restaurantStat = new RestaurantStat(restaurantId, count, average);
      restaurantStatRepository.save(restaurantStat);
      log.info("RestaurantStat 업데이트 완료: {} (count={}, average={}", restaurantId, count, average);
    } catch (Exception e) {
      log.error("RestaurantStat 업데이트 실패: {}", e.getMessage());
    }
  }
}
