package com.gachi_janchi.service;

import com.gachi_janchi.dto.CollectionCompleteRequest;
import com.gachi_janchi.dto.UserCollectionResponse;
import com.gachi_janchi.entity.*;
import com.gachi_janchi.repository.*;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CollectionService {

    @Autowired
    private CollectionRepository collectionRepository;

    @Autowired
    private UserCollectionRepository userCollectionRepository;

    @Autowired
    private UserIngredientRepository userIngredientRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtProvider jwtProvider;

    @Transactional
    public String completeCollection(String token, CollectionCompleteRequest request) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("유저를 찾을 수 없습니다."));

        // ✅ 컬렉션 가져오기
        Collection collection = collectionRepository.findByName(request.getCollectionName())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 컬렉션입니다."));

        // ✅ 해당 컬렉션을 완성하기 위해 필요한 재료 목록 조회 (CollectionIngredient 활용)
        for (CollectionIngredient ci : collection.getIngredients()) {
            Optional<UserIngredient> userIngredientOpt = userIngredientRepository
                    .findByUserIdAndIngredientId(user.getId(), ci.getIngredient().getId());

            if (userIngredientOpt.isEmpty() || userIngredientOpt.get().getQuantity() < ci.getQuantity()) {
                throw new IllegalArgumentException("❌ 재료 부족: " + ci.getIngredient().getName());
            }
        }

        // ✅ 재료 차감
        for (CollectionIngredient ci : collection.getIngredients()) {
            UserIngredient userIngredient = userIngredientRepository
                    .findByUserIdAndIngredientId(user.getId(), ci.getIngredient().getId()).get();

            userIngredient.setQuantity(userIngredient.getQuantity() - ci.getQuantity());
            userIngredientRepository.save(userIngredient);
        }

        // ✅ 컬렉션 획득
        UserCollection userCollection = new UserCollection();
        userCollection.setUser(user);
        userCollection.setCollection(collection);
        userCollectionRepository.save(userCollection);

        return request.getCollectionName() + " 컬렉션이 완성되었습니다!";
    }


    /**
     * ✅ 유저가 획득한 컬렉션 목록 조회
     */
    @Transactional(readOnly = true)
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
}
