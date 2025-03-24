package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.entity.UserIngredient;
import com.gachi_janchi.repository.IngredientRepository;
import com.gachi_janchi.repository.UserIngredientRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class UserIngredientService {

    @Autowired
    private UserIngredientRepository userIngredientRepository;

    @Autowired
    private IngredientRepository ingredientRepository; // ✅ static 제거

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtProvider jwtProvider;

    /**
     * ✅ 재료 추가 (획득)
     */
    public AddIngredientResponse addIngredient(String token, AddIngredientRequest request) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));

        // 유저 조회
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("유저를 찾을 수 없습니다."));

        // 재료 조회 (없으면 자동 추가)
        Ingredient ingredient = ingredientRepository.findByName(request.getIngredientName())
                .orElseGet(() -> {
                    Ingredient newIngredient = new Ingredient(request.getIngredientName());
                    return ingredientRepository.save(newIngredient); // ✅ 기본 이미지 제거됨
                });

        // 유저가 이미 보유한 재료인지 확인
        UserIngredient userIngredient = userIngredientRepository
                .findByUserIdAndIngredientId(user.getId(), ingredient.getId())
                .orElse(new UserIngredient(user, ingredient, 0)); // 기본 수량 0

        // 수량 증가 후 저장
        userIngredient.setQuantity(userIngredient.getQuantity() + 1);
        userIngredientRepository.save(userIngredient);

        return new AddIngredientResponse(request.getIngredientName() + " 재료가 추가되었습니다.");
    }


    /**
     * ✅ 전체 재료 목록 조회 (이름)
     */
    public List<IngredientResponse> getAllIngredients() {
        List<Ingredient> ingredients = ingredientRepository.findAll();
        return ingredients.stream()
                .map(i -> new IngredientResponse(i.getName()))
                .collect(Collectors.toList());
    }

    /**
     * ✅ 유저가 보유한 재료 리스트 조회 (이미지 포함)
     */
    public List<UserIngredientResponse> getUserIngredients(String token) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));

        return userIngredientRepository.findByUserId(userId).stream()
                .map(ui -> new UserIngredientResponse(
                        ui.getIngredient().getName(),
                        ui.getQuantity()))
                .collect(Collectors.toList());
    }
}
