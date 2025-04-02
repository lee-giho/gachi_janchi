package com.gachi_janchi.config;

import com.gachi_janchi.entity.*;
import com.gachi_janchi.entity.Collection;
import com.gachi_janchi.repository.*;
import com.gachi_janchi.repository.CollectionRepository;
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
        List<String> ingredients = Arrays.asList(
                "garlic", "meat", "mushroom", "tomato", "eggplant", "egg",
                "carrot", "pizza", "banana", "pineapple", "strawberry",
                "milk", "corn", "cake"
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
                Map.entry("kimchiStew", "매콤하고 구수한 김치찌개입니다."),
                Map.entry("soybeanPasteStew", "구수한 된장으로 끓인 전통 찌개입니다."),
                Map.entry("bulgogi", "달콤한 양념의 한국식 불고기입니다."),
                Map.entry("fruitSalad", "신선한 과일로 만든 건강 샐러드입니다."),
                Map.entry("omurice", "계란으로 감싼 볶음밥 요리입니다."),
                Map.entry("padThai", "달콤짭짤한 태국식 볶음면입니다."),
                Map.entry("tteokbokki", "매콤한 고추장 소스 떡볶이입니다."),
                Map.entry("bibimbap", "다양한 나물을 비벼먹는 전통 한식입니다."),
                Map.entry("seafoodPancake", "바삭한 해물과 파가 가득한 파전입니다."),
                Map.entry("steak", "육즙 가득한 두툼한 스테이크입니다."),
                Map.entry("friedRice", "재료를 볶아 만든 간편한 밥요리입니다."),
                Map.entry("spicySquid", "매콤한 양념의 오징어 볶음입니다."),
                Map.entry("curryRice", "향신료 가득한 카레와 밥입니다."),
                Map.entry("lasagna", "층층이 쌓인 파스타와 치즈의 조화입니다."),
                Map.entry("gambas", "올리브오일에 마늘과 새우를 볶은 요리입니다."),
                Map.entry("creamSoup", "부드럽고 고소한 크림 스프입니다."),
                Map.entry("pancake", "폭신한 식감의 아침용 팬케이크입니다."),
                Map.entry("fruitJuice", "싱싱한 과일로 만든 주스입니다."),
                Map.entry("smoothieBowl", "과일과 곡물이 어우러진 건강식입니다.")
        );

        for (Map.Entry<String, String> entry : collections.entrySet()) {
            Collection collection = collectionRepository.findByName(entry.getKey()).orElse(null);
            if (collection == null) {
                Collection c = new Collection();
                c.setName(entry.getKey());
                c.setDescription(entry.getValue());
                collectionRepository.save(c);
            } else {
                collection.setDescription(entry.getValue());
                collectionRepository.save(collection);
            }
        }
    }

    @Transactional
    public void addCollectionIngredients(CollectionRepository collectionRepository,
                                         IngredientRepository ingredientRepository,
                                         CollectionIngredientRepository collectionIngredientRepository) {

        Map<String, Map<String, Integer>> collectionIngredients = Map.ofEntries(
                Map.entry("kimchiStew", Map.of("garlic", 1, "meat", 1, "mushroom", 1, "tomato", 1)),
                Map.entry("soybeanPasteStew", Map.of("garlic", 1, "mushroom", 1, "eggplant", 1, "egg", 1)),
                Map.entry("bulgogi", Map.of("meat", 2, "garlic", 1, "carrot", 1)),
                Map.entry("fruitSalad", Map.of("banana", 1, "pineapple", 1, "strawberry", 1, "milk", 1)),
                Map.entry("omurice", Map.of("egg", 2, "carrot", 1, "milk", 1, "meat", 1)),
                Map.entry("padThai", Map.of("egg", 1, "meat", 1, "garlic", 1, "carrot", 1)),
                Map.entry("tteokbokki", Map.of("garlic", 1, "meat", 1, "egg", 1, "tomato", 1)),
                Map.entry("bibimbap", Map.of("carrot", 1, "meat", 1, "eggplant", 1, "egg", 1)),
                Map.entry("seafoodPancake", Map.of("garlic", 1, "mushroom", 1, "egg", 1, "milk", 1)),
                Map.entry("steak", Map.of("meat", 2, "garlic", 1, "mushroom", 1)),
                Map.entry("friedRice", Map.of("egg", 1, "meat", 1, "carrot", 1, "corn", 1)),
                Map.entry("spicySquid", Map.of("garlic", 1, "meat", 1, "mushroom", 1, "corn", 1)),
                Map.entry("curryRice", Map.of("meat", 1, "carrot", 1, "tomato", 1, "milk", 1)),
                Map.entry("lasagna", Map.of("pizza", 1, "meat", 1, "tomato", 1, "mushroom", 1)),
                Map.entry("gambas", Map.of("meat", 1, "garlic", 1, "pineapple", 1, "tomato", 1)),
                Map.entry("creamSoup", Map.of("milk", 2, "mushroom", 1, "garlic", 1)),
                Map.entry("pancake", Map.of("egg", 1, "milk", 1, "cake", 1, "strawberry", 1)),
                Map.entry("fruitJuice", Map.of("banana", 1, "strawberry", 1, "pineapple", 1, "milk", 1)),
                Map.entry("smoothieBowl", Map.of("banana", 1, "strawberry", 1, "corn", 1, "milk", 1))
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
                new Title("기본 칭호", 0), new Title("요리 입문자", 10), new Title("재료 수집가", 20),
                new Title("맛있는 한 상", 30), new Title("컬렉션 장인", 40), new Title("한식 마스터", 50),
                new Title("샐러드 마스터", 25), new Title("단짠 요정", 25), new Title("식재료 마스터", 35),
                new Title("컬렉션 완전체", 60)
        );

        for (Title t : titles) {
            Title existing = titleRepository.findByName(t.getName()).orElse(null);
            if (existing == null) {
                titleRepository.save(t);
            } else {
                existing.setExp(t.getExp());
                titleRepository.save(existing);
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
                Map.entry("한식 마스터", Map.of("conditionType", "COLLECTION_NAMES", "conditionValue", "kimchiStew,soybeanPasteStew,bulgogi")),
                Map.entry("샐러드 마스터", Map.of("conditionType", "COLLECTION_NAME", "conditionValue", "fruitSalad")),
                Map.entry("단짠 요정", Map.of("conditionType", "COLLECTION_NAMES", "conditionValue", "steak,pancake")),
                Map.entry("식재료 마스터", Map.of("conditionType", "ALL_INGREDIENTS", "conditionValue", "1")),
                Map.entry("컬렉션 완전체", Map.of("conditionType", "ALL_COLLECTIONS", "conditionValue", "ALL"))
        );

        for (var entry : conditionMap.entrySet()) {
            Title title = titleRepository.findByName(entry.getKey()).orElse(null);
            if (title == null) continue;

            TitleCondition condition = conditionRepository.findByTitleId(title.getId()).orElse(null);
            if (condition == null) {
                condition = new TitleCondition();
                condition.setTitle(title);
            }
            condition.setConditionType(entry.getValue().get("conditionType"));
            condition.setConditionValue(entry.getValue().get("conditionValue"));
            conditionRepository.save(condition);
        }
    }
}
