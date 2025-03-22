package com.gachi_janchi.service;

import com.gachi_janchi.dto.CollectionCompleteRequest;
import com.gachi_janchi.dto.CollectionIngredientDto;
import com.gachi_janchi.dto.CollectionResponse;
import com.gachi_janchi.dto.UserCollectionResponse;
import com.gachi_janchi.entity.*;
import com.gachi_janchi.entity.Collection;
import com.gachi_janchi.repository.*;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class CollectionService {

    @Autowired private CollectionRepository collectionRepository;
    @Autowired private UserCollectionRepository userCollectionRepository;
    @Autowired private UserIngredientRepository userIngredientRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private JwtProvider jwtProvider;

    // ✅ 모든 컬렉션 + 재료(이름, 수량, 이미지) 반환
    public List<CollectionResponse> getAllCollections(String token) {
        List<Collection> collections = collectionRepository.findAll();

        return collections.stream()
                .map(c -> {
                    List<CollectionIngredientDto> ingredients = c.getIngredients().stream()
                            .map(ci -> new CollectionIngredientDto(
                                    ci.getIngredient().getName(),
                                    ci.getQuantity(),
                                    ci.getIngredient().getImagePath()
                            ))
                            .collect(Collectors.toList());

                    return new CollectionResponse(
                            c.getName(),
                            c.getImagePath(),
                            c.getDescription(),
                            ingredients
                    );
                })
                .collect(Collectors.toList());
    }

    // ✅ 유저가 완성한 컬렉션 목록 조회
    public List<UserCollectionResponse> getUserCollections(String token) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));
        List<UserCollection> userCollections = userCollectionRepository.findByUserId(userId);

        return userCollections.stream()
                .map(uc -> new UserCollectionResponse(
                        uc.getCollection().getName(),
                        uc.getAcquiredAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                ))
                .collect(Collectors.toList());
    }

    // ✅ 컬렉션 완성 요청 처리
    public String completeCollection(String token, CollectionCompleteRequest request) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("유저를 찾을 수 없습니다."));

        Collection collection = collectionRepository.findByName(request.getCollectionName())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 컬렉션입니다."));

        // ✅ 유저가 이미 완성한 컬렉션인지 확인
        if (userCollectionRepository.existsByUserAndCollection(user, collection)) {
            throw new IllegalArgumentException("이미 완성한 컬렉션입니다.");
        }

        // ✅ 필요한 재료 충분한지 확인
        for (CollectionIngredient ci : collection.getIngredients()) {
            Optional<UserIngredient> userIngredientOpt = userIngredientRepository
                    .findByUserIdAndIngredientId(userId, ci.getIngredient().getId());

            if (userIngredientOpt.isEmpty() || userIngredientOpt.get().getQuantity() < ci.getQuantity()) {
                throw new IllegalArgumentException("❌ 재료 부족: " + ci.getIngredient().getName());
            }
        }

        // ✅ 재료 차감
        for (CollectionIngredient ci : collection.getIngredients()) {
            UserIngredient ui = userIngredientRepository
                    .findByUserIdAndIngredientId(userId, ci.getIngredient().getId())
                    .orElseThrow();

            ui.setQuantity(ui.getQuantity() - ci.getQuantity());
        }

        // ✅ 컬렉션 완성 저장
        UserCollection userCollection = new UserCollection(user, collection);
        userCollectionRepository.save(userCollection);

        return request.getCollectionName() + " 컬렉션을 완성했습니다!";
    }
}
