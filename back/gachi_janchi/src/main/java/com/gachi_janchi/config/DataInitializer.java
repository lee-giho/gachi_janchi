package com.gachi_janchi.config;
import com.gachi_janchi.entity.Collection;

import com.gachi_janchi.entity.*;
import com.gachi_janchi.repository.*;
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
            CollectionIngredientRepository collectionIngredientRepository,
            TitleRepository titleRepository,
            TitleConditionRepository titleConditionRepository
    ) {
        return args -> {
            addIngredients(ingredientRepository);
            addCollections(collectionRepository);
            addCollectionIngredients(collectionRepository, ingredientRepository, collectionIngredientRepository);
            addTitles(titleRepository);
            addTitleConditions(titleRepository, titleConditionRepository);
        };
    }

    @Transactional
    public void addIngredients(IngredientRepository ingredientRepository) {
        // Map<String, String> ingredients = Map.ofEntries(
        //         Map.entry("마늘", "assets/images/garlic.png"),
        //         Map.entry("고기", "assets/images/meat.png"),
        //         Map.entry("버섯", "assets/images/mushroom.png"),
        //         Map.entry("토마토", "assets/images/tomato.png"),
        //         Map.entry("가지", "assets/images/eggplant.png"),
        //         Map.entry("계란", "assets/images/egg.png"),
        //         Map.entry("당근", "assets/images/carrot.png"),
        //         Map.entry("피자", "assets/images/pizza.png"),
        //         Map.entry("바나나", "assets/images/banana.png"),
        //         Map.entry("파인애플", "assets/images/pineapple.png"),
        //         Map.entry("딸기", "assets/images/strawberry.png"),
        //         Map.entry("우유", "assets/images/milk.png"),
        //         Map.entry("옥수수", "assets/images/corn.png"),
        //         Map.entry("케이크", "assets/images/cake.png")
        // );

        // for (Map.Entry<String, String> entry : ingredients.entrySet()) {
        //     if (!ingredientRepository.existsByName(entry.getKey())) {
        //         ingredientRepository.save(new Ingredient(entry.getKey()));
        //     }
        // }
        
        List<String> ingredients = new ArrayList<>(
          Arrays.asList(
            "garlic",
            "meat",
            "mushroom",
            "tomato",
            "eggplant",
            "egg",
            "carrot",
            "pizza",
            "banana",
            "pineapple",
            "strawberry",
            "milk",
            "corn",
            "cake"
          )
        );

        for (String ingredient : ingredients) {
          if (!ingredientRepository.existsByName(ingredient)) {
            ingredientRepository.save(new Ingredient(ingredient));
          }
        }
    }

    @Transactional
    public void addCollections(CollectionRepository collectionRepository) {
        Map<String, String> collections = Map.ofEntries(
                Map.entry("김치찌개", "매콤하고 구수한 김치찌개입니다."),
                Map.entry("된장찌개", "구수한 된장으로 끓인 전통 찌개입니다."),
                Map.entry("불고기", "달콤한 양념의 한국식 불고기입니다."),
                Map.entry("과일 샐러드", "신선한 과일로 만든 건강 샐러드입니다."),
                Map.entry("오므라이스", "계란으로 감싼 볶음밥 요리입니다."),
                Map.entry("팟타이", "달콤짭짤한 태국식 볶음면입니다."),
                Map.entry("떡볶이", "매콤한 고추장 소스 떡볶이입니다."),
                Map.entry("비빔밥", "다양한 나물을 비벼먹는 전통 한식입니다."),
                Map.entry("해물파전", "바삭한 해물과 파가 가득한 파전입니다."),
                Map.entry("스테이크", "육즙 가득한 두툼한 스테이크입니다."),
                Map.entry("볶음밥", "재료를 볶아 만든 간편한 밥요리입니다."),
                Map.entry("오징어볶음", "매콤한 양념의 오징어 볶음입니다."),
                Map.entry("카레라이스", "향신료 가득한 카레와 밥입니다."),
                Map.entry("라자냐", "층층이 쌓인 파스타와 치즈의 조화입니다."),
                Map.entry("감바스", "올리브오일에 마늘과 새우를 볶은 요리입니다."),
                Map.entry("크림스프", "부드럽고 고소한 크림 스프입니다."),
                Map.entry("팬케이크", "폭신한 식감의 아침용 팬케이크입니다."),
                Map.entry("과일주스", "싱싱한 과일로 만든 주스입니다."),
                Map.entry("스무디볼", "과일과 곡물이 어우러진 건강식입니다.")
        );

        for (Map.Entry<String, String> entry : collections.entrySet()) {
            if (!collectionRepository.existsByName(entry.getKey())) {
                Collection c = new Collection();
                c.setName(entry.getKey());
                c.setDescription(entry.getValue());
                collectionRepository.save(c);
            }
        }
    }

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

        for (var entry : collectionIngredients.entrySet()) {
            Collection collection = collectionRepository.findByName(entry.getKey()).orElse(null);
            if (collection == null) continue;

            for (var iEntry : entry.getValue().entrySet()) {
                Ingredient ingredient = ingredientRepository.findByName(iEntry.getKey()).orElse(null);
                if (ingredient == null) continue;

                if (!collectionIngredientRepository.existsByCollectionAndIngredient(collection, ingredient)) {
                    collectionIngredientRepository.save(
                            new CollectionIngredient(collection, ingredient, iEntry.getValue()));
                }
            }
        }
    }
    @Transactional
    public void addTitles(TitleRepository titleRepository) {
        List<Title> titles = List.of(
                new Title("기본 칭호", "회원가입 시 자동으로 부여되는 칭호"),
                new Title("요리 입문자", "처음으로 재료를 획득한 유저에게 주어지는 칭호"),
                new Title("재료 수집가", "재료를 20개 이상 모은 유저에게 주어지는 칭호"),
                new Title("맛있는 한 상", "컬렉션을 3개 완성한 유저에게 주어지는 칭호"),
                new Title("컬렉션 장인", "컬렉션을 10개 완성한 유저에게 주어지는 칭호"),
                new Title("한식 마스터", "김치찌개, 된장찌개, 불고기를 완성한 유저에게 주어지는 칭호"),
                new Title("샐러드 마스터", "과일 샐러드를 완성한 유저에게 주어지는 칭호"),
                new Title("단짠 요정", "스테이크와 팬케이크를 완성한 유저에게 주어지는 칭호"),
                new Title("식재료 마스터", "모든 재료를 1개 이상 보유한 유저에게 주어지는 칭호"),
                new Title("컬렉션 완전체", "모든 컬렉션을 완성한 유저에게 주어지는 칭호")
        );

        for (Title t : titles) {
            if (!titleRepository.existsByName(t.getName())) {
                titleRepository.save(t);
            }
        }
    }

    @Transactional
    public void addTitleConditions(TitleRepository titleRepository, TitleConditionRepository conditionRepository) {
        Map<String, Map<String, String>> conditionMap = Map.ofEntries(
                Map.entry("기본 칭호", Map.of("conditionType", "DEFAULT", "conditionValue", "")),
                Map.entry("요리 입문자", Map.of("conditionType", "INGREDIENT", "conditionValue", "1")),
                Map.entry("재료 수집가", Map.of("conditionType", "INGREDIENT", "conditionValue", "20")),
                Map.entry("맛있는 한 상", Map.of("conditionType", "COLLECTION", "conditionValue", "3")),
                Map.entry("컬렉션 장인", Map.of("conditionType", "COLLECTION", "conditionValue", "10")),
                Map.entry("한식 마스터", Map.of("conditionType", "COLLECTION_NAMES", "conditionValue", "김치찌개,된장찌개,불고기")),
                Map.entry("샐러드 마스터", Map.of("conditionType", "COLLECTION_NAME", "conditionValue", "과일 샐러드")),
                Map.entry("단짠 요정", Map.of("conditionType", "COLLECTION_NAMES", "conditionValue", "스테이크,팬케이크")),
                Map.entry("식재료 마스터", Map.of("conditionType", "ALL_INGREDIENTS", "conditionValue", "1")),
                Map.entry("컬렉션 완전체", Map.of("conditionType", "ALL_COLLECTIONS", "conditionValue", "ALL"))
        );

        for (var entry : conditionMap.entrySet()) {
            Title title = titleRepository.findByName(entry.getKey()).orElse(null);
            if (title == null) continue;

            if (!conditionRepository.existsByTitleId(title.getId())) {
                TitleCondition condition = new TitleCondition();
                condition.setTitle(title);
                condition.setConditionType(entry.getValue().get("conditionType"));
                condition.setConditionValue(entry.getValue().get("conditionValue"));
                conditionRepository.save(condition);
            }
        }
    }
}
