package com.gachi_janchi.service;

import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.entity.RestaurantIngredient;
import com.gachi_janchi.repository.IngredientRepository;
import com.gachi_janchi.repository.RestaurantIngredientRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Service
@RequiredArgsConstructor
public class IngredientScheduler {
  private final RestaurantRepository restaurantRepository;
  private final RestaurantIngredientRepository restaurantIngredientRepository;
  private final IngredientRepository ingredientRepository;
  private final Random random = new Random();
  private final ExecutorService executorService = Executors.newFixedThreadPool(10); // 멀티스레드(10개) 처리

  // 서버가 실행될 때 한 번만 실행
  @PostConstruct
  public void initializeIngredients() {
    System.out.println("서버 시작 - 음식점 재료 초기화 실행!!!!");
    assignRandomIngredients();
  }

  // 매일 자정 실행
  @Scheduled(cron = "0 0 0 * * *")
  public void assignRandomIngredients() {
    List<Ingredient> allIngredients = ingredientRepository.findAll();
    if (allIngredients.isEmpty()) {
      System.out.println("재료 리스트가 비어있습니다.");
      return;
    }

    List<String> restaurantIds = restaurantRepository.findAll().stream()
            .map(Restaurant::getId)
            .toList();

    for (String restaurantId : restaurantIds) {
      executorService.submit(() -> processRestaurantIngredient(restaurantId, allIngredients));
    }
  }

  private void processRestaurantIngredient(String restaurantId, List<Ingredient> allIngredients) {
    Ingredient newRandomIngredient = allIngredients.get(random.nextInt(allIngredients.size()));

    restaurantIngredientRepository.findByRestaurantId(restaurantId).ifPresentOrElse(
            existingIngredient -> {
              if (!existingIngredient.getIngredient().getId().equals(newRandomIngredient.getId())) {
                existingIngredient.setIngredient(newRandomIngredient);
                restaurantIngredientRepository.save(existingIngredient);
                System.out.println("변경된 재료: " + restaurantId + "->" + newRandomIngredient.getName());
              }
            },
            () -> {
              RestaurantIngredient newAssignment = new RestaurantIngredient(
                      UUID.randomUUID().toString(),
                      restaurantId,
                      newRandomIngredient
              );
              restaurantIngredientRepository.save(newAssignment);
              System.out.println("새로 할당된 재료: " + restaurantId + "->" + newRandomIngredient.getName());
            }
    );
  }
}
