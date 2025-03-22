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

        // ✅ 재료 등록 (이름 + 이미지)
        @Transactional
        public void addIngredients(IngredientRepository ingredientRepository) {
            Map<String, String> ingredients = Map.ofEntries(
                    Map.entry("마늘", "assets/images/garlic.png"),
                    Map.entry("고기", "assets/images/meat.png"),
                    Map.entry("버섯", "assets/images/mushroom.png"),
                    Map.entry("토마토", "assets/images/tomato.png"),
                    Map.entry("가지", "assets/images/eggplant.png"),
                    Map.entry("계란", "assets/images/egg.png"),
                    Map.entry("당근", "assets/images/carrot.png"),
                    Map.entry("피자", "assets/images/pizza.png"),
                    Map.entry("바나나", "assets/images/banana.png"),
                    Map.entry("파인애플", "assets/images/pineapple.png"),
                    Map.entry("딸기", "assets/images/strawberry.png"),
                    Map.entry("우유", "assets/images/milk.png"),
                    Map.entry("옥수수", "assets/images/corn.png"),
                    Map.entry("케이크", "assets/images/cake.png")
            );


            for (Map.Entry<String, String> entry : ingredients.entrySet()) {
                String name = entry.getKey();
                String imagePath = entry.getValue();

                if (!ingredientRepository.existsByName(name)) {
                    ingredientRepository.save(new Ingredient(name, imagePath));
                }
            }
        }

        // ✅ 컬렉션 등록 (이름 + 이미지 + 설명)
        @Transactional
        public void addCollections(CollectionRepository collectionRepository) {
            Map<String, String[]> collections = Map.ofEntries(
                    Map.entry("김치찌개", new String[]{"assets/images/kimchi_stew.png", "매콤하고 구수한 김치찌개입니다."}),
                    Map.entry("된장찌개", new String[]{"assets/images/doenjang_stew.png", "구수한 된장으로 끓인 전통 찌개입니다."}),
                    Map.entry("불고기", new String[]{"assets/images/bulgogi.png", "달콤한 양념의 한국식 불고기입니다."}),
                    Map.entry("과일 샐러드", new String[]{"assets/images/fruit_salad.png", "신선한 과일로 만든 건강 샐러드입니다."}),
                    Map.entry("오므라이스", new String[]{"assets/images/omelet_rice.png", "계란으로 감싼 볶음밥 요리입니다."}),
                    Map.entry("팟타이", new String[]{"assets/images/pad_thai.png", "달콤짭짤한 태국식 볶음면입니다."}),
                    Map.entry("떡볶이", new String[]{"assets/images/tteokbokki.png", "매콤한 고추장 소스 떡볶이입니다."}),
                    Map.entry("비빔밥", new String[]{"assets/images/bibimbap.png", "다양한 나물을 비벼먹는 전통 한식입니다."}),
                    Map.entry("해물파전", new String[]{"assets/images/seafood_pancake.png", "바삭한 해물과 파가 가득한 파전입니다."}),
                    Map.entry("스테이크", new String[]{"assets/images/steak.png", "육즙 가득한 두툼한 스테이크입니다."}),
                    Map.entry("볶음밥", new String[]{"assets/images/fried_rice.png", "재료를 볶아 만든 간편한 밥요리입니다."}),
                    Map.entry("오징어볶음", new String[]{"assets/images/squid_stirfry.png", "매콤한 양념의 오징어 볶음입니다."}),
                    Map.entry("카레라이스", new String[]{"assets/images/curry_rice.png", "향신료 가득한 카레와 밥입니다."}),
                    Map.entry("라자냐", new String[]{"assets/images/lasagna.png", "층층이 쌓인 파스타와 치즈의 조화입니다."}),
                    Map.entry("감바스", new String[]{"assets/images/gambas.png", "올리브오일에 마늘과 새우를 볶은 요리입니다."}),
                    Map.entry("크림스프", new String[]{"assets/images/cream_soup.png", "부드럽고 고소한 크림 스프입니다."}),
                    Map.entry("팬케이크", new String[]{"assets/images/pancake.png", "폭신한 식감의 아침용 팬케이크입니다."}),
                    Map.entry("과일주스", new String[]{"assets/images/fruit_juice.png", "싱싱한 과일로 만든 주스입니다."}),
                    Map.entry("스무디볼", new String[]{"assets/images/smoothie_bowl.png", "과일과 곡물이 어우러진 건강식입니다."})
            );

            for (Map.Entry<String, String[]> entry : collections.entrySet()) {
                String name = entry.getKey();
                String imagePath = entry.getValue()[0];
                String description = entry.getValue()[1];

                if (!collectionRepository.existsByName(name)) {
                    Collection collection = new Collection();
                    collection.setName(name);
                    collection.setImagePath(imagePath);
                    collection.setDescription(description);
                    collectionRepository.save(collection);
                }
            }
        }

        // ✅ 컬렉션-재료 매핑 등록
        @Transactional
        public void addCollectionIngredients(
                CollectionRepository collectionRepository,
                IngredientRepository ingredientRepository,
                CollectionIngredientRepository collectionIngredientRepository) {

            Map<String, Map<String, Integer>> collectionIngredients = Map.ofEntries(
                    Map.entry("김치찌개", Map.of("마늘", 1, "고기", 1, "버섯", 1, "토마토", 1)),
                    Map.entry("된장찌개", Map.of("마늘", 1, "버섯", 1, "가지", 1, "계란", 1)),
                    Map.entry("불고기", Map.of("고기", 2, "마늘", 1, "당근", 1)),
                    Map.entry("과일 샐러드", Map.of("바나나", 1, "파인애플", 1, "딸기", 1, "우유", 1)),
                    Map.entry("오므라이스", Map.of("계란", 2, "당근", 1, "우유", 1, "고기", 1)),
                    Map.entry("팟타이", Map.of("계란", 1, "고기", 1, "마늘", 1, "당근", 1)),
                    Map.entry("떡볶이", Map.of("마늘", 1, "고기", 1, "계란", 1, "토마토", 1)),
                    Map.entry("비빔밥", Map.of("당근", 1, "고기", 1, "가지", 1, "계란", 1)),
                    Map.entry("해물파전", Map.of("마늘", 1, "버섯", 1, "계란", 1, "우유", 1)),
                    Map.entry("스테이크", Map.of("고기", 2, "마늘", 1, "버섯", 1)),
                    Map.entry("볶음밥", Map.of("계란", 1, "고기", 1, "당근", 1, "옥수수", 1)),
                    Map.entry("오징어볶음", Map.of("마늘", 1, "고기", 1, "버섯", 1, "옥수수", 1)),
                    Map.entry("카레라이스", Map.of("고기", 1, "당근", 1, "토마토", 1, "우유", 1)),
                    Map.entry("라자냐", Map.of("피자", 1, "고기", 1, "토마토", 1, "버섯", 1)),
                    Map.entry("감바스", Map.of("고기", 1, "마늘", 1, "파인애플", 1, "토마토", 1)),
                    Map.entry("크림스프", Map.of("우유", 2, "버섯", 1, "마늘", 1)),
                    Map.entry("팬케이크", Map.of("계란", 1, "우유", 1, "케이크", 1, "딸기", 1)),
                    Map.entry("과일주스", Map.of("바나나", 1, "딸기", 1, "파인애플", 1, "우유", 1)),
                    Map.entry("스무디볼", Map.of("바나나", 1, "딸기", 1, "옥수수", 1, "우유", 1))
            );


            for (Map.Entry<String, Map<String, Integer>> entry : collectionIngredients.entrySet()) {
                String collectionName = entry.getKey();
                Map<String, Integer> ingredientsMap = entry.getValue();

                Optional<Collection> collectionOpt = collectionRepository.findByName(collectionName);
                if (collectionOpt.isEmpty()) continue;
                Collection collection = collectionOpt.get();

                for (Map.Entry<String, Integer> ingredientEntry : ingredientsMap.entrySet()) {
                    String ingredientName = ingredientEntry.getKey();
                    int quantity = ingredientEntry.getValue();

                    Optional<Ingredient> ingredientOpt = ingredientRepository.findByName(ingredientName);
                    if (ingredientOpt.isEmpty()) continue;
                    Ingredient ingredient = ingredientOpt.get();

                    boolean alreadyExists = collectionIngredientRepository.existsByCollectionAndIngredient(collection, ingredient);
                    if (!alreadyExists) {
                        CollectionIngredient collectionIngredient = new CollectionIngredient(collection, ingredient, quantity);
                        collectionIngredientRepository.save(collectionIngredient);
                    }
                }
            }
        }
    }
