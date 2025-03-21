package com.gachi_janchi.config;

import com.gachi_janchi.entity.Collection;
import com.gachi_janchi.entity.CollectionIngredient;
import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.repository.CollectionIngredientRepository;
import com.gachi_janchi.repository.CollectionRepository;
import com.gachi_janchi.repository.IngredientRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initData(
            IngredientRepository ingredientRepository,
            CollectionRepository collectionRepository,
            CollectionIngredientRepository collectionIngredientRepository) {
        return args -> {
            addIngredients(ingredientRepository);
            addCollections(collectionRepository);
            addCollectionIngredients(collectionRepository, ingredientRepository, collectionIngredientRepository);
        };
    }

    // ✅ 기본 재료 추가
    @Transactional
    public void addIngredients(IngredientRepository ingredientRepository) {
        List<String> ingredientsList = Arrays.asList(
                "마늘", "고기", "버섯", "토마토", "가지", "계란", "당근", "피자",
                "바나나", "파인애플", "딸기", "우유", "옥수수", "케이크"
        );

        for (String name : ingredientsList) {
            if (!ingredientRepository.existsByName(name)) {
                ingredientRepository.save(new Ingredient(name));
            }
        }
    }

    // ✅ 컬렉션 추가
    @Transactional
    public void addCollections(CollectionRepository collectionRepository) {
        List<String> collectionsList = Arrays.asList(
                "김치찌개", "된장찌개", "불고기", "피자", "과일 샐러드",
                "오므라이스", "팟타이", "떡볶이", "비빔밥", "해물파전",
                "스테이크", "볶음밥", "오징어볶음", "카레라이스", "라자냐",
                "감바스", "크림스프", "팬케이크", "과일주스", "스무디볼"
        );

        for (String name : collectionsList) {
            if (!collectionRepository.existsByName(name)) {
                collectionRepository.save(new Collection(name));
            }
        }
    }

    // ✅ 컬렉션과 재료 매핑
    @Transactional
    public void addCollectionIngredients(
            CollectionRepository collectionRepository,
            IngredientRepository ingredientRepository,
            CollectionIngredientRepository collectionIngredientRepository) {

        // ✅ 컬렉션별 필요한 재료 및 개수 설정 (Map 사용)
        Map<String, Map<String, Integer>> collectionIngredients = new HashMap<>();

        collectionIngredients.put("김치찌개", Map.of("마늘", 1, "고기", 1, "버섯", 1, "토마토", 1));
        collectionIngredients.put("된장찌개", Map.of("마늘", 1, "버섯", 1, "가지", 1, "계란", 1));
        collectionIngredients.put("불고기", Map.of("고기", 2, "마늘", 1, "당근", 1));
        collectionIngredients.put("피자", Map.of("피자", 1, "토마토", 1, "버섯", 1, "고기", 1));
        collectionIngredients.put("과일 샐러드", Map.of("바나나", 1, "파인애플", 1, "딸기", 1, "우유", 1));
        collectionIngredients.put("오므라이스", Map.of("계란", 2, "당근", 1, "우유", 1, "고기", 1));
        collectionIngredients.put("팟타이", Map.of("계란", 1, "고기", 1, "마늘", 1, "당근", 1));
        collectionIngredients.put("떡볶이", Map.of("마늘", 1, "고기", 1, "계란", 1, "토마토", 1));
        collectionIngredients.put("비빔밥", Map.of("당근", 1, "고기", 1, "가지", 1, "계란", 1));
        collectionIngredients.put("해물파전", Map.of("마늘", 1, "버섯", 1, "계란", 1, "우유", 1));
        collectionIngredients.put("스테이크", Map.of("고기", 2, "마늘", 1, "버섯", 1));
        collectionIngredients.put("볶음밥", Map.of("계란", 1, "고기", 1, "당근", 1, "옥수수", 1));
        collectionIngredients.put("오징어볶음", Map.of("마늘", 1, "고기", 1, "버섯", 1, "옥수수", 1));
        collectionIngredients.put("카레라이스", Map.of("고기", 1, "당근", 1, "토마토", 1, "우유", 1));
        collectionIngredients.put("라자냐", Map.of("피자", 1, "고기", 1, "토마토", 1, "버섯", 1));
        collectionIngredients.put("감바스", Map.of("고기", 1, "마늘", 1, "파인애플", 1, "토마토", 1));
        collectionIngredients.put("크림스프", Map.of("우유", 2, "버섯", 1, "마늘", 1));
        collectionIngredients.put("팬케이크", Map.of("계란", 1, "우유", 1, "케이크", 1, "딸기", 1));
        collectionIngredients.put("과일주스", Map.of("바나나", 1, "딸기", 1, "파인애플", 1, "우유", 1));
        collectionIngredients.put("스무디볼", Map.of("바나나", 1, "딸기", 1, "옥수수", 1, "우유", 1));

        for (Map.Entry<String, Map<String, Integer>> entry : collectionIngredients.entrySet()) {
            String collectionName = entry.getKey();
            Map<String, Integer> ingredientsWithQuantities = entry.getValue();

            Optional<Collection> collectionOpt = collectionRepository.findByName(collectionName);
            if (collectionOpt.isPresent()) {
                Collection collection = collectionOpt.get();

                for (Map.Entry<String, Integer> ingredientEntry : ingredientsWithQuantities.entrySet()) {
                    String ingredientName = ingredientEntry.getKey();
                    int quantity = ingredientEntry.getValue();

                    Optional<Ingredient> ingredientOpt = ingredientRepository.findByName(ingredientName);
                    if (ingredientOpt.isPresent()) {
                        Ingredient ingredient = ingredientOpt.get();

                        // 기존에 이미 등록된 관계인지 확인
                        if (!collectionIngredientRepository.existsByCollectionAndIngredient(collection, ingredient)) {
                            CollectionIngredient collectionIngredient = new CollectionIngredient(collection, ingredient, quantity);
                            collectionIngredientRepository.save(collectionIngredient);
                        }
                    }
                }
            }
        }
    }
}
